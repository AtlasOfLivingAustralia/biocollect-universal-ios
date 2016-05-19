//
//  GAProjectJSON.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
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
#define kUrlImage       @"urlImage"
#define kUrlWeb         @"urlWeb"
#define kIsExternal     @"isExternal"

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

- (id)initWithArray: (NSMutableArray *)projects {
    
    // Call the superclass's designated initializer
    self = [super init];
    
    if(self) {
        self.projectJSONArray =  [[NSMutableArray alloc] init];
        self.projectJSONArray = projects;
        self.projectJSONDictionary = [[NSDictionary alloc] init];
        self.index = 0;
    }
    return self;
}


- (NSDictionary*)gellCurrentProject {
    return self.projectJSONDictionary;
}

- (NSDictionary*)nextProject {
    if(self.index < [self.projectJSONArray count]){
        self.projectJSONDictionary = [self.projectJSONArray objectAtIndex:self.index];
        self.index++;
        return self.projectJSONDictionary;
    }
    
    return nil;
}

- (NSDictionary*)firstProject {
    self.index = 0;
    if(self.index < [self.projectJSONArray count]){
        self.projectJSONDictionary = [self.projectJSONArray objectAtIndex:self.index];
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

- (NSString *) urlImage {
    NSString *url = [self.projectJSONDictionary objectForKey:kUrlImage];
    
    if (url == (id)[NSNull null] || url.length == 0 ) {
      url = [[[NSBundle mainBundle] URLForResource:@"table-place-holder" withExtension:@"png"] absoluteString];
    }
    
    return url;
}

- (NSString *) urlWeb {
    return [self.projectJSONDictionary objectForKey:kUrlWeb];
}

- (BOOL) isExternal {
    return [[self.projectJSONDictionary objectForKey:kIsExternal] boolValue];
}

@end
