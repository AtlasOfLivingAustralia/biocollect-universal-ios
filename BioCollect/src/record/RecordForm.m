    //
//  RecordForm.m
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 19/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "RecordForm.h"
#import "GASettings.h"
#import "GASettingsConstant.h"

@implementation RecordForm

@synthesize propertyKey;

- (instancetype)init{
    self = [super init];
    
    self.propertyKey = @{
                         @"displayKey": @"speciesDisplayName",
                         @"activityIdKey":@"activityId",
                         @"scientificNameKey": @"scientificName",
                         @"commonNameKey": @"commonName",
                         @"guidKey": @"guid",
                         @"uniqueIdKey":@"uniqueId",
                         @"commentsKey":@"comments",
                         @"surveyDate":@"surveyDate",
                         @"confidentKey":@"confident",
                         @"howManySpeciesKey":@"howManySpecies",
                         @"notesKey": @"notes",
                         @"recordedByKey": @"recordedBy",
                         @"identificationTagsKey": @"identificationTags",
                         @"locationNotesKey":@"locationNotes",
                         @"locationKey":@"location",
                         @"speciesPhotoKey":@"speciesPhoto",
                         @"photoDateKey":@"photoDate",
                         @"photoTitleKey": @"photoTitle",
                         @"photoLicenceKey": @"photoLicence",
                         @"photoAttributionKey": @"photoAttribution",
                         @"photoNotesKey": @"photoNotes",
                         @"photoUrlKey":@"photoUrl",
                         @"photoThumbnailUrlKey":@"photoThumbnailUrl",
                         @"photoContentTypeKey":@"photoContentType",
                         @"photoFilenameKey": @"photoFilename"
                         };
    return  self;
}

#pragma mark NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    
    self.speciesDisplayName = [aDecoder decodeObjectForKey: propertyKey[@"displayKey"]];
    self.activityId = [aDecoder decodeObjectForKey: propertyKey[@"activityIdKey"]];
    self.scientificName = [aDecoder decodeObjectForKey: propertyKey[@"scientificNameKey"]];
    self.commonName = [aDecoder decodeObjectForKey: propertyKey[@"commonNameKey"]];
    self.guid = [aDecoder decodeObjectForKey: propertyKey[@"guidKey"]];
    self.uniqueId = [aDecoder decodeObjectForKey: propertyKey[@"uniqueIdKey"]];
    self.comments = [aDecoder decodeObjectForKey: propertyKey[@"commentsKey"]];
    self.surveyDate = [aDecoder decodeObjectForKey: propertyKey[@"surveyDate"]];
    self.confident = [aDecoder decodeBoolForKey: propertyKey[@"confidentKey"]];
    self.howManySpecies = [aDecoder decodeIntegerForKey:propertyKey[@"howManySpeciesKey"]];
    self.notes = [aDecoder decodeObjectForKey: propertyKey[@"notesKey"]];
    self.recordedBy = [aDecoder decodeObjectForKey: propertyKey[@"recordedByKey"]];
    self.identificationTags = [aDecoder decodeObjectForKey: propertyKey[@"identificationTagsKey"]];
    self.locationNotes = [aDecoder decodeObjectForKey: propertyKey[@"locationNotesKey"]];
    self.location = [aDecoder decodeObjectForKey: propertyKey[@"locationKey"]];
    self.speciesPhoto = [aDecoder decodeObjectForKey: propertyKey[@"speciesPhotoKey"]];
    self.photoDate = [aDecoder decodeObjectForKey: propertyKey[@"photoDateKey"]];
    self.photoTitle = [aDecoder decodeObjectForKey: propertyKey[@"photoTitleKey"]];
    self.photoLicence = [aDecoder decodeObjectForKey: propertyKey[@"photoLicenceKey"]];
    self.photoAttribution = [aDecoder decodeObjectForKey: propertyKey[@"photoAttributionKey"]];
    self.photoNotes = [aDecoder decodeObjectForKey: propertyKey[@"photoNotesKey"]];
    self.photoUrl = [aDecoder decodeObjectForKey: propertyKey[@"photoUrlKey"]];
    self.photoThumbnailUrl = [aDecoder decodeObjectForKey: propertyKey[@"photoThumbnailUrlKey"]];
    self.photoContentType = [aDecoder decodeObjectForKey: propertyKey[@"photoContentTypeKey"]];
    self.photoFilename = [aDecoder decodeObjectForKey: propertyKey[@"photoFilenameKey"]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.speciesDisplayName forKey:propertyKey[@"displayKey"]];
    [aCoder encodeObject:self.activityId forKey: propertyKey[@"activityIdKey"]];
    [aCoder encodeObject:self.scientificName forKey: propertyKey[@"scientificNameKey"]];
    [aCoder encodeObject:self.commonName forKey: propertyKey[@"commonNameKey"]];
    [aCoder encodeObject:self.guid forKey: propertyKey[@"guidKey"]];
    [aCoder encodeObject:self.uniqueId forKey: propertyKey[@"uniqueIdKey"]];
    [aCoder encodeObject:self.comments forKey: propertyKey[@"commentsKey"]];
    [aCoder encodeObject:self.surveyDate forKey: propertyKey[@"surveyDate"]];
    [aCoder encodeBool:self.confident forKey: propertyKey[@"confidentKey"]];
    [aCoder encodeInteger:self.howManySpecies forKey: propertyKey[@"howManySpeciesKey"]];
    [aCoder encodeObject:self.notes forKey: propertyKey[@"notesKey"]];
    [aCoder encodeObject:self.recordedBy forKey: propertyKey[@"recordedByKey"]];
    [aCoder encodeObject:self.identificationTags forKey: propertyKey[@"identificationTagsKey"]];
    [aCoder encodeObject:self.locationNotes forKey: propertyKey[@"locationNotesKey"]];
    [aCoder encodeObject:self.location forKey: propertyKey[@"locationKey"]];
    [aCoder encodeObject:self.speciesPhoto forKey: propertyKey[@"speciesPhotoKey"]];
    [aCoder encodeObject:self.photoDate forKey: propertyKey[@"photoDateKey"]];
    [aCoder encodeObject:self.photoTitle forKey: propertyKey[@"photoTitleKey"]];
    [aCoder encodeObject:self.photoLicence forKey: propertyKey[@"photoLicenceKey"]];
    [aCoder encodeObject:self.photoAttribution forKey: propertyKey[@"photoAttributionKey"]];
    [aCoder encodeObject:self.photoNotes forKey: propertyKey[@"photoNotesKey"]];
    [aCoder encodeObject:self.photoUrl forKey: propertyKey[@"photoUrlKey"]];
    [aCoder encodeObject:self.photoThumbnailUrl forKey: propertyKey[@"photoThumbnailUrlKey"]];
    [aCoder encodeObject:self.photoContentType forKey: propertyKey[@"photoContentTypeKey"]];
    [aCoder encodeObject:self.photoFilename forKey: propertyKey[@"photoFilenameKey"]];

}

