//
//  BioProjectService.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 4/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

@interface BioProjectService : NSObject

// Get BioCollect projects.
- (NSInteger) getBioProjects : (NSMutableArray*)projects offset: (NSInteger) offset max: (NSInteger) max  error:(NSError**) error;

@end
