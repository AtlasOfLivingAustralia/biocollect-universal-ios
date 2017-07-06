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
                         @"photoFilenameKey": @"photoFilename",
                         @"uploadedKey": @"uploaded"
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
    self.uploaded = [aDecoder decodeBoolForKey: propertyKey[@"uploadedKey"]];
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
    [aCoder encodeBool:self.uploaded forKey: propertyKey[@"uploadedKey"]];
}

-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSDictionary *)confidentField
{
    return @{@"textLabel.color": [self colorFromHexString: @"#F1582B"]};
}

- (NSArray *)fields
{
    return @[
             
             
             //1. Upload Photo
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey:@"speciesPhoto", FXFormFieldTitle:@"Species Photo", FXFormFieldTypeImage:[UIImage imageNamed:@"icon_camera"],
               FXFormFieldHeader: @"1. Take or Upload a Photo", FXFormFieldAction: @"parseImageMetadata:"},
             
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey:@"photoTitle", FXFormFieldTitle:@"Title", FXFormFieldHeader: @"Image attributes"},
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey:@"photoAttribution", FXFormFieldTitle:@"Attribution", FXFormFieldDefaultValue: [GASettings getFullName]},
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey:@"photoDate", FXFormFieldTitle:@"Date"},
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey:@"photoLicence", FXFormFieldTitle:@"Licence", FXFormFieldOptions: @[@"CC BY", @"CC BY-NC", @"CC BY-SA", @"CC BY-NC-SA"], FXFormFieldDefaultValue: @"CC BY",  FXFormFieldValueTransformer: ^(id input) {
                 NSDictionary *licences = @{@"CC BY":@"CC Attribution 3.0",@"CC BY-NC":@"CC Attribution 0",@"CC BY-SA":@"CC Attribution 4.0",@"CC BY-NC-SA":@"CC Attribution-Noncommercial"};
                 return licences[ input ];
             }},
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"photoNotes",FXFormFieldTitle:@"Notes", FXFormFieldType: FXFormFieldTypeLongText},
             
             //2. Location
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"location", FXFormFieldTitle:@"Location *", FXFormFieldPlaceholder: @"", FXFormFieldHeader: @"2. Select Location", FXFormFieldViewController: @"HomeViewController", FXFormFieldTypeImage:[UIImage imageNamed:@"icon_marker"]},
             
             
             //3. Select Species
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"speciesDisplayName", FXFormFieldTitle: @"Name *", FXFormFieldHeader: @"3. Select Species", FXFormFieldType: FXFormFieldTypeLabel,  FXFormFieldAction: @"showSpeciesSearchTableViewController:", FXFormFieldPlaceholder: @"No species selected", FXFormFieldTypeImage:[UIImage imageNamed:@"icon_search_plus"]},
             
             @"confident",

             
             //@{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"locationNotes", FXFormFieldTitle:@"Notes", FXFormFieldType: FXFormFieldTypeLongText, FXFormFieldPlaceholder: @""},
             
             //4. Additional information
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"surveyDate", FXFormFieldTitle:@"Date", FXFormFieldHeader: @"4. Observation Details"},
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"surveyDate", FXFormFieldTitle:@"Time", FXFormFieldType: FXFormFieldTypeTime,FXFormFieldPlaceholder: @"" },
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey:@"howManySpecies", FXFormFieldTitle:@"Number of individuals", FXFormFieldCell: [FXFormStepperCell class]},
            @{@"textLabel.color": [self colorFromHexString: @"#F1582B"], FXFormFieldTitle: @"Recorded By", FXFormFieldKey: @"recordedBy", FXFormFieldDefaultValue: [GASettings getFullName]},
             
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldTitle: @"Identification Tags", FXFormFieldKey: @"identificationTags", FXFormFieldOptions: @[@"Amphibians",@"Amphibians, Australian Ground Frogs",@"Amphibians, Narrow-Mouthed Frogs",@"Amphibians, Tree Frogs",@"Amphibians, True Frogs",@"Amphibians, True Toads",@"Birds",@"Birds, Bitterns, Ibises",@"Birds, Buttonquails",@"Birds, Cranes",@"Birds, Cuckoos",@"Birds, Doves",@"Birds, Ducks, Geese, Swans",@"Birds, Falcons",@"Birds, Flamingos",@"Birds, Fowls",@"Birds, Grebes",@"Birds, Hummingbirds, Swifts",@"Birds, Kingfishers",@"Birds, Large waterbirds",@"Birds, Nightjars, Frogmouths, Potoos",@"Birds, Ostriches",@"Birds, Owls",@"Birds, Parrots",@"Birds, Penguins",@"Birds, Perching Birds",@"Birds, Petrels, Fulmars",@"Birds, Waders, Gulls, Auks",@"Crustaceans",@"Crustaceans, Barnacles, Copepods",@"Crustaceans, Crabs, Lobsters",@"Crustaceans, Fairy shrimp, Clam shrimp",@"Crustaceans, Seed shrimp",@"Fish",@"Fish, Anchovies ",@"Fish, Angel Sharks",@"Fish, Anglerfishes",@"Fish, Baldfishes,Tubeshoulders",@"Fish, Batoids",@"Fish, Batrachoidiforms",@"Fish, Beardfishes",@"Fish, Boarfishes",@"Fish, Bonefishes",@"Fish, Bonytongues",@"Fish, Bullhead Sharks",@"Fish, Carpet Sharks",@"Fish, Catfishes",@"Fish, Chimaeras",@"Fish, Cods",@"Fish, Cow Sharks",@"Fish, Cowfishes",@"Fish, Deep-sea ray-finned fishes",@"Fish, Deep-sea ray-finned fishes",@"Fish, Dogfish Sharks",@"Fish, Dragonfishes",@"Fish, Eels",@"Fish, Electric Rays",@"Fish, Flatfishes",@"Fish, Ground Sharks",@"Fish, Guitarfish",@"Fish, Hagfishes",@"Fish, Halfbeeks",@"Fish, Jellynose Fishes",@"Fish, Killifishes",@"Fish, Latern Fishes, Neoscopelids",@"Fish, Lungfish",@"Fish, Mackerel Sharks",@"Fish, Marine ray-finned fish",@"Fish, Milkfishes",@"Fish, Minnows",@"Fish, Mullet fish",@"Fish, Opahs",@"Fish, Ophidiiforms",@"Fish, Perch-like Fishes",@"Fish, Rainbow Fishes",@"Fish, Ray-finned fishes",@"Fish, Sackpharynx Fishes",@"Fish, Salmons",@"Fish, Saw Sharks",@"Fish, Sawfish",@"Fish, Scorpion Fishes, Sculpins",@"Fish, Softnose Skates",@"Fish, Spiny Eels",@"Fish, Swamp Eels",@"Fish, Tarpons",@"Fungi",@"Fungi, Asco's",@"Fungi, Basidio's",@"Fungi, Chytrids",@"Fungi, Glomeromycota",@"Fungi, Zygomycetes",@"Insects and Spiders",@"Insects and Spiders, Alderflies, Dobsonflies, Fishflies",@"Insects and Spiders, Beetles",@"Insects and Spiders, Booklice, Barklice, Barkflies",@"Insects and Spiders, Bristletails",@"Insects and Spiders, Butterflies, Moths",@"Insects and Spiders, Caddisflies, Sedge-flies or Rail-flies",@"Insects and Spiders, Cicadas, Aphids, Planthoppers, Leafhoppers, Shield Bugs",@"Insects and Spiders, Cockroaches, Termites",@"Insects and Spiders, Dragonflies, Damselflies",@"Insects and Spiders, Earwigs",@"Insects and Spiders, Fleas",@"Insects and Spiders, Flies, Mosquitoes",@"Insects and Spiders, Grasshoppers, Crickets, Locusts, Katydids, Weta, Lubber",@"Insects and Spiders, Lacewings, Mantidflies, Antlions",@"Insects and Spiders, Lice",@"Insects and Spiders, Mantises",@"Insects and Spiders, Mayflies, Shadlfies",@"Insects and Spiders, Scorpionflies, Hangingflies",@"Insects and Spiders, Silverfish",@"Insects and Spiders, Spiders",@"Insects and Spiders, Stick Insects, Phasmids",@"Insects and Spiders, Stoneflies",@"Insects and Spiders, Thrips",@"Insects and Spiders, Twisted-Wing Parasites",@"Insects and Spiders, Wasps, Ants, Bees, Sawflies",@"Insects and Spiders, Webspinners",@"Insects and Spiders, Zorapterans",@"Mammals",@"Mammals, Bandicoots, Bilbies",@"Mammals, Bats",@"Mammals, Carnivores",@"Mammals, Carnivorous Marsupials",@"Mammals, Dolphins, Porpoises, Whales",@"Mammals, Dugongs, Manatees, Sea Cows",@"Mammals, Even-toed hoofed",@"Mammals, Hares, Pikas, Rabbits",@"Mammals, Herbivorous Marsupials",@"Mammals, Marsupial Moles",@"Mammals, Monotremes",@"Mammals, Odd-toed hoofed",@"Mammals, Rodents",@"Mammals, Shrews, Hedgehogs",@"Molluscs",@"Molluscs, Chitons",@"Molluscs, Cuttlefish",@"Molluscs, Gastropods, Slugs, Snails",@"Molluscs, Mussels, Clams",@"Molluscs, Solenogasters",@"Molluscs, Tooth Shells",@"Plants",@"Plants, Conifers, Cycads",@"Plants, Dicots",@"Plants, Ferns and Allies",@"Plants, Flowering plants",@"Plants, Monocots",@"Reptiles",@"Reptiles, Crocodiles",@"Reptiles, Lizards, Snakes",@"Reptiles, Tortoises, Turtles, Terrapins"]},
             
             @{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"notes", FXFormFieldType: FXFormFieldTypeLongText,FXFormFieldPlaceholder: @"", FXFormFieldTitle: @"Observation Notes" },
             
             /*@{@"textLabel.color": [self colorFromHexString: @"#F1582B"],FXFormFieldKey: @"comments", FXFormFieldTitle:@"Notes", FXFormFieldType: FXFormFieldTypeLongText,FXFormFieldPlaceholder: @"" },*/
             ];
}

