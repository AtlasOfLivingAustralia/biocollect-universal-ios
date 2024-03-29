//
//  GARestCall.m
//  GreenArmy
//
//  Created by Sathish iMac on 12/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "GARestCall.h"
#import "GAProject.h"
#import "GAActivity.h"
#import "GASettingsConstant.h"
#import "GAProjectJSON.h"
#import "GAActivitiesJSON.h"
#import "GAAppDelegate.h"
#import "GASettings.h"
#import "GASiteJSON.h"
#import "GASettingsConstant.h"
#import "RecordForm.h"
#import "SpeciesSearchTableViewController.h"
#import "Reachability.h"

@interface GARestCall()
@property (nonatomic, retain) GAAppDelegate *appDelegate;
@property (nonatomic, retain) NSMutableArray *projects;
@property (nonatomic, retain) NSString *urlId;
@property (nonatomic, assign) int restRequestCounter;
@property (nonatomic, assign) int restResponseCounter;
@end

@implementation GARestCall
#define JSON_CONTENT_TYPE_VALUE @"application/json;charset=UTF-8"
#define JSON_CONTENT_TYPE_KEY @"Content-Type"
#define UNMATCHED_TAXON @"unmatched taxon"
#define NORANK_TAXON @"no rank"

@synthesize projects,  urlId, restRequestCounter, restResponseCounter, appDelegate;

-(id) init {
    self.projects = [[NSMutableArray alloc]init];
    self.urlId = @"1493";
    self.restRequestCounter = 0;
    self.restResponseCounter = 0;
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}

#pragma mark - Request to retreive projects

-(void) updateActivity : (GAActivity*) activity :(NSError**) e{
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[activity.activityJSON length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/mobile/updateActivity/%@",REST_SERVER,activity.activityId];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:JSON_CONTENT_TYPE_VALUE forHTTPHeaderField:JSON_CONTENT_TYPE_KEY];
    [request setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:[activity.activityJSON dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*e];
    
    if(*e == nil) {
        NSDictionary* respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply
                                                                  options:kNilOptions error:&*e];
        if ([[respDict objectForKey:@"message"] isEqualToString:@"updated"]) {
            DebugLog(@"[SUCCESS] ReST:updateActivity - Successfullly updated %@",activity.activityName);
        }
        else {
            DebugLog(@"[ERROR] ReST:updateActivity - Error updating %@",activity.activityName);
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"Error updating the activity" forKey:NSLocalizedDescriptionKey];
            *e = [NSError errorWithDomain:REST_SERVER code:1002 userInfo:details];
        }
    }
    else
        DebugLog(@"[ERROR] ReST:updateActivity - Connection error %@",[*e localizedDescription]);
 
}

-(NSString*) getAuthorizationHeader {
    OIDAuthState *authState = [GASettings getAuthState];
    __block NSString *accessToken = authState.lastTokenResponse.accessToken;
    
    NSDate* dateNow = [NSDate date];
    NSDate* dateExpiry = [[authState lastTokenResponse] accessTokenExpirationDate];
    
    NSLog(@"Token Expiry %@", dateExpiry);
    
    // Check whether the expiry date is in the future
    if ([dateNow compare:dateExpiry] != NSOrderedAscending) {
        __block bool gotToken = NO;
        
        // Token update check
        [authState performActionWithFreshTokens:^(NSString * _Nullable newAccessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
            if (error) {
                NSLog(@"Token refresh error %@", [error localizedDescription]);
            } else {
                // Update the authentication state
                [GASettings setAuthState:authState];
                
                NSLog(@"Token Refreshed! %@", newAccessToken);
                accessToken = newAccessToken;
            }
            
            gotToken = YES;
        }];
        
        // Wait for the token response
        while (!gotToken) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    }
    
    return  [[NSString alloc] initWithFormat:@"Bearer %@", accessToken];
}

