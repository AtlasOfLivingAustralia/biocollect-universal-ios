//
//  SightingForm.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 1/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FXForms.h"
#import <MapKit/MapKit.h>
#import "Species.h"

@interface SightingForm: NSObject<FXForm, NSCoding>
// Animal
@property (nonatomic, strong) Species *animal;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *visibleSign;
@property (nonatomic, strong) NSString *durationSign;
@property (nonatomic, strong) NSString *age;

- (UIImage *) getImage;
@end
