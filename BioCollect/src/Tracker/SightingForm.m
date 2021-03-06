//
//  SightingForm.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 1/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXForms.h"
#import <MapKit/MapKit.h>
#import "UIImageView+WebCache.h"
#import "SightingForm.h"
#import "GAAppDelegate.h"
#define colour @"#F1582B"

@implementation SightingForm
#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    
    self.animal = [aDecoder decodeObjectForKey: @"animal"];
    self.location = [aDecoder decodeObjectForKey: @"location"];
    self.photoLocation = [aDecoder decodeObjectForKey: @"photoLocation"];
    self.visibleSign = [aDecoder decodeObjectForKey: @"visibleSign"];
    self.durationSign = [aDecoder decodeObjectForKey: @"durationSign"];
    self.age = [aDecoder decodeObjectForKey: @"age"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.animal forKey: @"animal"];
    [aCoder encodeObject:self.location forKey: @"location"];
    [aCoder encodeObject:_photoLocation forKey: @"photoLocation"];
    [aCoder encodeObject:self.visibleSign forKey: @"visibleSign"];
    [aCoder encodeObject:self.durationSign forKey: @"durationSign"];
    [aCoder encodeObject:self.age forKey: @"age"];
}

# pragma mark - FXForm
- (NSArray*) fields {
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    UIColor* uiColour = [self colorFromHexString: colour];
    
    return @[
             // Tracker information
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"animal", FXFormFieldTitle:[locale get: @"sighting.animal"], FXFormFieldViewController: @"SpeciesListVC", FXFormFieldTypeImage:[UIImage imageNamed:@"icon_lizards"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"visibleSign", FXFormFieldTitle:[locale get: @"sighting.visiblesign"], FXFormFieldOptions: @[@"Animal", @"Track", @"Scat", @"Burrow/Nest/Cave/Resting place", @"Body part",   @"Digging", @"Digging into roots for grubs", @"Digging for ants/termites"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"durationSign", FXFormFieldTitle:[locale get: @"sighting.durationsign"], FXFormFieldOptions: @[@"Fresh (1-2days)", @"Older (3 days to 1 week)", @"Really old (> 1 week)"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"age", FXFormFieldTitle:[locale get: @"sighting.age"], FXFormFieldOptions: @[@"Big adult", @"Small adult", @"Young"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"photo", FXFormFieldTitle:[locale get: @"sighting.photo"], FXFormFieldCell: @"FXFormLargeImagePickerCell", FXFormFieldPlaceholder: [UIImage imageNamed: @"animalsignphoto"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey: @"location", FXFormFieldTitle:@"Location", FXFormFieldPlaceholder: @"", FXFormFieldViewController: @"MapPointViewController"}
           ];
}


- (NSString *)locationFieldDescription
{
    NSString *displayStr  = @"";
    if(self.location != nil){
        displayStr = [NSString stringWithFormat:@"%0.3f, %0.3f", self.location.coordinate.latitude, self.location.coordinate.longitude];
    }
    
    return displayStr;
}

- (NSString *)animalFieldDescription
{
    NSString *displayStr  = @"";
    if(self.animal != nil){
        displayStr = self.animal.displayName;
    }
    
    return displayStr;
}

- (void) saveImages {
    if (self.photo) {
        if (self.photoLocation == nil) {
            GAAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
            self.photoLocation = [appDelegate.utilService generateFileName: nil];
        }
        
        NSData *data = UIImageJPEGRepresentation(self.photo, 1.0);
        [data writeToFile:self.photoLocation atomically:NO];
        self.photo = nil;
    }
}

- (void) loadImages {
    if (self.photoLocation) {
        self.photo = [UIImage imageWithContentsOfFile:self.photoLocation];
    }
}

- (void) deleteImages {
    if (self.photoLocation) {
         [[NSFileManager defaultManager] removeItemAtPath: self.photoLocation error:nil];
    }
}

- (NSString*) getPhotoLocation {
    if (_photoLocation) {
        NSArray<NSURL *>* paths = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask];
        NSString* path = [paths[0] URLByAppendingPathComponent:_photoLocation].path;
        return path;
    }
    
    return nil;
}

#pragma mark - Helper functions
-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIImage *) getImage {
    UIImage *image = nil;
    
    if (_photo != nil) {
        image = _photo;
    } else {
        NSString *thumbnail = [self.animal getImageUrl];
        
        if(![thumbnail isEqualToString:@""]) {
            UIImageView *imageView = [[UIImageView alloc] init];
            [imageView sd_setImageWithURL:[NSURL URLWithString: thumbnail] placeholderImage:[UIImage imageNamed:@"noImage85.jpg"] options:SDWebImageRefreshCached];
            image = imageView.image;
        } else {
            image = [UIImage imageNamed:@"noImage85.jpg"];
        }
    }
    
    return image;
}

- (NSMutableDictionary*) getOutput {
    NSMutableDictionary* output = [[NSMutableDictionary alloc] initWithDictionary: @{
        @"species": [self.animal getOutput],
        @"typeOfSign": self.visibleSign ? self.visibleSign : @"",
        @"evidenceAgeClass": self.durationSign ? self.durationSign : @"",
        @"ageClassOfAnimal": self.age ? self.age : @"",
        @"observationLatitude": self.location.coordinate.latitude ? @(self.location.coordinate.latitude) : @"",
        @"observationLongitude": self.location.coordinate.longitude ? @(self.location.coordinate.longitude) : @""
    }];
    
    return output;
}

- (NSString*) getTitle {
    GAAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    NSString* title = [locale get: @"sighting.unknown"];
    if (self.animal) {
        title = self.animal.displayName;
    }
    
    return title;
}

- (NSString*) getSummary {
    GAAppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    NSMutableArray* summray = [NSMutableArray new];
    NSMutableArray* signs = [NSMutableArray new];
    NSString* sign = @"";
    NSString* name = @"";
    if (self.animal) {
        [summray addObject:[self.animal getSubTitle]];
    }
    
    if (self.visibleSign) {
        [signs addObject:self.visibleSign];
    }
    
    if (self.durationSign) {
        [signs addObject:self.durationSign];
    }
    
    if ([signs count] > 0) {
        sign = [signs componentsJoinedByString:@", "];
        [summray addObject: [NSString stringWithFormat:[locale get: @"sighting.details.sign"], sign]];
    }
    
    if (self.age) {
        [summray addObject: [NSString stringWithFormat:[locale get: @"sighting.details.age"], self.age]];
    }
    
    return [summray componentsJoinedByString:@"; "];
}
@end
