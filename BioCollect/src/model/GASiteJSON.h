//
//  GASiteJSON.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 12/05/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GASiteJSON : NSObject
- (id) initWithData:(NSData *)jsonData;

- (NSString *) siteId;
- (NSString *) name;
- (NSString *) description;
- (NSString *) latitude;
- (NSString *) longitude;

- (NSDictionary*)getSites;
- (NSDictionary*)nextSite;
- (NSDictionary*)firstSite;
- (int) getSiteCount;
- (BOOL) hasNext;
@end
