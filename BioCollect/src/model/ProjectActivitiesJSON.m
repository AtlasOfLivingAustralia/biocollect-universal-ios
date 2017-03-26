//
//  GAActivitiesJSON.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "ProjectActivitiesJSON.h"

@interface ProjectActivitiesJSON ()

@property (strong, nonatomic) NSMutableArray *pActivitiesJSONArray;
@property (assign, nonatomic) int index;
@property (assign, nonatomic) BOOL hasNext;
@property (strong, nonatomic) NSDictionary *pActivityJSONDictionary;
@property (assign, nonatomic) int totalProjectActivities;

@end

@implementation ProjectActivitiesJSON

#define kProjectActivityId @"projectActivityId"
#define kProjectActivityName @"name"
#define kDescription @"description"
#define kPublished @"published"
#define kProjectId @"projectId"


- (id)initWithData:(NSData *)jsonData {
    
    // Call the superclass's designated initializer
    self = [super init];
    
    if(self) {
        NSError *jsonParsingError = nil;
        self.pActivitiesJSONArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParsingError];
        self.totalProjectActivities = (int)[self.pActivitiesJSONArray count];
        self.pActivityJSONDictionary = [[NSDictionary alloc] init];
        self.index = 0;
    }
    return self;
}


-(NSString *) projectActivityId {
    return [self.pActivityJSONDictionary objectForKey:kProjectActivityId];
}

-(NSString *) projectId {
    return [self.pActivityJSONDictionary objectForKey:kProjectId];
}
-(NSString *) name {
    return [self.pActivityJSONDictionary objectForKey:kProjectActivityName];
}

-(NSString *) description {
    return [self.pActivityJSONDictionary objectForKey:kDescription];
}

-(NSString *) published {
    return [self.pActivityJSONDictionary objectForKey:kPublished];
}

- (NSDictionary*)getCurrentProjectActivity {
    return self.pActivityJSONDictionary;
}

- (NSDictionary*)nextProjectActivity {
    
    if(self.index < [self.pActivitiesJSONArray count]){
        self.pActivityJSONDictionary = [self.pActivitiesJSONArray objectAtIndex:self.index];
        self.index++;
        return self.pActivityJSONDictionary;
    }
    
    return nil;
}

- (NSDictionary*)firstProjectActivity {
    self.index = 0;
    if(self.index < [self.pActivitiesJSONArray count])
        return [self.pActivitiesJSONArray objectAtIndex:self.index];
    return nil;
}
- (int) getActivityCount {
    return (int)[self.pActivitiesJSONArray count];
}

- (BOOL) hasNext {
    return (self.index < [self.pActivitiesJSONArray count]);
}

- (int) getProjectActivityCount {
    return (int)[self.pActivitiesJSONArray count];
}

@end
