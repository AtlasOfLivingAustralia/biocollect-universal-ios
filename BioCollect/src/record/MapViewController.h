//
//  MapViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 21/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "FXForms.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <FXFormFieldViewController, MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) FXFormField *field;
@end
