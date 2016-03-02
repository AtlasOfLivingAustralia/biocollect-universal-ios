//
//  NSObject+Activities.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GAActivity.h"

@implementation GAActivity
@synthesize _id, url, activityName, description, progress, activityId, projectId, outputJSON, activityJSON, status, plannedStartDate,siteId,site,distance,themes;

- (NSComparisonResult)compareByProgress:(GAActivity *)otherObject {
    return [self.progress compare:otherObject.progress];
}
- (NSComparisonResult)compareByName:(GAActivity *)otherObject {
    return [self.activityName compare:otherObject.activityName];
}

//Decending the comparison
- (NSComparisonResult)compareByPlannedStartingDate:(GAActivity *)otherObject {
    return [otherObject.plannedStartDate compare:self.plannedStartDate];
}

- (NSComparisonResult)compareBySync:(GAActivity *)otherObject {
    return otherObject.status > self.status;
}


- (NSComparisonResult)compareByDistance:(GAActivity *)otherObject {
//    return [self.distance compare:otherObject.distance];
    if([self.distance integerValue] >= [otherObject.distance  integerValue]){
        return true;
    }
    else
        return false;
}

@end
