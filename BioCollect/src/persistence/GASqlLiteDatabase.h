#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "GAProject.h"
#import "GAActivity.h"

@interface GASqlLiteDatabase : NSObject
@property (nonatomic, assign) sqlite3 *db;

-(void) storeProjects : (NSMutableArray *) projects;
-(void) insertOrUpdateActivity : (GAActivity *) activity : (NSString *) projectId;
-(NSMutableArray *) loadProjectsAndActivities;
-(void) deleteAllTables;
-(void) insertSite : (GASite *) site;
-(void) insertProjectSites : (NSString *) projectId : (GASite *) site;
-(void) updateSite : (GASite *) site;
-(void) updateProjectSites :(GASite *) site;

@end
