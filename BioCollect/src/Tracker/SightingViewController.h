//
//  SightingViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 1/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXForms.h"
#import "SightingForm.h"

@interface SightingViewController : FXFormViewController {
    BOOL isUpdate;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
- (instancetype) initWithForm: (SightingForm *) form;
@end
