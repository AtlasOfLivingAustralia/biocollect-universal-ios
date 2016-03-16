//
//  ProjectActivityJSON.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 10/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectActivityJSON : NSObject {
    int _id;
    NSString *projectActivityId;
    NSString *projectId;
    NSString *name;
    NSString *description;
}
@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString * siteId;
@property (nonatomic, strong) NSString * projectId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * distance; // distance between current location and activity location.
@property (nonatomic, strong) NSString * permSiteId; // distance between current location and activity location.

@end