- (NSArray *)fields
{
    return @[

             @{FXFormFieldKey: @"speciesDisplayName", FXFormFieldTitle: @"Species Name", FXFormFieldHeader: @"Species Information", FXFormFieldType: FXFormFieldTypeLabel,  FXFormFieldAction: @"showSpeciesSearchTableViewController:", FXFormFieldPlaceholder: @"No species selected"},
             @"confident",
             @{FXFormFieldKey:@"howManySpecies", FXFormFieldTitle:@"Number of individuals", FXFormFieldCell: [FXFormStepperCell class]},
             @{FXFormFieldKey: @"identificationTags", FXFormFieldOptions: @[@"Amphibians", @"Amphibians, Australian Ground Frogs", @"Birds"]},
             @{FXFormFieldKey: @"comments", FXFormFieldTitle:@"Notes", FXFormFieldType: FXFormFieldTypeLongText,FXFormFieldPlaceholder: @"" },

             @{FXFormFieldKey: @"location", FXFormFieldTitle:@"Pick a location", FXFormFieldPlaceholder: @"", FXFormFieldHeader: @"Location", FXFormFieldViewController: @"MapViewController"},
             @{FXFormFieldKey: @"locationNotes", FXFormFieldTitle:@"Notes", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldPlaceholder: @""},
             
             @{FXFormFieldKey: @"surveyDate", FXFormFieldTitle:@"Date", FXFormFieldHeader: @"Sightings Information"},
             @{FXFormFieldKey: @"surveyDate", FXFormFieldTitle:@"Time", FXFormFieldType: FXFormFieldTypeTime,FXFormFieldPlaceholder: @"" },
             @{FXFormFieldKey: @"recordedBy", FXFormFieldDefaultValue: [GASettings getFullName]},
             @{FXFormFieldKey: @"notes", FXFormFieldType: FXFormFieldTypeLongText,FXFormFieldPlaceholder: @"" },
             
             @{FXFormFieldKey:@"speciesPhoto", FXFormFieldTitle:@"Image", FXFormFieldHeader: @"Multimedia - Image"},
             @{FXFormFieldKey:@"photoTitle", FXFormFieldTitle:@"Title"},
             @{FXFormFieldKey:@"photoDate", FXFormFieldTitle:@"Date"},
             @{FXFormFieldKey:@"photoAttribution", FXFormFieldTitle:@"Attribution"},
             @{FXFormFieldKey:@"photoLicence", FXFormFieldTitle:@"Licence", FXFormFieldOptions: @[@"CC BY", @"CC BY-NC", @"CC BY-SA", @"CC BY-NC-SA"], FXFormFieldDefaultValue: @"CC BY",  FXFormFieldValueTransformer: ^(id input) {
                 NSDictionary *licences = @{@"CC BY":@"CC Attribution",@"CC BY-NC":@"CC Attribution-Noncommercial",@"CC BY-SA":@"CC Attribution-Share Alike",@"CC BY-NC-SA":@"CC Attribution-Noncommercial-Share Alike"};
                 return licences[ input ];
             }},
             @{FXFormFieldKey: @"photoNotes",FXFormFieldTitle:@"Notes", FXFormFieldType: FXFormFieldTypeLongText},
             ];
    
    
}

