//
//  GAActivitiesJSON.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GAActivitiesJSON.h"

@interface GAActivitiesJSON ()

@property (strong, nonatomic) NSMutableArray *activitiesJSONArray;
@property (assign, nonatomic) int index;
@property (assign, nonatomic) BOOL hasNext;
@property (strong, nonatomic) NSDictionary *activityJSONDictionary;

@end

@implementation GAActivitiesJSON

#define kActivityId @"activityId"
#define kActivityType @"type"
#define kProjectId @"projectId"
#define kDescription @"description"
#define kPlannedStartDate @"plannedStartDate"
#define kPlannedEndDate @"plannedEndDate"
#define kStartDate @"startDate"
#define kEndDate @"endDate"
#define kLastUpdated @"lastUpdated"
#define kProgress @"progress"
#define kOutputs @"outputs"
#define kSiteId @"siteId"
#define kThemes @"themes"

#define kActivities @"activities"

- (id)initWithData:(NSData *)jsonData {
    
    // Call the superclass's designated initializer
    self = [super init];
    
    if(self) {
        NSError *jsonParsingError = nil;
        self.activitiesJSONArray = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonParsingError] objectForKey:kActivities];
        [self.activitiesJSONArray removeObjectIdenticalTo:[NSNull null]];
        self.activityJSONDictionary = [[NSDictionary alloc] init];
        self.index = 0;
    }
    return self;
}

-(NSString *) activityId {
    return [self.activityJSONDictionary objectForKey:kActivityId];
}

-(NSString *) activityType {
    return [self.activityJSONDictionary objectForKey:kActivityType];
}
-(NSString *) projectId {
    return [self.activityJSONDictionary objectForKey:kProjectId];
}

-(NSString *) description {
   return [self.activityJSONDictionary objectForKey:kDescription];
}

-(NSString *) plannedStartDate {
   return [self.activityJSONDictionary objectForKey:kPlannedStartDate];
}
-(NSString *) plannedEndDate {
   return [self.activityJSONDictionary objectForKey:kPlannedEndDate];
}

-(NSString *) startDate {
   return [self.activityJSONDictionary objectForKey:kStartDate];
}

-(NSString *) endDate {
   return [self.activityJSONDictionary objectForKey:kEndDate];
}

-(NSString *) lastUpdated {
   return [self.activityJSONDictionary objectForKey:kLastUpdated];
}

-(NSString *) progress {
    return [self.activityJSONDictionary objectForKey:kProgress];
}
-(NSString *) siteId {
    return [self.activityJSONDictionary objectForKey:kSiteId];
}
-(NSArray *) themes {
    return [self.activityJSONDictionary objectForKey:kThemes];
}



-(NSString *) outputs {
    NSArray *outputArray = [self.activityJSONDictionary objectForKey:kOutputs];
    NSMutableDictionary *outputsDic = [[NSMutableDictionary alloc] init];
    [outputsDic setValue:outputArray forKeyPath:@"outputs"];
    
    NSError *writeError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:outputsDic options:NSJSONWritingPrettyPrinted error:&writeError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

-(NSString *) activityJSON{
    NSError *writeError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.activityJSONDictionary options:NSJSONWritingPrettyPrinted error:&writeError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSDictionary*)getCurrentActivity {
    return self.activityJSONDictionary;
}

- (NSDictionary*)nextActivity {
   
    if(self.index < [self.activitiesJSONArray count]){
        self.activityJSONDictionary = [self.activitiesJSONArray objectAtIndex:self.index];
        self.index++;
        return self.activityJSONDictionary;
    }
    
    return nil;
}

- (NSDictionary*)firstActivity {
    self.index = 0;
    if(self.index < [self.activitiesJSONArray count])
        return [self.activitiesJSONArray objectAtIndex:self.index];
    return nil;
}
- (int) getActivityCount {
    return (int)[self.activitiesJSONArray count];
}

- (BOOL) hasNext {
    return (self.index < [self.activitiesJSONArray count]);
}


@end
