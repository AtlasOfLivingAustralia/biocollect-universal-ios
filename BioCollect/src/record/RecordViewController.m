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
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageSource.h>
#import "RKDropdownAlert.h"

@implementation RecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        //set up form
        RecordForm *record = [[RecordForm alloc] init];
        record.surveyDate = [NSDate date];
        record.howManySpecies = 1;
        record.confident = TRUE;
        record.uploaded = FALSE;
        record.photoDate = [NSDate date];
        
        // location manager
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        record.location = [self.locationManager location];
        
        self.formController.form = record;
        
        self.speciesSearchVC = [[SpeciesSearchTableViewController alloc] initWithNibName:@"SpeciesSearchTableViewController" bundle:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveSpeciesHandler:) name:@"SPECIESSEARCH SELECTED" object:nil];
        [self.formController.tableView setBackgroundColor:[UIColor blackColor]];
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
         [RKDropdownAlert title:@"ERROR" message:[formValidity valueForKey:@"message"] backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    } else {
        [self createRecord:record];
    }
    //now we can display a form value in our alert
}

- (void) createRecord: (RecordForm *) record {
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView showOverlayAddedTo:appDelegate.window title:@"Processing.." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Check internet and server status, if no internet connection then save the data on to disk.
        NSMutableDictionary *status;
        NSNumber *statusCode;
        BOOL notReachable = FALSE;
        if([[appDelegate restCall] notReachable]) {
            notReachable = TRUE;
            [[appDelegate restCall] saveRecordToDisk: record];
        } else {
            status = [[appDelegate restCall] createRecord: record];
            statusCode = status[@"status"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:NO];
            
            // Saved to local disk due
            if(notReachable) {
                [RKDropdownAlert title:@"Device offline" message:@"Record succesfully saved as Draft." backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
                [self.navigationController popViewControllerAnimated:YES];
            }
            else if([statusCode isEqualToNumber: [NSNumber numberWithInt: 200]]){
                record.activityId = status[@"activityId"];
                [appDelegate removeRecords: @[record]];
                [RKDropdownAlert title:@"Record successfully submitted!" message:@"" backgroundColor:[UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Record submission failed, try again later."
                                            message:status[@"message"]
                                           delegate: self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil] show];
            }
        });
    });
}


- (void)parseImageMetadata:(id<FXFormFieldCell>)cell {
    FXFormField *field = cell.field;
    UIImage *image = (UIImage *) cell.field.value;
    if(image != nil) {
        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
        CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpegData, NULL);
        CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
        NSLog(@"%@", imageMetaData);
        RecordForm *record = (RecordForm *)self.formController.form;
        record.photoTitle = @"iOS_IMAGE";
        self.formController.form = field.form;
        [self.formController.tableView reloadData];
    }
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

-(void) getLocation {
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
    //NSLog(@"didUpdateToLocation: %@", newLocation);
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

- (void) setRecordSpecies: (NSDictionary *) species {
    RecordForm *record = self.formController.form;
    [record setScientificName:species[@"name"] commonName:species[@"commonName"] guid:species[@"guid"]];
    self.recordCell.detailTextLabel.text = record.speciesDisplayName;
}
@end
