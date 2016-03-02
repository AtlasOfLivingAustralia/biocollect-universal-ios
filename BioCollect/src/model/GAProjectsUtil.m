//
//  GAProjectsUtil.m
//  GreenArmy
//
//  Created by Sathish iMac on 13/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GAProjectsUtil.h"
#import "GAActivity.h"

@interface GAProjectsUtil ()

@end

@implementation GAProjectsUtil


-(int) getPlannedActivitiesCount : (GAProject *) project{
    return [self getActivityCount : project : @"planned"];
}

-(int) getFinishedActivitiesCount : (GAProject *) project{
    return [self getActivityCount : project : @"finished"];

}

-(int) getDeferredActivitiesCount : (GAProject *) project {
    return [self getActivityCount : project : @"deferred"];
}

-(int) getActivityCount : (GAProject *) project : (NSString *) progress{

    int count = 0;
    for(int i =0; i < [project.activities count]; i++) {
        GAActivity *activity = [project.activities objectAtIndex:i];
        if([activity.progress isEqualToString:progress])
            count++;
    }
    return count;
}

@end
