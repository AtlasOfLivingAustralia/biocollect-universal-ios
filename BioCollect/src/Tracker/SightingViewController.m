//
//  SightingViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 1/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "SightingViewController.h"
#import "SightingForm.h"

@implementation SightingViewController
- (instancetype) init{
    self = [super init];
    
    SightingForm *form = [[SightingForm alloc] init];
    self.formController.form = form;
    
    return self;
}
@end
