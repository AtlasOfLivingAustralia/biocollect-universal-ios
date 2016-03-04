//
//  BioProjectService.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 4/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BioProjectService.h"
#import "GAProject.h"
#import "GAProjectJSON.h"
#import "GASettingsConstant.h"

@implementation BioProjectService
#define BIO_PROJECT_SEARCH @"/ws/project/search?initiator=biocollect"
#define kProjects @"projects"
#define kTotal @"total"

// Get BioCollect projects.
- (NSInteger) getBioProjects : (NSMutableArray*) projects offset: (int) offset max: (int) max  error:(NSError**) error {
    //Request projects.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat: @"%@%@&offset=%dmax=%d", BIOCOLLECT_SERVER, BIO_PROJECT_SEARCH, offset, max];
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    NSLog(@"[INFO] BioProjectService:getBioProjects - Biocollect projects search url %@",escapedUrlString);

    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];
    DebugLog(@"[INFO] BioProjectService:getBioProjects - Initiating ReST call.");
    
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
                [projects addObject:project];
            }
        }
    }
    
    return totalProjects;
}

@end