//
//  UtilService.h
//  BioCollect
//
//  Created by Varghese, Temi (PI, Black Mountain) on 9/4/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <MapKit/MapKit.h>

@interface UtilService : NSObject
- (NSString *) generateFileName: (NSString*) extension;
- (CLLocation*) locationWithBearing:(float)bearing distance:(float)distanceMeters fromLocation:(CLLocationCoordinate2D)origin;
@end
