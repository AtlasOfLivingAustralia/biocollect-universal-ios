//
//  MetadataForm.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 27/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MetadataForm.h"
#import "GAAppDelegate.h"
#import "GASettings.h"
#import "Species.h"
#import "SightingForm.h"
#define colour @"#F1582B"
#define MIN_DISTANCE_BETWEEN_LOCATION 40

@implementation MetadataForm

- (instancetype)init{
    self = [super init];
    
    _animals = [NSMutableArray new];
    _route = [NSMutableArray new];
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    
    self.organisationName = [aDecoder decodeObjectForKey: @"organisationName"];
    self.leadTracker = [aDecoder decodeObjectForKey: @"leadTracker"];
    self.otherTrackers = [aDecoder decodeObjectForKey: @"otherTrackers"];
    self.comments = [aDecoder decodeObjectForKey: @"comments"];
    
    self.date = [aDecoder decodeObjectForKey: @"date"];
    self.startTime = [aDecoder decodeObjectForKey: @"startTime"];
    self.endTime = [aDecoder decodeObjectForKey: @"endTime"];
    self.surveyType = [aDecoder decodeObjectForKey: @"surveyType"];
    self.surveyChoice = [aDecoder decodeObjectForKey: @"surveyChoice"];
    
    self.countryName = [aDecoder decodeObjectForKey: @"countryName"];
    self.countryType = [aDecoder decodeObjectForKey: @"countryType"];
    self.countryPhoto = [aDecoder decodeObjectForKey: @"countryPhoto"];
    self.vegetationType = [aDecoder decodeObjectForKey: @"vegetationType"];
    self.foodPlant = [aDecoder decodeObjectForKey: @"foodPlant"];
    self.timeSinceFire = [aDecoder decodeObjectForKey: @"timeSinceFire"];
    
    self.clearGround = [aDecoder decodeObjectForKey: @"clearGround"];
    self.disturbance = [aDecoder decodeObjectForKey: @"disturbance"];
    self.groundSoftness = [aDecoder decodeObjectForKey: @"groundSoftness"];
    self.weather = [aDecoder decodeObjectForKey: @"weather"];
    
    self.animals = [aDecoder decodeObjectForKey: @"animals"];
    self.route = [aDecoder decodeObjectForKey: @"route"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.organisationName forKey: @"organisationName"];
    [aCoder encodeObject:self.leadTracker forKey: @"leadTracker"];
    [aCoder encodeObject:self.otherTrackers forKey: @"otherTrackers"];
    [aCoder encodeObject:self.comments forKey: @"comments"];
    
    [aCoder encodeObject:self.date forKey: @"date"];
    [aCoder encodeObject:self.startTime forKey: @"startTime"];
    [aCoder encodeObject:self.endTime forKey: @"endTime"];
    [aCoder encodeObject:self.surveyType forKey: @"surveyType"];
    [aCoder encodeObject:self.surveyChoice forKey: @"surveyChoice"];
    
    [aCoder encodeObject:self.countryName forKey: @"countryName"];
    [aCoder encodeObject:self.countryType forKey: @"countryType"];
    [aCoder encodeObject:self.countryPhoto forKey: @"countryPhoto"];
    [aCoder encodeObject:self.vegetationType forKey: @"vegetationType"];
    [aCoder encodeObject:self.foodPlant forKey: @"foodPlant"];
    [aCoder encodeObject:self.timeSinceFire forKey: @"timeSinceFire"];
    
    [aCoder encodeObject:self.clearGround forKey: @"clearGround"];
    [aCoder encodeObject:self.disturbance forKey: @"disturbance"];
    [aCoder encodeObject:self.groundSoftness forKey: @"groundSoftness"];
    [aCoder encodeObject:self.weather forKey: @"weather"];
    
    [aCoder encodeObject:self.animals forKey: @"animals"];
    [aCoder encodeObject:self.route forKey: @"route"];
}

# pragma mark - Helper functions
-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void) startRecordingLocation {
    [_locationManager startUpdatingLocation];
}

- (void) stopRecordingLocation {
    [_locationManager stopUpdatingLocation];
}

