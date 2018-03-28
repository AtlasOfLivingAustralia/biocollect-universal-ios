//  Oz Atlas
#import <Foundation/Foundation.h>
#import "TracksUpload.h"
#import "GASettingsConstant.h"
#import "GAAppDelegate.h"
#import "GASettings.h"
#import "MetadataForm.h"

@interface TracksUpload ()
@property (strong, nonatomic) GAAppDelegate *appDelegate;
@end

@implementation TracksUpload
#define JSON_CONTENT_TYPE_VALUE @"application/json;charset=UTF-8"
#define JSON_CONTENT_TYPE_KEY @"Content-Type"
#define kSiteUploadException @"SiteUploadException"
#define kImageUploadException @"ImageUploadException"
#define kActivityUploadException @"ActivityUploadException"
#define kProjectNotSelected @"ProjectNotSelected"

-(id) init {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}

// Caller should handle ProjectNotSelected exception
- (void) uploadTracks: (NSMutableArray<MetadataForm*>*) uploadItems andUpdateError: (NSError **) error {
    Project *project = [self.appDelegate.projectService loadSelectedProject];
    if(project == nil) {
        @throw [NSException exceptionWithName:kProjectNotSelected
                                       reason:@"Error, please go to settings and select ranger group."
                                     userInfo:nil];
    }
    
    NSMutableArray* uploadedTracks = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [uploadItems count]; i++) {
        MetadataForm* form = [uploadItems objectAtIndex:i];
        NSMutableDictionary *item = [form transformDataToUploadableFormat];
        NSLog(@"%@", item);
        @try {
            // Upload site and images.
            NSString *siteId = nil;
            NSMutableDictionary *countryMetadata = nil;
            [self uploadSite : item[@"site"] siteId: siteId];
            [self uploadImage : item[@"countryImage"] imageMetadata:countryMetadata];
            
            // Upload species images.
            NSMutableArray *images = item[@"speciesImages"];
            NSMutableArray *speciesImages = [[NSMutableArray alloc] init];
            for(int j = 0; j < [images count]; j++) {
                NSObject *image = [images objectAtIndex:j];
                if([image isKindOfClass: [UIImage class]]) {
                    NSMutableDictionary *metadata = nil;
                    [self uploadImage : (UIImage *)image imageMetadata:metadata];
                    [speciesImages addObject:metadata];
                } else {
                    [speciesImages addObject:@""];
                }
            }
            
            // Upload activity.
            // TODO : Update item[@"activity"] with siteId, locationId & image metadata
            [self uploadActivity:item[@"activity"] pActivityId: project.projectActivityId];
            
            // Flag the object as uploaded.
            item[@"uploadedStatus"] = @"1";
            [uploadedTracks addObject:item];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOADED-TRACK" object:item];
        }
        @catch (NSException *exception) {
            if([exception.name isEqualToString:kSiteUploadException]) {
                NSLog(@"%@", exception.reason);
            } else if([exception.name isEqualToString:kImageUploadException]) {
                NSLog(@"%@", exception.reason);
            } else if([exception.name isEqualToString:kActivityUploadException]) {
               NSLog(@"%@", exception.reason);
            }
            item[@"uploadedStatus"] = @"0";
        }
        @finally {
            // TODO: Handle exception...
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-UPLOADING-COMPLETE" object:uploadedTracks];
    // [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIES_SEARCH_SELECTED" object: self.selectedSpecies];
    // TODO - Remove items from the local array that are successfully submitted to the server.
}

- (void) uploadActivity: (NSDictionary *) activity pActivityId: (NSString *) pActivityId {
    NSString *activityJson = [self dictionaryToString: activity];
    NSString *url = [NSString stringWithFormat:@"%@%@%@", BIOCOLLECT_SERVER, CREATE_RECORD, pActivityId];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[activityJson length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:JSON_CONTENT_TYPE_VALUE forHTTPHeaderField:JSON_CONTENT_TYPE_KEY];
    [request setValue:[GASettings getEmailAddress] forHTTPHeaderField: @"userName"];
    [request setValue:[GASettings getAuthKey] forHTTPHeaderField: @"authKey"];
    [request setHTTPBody:[self dictionaryToData: activity]];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSDictionary *respDict = nil;
    NSString *activityId = nil;
    if(error == nil) {
        respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:&error];
        activityId = error == nil && respDict != nil ? respDict[@"id"] : nil;
    }
    
    if(error == nil || respDict == nil || activityId == nil){
        @throw [NSException exceptionWithName:kActivityUploadException
                                       reason:@"Error, submitting tracks, please try again later."
                                     userInfo:nil];
    }
}
             
