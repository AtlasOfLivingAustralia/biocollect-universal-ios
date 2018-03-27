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
    self.photo = [aDecoder decodeObjectForKey: @"photo"];
    self.visibleSign = [aDecoder decodeObjectForKey: @"visibleSign"];
    self.durationSign = [aDecoder decodeObjectForKey: @"durationSign"];
    self.age = [aDecoder decodeObjectForKey: @"age"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.animal forKey: @"animal"];
    [aCoder encodeObject:self.location forKey: @"location"];
    [aCoder encodeObject:self.photo forKey: @"photo"];
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
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"animal", FXFormFieldTitle:[locale get: @"sighting.animal"], FXFormFieldViewController: @"SpeciesListVC"},
             @{@"textLabel.color": uiColour, FXFormFieldKey: @"location", FXFormFieldTitle:@"Location", FXFormFieldPlaceholder: @"", FXFormFieldViewController: @"MapPointViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"photo", FXFormFieldTitle:[locale get: @"sighting.photo"]},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"visibleSign", FXFormFieldTitle:[locale get: @"sighting.visiblesign"], FXFormFieldOptions: @[@"Animal", @"Body part", @"Burrow/Nest/Cave/Resting place",  @"Digging", @"Digging for ants/termites", @"Digging into roots for grubs", @"Scat", @"Track"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"durationSign", FXFormFieldTitle:[locale get: @"sighting.durationsign"], FXFormFieldOptions: @[@"Fresh (1-2days)", @"Older (3 days to 1 week)", @"Really old (> 1 week)"], FXFormFieldViewController: @"FXFormExtendedViewController"},
             @{@"textLabel.color": uiColour, FXFormFieldKey:@"age", FXFormFieldTitle:[locale get: @"sighting.age"], FXFormFieldOptions: @[@"Big adult", @"Small adult", @"Young"], FXFormFieldViewController: @"FXFormExtendedViewController"}
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
            [imageView sd_setImageWithURL:[NSURL URLWithString: thumbnail] placeholderImage:[UIImage imageNamed:@"ajax_loader.gif"] options:SDWebImageRefreshCached];
            image = imageView.image;
        } else {
            image = [UIImage imageNamed:@"noImage85.jpg"];
        }
    }
    
    return image;
}
@end
