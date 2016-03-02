//
//  GASqlLiteDatabase.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 14/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

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
    
    sqlite3 *database = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *sqlitePath = [documentsDirectory stringByAppendingPathComponent: DB_NAME];
    
    if (![fileManager fileExistsAtPath:sqlitePath]){
		if(![fileManager createFileAtPath:sqlitePath contents:nil attributes:nil]){
			DebugLog(@"[ERROR] SQLITE Database failed to initialize! File could not be created in application.");
		}
        else {
			if(sqlite3_open([sqlitePath UTF8String], &database) == SQLITE_OK) {
				
                sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS project (_id INTEGER PRIMARY KEY AUTOINCREMENT, projectId TEXT NOT NULL UNIQUE, name TEXT, description TEXT, lastUpdated TEXT)",
                                        NULL, NULL, NULL);
                
                sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS activity (_id INTEGER PRIMARY KEY AUTOINCREMENT, activityId TEXT NOT NULL UNIQUE, projectId TEXT, description TEXT, "
                                       "plannedStartDate TEXT, plannedEndDate TEXT, startDate TEXT, endDate TEXT, lastUpdated TEXT, activityDataJSON TEXT, status TEXT, progress TEXT, activityName TEXT, siteId TEXT, themes TEXT)",
                                        NULL, NULL, NULL);
                
                sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS site (_id INTEGER PRIMARY KEY AUTOINCREMENT, siteId TEXT NOT NULL UNIQUE, name TEXT, description TEXT, latitude TEXT, longitude TEXT, lastUpdated TEXT, permSiteId TEXT)",
                                        NULL, NULL, NULL);
                
                sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS project_sites (projectId INTEGER, siteId INTEGER)",
                                        NULL, NULL, NULL);
                
                sqlite3_close(database);
                
				database = nil;
			}
            else {
				DebugLog(@"[ERROR] SQLITE could not seed tables!");
			}
		}
	}
	
	sqlite3_open([sqlitePath UTF8String], &database);
    
    [self setDb: database];
}

-(NSMutableArray *) loadProjectsAndActivities {
    NSMutableArray *projects = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(self.db, "SELECT * FROM project WHERE _id > 0", -1, &statement, nil) != SQLITE_OK){
        DebugLog(@"[ERROR] SQLITE:loadProjectsAndActivities Failed to prepare statement! Error: '%s'", sqlite3_errmsg(self.db));
		return projects;
	}
    
  	while(sqlite3_step(statement) == SQLITE_ROW) {
        GAProject *project = [[GAProject alloc] init];

        int index = 1;
        project.projectId = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];

        index++;
        project.projectName = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];

        index++;
        project.description = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];

        index++;
        project.lastUpdated = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];

        project.sites = [self loadSites : project.projectId];
        
        project.activities = [self loadActivities : project.projectId : project.sites];

        [projects addObject:project];
    }
    return projects;
}

-(NSMutableArray *) loadSites : (NSString *) projectId {
    
    sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(self.db, "SELECT * FROM project_sites WHERE projectId = ?", -1, &statement, nil) != SQLITE_OK){
        DebugLog(@"[ERROR] SQLITE:loadSites Failed to prepare statement! Error: '%s'", sqlite3_errmsg(self.db));
		return nil;
	}
    
    NSMutableArray *sites = [[NSMutableArray alloc] init];
    NSMutableArray *siteIds = [[NSMutableArray alloc] init];
    
    int index = 1;
    sqlite3_bind_text(statement, index, [projectId UTF8String], -1, SQLITE_TRANSIENT);
    
  	while(sqlite3_step(statement) == SQLITE_ROW) {
        index = 1;
        [siteIds addObject:[[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""]];
    }
    
    if([siteIds count] > 0){
        
        for(NSString *siteId in siteIds) {
            sqlite3_stmt *statement;
            if(sqlite3_prepare_v2(self.db, "SELECT * FROM site WHERE siteId = ?", -1, &statement, nil) != SQLITE_OK){
                DebugLog(@"[ERROR] SQLITE:loadSites Failed to prepare statement! Error: '%s'", sqlite3_errmsg(self.db));
                return nil;
            }
            int index = 1;
            sqlite3_bind_text(statement, index, [siteId UTF8String], -1, SQLITE_TRANSIENT);
            
            while(sqlite3_step(statement) == SQLITE_ROW) {
                GASite *site = [[GASite alloc] init];
                index = 1;
                site.siteId = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
                index++;
                site.name = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
                index++;
                site.description = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
                index++;
                site.latitude = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
                index++;
                site.longitude = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
                index = 7;
                site.permSiteId = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
                site.projectId = projectId;
                [sites addObject:site];

            }

        }
    }
    return sites;
}

