//
//  GAProjectJSON.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAProjectJSON : NSObject

- (id) initWithData:(NSData *)jsonData;
- (id) initWithArray:(NSMutableArray *)projects;

- (NSString *) projectId;
- (NSString *) projectName;
- (NSString *) lastUpdatedDate;
- (NSString *) description;
- (NSString *) urlImage;
- (NSString *) urlWeb;
- (NSDictionary*) gellCurrentProject;
- (NSDictionary*)nextProject;
- (NSDictionary*)firstProject;
- (BOOL) isExternal;
- (int) getProjectCount;
- (BOOL) hasNext;
@end
