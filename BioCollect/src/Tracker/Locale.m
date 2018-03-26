//
//  Locale.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 26/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "Locale.h"

@implementation Locale: NSObject
- (id)init{
    self = [super init];
    language = @"en";
    translation = @{
                    @"en" : @{
                            @"trackviewcontroller.title" : @"Track",
                            @"trackmetadataviewcontroller.title" : @"Track details",
                            @"sighting.title" : @"Animals spotted",
                            @"map.title" : @"Journey",
                            
                            @"trackmetadata.trackerinfo": @"1. Tracker details",
                            @"trackmetadata.organisationname": @"Organisation name",
                            @"trackmetadata.leadTracker": @"Lead tracker",
                            @"trackmetadata.otherTrackers": @"Other trackers",
                            @"trackmetadata.comments": @"Comments",
                            @"trackmetadata.save": @"Done",
                            
                            @"trackmetadata.trackinginfo": @"2. Tracking details",
                            @"trackmetadata.eventdate": @"Trek Date",
                            @"trackmetadata.eventstarttime": @"Start time",
                            @"trackmetadata.eventendtime": @"End time",
                            @"trackmetadata.surveytype": @"Survey type",
                            @"trackmetadata.surveychoice": @"Survey choice",
                            
                            @"trackmetadata.country": @"3. Country",
                            @"trackmetadata.countryname" : @"Country name",
                            @"trackmetadata.countrytype" : @"Country type",
                            @"trackmetadata.vegetationtype" : @"Vegetation type",
                            @"trackmetadata.foodplant" : @"Food plant",
                            @"trackmetadata.timesincefire" : @"How long since fire?",
                            @"trackmetadata.countryphoto" : @"Country photo",
                            
                            @"trackmetadata.trackability": @"4. Trackability",
                            @"trackmetadata.clearground": @"How much clear ground for tracking?",
                            @"trackmetadata.disturbance": @"Have tracks been disturbed?",
                            @"trackmetadata.groundsoftness": @"How soft is the ground for leaving tracks?",
                            @"trackmetadata.weather": @"Weather?",
                            
                            @"sighting.title": @"Add an animal",
                            @"sighting.animal": @"Animal",
                            @"sighting.photo": @"Photo",
                            @"sighting.visiblesign": @"What sign did you see?",
                            @"sighting.durationsign": @"How old is the sign?",
                            @"sighting.age": @"How old is the animal?",
                            @"sighting.notfound": @"No animals spotted",
                            @"sighting.notfound.helptext": @"To add an animal, touch the '+' button above.",
                            @"sighting.save": @"Done",
                            
                            @"tracklist.notfound": @"No tracks found",
                            @"tracklist.notfound.helptext": @"To add a track, go back to the main menu and select 'Add a track' menu item.",
                            
                            @"trackmetadata.modal.title": @"Do you want to continue tracking?",
                            @"trackmetadata.modal.content": @"If you want the system to continue recording your location, click 'Yes'. Otherwise, to review data click 'Review'",
                            @"trackmetadata.modal.record": @"Yes",
                            @"trackmetadata.modal.cancel": @"Review"
                            }
                    };
    return self;
}

- (NSString *)get:(NSString *) label {
    return translation[language][label];
}

@end
