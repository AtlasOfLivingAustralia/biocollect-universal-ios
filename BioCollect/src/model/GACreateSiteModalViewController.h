//
//  GACreateSiteModalViewController.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 16/05/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GASite.h"
#import <CoreLocation/CLLocation.h>

@protocol GACreateSiteModalDelegate
    - (void)siteCreated : (GASite *) site;
@end

@interface GACreateSiteModalViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate> {
    id delgate;
}

@property (strong, nonatomic) IBOutlet UILabel *createSiteLabel;
@property (strong, nonatomic) IBOutlet UILabel *siteNamelabel;
@property (strong, nonatomic) IBOutlet UILabel *siteDesLabel;
@property (strong, nonatomic) IBOutlet UITextField *siteNameTxt;
@property (strong, nonatomic) IBOutlet UITextView *siteDescriptionTxt;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *createBtn;
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) IBOutlet UILabel *coordinatesLabel;


@property (strong, nonatomic) GASite *site;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)onClickCancel:(id)sender;
- (IBAction)onClickCreate:(id)sender;
- (void) setDelegate:(id)newDelegate;

@end
