//
//  MetadataForm.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 27/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetadataForm.h"
#import "GAAppDelegate.h"
#define colour @"#F1582B"

@implementation MetadataForm

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
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"organisationName", FXFormFieldTitle:[locale get: @"trackmetadata.organisationname"], FXFormFieldHeader: [locale get: @"trackmetadata.trackerinfo"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"leadTracker", FXFormFieldTitle:[locale get: @"trackmetadata.leadTracker"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"otherTrackers", FXFormFieldTitle:[locale get: @"trackmetadata.otherTrackers"], FXFormFieldType: FXFormFieldTypeLongText},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"comments", FXFormFieldTitle: [locale get: @"trackmetadata.comments"], FXFormFieldType: FXFormFieldTypeLongText},
             
             // Tracking information
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"date", FXFormFieldTitle:[locale get: @"trackmetadata.eventdate"], FXFormFieldHeader: [locale get: @"trackmetadata.trackinginfo"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"startTime", FXFormFieldTitle:[locale get: @"trackmetadata.eventstarttime"], FXFormFieldType: FXFormFieldTypeTime},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"endTime", FXFormFieldTitle:[locale get: @"trackmetadata.eventendtime"], FXFormFieldType: FXFormFieldTypeTime},
             @{@"textLabel.color": uiColour,FXFormFieldTitle: [locale get: @"trackmetadata.surveytype"], FXFormFieldKey: @"surveyType", FXFormFieldOptions: @[@"Incidental", @"KJ Mankarr Survey", @"Road", @"Trackplot 2ha 100m x 200m"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour,FXFormFieldTitle: [locale get: @"trackmetadata.surveychoice"], FXFormFieldKey: @"surveyChoice", FXFormFieldOptions: @[@"Anywhere", @"Targeted"], @"viewController": @"FXFormExtendedViewController"},
             
             // Country
             @{@"textLabel.color": uiColour, FXFormFieldKey: @"countryName", FXFormFieldTitle:[locale get: @"trackmetadata.countryname"], FXFormFieldHeader: [locale get: @"trackmetadata.country"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"countryType", FXFormFieldTitle: [locale get: @"trackmetadata.countrytype"], FXFormFieldOptions: @[@"Calcrete/Limestone rise",  @"Claypan", @"Creek line", @"Drainage line", @"Laterite (red rocks)", @"Rocky range",  @"Salt lake", @"Sand dune", @"Sand plain", @"Waterhole", @"Other"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"countryPhoto", FXFormFieldTitle: [locale get: @"trackmetadata.countryphoto"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"vegetationType", FXFormFieldTitle: [locale get: @"trackmetadata.vegetationtype"], FXFormFieldOptions: @[@"Buffel grassland", @"Dense woodland", @"Open grassland", @"Open woodland",  @"Shrubland", @"Spinifex grassland",  @"Other"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"foodPlant", FXFormFieldTitle: [locale get: @"trackmetadata.foodplant"], FXFormFieldOptions: @[@"Bush fruits", @"Bush onions", @"Grass seeds", @"Witchetty grub shrubs", @"Yakirra grass", @"Yams and potatoes"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"timeSinceFire", FXFormFieldTitle: [locale get: @"trackmetadata.timesincefire"], FXFormFieldOptions: @[@"Fresh shoots and plants growing", @"Long unburnt", @"Mature herbs with small grasses", @"Old enough to burn", @"Recent fire"], @"viewController": @"FXFormExtendedViewController"},
             
             // Trackability
             @{@"textLabel.color": uiColour, FXFormFieldKey: @"clearGround", FXFormFieldTitle:[locale get: @"trackmetadata.clearground"], FXFormFieldHeader: [locale get: @"trackmetadata.trackability"], FXFormFieldOptions: @[@"Little or no clear ground", @"Lots of clear ground", @"Some clear ground"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"disturbance", FXFormFieldTitle: [locale get: @"trackmetadata.disturbance"], FXFormFieldOptions: @[@"Car", @"No recent disturbance", @"Rain", @"Wind"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"groundSoftness", FXFormFieldTitle: [locale get: @"trackmetadata.groundsoftness"], FXFormFieldOptions: @[@"Bit hard for little animal tracks", @"Hard (only tracks of big animals)", @"Soft (lots of little tracks)"], @"viewController": @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"weather", FXFormFieldTitle: [locale get: @"trackmetadata.weather"], FXFormFieldOptions: @[@"Bright sun", @"Calm", @"Cloudy", @"Windy"], @"viewController": @"FXFormExtendedViewController"}
             ];
}
@end