- (NSArray *)extraFields
{
    return @[
             
             //this field doesn't correspond to any property of the form
             //it's just an action button. the action will be called on first
             //object in the responder chain that implements the submitForm
             //method, which in this case would be the AppDelegate
             
             @{FXFormFieldTitle: @"Save", FXFormFieldHeader: @"", FXFormFieldAction: @"submitLoginForm", @"backgroundColor": [UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:47.0/255.0 alpha:1], @"textLabel.color": [UIColor whiteColor]}
             
             ];
}

// hide these fields. they are autopopulated when a species is selected.
- (NSArray *) excludedFields {
    if(self.speciesPhoto == nil) {
        return @[
                 @"scientificName",
                 @"commonName",
                 @"guid",
                 @"uniqueId",
                 @"photoUrl",
                 @"photoThumbnailUrl",
                 @"photo",
                 @"photoTitle",
                 @"photoAttribution",
                 @"photoLicence",
                 @"photoNotes",
                 @"photoDate",
                 @"uploaded"
                 ];
    } else {
        return @[
                 @"scientificName",
                 @"commonName",
                 @"guid",
                 @"uniqueId",
                 @"photoUrl",
                 @"photoThumbnailUrl",
                 @"uploaded",
                 @"photoTitle",
                 @"photoDate",
                 @"photoNotes"
                 ];
    }
    
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
        [invalidFields addObject: @"\n* Species name"];
    }
    
    if([self location] == nil){
        validity[@"valid"] =  [NSNumber numberWithInt:0];
        [invalidFields addObject: @"\n* Location"];
    }
    
    if([self surveyDate] == nil){
        validity[@"valid"] =  [NSNumber numberWithInt:0];
        [invalidFields addObject: @"\n* Survey date"];
    }
    
    NSString *msg = [NSString stringWithFormat:@"Following mandatory fields are missing:%@", [invalidFields componentsJoinedByString:@", "]];
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

- (NSData *) toJSONData {
    NSDictionary *data = [self toBiocollectFormat];
    NSError *e;
    return [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&e];
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
    
    if(data && [data count] > 0 && data[@"files"] && [data[@"files"] count]){
        NSDictionary *file = data[@"files"][0];
        
        if(!self.photoTitle){
            self.photoTitle = file[@"name"];
        }
        
        if(!self.photoAttribution){
            self.photoAttribution = file[@"attribution"];
        }
        
        if(!self.photoDate) {
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
    
    if(![self.guid isEqual:@""]){
        self.guid = guid;
    } else {
        self.guid = nil;
    }
}
@end