-(GASite *) getSiteBySiteId : (NSMutableArray *) sites : (NSString *) siteId{
    for (GASite *site in sites){
        if([site.siteId isEqualToString:siteId]){
            return site;
        }
    }
    return nil;
}

-(NSMutableArray *) loadActivities : (NSString *) projectId : (NSMutableArray *) sites{
    
    sqlite3_stmt *statement;
	if(sqlite3_prepare_v2(self.db, "SELECT * FROM activity WHERE projectId = ?", -1, &statement, nil) != SQLITE_OK){
        DebugLog(@"[ERROR] SQLITE:loadActivities Failed to prepare statement! Error: '%s'", sqlite3_errmsg(self.db));
		return nil;
	}

    NSMutableArray *activities = [[NSMutableArray alloc] init];
    
    int index = 1;
    sqlite3_bind_text(statement, index, [projectId UTF8String], -1, SQLITE_TRANSIENT);
    
  	while(sqlite3_step(statement) == SQLITE_ROW) {
        GAActivity *activity = [[GAActivity alloc] init];
        index = 1;
        activity.activityId = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
        
        index++;
        activity.projectId = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
        
        index++;
        activity.description = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];

        index++;
        activity.plannedStartDate = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
        
        index = 9;
        activity.activityJSON = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
        
        index++;
        activity.status = [[[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""] integerValue];

        index++;
        activity.progress = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
        
        index++;
        activity.activityName = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];

        index++;
        activity.siteId = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];

        index++;
        NSString *result = [[NSString alloc] initWithUTF8String: ((char *)sqlite3_column_text(statement, index) != NULL) ? (char *)sqlite3_column_text(statement, index) : ""];
        activity.themes = [result componentsSeparatedByString:DB_THEME_SEPERATOR];
        //NSString *result = [activity.themes componentsJoinedByString:@"|,|"];

        activity.url = [[NSString alloc] initWithFormat:@"%@/activity/enterData/%@?mobile=mobile",REST_SERVER,activity.activityId];
        
        activity.site = [self getSiteBySiteId : sites : activity.siteId];
        [activities addObject:activity];
    }
    return activities;
}



-(void) storeProjects: (NSMutableArray*) projects {
    [self deleteAllTables];
    DebugLog(@"[INFO] SQLITE:storeProjects - storing projects, activities and sites..");

    //IMPORTANT:  Do the bulk insert manipulation in the memory and do the IO operation at the end using transaction wrapper.
    sqlite3_exec(self.db, "BEGIN TRANSACTION", NULL, NULL, NULL);
        for(int i = 0; i < [projects count]; i++)
            [self insertProject: [projects objectAtIndex:i]];
        DebugLog(@"[INFO] SQLITE:storeProjects - Operation completed.");
    sqlite3_exec(self.db, "END TRANSACTION", NULL, NULL, NULL);
}


