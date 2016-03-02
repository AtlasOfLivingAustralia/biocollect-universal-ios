//
//  GAProjectsHandler.h
//  GreenArmy
//
//  Created by Sathish iMac on 13/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAProject.h"
@interface GAProjectsUtil : NSObject

#define ACTIVITY_PLANNED @"Planned"
#define ACTIVITY_FINISHED @"Finished"
#define ACTIVITY_STARTED @"Started"

-(int) getPlannedActivitiesCount : (GAProject *) project;
-(int) getFinishedActivitiesCount : (GAProject *) project;
-(int) getDeferredActivitiesCount : (GAProject *) project;
@end