//we're happy with the layout and properties of our login form, but we
//want to add an additional button field at the end, so
//we've used the extraFields method

- (NSArray *)extraFields
{
    return @[
             
             //this field doesn't correspond to any property of the form
             //it's just an action button. the action will be called on first
             //object in the responder chain that implements the submitForm
             //method, which in this case would be the AppDelegate
             
             @{FXFormFieldTitle: @"Submit", FXFormFieldHeader: @"", FXFormFieldAction: @"submitLoginForm", @"backgroundColor": [UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:47.0/255.0 alpha:1], @"textLabel.color": [UIColor whiteColor]}
             
             ];
}

// hide these fields. they are autopopulated when a species is selected.
- (NSArray *) excludedFields{
    return @[
             @"scientificName",
             @"commonName",
             @"guid",
             @"uniqueId",
             @"photoUrl",
             @"photoThumbnailUrl"
             ];
}

- (NSString *)locationFieldDescription
{
    return self.location? [NSString stringWithFormat:@"%0.3f, %0.3f",
                           self.location.coordinate.latitude,
                           self.location.coordinate.longitude]: nil;
}


- (NSString *)speciesDisplayNameFieldDescription {
    return self.speciesDisplayName;
}

/**
 * Check all required fields are filled by user.
 */
- (NSMutableDictionary *)isValid{
    NSMutableDictionary *validity = [NSMutableDictionary dictionaryWithDictionary: @{@"valid":[NSNumber numberWithInt:1], @"message": @""}];
    NSMutableArray *invalidFields = [[NSMutableArray alloc] init];
    NSDictionary *mandatory = @{ @"scientificName":@"species name", @"location": @"location", @"surveyDate": @"survey date"};
    if([self scientificName] == nil){
        validity[@"valid"] =  [NSNumber numberWithInt:0];
        [invalidFields addObject: @"species name"];
    }
    
    if([self location] == nil){
        validity[@"valid"] =  [NSNumber numberWithInt:0];
        [invalidFields addObject: @"location"];
    }
    
    if([self surveyDate] == nil){
        validity[@"valid"] =  [NSNumber numberWithInt:0];
        [invalidFields addObject: @"survey date"];
    }
    
    NSString *msg = [NSString stringWithFormat:@"The following mandatory fields are invalid - %@", [invalidFields componentsJoinedByString:@", "]];
    [validity setValue: msg forKey:@"message"];
    
    return validity;
}

