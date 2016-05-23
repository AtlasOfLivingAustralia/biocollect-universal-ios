//
//  BioProjectService.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 4/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

@interface BioProjectService : NSObject

// TODO move arguments to seperate class.
// Get all projects.
- (NSInteger) getBioProjects : (NSMutableArray*)projects offset: (NSInteger) offset max: (NSInteger) max query:(NSString*) query params:(NSString*) params isUserPage:(BOOL) isUserPage error:(NSError**) error;

// Get activities for the given projectId.
- (NSInteger) getActivities : (NSMutableArray*) records offset: (NSInteger) offset max: (NSInteger) max projectId: (NSString*) projectId query:(NSString*) query myRecords:(BOOL) myRecords  error:(NSError**) error;

@end
