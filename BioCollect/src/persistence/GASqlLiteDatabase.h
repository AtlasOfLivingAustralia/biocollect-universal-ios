//
//  GASqlLiteDatabase.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 14/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

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
