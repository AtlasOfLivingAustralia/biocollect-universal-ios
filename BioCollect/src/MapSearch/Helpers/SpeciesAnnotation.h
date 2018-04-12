//
//  SpeciesAnnotation.h
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 15/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <MapKit/MapKit.h>
#import "SightingForm.h"

@interface SpeciesAnnotation: MKPointAnnotation
@property (nonatomic, strong) NSMutableArray<SightingForm*> *forms;
@end
