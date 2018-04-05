//
//  SightingViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 1/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "SightingViewController.h"
#import "SightingForm.h"
#import "GAAppDelegate.h"

@implementation SightingViewController
- (instancetype) init {
    self = [super init];
    
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    
    self.title = [locale get:@"sighting.viewcontroller.title"];
    
    SightingForm *form = [[SightingForm alloc] init];
    self.formController.form = form;
    
    [self initLocationManager];
    return self;
}

- (instancetype) initWithForm: (SightingForm *) form {
    self = [super init];
    
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    
    self.title = [locale get:@"sighting.viewcontroller.title"];
    self.formController.form = form;
    
    [self initLocationManager];
    return self;
}

- (void) initLocationManager {
    // Initialise location manager
    // Track user location.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];
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
    
    SightingForm *form = self.formController.form;
    if (form && form.location == nil) {
        form.location = newLocation;
        [self.formController.tableView  reloadData];
        [_locationManager stopUpdatingLocation];
    }
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle: [locale get: @"sighting.save"]
                                                                  style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = barButton;

}

- (void) save {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SPECIES-SIGHTING-SAVED" object:self.formController.form];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
