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
#define kAuthorizationError @"kAuthorizationError"

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
    int uploadError = 0;
    for(int i = 0; i < [uploadItems count]; i++) {
        MetadataForm* form = [uploadItems objectAtIndex:i];
        NSMutableDictionary *item = [form transformDataToUploadableFormat];
        item[@"uploadedStatus"] = @"0";
        
        @try {
            // Upload site and images.
            NSString *siteId = [self uploadSite:item[@"site"]];
            NSMutableDictionary *countryMetadata = item[@"countryImage"] != nil ? [self uploadImage : item[@"countryImage"]] : [[NSMutableDictionary alloc] init];
            // Upload species images.
            NSMutableArray *images = item[@"speciesImages"];
            NSMutableArray *speciesImages = [[NSMutableArray alloc] init];
            for(int j = 0; j < [images count]; j++) {
                NSObject *image = [images objectAtIndex:j];
                if([image isKindOfClass: [UIImage class]]) {
                    NSMutableDictionary *metadata = [self uploadImage : (UIImage *)image];
                    [speciesImages addObject:metadata];
                } else {
                    [speciesImages addObject:@""];
                }
            }
            
            // Update siteId.
            NSDictionary *tempOutput = [item[@"activity"][@"outputs"] objectAtIndex:0];
            NSDictionary *data = tempOutput[@"data"];
            if(siteId != nil) {
                item[@"activity"][@"siteId"] = siteId;
                [data objectForKey:@"location"] ? [data setValue:siteId forKey:@"location"] : nil;
            }
            
            // Update countryImage
            if(countryMetadata[@"files"] != nil) {
                tempOutput[@"data"][@"locationImage"] = countryMetadata[@"files"];
            } else {
                tempOutput[@"data"][@"locationImage"] = [[NSMutableArray alloc] init];
            }
            
            // Update species images.
            if([speciesImages count] == [tempOutput[@"data"][@"sightingEvidenceTable"] count] ) {
                for (int index = 0 ; index < [tempOutput[@"data"][@"sightingEvidenceTable"] count]; index++){
                    NSObject *image = speciesImages[index];
                    if([image isKindOfClass: [NSDictionary class]]) {
                        NSMutableDictionary *row = [tempOutput[@"data"][@"sightingEvidenceTable"] objectAtIndex:index];
                        NSDictionary *files = speciesImages[index];
                        NSMutableArray *imageOfSign = files[@"files"] ? files[@"files"] : [[NSMutableArray alloc] init];
                        row[@"imageOfSign"] = imageOfSign;
                    }
                }
            }
            [self uploadActivity:item[@"activity"] pActivityId: project.projectActivityId];
            item[@"uploadedStatus"] = @"1";
            [uploadedTracks addObject:form];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPLOADED-TRACK" object:form];
        }
        @catch (NSException *exception) {
            item[@"uploadedStatus"] = @"0";
            uploadError = 1;
            if([exception.name isEqualToString:kAuthorizationError]) {
                NSLog(@"%@", exception.reason);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ERROR-NOT-AUTHORIZED" object:form];
                break;
            } else if([exception.name isEqualToString:kSiteUploadException]) {
                NSLog(@"%@", exception.reason);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ERROR-SITE-UPLOAD" object:form];
            } else if([exception.name isEqualToString:kImageUploadException]) {
                NSLog(@"%@", exception.reason);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ERROR-IMAGE-UPLOAD" object:form];
            } else if([exception.name isEqualToString:kActivityUploadException]) {
               NSLog(@"%@", exception.reason);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ERROR-ACTIVITY-UPLOAD" object:form];
            }
        }
        @finally {
        }
    }
    if(uploadError) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-UPLOADING-COMPLETE" object:uploadedTracks];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"ERROR-TRACK-UPLOADING" object:uploadedTracks];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-UPLOADING-COMPLETE" object:uploadedTracks];
    }
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
    
    if(error == nil) {
        respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:&error];
        if(respDict != nil && [[NSNumber numberWithInt:401] isEqual: respDict[@"statusCode"]]){
            @throw [NSException exceptionWithName:kAuthorizationError
                                           reason:@"Access denied"
                                         userInfo:nil];
        }
    }
    
    if(error != nil  || (respDict != nil && ![[NSNumber numberWithInt:200] isEqual: respDict[@"statusCode"]])){
        @throw [NSException exceptionWithName:kActivityUploadException
                                       reason:@"Error, submitting tracks, please try again later."
                                     userInfo:nil];
    }
}
             
- (NSMutableDictionary *) uploadImage: (UIImage *) image{
    NSMutableDictionary *dict = nil;
    NSMutableDictionary *result = [self.appDelegate.restCall uploadImage:image];
    
    if((result == nil) || [[NSNumber numberWithInt:200] isEqual: result[@"statusCode"]]){
        dict = result[@"resp"];
    }
    
    if(dict == nil) {
        @throw [NSException exceptionWithName:kImageUploadException
                                       reason:@"Error, uploading species image, please try again later."
                                     userInfo:nil];
    }
    return dict;
}

- (NSString *) uploadSite: (NSDictionary *) site {
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
    NSString *siteId = nil;
    if(error == nil) {
        NSDictionary *respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:&error];
        //{"status":"created","id":"2628a2a2-2f27-4863-bcb3-f491ed9989aa"}
        siteId = (error == nil && respDict != nil) ? respDict[@"id"] : nil;
    } else {
        @throw [NSException exceptionWithName:kSiteUploadException
                                       reason:@"Error, uploading tracks coordinates."
                                        userInfo:nil];
    }
    
    return siteId;
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
