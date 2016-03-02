//
//  NSObject+Activities.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GASite.h"

#define ACTIVITY_NO_CHANGE  0
#define ACTIVITY_CHANGED ACTIVITY_NO_CHANGE + 1
#define ACTIVITY_CHANGED_WITH_ERROR ACTIVITY_CHANGED + 1

#define ACTIVITY_SORT_BY_NAME  0
#define ACTIVITY_SORT_BY_PROGRESS  ACTIVITY_SORT_BY_NAME + 1
#define ACTIVITY_SORT_BY_PLANNED_STARTING_DATE  ACTIVITY_SORT_BY_PROGRESS + 1
#define ACTIVITY_SORT_BY_SYNC  ACTIVITY_SORT_BY_PLANNED_STARTING_DATE + 1
#define ACTIVITY_SORT_BY_LOCATION  ACTIVITY_SORT_BY_SYNC + 1

@interface GAActivity : NSObject  {
    int _id;
    NSString *activityName;
    NSString *activityId;
    NSString *projectId;
    NSString *description;
    NSString *url;
    NSString *progress;
    NSString *outputJSON;
    NSString *activityJSON;
    NSString *plannedStartDate;
    int status; // 0 => NO_CHANGE, 1 = CHANGED
    NSString *siteId;
    GASite *site;
    NSString *distance;
    NSArray *themes;
}
@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString * activityName;
@property (nonatomic, strong) NSString * activityId;
@property (nonatomic, strong) NSString * projectId;
@property (nonatomic, strong) NSString * progress;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * outputJSON;
@property (nonatomic, strong) NSString * activityJSON;
@property (nonatomic, assign) int status;
@property (nonatomic, strong) NSString * plannedStartDate;
@property (nonatomic, strong) NSString * siteId;
@property (nonatomic, strong) GASite * site;
@property (nonatomic, strong) NSString * distance;
@property (nonatomic, strong) NSArray * themes;

- (NSComparisonResult)compareByProgress:(GAActivity *)otherObject;
- (NSComparisonResult)compareByName:(GAActivity *)otherObject;
- (NSComparisonResult)compareByPlannedStartingDate:(GAActivity *)otherObject;
- (NSComparisonResult)compareBySync:(GAActivity *)otherObject;
- (NSComparisonResult)compareByDistance:(GAActivity *)otherObject;
@end
