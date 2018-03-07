//
//  TrackMetadataViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 26/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "TrackMetadataViewController.h"
#import "MetadataForm.h"

@implementation TrackMetadataViewController
- (instancetype) init{
    self = [super init];
    
    MetadataForm *form = [[MetadataForm alloc] init];
    self.formController.form = form;
    
    return self;
}
@end