- (void) uploadImage: (UIImage *) image imageMetadata: (NSMutableDictionary *) dict {
    NSMutableDictionary *result = [self.appDelegate.restCall uploadImage:image];
    if((result == nil) || [[NSNumber numberWithInt:200] isEqual: result[@"statusCode"]]){
        dict = result[@"resp"];
    }
    
    if(dict == nil) {
        @throw [NSException exceptionWithName:kImageUploadException
                                       reason:@"Error, uploading species image, please try again later."
                                     userInfo:nil];
    }
}

- (void) uploadSite: (NSDictionary *) site siteId: (NSString *) siteId {
    NSString *siteJson = [self dictionaryToString: site];
    NSString *url = [NSString stringWithFormat:@"%@%@", BIOCOLLECT_SERVER, CREATE_SITE];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[siteJson length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:JSON_CONTENT_TYPE_VALUE forHTTPHeaderField:JSON_CONTENT_TYPE_KEY];
    [request setValue:[GASettings getEmailAddress] forHTTPHeaderField: @"userName"];
    [request setValue:[GASettings getAuthKey] forHTTPHeaderField: @"authKey"];
    [request setHTTPBody:[self dictionaryToData: site]];
    [request setHTTPMethod:@"POST"];
    NSError *error;
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error == nil) {
        NSDictionary *respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:&error];
        //{"status":"created","id":"2628a2a2-2f27-4863-bcb3-f491ed9989aa"}
        siteId = error == nil && respDict != nil ? respDict[@"id"] : nil;
    } else {
        @throw [NSException exceptionWithName:kSiteUploadException
                                       reason:@"Error, uploading tracks coordinates."
                                        userInfo:nil];
    }
}
- (NSString *) dictionaryToString : (NSDictionary *) dictionary {
    NSDictionary *data = dictionary;
    NSError *e;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&e];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSData *) dictionaryToData : (NSDictionary *) dictionary {
    NSDictionary *data = dictionary;
    NSError *e;
    return [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&e];
}

- (NSDictionary *)JSONFromFile: (NSString *) file {
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

- (void) populateTestData: (NSMutableArray *) uploadItems {
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    item[@"ready"] = @"1";
    item[@"uploadedStatus"] = @"0";
    item[@"activity"] = [self JSONFromFile : @"TracksActivityTemplate"];

    // Populate site data - projectId and projectActivityId
    Project *project = [self.appDelegate.projectService loadSelectedProject];
    NSDictionary *dict = [self JSONFromFile : @"TracksSiteTemplate"];
    [dict setValue:project.projectActivityId forKey:@"pActivityId"];
    NSMutableArray *projects = [[NSMutableArray alloc] init];
    [projects addObject:project.projectId];
    [dict[@"site"] setValue:projects forKey:@"projects"];
    item[@"site"] = dict;
    
    item[@"countryImage"] = [UIImage imageNamed:@"noImage85.jpg"];
    item[@"speciesImages"] = [[NSMutableArray alloc] init];
    [item[@"speciesImages"] addObject: [UIImage imageNamed:@"noImage85.jpg"]];
    [item[@"speciesImages"] addObject: @""]; // Empty entry for species without any image.
    [item[@"speciesImages"] addObject: [UIImage imageNamed:@"noImage85.jpg"]];
    [uploadItems addObject:item];
}

@end
