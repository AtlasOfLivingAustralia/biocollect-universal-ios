//
//  MetadataForm.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 27/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FXForms.h"

@interface MetadataForm: NSObject<FXForm, CLLocationManagerDelegate, NSCoding> {
    CLLocationManager * _locationManager;
}
// Tracker details
@property (nonatomic, strong) NSString *organisationName;
@property (nonatomic, strong) NSString *leadTracker;
@property (nonatomic, strong) NSString *otherTrackers;
@property (nonatomic, strong) NSString *comments;

// Tracking details
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSString *surveyType;
@property (nonatomic, strong) NSString *surveyChoice;

// Country
@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSString *countryType;
@property (nonatomic, strong) NSString *vegetationType;
@property (nonatomic, strong) NSArray *foodPlant;
@property (nonatomic, strong) NSString *timeSinceFire;
@property (nonatomic, strong) UIImage *countryPhoto;

// Trackability
@property (nonatomic, strong) NSString *clearGround;
@property (nonatomic, strong) NSString *disturbance;
@property (nonatomic, strong) NSString *groundSoftness;
@property (nonatomic, strong) NSString *weather;

// Animals
@property (nonatomic, strong) NSMutableArray *animals;

// Route
@property (nonatomic, strong) NSMutableArray<CLLocation *> *route;

- (void) startRecordingLocation;
- (void) stopRecordingLocation;
- (BOOL) isValid;
- (NSMutableDictionary *) transformDataToUploadableFormat;
@end
