//
//  GAActivitiesJSON.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAActivitiesJSON : NSObject

- (id)initWithData:(NSData *)jsonData;
-(NSString *) activityId;
-(NSString *) projectActivityName; // ProjectActivity name
-(NSString *) activityType;
-(NSString *) projectId;
-(NSString *) description;
-(NSString *) plannedStartDate;
-(NSString *) plannedEndDate;
-(NSString *) startDate;
-(NSString *) endDate;
-(NSString *) lastUpdated;
-(NSString *) progress;
-(NSString *) outputs;
-(NSString *) activityJSON;
-(NSString *) siteId;
-(NSString *) activityOwnerName;
-(NSString *) thumbnailUrl;
-(NSArray *) themes;

- (int) totalActivities;

- (NSDictionary*)getCurrentActivity;
- (NSDictionary*)nextActivity;
- (NSDictionary*)firstActivity;
- (int) getActivityCount;
- (BOOL) hasNext;
@end
