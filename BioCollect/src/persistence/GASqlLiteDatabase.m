//
//  GASqlLiteDatabase.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 14/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "GASqlLiteDatabase.h"
#import "GAAppDelegate.h"
#import "GASettingsConstant.h"

@implementation GASqlLiteDatabase
@synthesize db;

#define DB_NAME @"SQLITE_BIOCOLLECT_v001.sqlite"
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

// Only 3 values expected to change here => status, siteId and activityJSON
-(void) updateActivity : (GAActivity *) activity  : (NSString *) projectId {
}

-(void) updateProjectSites : (GASite *) site {
}

-(void) updateSite : (GASite *) site {
}

- (void) deleteAllTables {
    
}



@end
