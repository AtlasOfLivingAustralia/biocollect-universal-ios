//
//  ProjectActivityJSON.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 10/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectActivitiesJSON : NSObject

- (id)initWithData:(NSData *)jsonData;
-(NSString *) projectActivityId;
-(NSString *) projectId;
-(NSString *) name;
-(NSString *) description;
-(NSString *) published;


- (NSDictionary*)getCurrentProjectActivity;
- (NSDictionary*)nextProjectActivity;
- (NSDictionary*)firstProjectActivity;
- (int) getProjectActivityCount;
- (BOOL) hasNext;

@end
