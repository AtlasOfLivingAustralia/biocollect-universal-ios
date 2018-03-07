//
//  MetadataForm.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 27/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FXForms.h"

@interface MetadataForm: NSObject<FXForm>
// Tracker details
@property (nonatomic, copy) NSString *organisationName;
@property (nonatomic, copy) NSString *leadTracker;
@property (nonatomic, copy) NSString *otherTrackers;
@property (nonatomic, copy) NSString *comments;

// Tracking details
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, copy) NSString *surveyType;
@property (nonatomic, copy) NSString *surveyChoice;

// Country
@property (nonatomic, copy) NSString *countryName;
@property (nonatomic, copy) NSString *countryType;
@property (nonatomic, copy) NSString *vegetationType;
@property (nonatomic, copy) NSArray *foodPlant;
@property (nonatomic, copy) NSString *timeSinceFire;
@property (nonatomic, strong) UIImage *countryPhoto;

// Trackability
@property (nonatomic, copy) NSString *clearGround;
@property (nonatomic, copy) NSString *disturbance;
@property (nonatomic, copy) NSString *groundSoftness;
@property (nonatomic, copy) NSString *weather;
@end
