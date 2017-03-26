//
//  RecordViewController.h
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 19/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "FXForms.h"
#import "SpeciesSearchTableViewController.h"
#import <MapKit/MapKit.h>
#import "RecordForm.h"

@interface RecordViewController : FXFormViewController<CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) SpeciesSearchTableViewController *speciesSearchVC;
@property (nonatomic, strong) UITableViewCell<FXFormFieldCell> *recordCell;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void) setRecord: (RecordForm *) record;
@end
