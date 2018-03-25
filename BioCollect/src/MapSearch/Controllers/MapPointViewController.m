//
//  MapPointViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 2/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

//
//  HomeViewController.m
//  MapView
//
//  Created by Roman Efimov on 10/4/12.
//  Copyright (c) 2012 Roman Efimov. All rights reserved.
//

#import "MapPointViewController.h"
#import "BookmarksViewController.h"
#import "Annotation.h"
#import "DetailsViewController.h"
#import "AFJSONRequestOperation.h"
#import "Storage.h"
#import "SpeciesGroupTableViewController.h"
#import "RKDropdownAlert.h"
#import "GAAppDelegate.h"

@interface MapPointViewController ()
@property (nonatomic, strong) CLLocation *lastKnownGPSLocation;
@end

@implementation MapPointViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height -  44)];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.mapType = MKMapTypeHybrid;
    [self.view addSubview:_mapView];
    
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [self.view addSubview:_toolBar];
    _toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    UIImage *image = [UIImage imageNamed: @"icon_marker"];
    UIBarButtonItem *mapButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:Nil target:self action:@selector(updatePinLocation)];
    UIBarButtonItem *spacing = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Standard", @"Satellite", @"Hybrid"]];
    segmentedControl.selectedSegmentIndex = 2;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self
                         action:@selector(segmentedControlChanged:)
               forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentedButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    
    _toolBar.items = @[mapButtonItem, spacing, segmentedButton, spacing];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    _annotations = [[NSMutableArray alloc] init];
    _droppedAnnotations = [[NSMutableArray alloc] init];
    
    // Initialise location manager
    // Track user location.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    
    if (self.field.value)
    {
        // Default map value
        //set start location
        self.mapView.centerCoordinate = ((CLLocation *)self.field.value).coordinate;
        [self showPinCoordinate:self.mapView.centerCoordinate];
        
        // enable done button if field value is present
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)zoomToAnnotationsBounds:(NSArray *)annotations
{
    CLLocationDegrees minLatitude = DBL_MAX;
    CLLocationDegrees maxLatitude = -DBL_MAX;
    CLLocationDegrees minLongitude = DBL_MAX;
    CLLocationDegrees maxLongitude = -DBL_MAX;
    
    for (Annotation *annotation in annotations) {
        double annotationLat = annotation.coordinate.latitude;
        double annotationLong = annotation.coordinate.longitude;
        if (annotationLat == 0 && annotationLong == 0) continue;
        minLatitude = fmin(annotationLat, minLatitude);
        maxLatitude = fmax(annotationLat, maxLatitude);
        minLongitude = fmin(annotationLong, minLongitude);
        maxLongitude = fmax(annotationLong, maxLongitude);
    }
    
    // See function below
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
    
    // If your markers were 40 in height and 20 in width, this would zoom the map to fit them perfectly. Note that there is a bug in mkmapview's set region which means it will snap the map to the nearest whole zoom level, so you will rarely get a perfect fit. But this will ensure a minimum padding.
    UIEdgeInsets mapPadding = UIEdgeInsetsMake(40.0, 10.0, 40.0, 10.0);
    CLLocationCoordinate2D relativeFromCoord = [self.mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.mapView];
    
    // Calculate the additional lat/long required at the current zoom level to add the padding
    CLLocationCoordinate2D topCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.top) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D rightCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.right) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D bottomCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.bottom) toCoordinateFromView:self.mapView];
    CLLocationCoordinate2D leftCoord = [self.mapView convertPoint:CGPointMake(0, mapPadding.left) toCoordinateFromView:self.mapView];
    
    double latitudeSpanToBeAddedToTop = relativeFromCoord.latitude - topCoord.latitude;
    double longitudeSpanToBeAddedToRight = relativeFromCoord.latitude - rightCoord.latitude;
    double latitudeSpanToBeAddedToBottom = relativeFromCoord.latitude - bottomCoord.latitude;
    double longitudeSpanToBeAddedToLeft = relativeFromCoord.latitude - leftCoord.latitude;
    
    maxLatitude = maxLatitude + latitudeSpanToBeAddedToTop;
    minLatitude = minLatitude - latitudeSpanToBeAddedToBottom;
    
    maxLongitude = maxLongitude + longitudeSpanToBeAddedToRight;
    minLongitude = minLongitude - longitudeSpanToBeAddedToLeft;
    
    [self setMapRegionForMinLat:minLatitude minLong:minLongitude maxLat:maxLatitude maxLong:maxLongitude];
}