-(NSMutableArray *) downloadProjects : (NSError **) error{
    
    //Request projects.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //Green ARMY filter
    NSString *url = [[NSString alloc] initWithFormat: @"%@/mobile/userProjects?program=Green Army",REST_SERVER];
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    DebugLog(@"ReSt projects url %@",escapedUrlString);
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];

    DebugLog(@"[INFO] ReST:requestProjects - Initiating ReST call.");
    if(*error == nil) {
        GAProjectJSON  *projectJSON = [[GAProjectJSON alloc] initWithData:GETReply];
        self.projects = [[NSMutableArray alloc] init];
        //Iterate projects
        while([projectJSON hasNext]) {
            [projectJSON nextProject];
            GAProject *project = [[GAProject alloc] init];
            project.projectName = projectJSON.projectName;
            project.lastUpdated = projectJSON.lastUpdatedDate;
            project.description = projectJSON.description;
            project._id = -1;
            project.projectId = projectJSON.projectId;

            //Request activities for a project
            NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] init];
            NSString *url1 = [[NSString alloc]initWithFormat:@"%@/mobile/projectDetails/%@",REST_SERVER,project.projectId];
            [request1 setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
            [request1 setURL:[NSURL URLWithString:url1]];
            [request1 setHTTPMethod:@"GET"];
            NSURLResponse *response1;
            NSData *GETReply1 = [NSURLConnection sendSynchronousRequest:request1 returningResponse:&response1 error:&*error];
            
            if(*error == nil) {
                //Iterate activities
                GAActivitiesJSON  *activitiesJSON = [[GAActivitiesJSON alloc] initWithData:GETReply1];

                //Site information.
                GASiteJSON *sitesJSON = [[GASiteJSON alloc] initWithData:GETReply1];
                NSMutableArray *sites = [[NSMutableArray alloc] init];
                while([sitesJSON hasNext]) {
                    [sitesJSON nextSite];
                    GASite *site = [[GASite alloc] init];
                    site.siteId = sitesJSON.siteId;
                    site.permSiteId = sitesJSON.siteId;
                    site.name = sitesJSON.name;
                    site.description = sitesJSON.description;
                    site.latitude = sitesJSON.latitude;
                    site.longitude = sitesJSON.longitude;
                    site.projectId = project.projectId;
                    [sites addObject:site];
                }
                project.sites = sites;
                
                DebugLog(@"[SUCCESS] ReST:requestProjects - Total activities = %d",[activitiesJSON getActivityCount]);
                NSMutableArray *activities = [[NSMutableArray alloc] init];
                while([activitiesJSON hasNext]) {
                    [activitiesJSON nextActivity];
                    GAActivity *activity = [[GAActivity alloc] init];
                    activity.activityName = activitiesJSON.activityType;
                    activity.description = ([activitiesJSON.description length])?(activitiesJSON.description):@"";
                    activity.url = [[NSString alloc] initWithFormat:@"%@/activity/enterData/%@?mobile=mobile",REST_SERVER,activitiesJSON.activityId];
                    activity._id = -1;
                    activity.activityId = activitiesJSON.activityId;
                    activity.progress = activitiesJSON.progress;
                    activity.outputJSON = @"";// Not used.
                    activity.activityJSON  = activitiesJSON.activityJSON;
                    activity.status = 0;
                    activity.plannedStartDate = activitiesJSON.plannedStartDate;
                    activity.plannedStartDate = ([activity.plannedStartDate length])?(activity.plannedStartDate):@"-";
                    activity.siteId = activitiesJSON.siteId;
                    activity.site = [self getSiteBySiteId:sites : activity.siteId];
                    activity.themes = [[NSArray alloc] initWithArray:activitiesJSON.themes];
                    [activities addObject:activity];
                }
                project.activities = activities;
            }else{
                DebugLog(@"[ERROR] ReST:requestProjects - Error retreiving the activity, %@", [*error localizedDescription]);
            }
            [self.projects addObject:project];
        }
        DebugLog(@"[SUCCESS] ReST:requestProjects - Total projects = %lu",(unsigned long)[self.projects count]);
    }else{
        DebugLog(@"[ERROR] ReST:requestProjects - Error retreiving the projects, %@", [*error localizedDescription]);
    }
    return [self.projects mutableCopy];
}