- (NSDictionary *) getData{
    NSDictionary *data = @{
                           @"surveyDate":[self dateToString: self.surveyDate]?:[NSNull null],
                           @"surveyStartTime": [self getTimeFromDate: self.surveyDate] ?:[NSNull null],
                           @"recordedBy":[self recordedBy]?:[NSNull null],
                           @"locationLatitude": [NSNumber numberWithDouble:self.location.coordinate.latitude]?:[NSNull null],
                           @"locationLongitude":[NSNumber numberWithDouble:self.location.coordinate.longitude]?:[NSNull null],
                           @"species":@{
                                   @"name":[self speciesDisplayName]?:[NSNull null],
                                   @"guid":[self guid]?:[NSNull null],
                                   @"scientificName":[self scientificName]?:[NSNull null],
                                   @"commonName":[self commonName]?:[NSNull null],
                                   @"outputSpeciesId": [self uniqueId]
                                   },
                           @"sightingPhoto": [self getPhotoData],
                           @"individualCount": [NSNumber numberWithUnsignedInteger:self.howManySpecies]?:[NSNull null],
                           @"identificationConfidence": self.confident? @"Certain" : @"Uncertain",
                           @"tags":[self identificationTags]?:@[]
                           };
    return data;
}
/**
 *
 */
- (NSDictionary *) toBiocollectFormat{
    return @{
             @"activityId":self.activityId ?:@"",
             @"projectStage":@"",
             @"mainTheme":@"",
             @"type":PROJECT_NAME,
             @"projectId": SIGHTINGS_PROJECT_ID,
             @"siteId":@"",
             @"outputs":@[@{
                     @"name":PROJECT_ACTIVITY_NAME,
                     @"outputId":@"",
                     @"outputNotCompleted":@"",
                     @"data": [self getData]
                     }]
             };
}

/**
 * combine related photo fields to a dictionary
 */
- (NSArray *) getPhotoData {
    if(self.speciesPhoto != nil){
        return @[@{
                 @"name": self.photoTitle?:[NSNull null],
                 @"attribution": self.photoAttribution?:[NSNull null],
                 @"dateTaken": [self dateToString:self.photoDate]?:[NSNull null],
                 @"licence": self.photoLicence?:[NSNull null],
                 @"url": self.photoUrl?:[NSNull null],
                 @"thumbnailUrl": self.photoThumbnailUrl?:[NSNull null],
                 @"contentType": self.photoContentType?:[NSNull null],
                 @"filename": self.photoFilename?:[NSNull null],
                 @"staged": @(YES),
                 @"notes": self.notes?:[NSNull null]
                 }];
    }
    
    return @[];
}


/**
 * convert record form to biocollect compliant format
 */
- (NSString *) toJSON{
    NSDictionary *data = [self toBiocollectFormat];
    NSError *e;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&e];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

/*
 * http://stackoverflow.com/questions/16254575/how-do-i-get-iso-8601-date-in-ios
 */
- (NSString *) dateToString: (NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    NSString *iso8601String = [dateFormatter stringFromDate:date];
    return [iso8601String stringByAppendingString:@"Z"];
}

- (NSString *) getTimeFromDate: (NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    return [dateFormatter stringFromDate:date];
}

/**
 * update photo related fields with the properties in data.
 */
- (void) updateImageSettings: (NSMutableDictionary *) data{
    if(data){
        if(data[@"files"] && [data[@"files"] count]){
            NSDictionary *file = data[@"files"][0];
            
            if(!self.photoTitle){
                self.photoTitle = file[@"name"];
            }
            
            if(!self.photoAttribution){
                self.photoAttribution = file[@"attribution"];
            }
            
            if(!self.photoDate){
                // todo: how to format string date?
            }
            
            if(!self.photoAttribution){
                self.photoAttribution = file[@"attribution"];
            }
            
            self.photoUrl = file[@"url"];
            self.photoThumbnailUrl = file[@"thumbnail_url"];
            self.photoFilename = file[@"name"];
            self.photoContentType = file[@"contentType"];
        }
    }
}

- (NSString *) getSubtitle{
    return [NSString stringWithFormat:@"%@ %@", self.recordedBy?:@"", self.surveyDate];
}

- (void)setScientificName:(NSString *)sn commonName:(NSString *)cn guid:(NSString *)guid{
    
    self.commonName = cn != [NSNull null]? cn:@"";
    self.scientificName = sn != [NSNull null]? sn:@"";
    self.guid = guid != [NSNull null]?guid:@"";
    
    if(![self.commonName isEqual:@""]){
        self.speciesDisplayName = [NSString stringWithFormat:@"%@ (%@)", self.scientificName, self.commonName];
    } else {
        self.speciesDisplayName = self.scientificName;
    }
    
    if([self.guid isEqual:@""]){
        self.guid = guid;
    } else {
        self.guid = nil;
    }
}
@end
