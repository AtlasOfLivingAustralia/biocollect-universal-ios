//
//  GAProjectJSON.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAProjectJSON : NSObject

- (id) initWithData:(NSData *)jsonData;

- (NSString *) projectId;
- (NSString *) projectName;
- (NSString *) lastUpdatedDate;
- (NSString *) description;
- (NSDictionary*) gellCurrentProject;
- (NSDictionary*)nextProject;
- (NSDictionary*)firstProject;
- (int) getProjectCount;
- (BOOL) hasNext;
@end
