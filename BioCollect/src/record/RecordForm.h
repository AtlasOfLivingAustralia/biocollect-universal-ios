//
//  RecordForm.h
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 19/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FXForms.h"
#import <MapKit/MapKit.h>

@interface RecordForm : NSObject <FXForm, NSCoding>

@property (nonatomic, copy) NSString *activityId;
@property (nonatomic, copy) NSString *speciesDisplayName;
@property (nonatomic, copy) NSString *scientificName;
@property (nonatomic, copy) NSString *commonName;
@property (nonatomic, copy) NSString *guid;
@property (nonatomic, copy) NSString *uniqueId;
@property (nonatomic, copy) NSString *comments;
@property (nonatomic, strong) NSDate *surveyDate;
@property (nonatomic) BOOL confident;
@property (nonatomic) NSUInteger howManySpecies;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, copy) NSString *recordedBy;
@property (nonatomic, copy) NSArray *identificationTags;
@property (nonatomic, copy) NSString *locationNotes;
@property (nonatomic, strong) CLLocation *location;

@property (nonatomic, strong) UIImage *speciesPhoto;
@property (nonatomic, strong) NSDate *photoDate;
@property (nonatomic, copy) NSString *photoTitle;
@property (nonatomic, copy) NSString *photoLicence;
@property (nonatomic, copy) NSString *photoAttribution;
@property (nonatomic, copy) NSString *photoNotes;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, copy) NSString *photoThumbnailUrl;
@property (nonatomic, copy) NSString *photoContentType;
@property (nonatomic, copy) NSString *photoFilename;

@property (nonatomic, strong) NSDictionary *propertyKey;

- (NSObject *) isValid;
- (NSDictionary *) toDictionary;
- (NSString *) toJSON;
- (void) updateImageSettings: (NSMutableDictionary *) data;
- (NSString *) getSubtitle;
- (void)setScientificName:(NSString *)sn commonName:(NSString *)cn guid:(NSString *)guid;
@end
