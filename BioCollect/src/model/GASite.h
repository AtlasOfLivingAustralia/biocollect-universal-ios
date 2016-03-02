//
//  GASite.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 12/05/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GASite : NSObject {
    int _id;
    NSString *siteId;
    NSString *projectId;
    NSString *name;
    NSString *description;
    NSString *latitude;
    NSString *longitude;
    NSString *permSiteId;
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
