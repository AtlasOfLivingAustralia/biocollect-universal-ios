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
#import "SightingForm.h"
#import "GAAppDelegate.h"
#define colour @"#F1582B"

@implementation SightingForm
-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSArray*) fields {
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    UIColor* uiColour = [self colorFromHexString: colour];
    
    return @[
             // Tracker information
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"animal", FXFormFieldTitle:[locale get: @"sighting.animal"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey: @"location", FXFormFieldTitle:@"Location", FXFormFieldPlaceholder: @"", FXFormFieldViewController: @"MapPointViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"photo", FXFormFieldTitle:[locale get: @"sighting.photo"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"visibleSign", FXFormFieldTitle:[locale get: @"sighting.visiblesign"], FXFormFieldOptions: @[@"Animal", @"Body part", @"Burrow/Nest/Cave/Resting place",  @"Digging", @"Digging for ants/termites", @"Digging into roots for grubs", @"Scat", @"Track"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"durationSign", FXFormFieldTitle:[locale get: @"sighting.durationsign"], FXFormFieldOptions: @[@"Fresh (1-2days)", @"Older (3 days to 1 week)", @"Really old (> 1 week)"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"age", FXFormFieldTitle:[locale get: @"sighting.age"], FXFormFieldOptions: @[@"Big adult", @"Small adult", @"Young"], @"viewController": @"FXFormExtendedViewController"}
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
@end
