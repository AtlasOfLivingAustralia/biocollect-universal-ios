//
//  GACreateSiteModalViewController.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 16/05/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GACreateSiteModalViewController.h"
#import "GAAppDelegate.h"
#import "GASettings.h"

@interface GACreateSiteModalViewController ()

@end

@implementation GACreateSiteModalViewController

@synthesize siteDescriptionTxt,siteNamelabel,siteDesLabel,siteNameTxt,cancelBtn,createBtn,map,coordinatesLabel,site,createSiteLabel,locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        site = [[GASite alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.map.showsUserLocation = YES;
    self.map.mapType = MKMapTypeHybrid;
    self.map.zoomEnabled = true;
    self.map.delegate = self;
    site.latitude = @"0.0";
    site.longitude = @"0.0";
    coordinatesLabel.text = @"Loading GPS coordinates...";
    
    // Track user location.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }

    [locationManager startUpdatingLocation];
    [self performSelector:@selector(gpsTimeout:) withObject:nil afterDelay:120];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    /*  CLLocationManagerDelegate delegate to update new location. */
    site.latitude = [[NSString alloc] initWithFormat:@"%.6f",newLocation.coordinate.latitude];
    site.longitude = [[NSString alloc] initWithFormat:@"%.6f",newLocation.coordinate.longitude];
    NSString *displayStr = [[NSString alloc] initWithFormat:@"Latitude: %0.6f Longitude: %0.6f",
                            newLocation.coordinate.latitude,
                            newLocation.coordinate.longitude];

    coordinatesLabel.text = displayStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.005;
    mapRegion.span.longitudeDelta = 0.005;
    [mapView setRegion:mapRegion animated: YES];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {

}

- (IBAction)onClickCancel:(id)sender {
    [locationManager stopUpdatingLocation];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(gpsTimeout:) object:nil];
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)onClickCreate:(id)sender {
    site.name = siteNameTxt.text;
    site.description = siteDescriptionTxt.text;
    NSString *error = nil;
    site.name = [site.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    site.description = [site.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([site.name length] == 0 && [site.description length] == 0){
        error = @"Please enter Site Name and Site Description.";
    }
    else if([site.latitude isEqualToString:@"0.0"] && [site.longitude isEqualToString:@"0.0"]){
        error = @"Turn on Location Services to Allow \"Green Army\" to access your location";
    }

    if([error length] > 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:error
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    [GASettings setDataToSync:kDataToSyncTrue];
    site.siteId = [self GetUUID];
    site.permSiteId = @"";
    [delgate siteCreated:site];
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window.rootViewController dismissViewControllerAnimated:true completion:nil];
    [locationManager stopUpdatingLocation];
}
- (void) setDelegate:(id)newDelegate{
    delgate = newDelegate;
}

-(NSString *) GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    coordinatesLabel.text = @"Cannot determine GPS location";
    site.latitude = @"0.0";
    site.longitude = @"0.0";
    [coordinatesLabel setTextColor:[UIColor redColor]];
}

-(void) gpsTimeout : (id) object{
    if([site.latitude isEqualToString:@"0.0"] && [site.longitude isEqualToString:@"0.0"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Unable to determine your position. You will need to create your site in MERIT once you have Internet access."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Text field delegate handler.

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.siteNameTxt){
        [textField resignFirstResponder];
        [self.siteDescriptionTxt becomeFirstResponder];
    }
    return TRUE;
}
@end






