-(GASite *) getSiteBySiteId : (NSMutableArray *) sites : (NSString *) siteId{
    for (GASite *site in sites){
        if([site.siteId isEqualToString:siteId]){
            return site;
        }
    }
    return nil;
}

/**
 * Search BIE to autocomplete a species.
 */
-(NSMutableArray *) autoCompleteSpecies : (NSString *) searchText numberOfItemsPerPage: (int) pageSize fromSerialNumber: (int) offset addSearchText:(BOOL)addUnmatchedTaxon viewController: (SpeciesSearchTableViewController *) vc{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat:@"%@%@&pageSize=%d&start=%d", AUTOCOMPLETE_URL, [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], pageSize, offset];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *e) {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        int total = 0;
        if((e == nil) && (data != nil)){
            NSDictionary* respDict =  [NSJSONSerialization JSONObjectWithData:data
                                                                      options:kNilOptions error:&e];
            NSArray *reducedResults = [self minimizeSizeOfSpeciesSearchResult:respDict[@"searchResults"][@"results"]];
            total = [respDict[@"searchResults"][@"totalRecords"] intValue];
            [results addObjectsFromArray: reducedResults];
        }
        
        if(vc != nil){
            [vc updateDisplayItems:results totalRecords: total];
        }
    }];
    
    NSMutableArray *initialResult = [[NSMutableArray alloc] init];
    // only return unmatched taxon when the first page is loaded.
    if(offset == 0){
        // do not include if string is empty
        if(addUnmatchedTaxon && ![searchText isEqualToString:@""]){
            NSDictionary *unmatchedTaxon = @{
                                             @"displayName": searchText,
                                             @"name": searchText,
                                             @"guid": [NSNull null],
                                             @"commonName": [NSNull null],
                                             @"rank": UNMATCHED_TAXON
                                             };
            [initialResult addObject: unmatchedTaxon];
        }
    }

    return initialResult;
}

- (NSArray *) minimizeSizeOfSpeciesSearchResult: (NSArray *) results {
    NSEnumerator *e = [results objectEnumerator];
    NSMutableArray *reduced = [[NSMutableArray alloc] init];
    NSDictionary *species;
    NSString *displayName, *rank, *commonName;
    
    while (species = [e nextObject]) {
        commonName = species[@"commonName"]?:@"";
        if(![commonName isEqual:@""]){
            displayName = [NSString stringWithFormat:@"%@ (%@)", species[@"name"], commonName];
        } else {
            displayName = species[@"name"];
        }

        if(!species[@"guid"]){
            rank = UNMATCHED_TAXON;
        } else if(!species[@"rank"]){
            rank = NORANK_TAXON;
        } else {
            rank = species[@"rank"];
        }

        
        [reduced addObject:@{
                             @"displayName": displayName?:[NSNull null],
                             @"rank": rank?:[NSNull null],
                             @"name": species[@"name"]?:[NSNull null],
                             @"guid": species[@"guid"]?:[NSNull null],
                             @"commonName": species[@"commonName"]?:[NSNull null],
                             @"thumbnailUrl": species[@"thumbnailUrl"]?:[NSNull null]
                             }];
    }
    
    return [[NSArray alloc] initWithArray: [reduced copy]];
}

-(NSString *) uploadSite : (GASite*) site :(NSError**) e{
    
    NSMutableDictionary *postBodyJSON = [[NSMutableDictionary alloc] init];
    [postBodyJSON setObject:site.projectId forKey:@"projectId"];
    [postBodyJSON setObject:site.name forKey:@"name"];
    [postBodyJSON setObject:site.description forKey:@"description"];
    [postBodyJSON setObject:site.latitude forKey:@"centroidLat"];
    [postBodyJSON setObject:site.longitude forKey:@"centroidLon"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postBodyJSON options:NSJSONWritingPrettyPrinted error:&*e];

    if(*e == nil){
        
        NSString *postStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postStr length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString *url = [[NSString alloc] initWithFormat:@"%@/mobile/createSite",REST_SERVER];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:JSON_CONTENT_TYPE_VALUE forHTTPHeaderField:JSON_CONTENT_TYPE_KEY];
        [request setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
        [request setHTTPBody:[postStr dataUsingEncoding:NSUTF8StringEncoding]];
       
        NSURLResponse *response;
        NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*e];
        
        if(*e == nil) {
            NSDictionary* respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply
                                                                      options:kNilOptions error:&*e];
            if ([[respDict objectForKey:@"message"] isEqualToString:@"created"]) {
                DebugLog(@"[SUCCESS] ReST:uploadSite - Successfullly updated - Site name:%@",site.name);
                return [respDict objectForKey:@"siteId"];
            }
            else {
                DebugLog(@"[ERROR] ReST:uploadSite - Error updating %@",site.name);
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Error uploading new site" forKey:NSLocalizedDescriptionKey];
                *e = [NSError errorWithDomain:REST_SERVER code:1002 userInfo:details];
            }
        }
        else
            DebugLog(@"[ERROR] ReST:updateActivity - Connection error %@",[*e localizedDescription]);
    }
    return @"";
}

