//
//  MapPointViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 2/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKCircleView.h>
#import <CoreLocation/CoreLocation.h>
#import "SettingsViewController.h"
#import "BookmarksViewController.h"
#import "FXForms.h"

@interface MapPointViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate> {
    UINavigationBar *_navBar;
    UIToolbar *_toolBar;
    
    NSMutableArray *_annotations;
    NSMutableArray *_droppedAnnotations;
    
    BOOL _hasPin;
    
    CLLocationManager *_locationManager;
}

@property (nonatomic, strong) FXFormField *field;
@property (nonatomic, strong) CLLocation *clLocation;
@property (strong, nonatomic) MKMapView *mapView;
@end

