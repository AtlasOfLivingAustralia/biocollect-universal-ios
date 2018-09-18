//
//  OzHomeVCDelegate.h
//  Oz Atlas

@import Foundation;

#import "MGSpotyViewControllerDelegate.h"
#import <MapKit/MapKit.h>
#import "JGActionSheet.h"

@interface OzHomeVCDelegate : NSObject <JGActionSheetDelegate, MGSpotyViewControllerDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
//Location details [lat, lng, radius]
@property (strong, nonatomic) CLLocation *curentLocation;
@property (strong, nonatomic) MGSpotyViewController* spotyViewController;
@end
