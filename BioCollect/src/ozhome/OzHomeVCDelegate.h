//
//  OzHomeVCDelegate.h
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 14/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

@import Foundation;

#import "MGSpotyViewControllerDelegate.h"
#import <MapKit/MapKit.h>

@interface OzHomeVCDelegate : NSObject <MGSpotyViewControllerDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
//Location details [lat, lng, radius]
@property (strong, nonatomic) CLLocation *curentLocation;
@end
