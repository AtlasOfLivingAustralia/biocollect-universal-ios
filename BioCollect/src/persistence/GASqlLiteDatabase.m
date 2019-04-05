#import "GASqlLiteDatabase.h"
#import "GAAppDelegate.h"
#import "GASettingsConstant.h"

@implementation GASqlLiteDatabase
@synthesize db;

#define DB_NAME @"SQLITE_GreenArmy_v001.sqlite"
#define DB_THEME_SEPERATOR @"|,|"

-(id) init {
    self = [super init];

    if(self){
        [self sqlLiteConnect];
    }
    return self;
}

- (void) sqlLiteConnect {
}

-(NSMutableArray *) loadProjectsAndActivities {
    return NULL;
}

-(NSMutableArray *) loadSites : (NSString *) projectId {
    
    return NULL;
}

-(GASite *) getSiteBySiteId : (NSMutableArray *) sites : (NSString *) siteId{
    return NULL;
}

-(NSMutableArray *) loadActivities : (NSString *) projectId : (NSMutableArray *) sites{
    
    return NULL;
}



-(void) storeProjects: (NSMutableArray*) projects {
    
}


-(void) insertProject : (GAProject *) project {
}



-(void) insertProjectSites : (NSString *) projectId : (GASite *) site {
    
}

-(void) insertSite : (GASite *) site {

}


-(void) insertOrUpdateActivity : (GAActivity *) activity : (NSString *) projectId{
}

-(void) insertActivity : (GAActivity *) activity : (NSString *) projectId {

	
}



@end