- (void)setMapRegionForMinLat:(double)minLatitude minLong:(double)minLongitude maxLat:(double)maxLatitude maxLong:(double)maxLongitude
{
    MKCoordinateRegion region;
    region.center.latitude = (minLatitude + maxLatitude) / 2;
    region.center.longitude = (minLongitude + maxLongitude) / 2;
    region.span.latitudeDelta = (maxLatitude - minLatitude);
    region.span.longitudeDelta = (maxLongitude - minLongitude);
    
    if (region.span.latitudeDelta < 0.019863)
        region.span.latitudeDelta = 0.019863;
    
    if (region.span.longitudeDelta < 0.019863)
        region.span.longitudeDelta = 0.019863;
    
    [_mapView setRegion:region animated:NO];
}

#pragma mark -
#pragma mark Button actions

- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    _mapView.mapType = sender.selectedSegmentIndex;
}

- (void)showPinCoordinate:(CLLocationCoordinate2D)coordinate
{
    _hasPin = YES;
    [_mapView removeAnnotations:_droppedAnnotations];
    [_droppedAnnotations removeAllObjects];
    
    Annotation *annotation = [[Annotation alloc] init];
    annotation.placemark = nil;
    annotation.tag = 1;
    annotation.coordinate = coordinate;
    annotation.title = @"Animal sighted";
    [self.mapView addAnnotation:annotation];
    [_droppedAnnotations addObject:annotation];
    
    [self zoomToAnnotationsBounds:_droppedAnnotations];
}

#pragma mark -
#pragma mark MKMapViewDelegate


// MKMapViewDelegate Methods
- (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    // Check authorization status (with class method)
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // User has never been asked to decide on location authorization
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Requesting when in use auth");
        [_locationManager requestWhenInUseAuthorization];
    }
    // User has denied location use (either for this app or for all apps
    else if (status == kCLAuthorizationStatusDenied) {
        NSLog(@"Location services denied");
        // Alert the user and send them to the settings to turn on location
        [_locationManager requestWhenInUseAuthorization];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *newLocation = [locations lastObject];
    if (newLocation == nil) {
        //can happen if still waiting for user permission
        return;
    }
    if (!CLLocationCoordinate2DIsValid(newLocation.coordinate)) {
        //can happen if just resumed from some time in the background
        return;
    }
    
    _lastKnownGPSLocation = newLocation;
    [self initialiseFieldValueWithLocation];
}


-(void) setFormValue: (CLLocation *)location {
    CLLocation *newLocation = location;
    if(newLocation == nil) {
        return;
    }
    
    // Set default locatiom.
    self.clLocation = newLocation;
    self.field.value = newLocation;
    self.title = [NSString stringWithFormat:@"%0.3f, %0.3f", newLocation.coordinate.latitude, newLocation.coordinate.longitude];
    
    [self enableNavigationButton];
}

- (void)updatePinLocation {
    [self showPinCoordinate: _lastKnownGPSLocation.coordinate];
    [self setFormValue: _lastKnownGPSLocation];
}

- (void) initialiseFieldValueWithLocation {
    if(self.field.value == Nil){
        [self updatePinLocation];
    }
}

- (void) done {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) enableNavigationButton {
    if (!self.navigationItem.rightBarButtonItem.enabled) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

@end

