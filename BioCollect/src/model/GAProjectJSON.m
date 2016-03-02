//
//  GAProjectJSON.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GAProjectJSON.h"

@interface GAProjectJSON ()

@property (strong, nonatomic) NSMutableArray *projectJSONArray;
@property (assign, nonatomic) int index;
@property (assign, nonatomic) BOOL hasNext;
@property (strong, nonatomic) NSDictionary *projectJSONDictionary;

@end

@implementation GAProjectJSON
#define kProject        @"project"
#define kProjectId      @"projectId"
#define kProjectName    @"name"
#define kLastUpdated    @"lastUpdated"
#define kDescription    @"description"

@synthesize projectJSONArray;

- (id)initWithData:(NSData *)jsonData {
    
    // Call the superclass's designated initializer
    self = [super init];
    
    if(self) {
        NSError *jsonParsingError = nil;
        self.projectJSONArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParsingError];
        self.projectJSONDictionary = [[NSDictionary alloc] init];
        self.index = 0;
    }
    return self;
}

- (NSDictionary*)gellCurrentProject {
    return self.projectJSONDictionary;
}

- (NSDictionary*)nextProject {
    if(self.index <[self.projectJSONArray count]){
        self.projectJSONDictionary = [[self.projectJSONArray objectAtIndex:self.index] objectForKey:kProject];
        self.index++;
        return self.projectJSONDictionary;
    }
    
    return nil;
}

- (NSDictionary*)firstProject {
    self.index = 0;
    if(self.index < [self.projectJSONArray count]){
        self.projectJSONDictionary = [[self.projectJSONArray objectAtIndex:self.index] objectForKey:kProject];
        return self.projectJSONDictionary;
    }

    return nil;
}
- (int) getProjectCount {
    return (int)[self.projectJSONArray count];
}

- (BOOL) hasNext {
    return (self.index < [self.projectJSONArray count]);
}

- (NSString *) projectId {
    return [self.projectJSONDictionary objectForKey:kProjectId];
}

- (NSString *) projectName {
    return [self.projectJSONDictionary objectForKey:kProjectName];
}

- (NSString *) lastUpdatedDate {
    return [self.projectJSONDictionary objectForKey:kLastUpdated];
}

- (NSString *) description {
    return [self.projectJSONDictionary objectForKey:kDescription];
}

@end