- (NSArray*) fields {
    GAAppDelegate *appDelegate = (GAAppDelegate *) [[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    UIColor* uiColour = [self colorFromHexString: colour];
    NSString* fullName = [GASettings getFullName];
    Project* project = [appDelegate.projectService loadSelectedProject];
    NSString* organisationName = @"";
    if (project != nil){
        organisationName = project.name;
    }
    
    return @[
             // Tracker information
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"organisationName", FXFormFieldTitle:[locale get: @"trackmetadata.organisationname"], FXFormFieldHeader: [locale get: @"trackmetadata.trackerinfo"], FXFormFieldDefaultValue: organisationName},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"leadTracker", FXFormFieldTitle:[locale get: @"trackmetadata.leadTracker"], FXFormFieldDefaultValue: fullName},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"otherTrackers", FXFormFieldTitle:[locale get: @"trackmetadata.otherTrackers"], FXFormFieldType: FXFormFieldTypeLongText},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"comments", FXFormFieldTitle: [locale get: @"trackmetadata.comments"], FXFormFieldType: FXFormFieldTypeLongText},
             
             // Tracking information
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"date", FXFormFieldTitle:[locale get: @"trackmetadata.eventdate"], FXFormFieldHeader: [locale get: @"trackmetadata.trackinginfo"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"startTime", FXFormFieldTitle:[locale get: @"trackmetadata.eventstarttime"], FXFormFieldType: FXFormFieldTypeTime},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"endTime", FXFormFieldTitle:[locale get: @"trackmetadata.eventendtime"], FXFormFieldType: FXFormFieldTypeTime},
             @{@"textLabel.color": uiColour,FXFormFieldTitle: [locale get: @"trackmetadata.surveytype"], FXFormFieldKey: @"surveyType", FXFormFieldOptions: @[@"Incidental", @"KJ Mankarr Survey", @"Road", @"Trackplot 2ha 100m x 200m"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour,FXFormFieldTitle: [locale get: @"trackmetadata.surveychoice"], FXFormFieldKey: @"surveyChoice", FXFormFieldOptions: @[@"Anywhere", @"Targeted"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             
             // Country
             @{@"textLabel.color": uiColour, FXFormFieldKey: @"countryName", FXFormFieldTitle:[locale get: @"trackmetadata.countryname"], FXFormFieldHeader: [locale get: @"trackmetadata.country"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"countryType", FXFormFieldTitle: [locale get: @"trackmetadata.countrytype"], FXFormFieldOptions: @[@"Calcrete/Limestone rise",  @"Claypan", @"Creek line", @"Drainage line", @"Laterite (red rocks)", @"Rocky range",  @"Salt lake", @"Sand dune", @"Sand plain", @"Waterhole", @"Other"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"countryPhoto", FXFormFieldTitle: [locale get: @"trackmetadata.countryphoto"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"vegetationType", FXFormFieldTitle: [locale get: @"trackmetadata.vegetationtype"], FXFormFieldOptions: @[@"Buffel grassland", @"Dense woodland", @"Open grassland", @"Open woodland",  @"Shrubland", @"Spinifex grassland",  @"Other"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"foodPlant", FXFormFieldTitle: [locale get: @"trackmetadata.foodplant"], FXFormFieldOptions: @[@"Bush fruits", @"Bush onions", @"Grass seeds", @"Witchetty grub shrubs", @"Yakirra grass", @"Yams and potatoes"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"timeSinceFire", FXFormFieldTitle: [locale get: @"trackmetadata.timesincefire"], FXFormFieldOptions: @[@"Fresh shoots and plants growing", @"Long unburnt", @"Mature herbs with small grasses", @"Old enough to burn", @"Recent fire"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             
             // Trackability
             @{@"textLabel.color": uiColour, FXFormFieldKey: @"clearGround", FXFormFieldTitle:[locale get: @"trackmetadata.clearground"], FXFormFieldHeader: [locale get: @"trackmetadata.trackability"], FXFormFieldOptions: @[@"Little or no clear ground", @"Lots of clear ground", @"Some clear ground"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"disturbance", FXFormFieldTitle: [locale get: @"trackmetadata.disturbance"], FXFormFieldOptions: @[@"Car", @"No recent disturbance", @"Rain", @"Wind"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"groundSoftness", FXFormFieldTitle: [locale get: @"trackmetadata.groundsoftness"], FXFormFieldOptions: @[@"Bit hard for little animal tracks", @"Hard (only tracks of big animals)", @"Soft (lots of little tracks)"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"weather", FXFormFieldTitle: [locale get: @"trackmetadata.weather"], FXFormFieldOptions: @[@"Bright sun", @"Calm", @"Cloudy", @"Windy"], FXFormFieldViewController: @"FXFormExtendedViewController"}
             ];
}


#pragma mark - location manager delegate functions
- (void)locationManager: (CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
    
    CLLocation *lastLocation = [_route lastObject];
    
    CLLocationDistance dist = [newLocation distanceFromLocation:lastLocation];
    
    if ( (dist >= MIN_DISTANCE_BETWEEN_LOCATION) || ( [_route count] == 0 ) ) {
        [self.route addObject:newLocation];
    }
}

#pragma mark - helper functions
- (BOOL) isValid {
    if(_organisationName == @"" || _organisationName == nil){
        return NO;
    }
    
    if(_leadTracker == @"" || _leadTracker == nil){
        return NO;
    }
    
    if(_date == nil){
        return NO;
    }
    
    if(_startTime == nil){
        return NO;
    }
    
    if((_animals == nil) || ([_animals count] == 0)){
        return NO;
    } else {
        for (int i = 0; i < [_animals count];  i++) {
            Species * animal = [_animals objectAtIndex:i];
            if ( (animal.displayName == nil) && (animal.displayName == nil)) {
                return NO;
            }
        }
    }

    return YES;
}

- (NSDictionary *)JSONFromFile: (NSString *) file {
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}


- (NSMutableDictionary*) transformDataToUploadableFormat {
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    item[@"ready"] = @"1";
    item[@"uploadedStatus"] = @"0";
    item[@"activity"] = [self getActivityObject];
    item[@"site"] = [self getSiteObject];
    item[@"countryImage"] = [self countryPhoto];
    item[@"speciesImages"] = [self getAnimalImageList];
    return item;
}

- (NSDictionary*) getSiteObject {
    GAAppDelegate *appDelegate = (GAAppDelegate *) [[UIApplication sharedApplication] delegate];
    Project *project = [appDelegate.projectService loadSelectedProject];

    NSMutableDictionary* obj = [[NSMutableDictionary alloc] init];
    NSMutableArray* route = [[NSMutableArray alloc] initWithCapacity:[_route count]];
    
    for (int i = 0; i < [_route count]; i++) {
        CLLocation* loc = _route[i];
        NSArray* location = @[@(loc.coordinate.longitude), @(loc.coordinate.latitude)];
        route[i] = location;
    }
    
    NSArray* line = [route copy];
    NSArray* centre = @[];
    
    if ([line count] > 0) {
        centre = line[0];
    }
    
    obj[@"site"] = @{
        @"name":@"Private site for survey Tracsks Hub",
        @"visibility":@"private",
        @"projects":@[
                    project.projectId
                 ],
        @"extent":@{
         @"geometry":@{
             @"centre":centre,
             @"type":@"LineString",
             @"areaKmSq":@0,
             @"coordinates":line
         },
         @"source":@"drawn"
        },
        @"asyncUpdate":@YES
    };
    
    obj[@"pActivityId"] = project.projectActivityId ? project.projectActivityId : @"";
    
    return [obj copy];
}

- (NSArray*) getAnimalImageList {
    NSMutableArray* images = [[NSMutableArray alloc] initWithCapacity:[_animals count]];
    
    for (int i = 0; i < [_animals count]; i++) {
        SightingForm* animal = _animals[i];
        if (animal.photo != nil) {
            [images addObject:animal.photo];
        } else {
            [images addObject:@""];
        }
    }
    
    return [images copy];
}

- (NSMutableDictionary*) getActivityObject {
    // Populate site data - projectId and projectActivityId
    GAAppDelegate *appDelegate = (GAAppDelegate *) [[UIApplication sharedApplication] delegate];
    Project *project = [appDelegate.projectService loadSelectedProject];
    
    NSMutableDictionary* activity = [[NSMutableDictionary alloc] initWithDictionary: @{
        @"activityId": @"",
        @"projectStage": @"",
        @"mainTheme": @"",
        @"type": @"CLC 2Ha Track Plot",
        @"projectId": project.projectId ? project.projectId : @"",
        @"siteId": @"",
        @"outputs": @[[self getOutput]]
    }];

    return activity;
}

- (NSMutableDictionary *) getOutput {
    NSMutableArray* animals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_animals count]; i++) {
        SightingForm* animal = _animals[i];
        [animals addObject: [animal getOutput]];
    }
    
    NSMutableDictionary* output = [[NSMutableDictionary alloc] initWithDictionary: @{
     @"name": @"CLC 2Ha Track Plot",
     @"outputId": @"",
     @"data": @{
        @"organisationName": self.organisationName ? self.organisationName : @"",
        @"recordedBy": self.leadTracker ? self.leadTracker : @"",
        @"additionalTrackers": self.otherTrackers ? self.otherTrackers : @"",
        @"eventComments": self.comments ? self.comments : @"",
        @"surveyType": self.surveyType ? self.surveyType : @"",
        @"locationAccuracy": @50,
        @"location": @"",
        @"locationLatitude": @"",
        @"locationLongitude": @"",
        @"locationCentroidLatitude": @0,
        @"locationCentroidLongitude": @0,
        // TODO: Convert to ISO format
        @"surveyDate": self.date ? self.date : @"",
        // convert to time string format
        @"surveyStartTime": self.startTime ? self.startTime : @"",
        // convert to time string format
        @"surveyFinishTime": self.endTime ? self.endTime : @"",
        @"habitatType": self.countryType ? self.countryType : @"",
        @"siteChoice": self.surveyChoice ? self.surveyChoice : @"",
        @"disturbance": self.disturbance ? self.disturbance : @"",
        @"fireHistory": self.timeSinceFire ? self.timeSinceFire : @"",
        @"visibility": self.weather ? self.weather : @"",
        @"surfaceTrackability": self.groundSoftness ? self.groundSoftness : @"",
        @"trackingSurfaceContinuity": self.clearGround ? self.clearGround : @"",
        @"locationImage": @"",
        @"countryName": self.countryName ? self.countryName : @"",
        @"vegetationType": self.vegetationType ? self.vegetationType : @"",
        @"foodPlants": self.foodPlant ? self.foodPlant : @[],
        @"sightingEvidenceTable": animals
        },
     @"outputNotCompleted":@(NO),
     @"selectFromSitesOnly":@(NO),
     @"checkMapInfo":@{
        @"validation":@(YES)
    },
     @"appendTableRows":@(YES)
     }];
    
    return output;
}

@end