-(void) insertProject : (GAProject *) project {
    
    if(!self.db ) {
        DebugLog(@"[ERROR] SQLITE: Database not available! - insertProject:");
		return;
    }
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(self.db, "INSERT INTO project (projectId, name, description, lastUpdated) VALUES(?,?,?,?)", -1, &statement, nil) != SQLITE_OK){
        DebugLog(@"[ERROR] SQLITE:insertProject Failed to prepare statement!:");
        return;
    }
    
    int index = 1;
   
    sqlite3_bind_text(statement, index, [project.projectId UTF8String], -1, SQLITE_TRANSIENT);
    
    index++;
    sqlite3_bind_text(statement, index, [project.projectName UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [project.description UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [project.lastUpdated UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(statement) == SQLITE_ERROR) {
        DebugLog(@"[ERROR] SQLITE:insertProject - Failed to insert into database! Error: '%s'", sqlite3_errmsg(self.db));
        return;
    }
    
    // InsertOrUpdateSite
    for (GASite *site in project.sites) {
        [self insertProjectSites : project.projectId : site];
        [self insertSite: site];
    }
    
    // Insert or update activity
    for(int i = 0; i < [project.activities count]; i++) {
        [self insertOrUpdateActivity : [project.activities objectAtIndex:i] : project.projectId];
    }
}



-(void) insertProjectSites : (NSString *) projectId : (GASite *) site {
    
    if (!self.db) {
            DebugLog(@"[ERROR] SQLITE:insertProjectSites- database not available!");
		return;
	}
    
    NSString *cmd = [NSString stringWithFormat:@ "insert into project_sites (projectId, siteId) VALUES ('%@','%@');",
                     projectId,site.siteId];
    const char * sql = [cmd UTF8String];
    sqlite3_stmt *compiledStatement;
    
    int step =  sqlite3_prepare_v2(self.db, sql, -1, &compiledStatement, NULL);
    if(step == SQLITE_OK) {
        sqlite3_step(compiledStatement);
        //DebugLog(@"[SUCCESS] SQLLITE:insertProjectSites - site update successfull");
    }
    else {
        DebugLog(@"[ERROR] SQLLITE:insertProjectSites - site update unsuccessful (Error = %s)",sqlite3_errmsg(self.db));
    }
    sqlite3_finalize(compiledStatement);
}

-(void) insertSite : (GASite *) site {

    if (!self.db) {
        DebugLog(@"[ERROR] SQLITE:insertSite- database not available!");
		return;
	}
    
    const char *sql = "INSERT INTO site (siteId, name, description,latitude,longitude,permSiteId) VALUES (?,?,?,?,?,?);";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [site.siteId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [site.name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [site.description UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 4, [site.latitude UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 5, [site.longitude UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 6, [site.permSiteId UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            DebugLog(@"[ERROR] SQLLITE:insertSite - site update unsuccessful ( execution failed = %s)",sqlite3_errmsg(self.db));
        }
    } else {
        DebugLog(@"[ERROR] SQLLITE:insertSite - site update unsuccessful ( prepare failed = %s)",sqlite3_errmsg(self.db));
    }
    sqlite3_finalize(stmt);
}


-(void) insertOrUpdateActivity : (GAActivity *) activity : (NSString *) projectId{
    sqlite3_stmt *statement;
	
	if(sqlite3_prepare_v2(self.db, "SELECT * FROM activity WHERE activityId = ?", -1, &statement, nil) != SQLITE_OK){
        DebugLog(@"[ERROR] SQLITE:insertOrUpdateActivity - Failed to prepare statement! Error: '%s' - activity", sqlite3_errmsg(self.db));
		return;
	}
    int index = 1;
    sqlite3_bind_text(statement, index, [activity.activityId UTF8String], -1, SQLITE_TRANSIENT);
    
	
  	if(sqlite3_step(statement) == SQLITE_ROW)
        [self updateActivity : activity : projectId];
    else
        [self insertActivity: activity : projectId];
}

-(void) insertActivity : (GAActivity *) activity : (NSString *) projectId {

    if(!self.db ) {
        DebugLog(@"[ERROR] SQLITE:insertActivity - Database not available! - insertProject:");
		return;
    }
    
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(self.db, "INSERT INTO activity (activityId, projectId, description, plannedStartDate, plannedEndDate, startDate, endDate, lastUpdated, activityDataJSON, status,progress,activityName,siteId,themes) "
                          "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)", -1, &statement, nil) != SQLITE_OK){
        DebugLog(@"[ERROR] SQLITE:insertActivity - Failed to prepare statement! - insertActivity:");
        return;
    }
    
    int index = 1;
    sqlite3_bind_text(statement, index, [activity.activityId UTF8String], -1, SQLITE_TRANSIENT);
    
    index++;
    sqlite3_bind_text(statement, index, [projectId UTF8String], -1, SQLITE_TRANSIENT);
    
    index++;
    sqlite3_bind_text(statement, index, [activity.description UTF8String], -1, SQLITE_TRANSIENT);
    
    index++;
    sqlite3_bind_text(statement, index, [activity.plannedStartDate UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [@"" UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [@"" UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [@"" UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [@"" UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [activity.activityJSON UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    NSString *status = [[NSString alloc] initWithFormat:@"%d",activity.status];
    sqlite3_bind_text(statement, index, [status UTF8String], -1, SQLITE_TRANSIENT);
    
    index++;
    sqlite3_bind_text(statement, index, [activity.progress UTF8String], -1, SQLITE_TRANSIENT);
    
    index++;
    sqlite3_bind_text(statement, index, [activity.activityName UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    sqlite3_bind_text(statement, index, [activity.siteId UTF8String], -1, SQLITE_TRANSIENT);

    index++;
    NSString *themes = [activity.themes componentsJoinedByString:DB_THEME_SEPERATOR];
    sqlite3_bind_text(statement, index, [themes UTF8String], -1, SQLITE_TRANSIENT);

    if (sqlite3_step(statement) == SQLITE_ERROR) {
        DebugLog(@"[ERROR] SQLITE:insertActivity - Failed to insert into database! Error: '%s' ", sqlite3_errmsg(self.db));
        return;
    }
    
}

// Only 3 values expected to change here => status, siteId and activityJSON
-(void) updateActivity : (GAActivity *) activity  : (NSString *) projectId {
    if (!self.db) {
        DebugLog(@"[ERROR] SQLITE:updateActivity - database not available!");
		return;
	}
    NSString *status = [[NSString alloc] initWithFormat:@"%d",activity.status];
    const char *sql = "update activity set status=?, activityDataJSON=?, siteId=? where activityId=?;";
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, [status UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [activity.activityJSON UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [activity.siteId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 4, [activity.activityId UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(stmt) != SQLITE_DONE) {
            DebugLog(@"[ERROR] SQLITE:updateActivity - activity update unsuccessful ( execution failed = %s)",sqlite3_errmsg(self.db));
        }
    } else {
        DebugLog(@"[ERROR] SQLITE:updateActivity - activity update unsuccessful ( prepare failed = %s)",sqlite3_errmsg(self.db));
    }
    sqlite3_finalize(stmt);
}

-(void) updateProjectSites : (GASite *) site {
    
    if (!self.db) {
        DebugLog(@"[ERROR] SQLITE:updateProjectSites - database not available!");
		return;
	}

    NSString *cmd = [NSString stringWithFormat:@    "update project_sites set siteId='%@' where projectId='%@';",
                     site.permSiteId, site.projectId];
    
    const char * sql = [cmd UTF8String];
    sqlite3_stmt *compiledStatement;
    
    int step =  sqlite3_prepare_v2(self.db, sql, -1, &compiledStatement, NULL);
    if(step == SQLITE_OK) {
        sqlite3_step(compiledStatement);
        //DebugLog(@"[SUCCESS] SQLITE:updateProjectSites - project_site update successfull");
    }
    else {
        DebugLog(@"[ERROR] SQLITE:updateProjectSites - project_site update unsuccessful (Error = %s)",sqlite3_errmsg(self.db));
    }
    sqlite3_finalize(compiledStatement);
    
}

-(void) updateSite : (GASite *) site {
    
    if (!self.db) {
        DebugLog(@"[ERROR] SQLITE:updateSite - database not available!");
		return;
	}
    
    NSString *cmd = [NSString stringWithFormat:@    "update project_sites set siteId='%@' where siteId='%@';",
                     site.siteId, site.permSiteId];
    const char * sql = [cmd UTF8String];
    sqlite3_stmt *compiledStatement;
    
    int step =  sqlite3_prepare_v2(self.db, sql, -1, &compiledStatement, NULL);
    if(step == SQLITE_OK) {
        sqlite3_step(compiledStatement);
        //DebugLog(@"[SUCCESS] SQLITE:updateProjectSites - site update successfull");
    }
    else {
        DebugLog(@"[ERROR] SQLITE:updateProjectSites - site update unsuccessful (Error = %s)",sqlite3_errmsg(self.db));
    }
    sqlite3_finalize(compiledStatement);
    
}

- (void) deleteAllTables {
    
	if (!self.db) {
        DebugLog(@"[ERROR] SQLITE:Database not available! - deleteAllTables:");
		return;
	}

	
	NSString *deleteProject = [NSString stringWithFormat:@"DELETE FROM project WHERE _id > 0"];
    NSString *deleteSeqProject = [NSString stringWithFormat:@"DELETE from sqlite_sequence where name='project'"];

	if (sqlite3_exec(self.db, [deleteProject UTF8String], NULL, NULL, NULL) == SQLITE_ABORT) {
        DebugLog(@"[ERROR] SQLITE:deleteAllTables - Failed to delete record from the database! Error: '%s' - deleteProject:", sqlite3_errmsg(self.db));
		return;
	}
    
    if (sqlite3_exec(self.db, [deleteSeqProject UTF8String], NULL, NULL, NULL) == SQLITE_ABORT) {
        DebugLog(@"[ERROR] SQLITE:deleteAllTables - Failed to delete record from the database! Error: '%s' - deleteProject:", sqlite3_errmsg(self.db));
		return;
	}
    
    NSString *deleteActivity = [NSString stringWithFormat:@"DELETE FROM activity WHERE _id > 0"];
    NSString *deleteSeqActivity = [NSString stringWithFormat:@"DELETE from sqlite_sequence where name='activity'"];
    
	if (sqlite3_exec(self.db, [deleteActivity UTF8String], NULL, NULL, NULL) == SQLITE_ABORT) {
        DebugLog(@"[ERROR] SQLITE:deleteAllTables - Failed to delete record from the database! Error: '%s' - deleteActivity:", sqlite3_errmsg(self.db));
		return;
	}
    if (sqlite3_exec(self.db, [deleteSeqActivity UTF8String], NULL, NULL, NULL) == SQLITE_ABORT) {
        DebugLog(@"[ERROR] SQLITE:deleteAllTables - Failed to delete record from the database! Error: '%s' - deleteActivity:", sqlite3_errmsg(self.db));
		return;
	}
    
    NSString *deleteProjectSites = [NSString stringWithFormat:@"DELETE FROM project_sites"];
    NSString *deleteSeqProjectSites = [NSString stringWithFormat:@"DELETE from sqlite_sequence where name='project_sites'"];
	
	if (sqlite3_exec(self.db, [deleteProjectSites UTF8String], NULL, NULL, NULL) == SQLITE_ABORT) {
        DebugLog(@"[ERROR] SQLITE:deleteAllTables - Failed to delete record from the database! Error: '%s' - deleteProjectSites:", sqlite3_errmsg(self.db));
		return;
	}
    
    if (sqlite3_exec(self.db, [deleteSeqProjectSites UTF8String], NULL, NULL, NULL) == SQLITE_ABORT) {
        DebugLog(@"[ERROR] SQLITE:deleteAllTables - Failed to delete record from the database! Error: '%s' - deleteSeqProjectSites:", sqlite3_errmsg(self.db));
		return;
	}
    
    NSString *deleteSite = [NSString stringWithFormat:@"DELETE FROM site WHERE _id > 0"];
	
	if (sqlite3_exec(self.db, [deleteSite UTF8String], NULL, NULL, NULL) == SQLITE_ABORT) {
        DebugLog(@"[ERROR] SQLITE:deleteAllTables - Failed to delete record from the database! Error: '%s' - deleteSite:", sqlite3_errmsg(self.db));
		return;
	}
	
    DebugLog(@"[SUCCESS] SQLITE:deleteAllTables - Record deleted from the database. Changes: %i", sqlite3_changes(self.db));
	
}



@end
