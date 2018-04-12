//  Oz Atlas
#import <Foundation/Foundation.h>
#import "ProjectService.h"
#import "GASettingsConstant.h"
#import "GAProjectJSON.h"
#import "GASettings.h"
#import "ProjectActivitiesJSON.h"
#import "ProjectActivity.h"
#import "GAAppDelegate.h"

@interface ProjectService ()
@property (nonatomic, strong) NSURL *projectsFileUrlPath;
@property (nonatomic, retain) NSMutableArray *projects;
@property (nonatomic, strong) NSURL *selectedProjectUrlPath;
@property (strong, nonatomic) GAAppDelegate *appDelegate;
@end

@implementation ProjectService
#define kProjectsHubStorageLocation @"TRACKS_PROJECTS_HUB"
#define kSelectedProjectLocation @"TRACKS_SELECTED_PROJECTS"
#define kHubProjects @"/ws/project/search?sort=nameSort&fq=isExternal:F&initiator=biocollect&max=150&offset=0&mobile=true"
@synthesize projects;

-(id) init {
    self.projects = [[NSMutableArray alloc]init];
    NSArray<NSURL *> *urls = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask];
    if([urls count] > 0){
        self.projectsFileUrlPath = [urls[0] URLByAppendingPathComponent:kProjectsHubStorageLocation];
        self.selectedProjectUrlPath = [urls[0] URLByAppendingPathComponent:kSelectedProjectLocation];
    }
    NSError *error;
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(![[self.appDelegate restCall] notReachable]) {
        [self wsGetProjects:&error];
    }
    return self;
}

- (void) wsGetProjects : (NSError**) error {

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat: @"%@%@&hub=%@", BIOCOLLECT_SERVER, kHubProjects,[GASettings appHubName]];
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    
    NSData *nsData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];
    if(*error == nil) {
        self.projects = [[NSMutableArray alloc] init];
        NSDictionary *resultDictionary = [[NSDictionary alloc] init];
        NSError *jsonError = nil;
        resultDictionary = [NSJSONSerialization JSONObjectWithData:nsData options: 0 error:&jsonError];
        GAProjectJSON  *projectJSON = [[GAProjectJSON alloc] initWithArray:resultDictionary[@"projects"]];
        while([projectJSON hasNext]) {
            [projectJSON nextProject];
            Project *projectObj = [[Project alloc] init];
            projectObj.projectId = projectJSON.projectId;
            projectObj.name = projectJSON.projectName;
            projectObj.urlImage = projectJSON.urlImage;
            projectObj.projectActivityId = [self getProjectActivityId: projectObj.projectId];
            [projects addObject:projectObj];
        }
        
        if([self.projects count] > 0) {
            [self storeHubProjects];
        }
    }
}

-(BOOL) storeHubProjects {
    BOOL archived = [NSKeyedArchiver archiveRootObject: self.projects toFile: self.projectsFileUrlPath.path];
    if (!archived) {
        NSLog(@"Failed to load to project list from local storage.");
    }
    return archived;
}

- (NSMutableArray *) loadProjects {
    NSArray<Project *> *projectObj = [NSKeyedUnarchiver unarchiveObjectWithFile: self.projectsFileUrlPath.path];
    [self.projects removeAllObjects];
    [self.projects addObjectsFromArray:projectObj];
    
    if([self.projects count] == 0) {
        NSError *error;
        [self wsGetProjects:&error];
    }
    
    return [self projects];
}

-(BOOL) storeSelectedProject : (Project *) project{
    BOOL archived = [NSKeyedArchiver archiveRootObject: project toFile: self.selectedProjectUrlPath.path];
    if (!archived) {
        NSLog(@"Failed to load to project list from local storage.");
    }
    return archived;
}

- (Project *) loadSelectedProject {
    Project *projectObj = [NSKeyedUnarchiver unarchiveObjectWithFile: self.selectedProjectUrlPath.path];
    return projectObj;
}

-(NSString *) getProjectActivityId : (NSString *) projectId {
    NSString *pActivityId = nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat: @"%@%@/%@", BIOCOLLECT_SERVER, LIST_PROJECT_ACTIVITIES, projectId];
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    NSError *error = nil;
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error == nil) {
        ProjectActivitiesJSON  *pActivitiesJSON = [[ProjectActivitiesJSON alloc] initWithData:GETReply];
        while([pActivitiesJSON hasNext]) {
            [pActivitiesJSON nextProjectActivity];
            ProjectActivity *pActivity = [[ProjectActivity alloc] init];
            pActivity.projectActivityId = pActivitiesJSON.projectActivityId;
            pActivity.published = pActivitiesJSON.published;
            BOOL published = [pActivity.published boolValue];
            if(published){
                pActivityId = pActivity.projectActivityId;
            }
            if(pActivityId) break;
        }
    }
    
    return pActivityId;
}

@end