/**
 * Call auth service to get detail of a user such as first name, last name and user id
 */
- (void) updateUserDetails {
    NSString *url = [NSString stringWithFormat:@"%@%@%@", AUTH_SERVER, AUTH_USERDETAILS, [GASettings getEmailAddress]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *e) {
        // set properties only when request succeeded
        if(e == nil){
            NSError *error;
            NSDictionary* respDict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            [GASettings setFirstName:respDict[@"firstName"]];
            [GASettings setLastName:respDict[@"lastName"]];
            [GASettings setUserId:respDict[@"userId"]];
        }
    }];
}

/**
 * create a record on server
 */
- (NSMutableDictionary * )createRecord: (RecordForm *) record {
    
    // first get unique id for species
    if(record.uniqueId == nil) {
        NSString *uniqueId = [self getSpeciesUniqueId];
        record.uniqueId = uniqueId;
    }
    
    // Upload site
    if(record.siteId == nil) {
        [self createSite:record];
    }
    
    // now save record if unique id was generated
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                    @"status":[NSNull null],
                                                                                    @"message":[NSNull null],
                                                                                    @"activityId": [NSNull null]
                                                                                    }];
    if(record.uniqueId != nil && record.siteId != nil) {
        // check if photo is attached. then upload photo.
        NSMutableDictionary *photoStatus = [self uploadImage:record.speciesPhoto];
        
        
        if((photoStatus == nil) || [[NSNumber numberWithInt:200] isEqual: photoStatus[@"statusCode"]]){
            [record updateImageSettings: photoStatus[@"resp"]];
            
            NSString *url = [NSString stringWithFormat:@"%@%@%@", BIOCOLLECT_SERVER, CREATE_RECORD, [GASettings appProjectActivityID]];
            NSString *data = [record toJSON];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:url]];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:JSON_CONTENT_TYPE_VALUE forHTTPHeaderField:JSON_CONTENT_TYPE_KEY];
            [request setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField: @"Authorization"];
            [request setHTTPBody:[record toJSONData]];
            [request setHTTPMethod:@"POST"];
            NSLog(@"%@", data);
            
            NSError *e;
            NSURLResponse *response;
            NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&e];
            
            if(e == nil) {
                NSDictionary* respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:&e];
                if( [[NSNumber numberWithInt:200] isEqual: respDict[@"statusCode"]] ){
                    result[@"status"] = [NSNumber numberWithInt: 200];
                    result[@"message"] = @"Record saved";
                    result[@"activityId"] = respDict[@"resp"][@"activityId"];
                    
                    record.uploaded = TRUE;
                } else {
                    DebugLog(@"[ERROR] Server error %@",[*e localizedDescription]);
                    [self saveRecordToDisk: record];
                    result[@"status"] = [NSNumber numberWithInt: 500];
                    result[@"message"] = @"An error occurred while saving at the server. The record is now saved to disk. Try uploading it later.";
                }
            }
            else {
                // save record for sync later
                DebugLog(@"[ERROR] Connection error %@",[*e localizedDescription]);
                [self saveRecordToDisk: record];
                result[@"status"] = [NSNumber numberWithInt: 500];
                result[@"message"] = @"An error occurred while connceting to server. The record is now saved to disk. Try uploading it later.";
            }
        } else {
            // save record for sync later
            DebugLog(@"[ERROR] Connection error %@",[*e localizedDescription]);
            [self saveRecordToDisk: record];
            result[@"status"] = [NSNumber numberWithInt: 500];
            result[@"message"] = @"An error occurred while uploading multimedia. The record is now saved to disk. Try uploading it later.";
        }
    } else {
        DebugLog(@"[ERROR] Connection error %@",[*e localizedDescription]);
        [self saveRecordToDisk: record];
        result[@"status"] = [NSNumber numberWithInt: 500];
        result[@"message"] = @"An error occurred while connceting to server. Is your internet connection switched on? The record is now saved to disk. Try uploading it later.";
    }
    
    return result;
}

