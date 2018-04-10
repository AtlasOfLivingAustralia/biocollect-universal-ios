//
//  UtilService.m
//  BioCollect
//
//  Created by Varghese, Temi (PI, Black Mountain) on 9/4/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilService.h"
#import <MapKit/MapKit.h>

@implementation UtilService
- (instancetype) init {
    self = [super init];
    return self;
}

- (NSString *) generateFileName: (NSString*) extension {
    extension = extension ? extension : @"jpg";
    NSString *guid = [[NSUUID new] UUIDString];
    NSString* fileName = [[NSString alloc] initWithFormat: @"%@.%@", guid, extension];
    return fileName;
}

/*
 * https://stackoverflow.com/questions/7278094/moving-a-cllocation-by-x-meters
 */
- (CLLocation*) locationWithBearing:(float)bearing distance:(float)distanceMeters fromLocation:(CLLocationCoordinate2D)origin {
    const double distRadians = distanceMeters / (6372797.6); // earth radius in meters
    
    float lat1 = origin.latitude * M_PI / 180;
    float lon1 = origin.longitude * M_PI / 180;
    
    float lat2 = asin( sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearing));
    float lon2 = lon1 + atan2( sin(bearing) * sin(distRadians) * cos(lat1),
                              cos(distRadians) - sin(lat1) * sin(lat2) );
    lat2 = lat2 * 180 / M_PI;
    lon2 = lon2 * 180 / M_PI;
    
    return [[CLLocation alloc] initWithLatitude:lat2 longitude: lon2];
}

@end
