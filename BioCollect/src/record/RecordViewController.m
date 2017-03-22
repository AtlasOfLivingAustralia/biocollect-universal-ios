//
//  RecordViewController.m
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 19/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "RecordViewController.h"
#import "RecordForm.h"
#import "GAAppDelegate.h"
#import "MRProgressOverlayView.h"


@implementation RecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        //set up form
        
        RecordForm *record = [[RecordForm alloc] init];
        record.surveyDate = [NSDate date];
        record.howManySpecies = 1;
        record.photoDate = [NSDate date];
    
        // location manager
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        record.location = [self.locationManager location];
        
        self.formController.form = record;
        
        self.speciesSearchVC = [[SpeciesSearchTableViewController alloc] initWithNibName:@"SpeciesSearchTableViewController" bundle:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSpeciesHandler:) name:@"SPECIESSEARCH SELECTED" object:nil];
        
    }
    return self;
}

//- (void) viewDidLoad{
//}

//these are action methods for our forms
//the methods escalate through the responder chain until
//they reach the AppDelegate

- (void)submitLoginForm
{
    RecordForm *record = self.formController.form;
    NSMutableDictionary *formValidity = [record isValid];
    NSNumber *valid = formValidity[@"valid"];
    if( [valid isEqualToNumber:[NSNumber numberWithInt: 0]] ) {
        [[[UIAlertView alloc] initWithTitle: @"Form not valid"
                                    message:[formValidity valueForKey:@"message"]
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];

    } else {
        [self createRecord:record];
    }
    //now we can display a form value in our alert
}

- (void) createRecord: (RecordForm *) record {
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // set animation to show record creation is in progress
            [MRProgressOverlayView showOverlayAddedTo:appDelegate.window title:@"Processing.." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *status = [[appDelegate restCall] createRecord: record];
        NSNumber *statusCode = status[@"status"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:NO];
            
            if([statusCode isEqualToNumber: [NSNumber numberWithInt: 200]]){
                record.activityId = status[@"activityId"];
                [[[UIAlertView alloc] initWithTitle:@"Successfully submitted."
                                            message:status[@"message"]
                                           delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Submission failed"
                                            message:status[@"message"]
                                           delegate: self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
        });
    });
}

- (void)showSpeciesSearchTableViewController: (UITableViewCell *) sender {
    self.recordCell = sender;
    [self.navigationController pushViewController:self.speciesSearchVC animated:YES];
}

- (void)saveSpeciesHandler: (NSNotification *) notice{
    NSDictionary *selection = (NSDictionary *)[notice object];
    RecordForm *record = self.formController.form;
    [record setScientificName:selection[@"name"] commonName:selection[@"commonName"] guid:selection[@"guid"]];
    
    self.recordCell.detailTextLabel.text = record.speciesDisplayName;
}

-(void) getLocation{
    if(self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
        
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    RecordForm *record = self.formController.form;
    if (record.location == nil) {
        record.location = currentLocation;
    }
}

- (void) setRecord: (RecordForm *) record{
    self.formController.form = record;
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
