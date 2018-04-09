//
//  RouteViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 13/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <MapKit/MapKit.h>
#import "SightingForm.h"

@interface RouteViewController : UIViewController <MKMapViewDelegate> {
    MKPolyline * _polyline;
    NSMutableArray * _annotations;
    NSTimer* _timer;
}

@property (strong, nonatomic) NSMutableArray *route;
@property (strong, nonatomic) NSMutableArray *animals;
@property (strong, nonatomic) MKMapView *mapView;

- (instancetype) initWithRoute: (NSMutableArray *) route andAnimals: (NSMutableArray *) animals;
- (void) removeAnnotation: (SightingForm *) sighting;
- (void) addAnnotations;
- (void) stopNotification;
- (void) zoomToRoute;
@end
