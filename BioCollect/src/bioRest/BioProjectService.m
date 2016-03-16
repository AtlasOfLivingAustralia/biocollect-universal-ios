//
//  BioProjectService.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 4/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BioProjectService.h"
#import "GAProject.h"
#import "GAActivity.h"
#import "GAActivitiesJSON.h"
#import "GAProjectJSON.h"
#import "GASettingsConstant.h"

@implementation BioProjectService
#define BIO_PROJECT_SEARCH @"/ws/project/search?initiator=biocollect&sort=nameSort"
#define BIO_PROJECT_ACTIVITY_LIST @"/projectActivity/list/"
#define BIO_ACTIVITIES @"/bioActivity/searchProjectActivities"
#define kProjects @"projects"
#define kTotal @"total"

/*
 Get BioCollect projects - run as async task.
 Example: http://biocollect-test.ala.org.au/ws/project/search?initiator=biocollect&max=10&offset=0
*/
- (NSInteger) getBioProjects : (NSMutableArray*) projects offset: (NSInteger) offset max: (NSInteger) max  error:(NSError**) error {
    //Request projects.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat: @"%@%@&offset=%ld&max=%ld", BIOCOLLECT_SERVER, BIO_PROJECT_SEARCH, (long)offset, (long)max];
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    DebugLog(@"[INFO] BioProjectService:getBioProjects - Biocollect projects search url %@",escapedUrlString);
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];
    NSInteger totalProjects = 0;
    if(*error == nil) {
        NSError *jsonParsingError = nil;
        NSMutableArray *projectJSONArray = [NSJSONSerialization JSONObjectWithData:GETReply options: 0 error:&jsonParsingError];
 
        if([projectJSONArray count] > 0) {
            GAProjectJSON  *projectJSON = [[GAProjectJSON alloc] initWithArray:[projectJSONArray valueForKey: kProjects]];
            totalProjects = [[projectJSONArray valueForKey: kTotal] integerValue];
            
            while([projectJSON hasNext]) {
                [projectJSON nextProject];
                
                GAProject *project = [[GAProject alloc] init];
                project.projectId = projectJSON.projectId;
                project.projectName = projectJSON.projectName;
                project.description = projectJSON.description;
                project.lastUpdated = projectJSON.lastUpdatedDate;
                project.urlImage = projectJSON.urlImage;
                project.urlWeb = projectJSON.urlWeb;
                project.isExternal = projectJSON.isExternal;
                [projects addObject:project];
            }
        }
    }
    
    DebugLog(@"[INFO] BioProjectService:getBioProjects - Total projects %ld",totalProjects);
    return totalProjects;
}

// List of all activities associated to the project
// http://biocollect-test.ala.org.au/bioActivity/searchProjectActivities?projectId=eccadc59-2dc5-44df-8aac-da41bcf17ba4&view=project
- (NSInteger) getActivities : (NSMutableArray*) records offset: (NSInteger) offset max: (NSInteger) max projectId: (NSString*) projectId error:(NSError**) error {
    //Request projects.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = nil;
    if(projectId) {
        url = [[NSString alloc] initWithFormat: @"%@%@?view=project&offset=%ld&max=%ld&projectId=%@", BIOCOLLECT_SERVER, BIO_ACTIVITIES, (long)offset, (long)max, projectId];
    } else {
        url = [[NSString alloc] initWithFormat: @"%@%@?view=all&offset=%ld&max=%ld", BIOCOLLECT_SERVER, BIO_ACTIVITIES, (long)offset, (long)max];
    }
    
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    DebugLog(@"[INFO] BioProjectService:getActivities - Biocollect activities search url %@",escapedUrlString);
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];
    
    NSInteger totalRecords = 0;
    if(*error == nil) {
        GAActivitiesJSON  *activitiesJSON = [[GAActivitiesJSON alloc] initWithData:GETReply];
        totalRecords = activitiesJSON.totalActivities;
        DebugLog(@"[INFO] BioProjectService:getBioProjects - Total projects %d",activitiesJSON.totalActivities);
        while([activitiesJSON hasNext]) {
            [activitiesJSON nextActivity];
            GAActivity *activity = [[GAActivity alloc] init];
            activity.activityName = activitiesJSON.activityType;
            activity.description = ([activitiesJSON.description length])?(activitiesJSON.description):@"";
            activity.url = [[NSString alloc] initWithFormat:@"%@/bioActivity/index/%@?mobile=true",BIOCOLLECT_SERVER,activitiesJSON.activityId];
            activity._id = -1;
            activity.activityOwnerName = activitiesJSON.activityOwnerName;
            activity.activityId = activitiesJSON.activityId;
            activity.status = 0;
            activity.projectActivityName = activitiesJSON.projectActivityName;
            activity.thumbnailUrl = activitiesJSON.thumbnailUrl;
            activity.lastUpdated = ([activitiesJSON.lastUpdated length])?(activitiesJSON.lastUpdated):@"-";
            [records addObject:activity];
        }

    }
    
    return totalRecords;
}

/*
 Get BioCollect project activity list
 Example: http://ecodata-test.ala.org.au/projectActivity/list/eccadc59-2dc5-44df-8aac-da41bcf17ba4
*/
-(void) getProjectActivities : (NSString*) projectId error:(NSError**) error {
    
    //Request projects.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat: @"%@%@%@", ECODATA_SERVER, BIO_PROJECT_ACTIVITY_LIST, projectId];
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    NSLog(@"[INFO] BioProjectService:getProjectActivities - Biocollect Project Activities list url %@",escapedUrlString);
    
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];
    DebugLog(@"[INFO] BioProjectService:getProjectActivities - Initiating ReST call.");
    
    if(*error == nil) {
        NSError *jsonParsingError = nil;
        NSMutableArray *projectActivitiesJSONArray = [NSJSONSerialization JSONObjectWithData:GETReply options: 0 error:&jsonParsingError];

        if([projectActivitiesJSONArray count] > 0) {
            
        }
    }
}


// List of all the Project Activities
// http://ecodata-test.ala.org.au/projectActivity/list/eccadc59-2dc5-44df-8aac-da41bcf17ba4

// Fauna
// http://ecodata-test.ala.org.au/activity/list/09a5e016-ec4c-4421-9dbe-43c586d00e5e

// All data
// http://biocollect-test.ala.org.au/bioActivity/searchProjectActivities

// Project Activity Data
//http://biocollect-test.ala.org.au/bioActivity/searchProjectActivities?projectId=eccadc59-2dc5-44df-8aac-da41bcf17ba4&max=10&offset=0&sort=lastUpdated&order=DESC&flimit=1000&view=project&searchTerm=

@end