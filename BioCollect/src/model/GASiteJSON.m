//
//  GASiteJSON.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 12/05/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GASiteJSON.h"

@interface GASiteJSON ()

@property (strong, nonatomic) NSMutableArray *arrayJSON;
@property (assign, nonatomic) int index;
@property (assign, nonatomic) BOOL hasNext;
@property (strong, nonatomic) NSDictionary *dictionaryJSON;

@end

#define kSite @"sites"

#define kName @"name"
#define kSiteId @"siteId"
#define kDescription @"description"
#define kLatitude @"centroidLat"
#define kLongitude @"centroidLon"

@implementation GASiteJSON

@synthesize arrayJSON, dictionaryJSON;


- (id)initWithData:(NSData *)jsonData {
    
    // Call the superclass's designated initializer
    self = [super init];
    
    if(self) {
        NSError *jsonParsingError = nil;
        self.arrayJSON = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonParsingError] objectForKey:kSite];
        [self.arrayJSON removeObjectIdenticalTo:[NSNull null]];
        
        self.dictionaryJSON = [[NSDictionary alloc] init];
        self.index = 0;
    }
    return self;
}

- (NSDictionary*)getSites {
    return self.dictionaryJSON;
}

- (NSDictionary*)nextSite {
    if(self.index <[self.arrayJSON count]){
        self.dictionaryJSON = [self.arrayJSON objectAtIndex:self.index];
        self.index++;
        return self.dictionaryJSON;
    }
    return nil;
}

- (NSDictionary*)firstSite {
    self.index = 0;
    if(self.index < [self.arrayJSON count]){
        self.dictionaryJSON = [self.arrayJSON objectAtIndex:self.index];
        return self.dictionaryJSON;
    }
    
    return nil;
}
- (int) getSiteCount {
    return (int)[self.arrayJSON count];
}

- (BOOL) hasNext {
    return (self.index < [self.arrayJSON count]);
}

- (NSString *) siteId {
    return [self.dictionaryJSON objectForKey:kSiteId];
}

- (NSString *) name {
    return [self.dictionaryJSON objectForKey:kName];
}

- (NSString *) latitude {
     return [[NSString alloc] initWithFormat:@"%@",[self.dictionaryJSON objectForKey:kLatitude]];
}

- (NSString *) longitude {
    return [[NSString alloc] initWithFormat:@"%@",[self.dictionaryJSON objectForKey:kLongitude]];
}

- (NSString *) description {
    return [self.dictionaryJSON objectForKey:kDescription];
}

@end