-(void)saveRecordToDisk: (RecordForm *) record{
    // save record for sync later
    [self.appDelegate addRecord:record];
}

/**
 * get unique id for species
 */
- (NSString *) getSpeciesUniqueId{
    NSString *uniqueId;
    NSString *url = [NSString stringWithFormat:@"%@%@", BIOCOLLECT_SERVER, UNIQUE_SPECIES_ID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSError *e;
    NSURLResponse *response;
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&e];
    
    if(e == nil) {
        NSDictionary* respDict =  [NSJSONSerialization JSONObjectWithData:GETReply options:kNilOptions error:&e];
        uniqueId = respDict[@"outputSpeciesId"];
    }
    
    return uniqueId;
}

/**
 * Upload image to server.
 */
- (NSMutableDictionary *) uploadImage: (UIImage *) image {
    if(image != nil){
        NSString *url = [NSString stringWithFormat: @"%@%@", BIOCOLLECT_SERVER, DOCUMENT_UPLOAD_URL];
        NSMutableDictionary *dict = [[NSMutableDictionary  alloc] initWithDictionary: @{ @"statusCode":[NSNull null],
                                                                                         @"resp": [NSNull null]
                                                                                         }];
        NSData *imageData = UIImagePNGRepresentation([self resizeImage:image]);
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL: [NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        
        // create request headers
        NSString *boundary = @"ydiasdaTXWa";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField: @"Authorization"];
        
        // create body of request
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=files; filename=%@\r\n", [appDelegate.utilService generateFileName:@"jpg"]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [request setHTTPBody:body];
        
        NSURLResponse *response;
        NSError *error;
        
        NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if(error == nil){
            NSDictionary* respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:&error];
            dict[@"statusCode"] = [NSNumber numberWithInt: 200];
            dict[@"resp"] = respDict;
        } else {
            dict[@"statusCode"] = [NSNumber numberWithInt: 500];
            dict[@"resp"] = @{};
        }
        
        return dict;
    } else {
        return nil;
    }
}

-(UIImage *)resizeImage:(UIImage *)image
{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 800.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth)
    {
        if(imgRatio < maxRatio)
        {
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio)
        {
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else
        {
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
    
}

- (void) createSite: (RecordForm *) recordForm {
    NSString *siteJson = [recordForm toSiteJSON];
    NSString *url = [NSString stringWithFormat:@"%@%@", BIOCOLLECT_SERVER, CREATE_SITE];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[siteJson length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:JSON_CONTENT_TYPE_VALUE forHTTPHeaderField:JSON_CONTENT_TYPE_KEY];
    [request setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField: @"Authorization"];
    [request setHTTPBody:[recordForm toSiteJSONData]];
    [request setHTTPMethod:@"POST"];
    NSLog(@"%@", siteJson);
    NSError *error;
    NSURLResponse *response;
    NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error == nil) {
        NSDictionary *respDict =  [NSJSONSerialization JSONObjectWithData:POSTReply options:kNilOptions error:&error];
        recordForm.siteId = error == nil && respDict != nil ? respDict[@"id"] : nil;
        NSLog(@"%@", recordForm.siteId);
    } else {
         NSLog(@"Error creating a site");
    }
}

-(Boolean) notReachable {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    return (networkStatus == NotReachable);
}

@end
