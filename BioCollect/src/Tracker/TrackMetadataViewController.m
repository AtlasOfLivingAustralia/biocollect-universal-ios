//
//  TrackMetadataViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 26/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "TrackMetadataViewController.h"
#import "MetadataForm.h"
#import "GAAppDelegate.h"

@implementation TrackMetadataViewController
- (instancetype) init {
    self = [super init];
    
    MetadataForm *form = [[MetadataForm alloc] init];
    [form startRecordingLocation];
    self.formController.form = form;
    showModal = NO;
    
    return self;
}

- (instancetype) initWithForm: (MetadataForm*) form {
    self = [super init];
 
    self.formController.form = form;
    showModal = YES;
        
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
}
@end
