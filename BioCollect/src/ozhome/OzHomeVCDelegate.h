//
//  OzHomeVCDelegate.h
//  Oz Atlas

@import Foundation;

#import "MGSpotyViewControllerDelegate.h"
#import <MapKit/MapKit.h>

@interface OzHomeVCDelegate : NSObject <MGSpotyViewControllerDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
//Location details [lat, lng, radius]
@property (strong, nonatomic) CLLocation *curentLocation;
@end
