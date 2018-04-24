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
                            @"trackmetadataviewcontroller.title" : @"1. Track details",
                            @"sighting.title" : @"2. Animal signs",
                            @"map.title" : @"3. Walked route",
                            
                            @"trackmetadata.trackerinfo": @"1. Tracker details",
                            @"trackmetadata.organisationname": @"Organisation name *",
                            @"trackmetadata.leadTracker": @"Lead tracker *",
                            @"trackmetadata.otherTrackers": @"Other trackers",
                            @"trackmetadata.comments": @"Comments",
                            @"trackmetadata.save": @"Save",
                            
                            @"trackmetadata.trackinginfo": @"2. Tracking details",
                            @"trackmetadata.eventdate": @"Trek Date *",
                            @"trackmetadata.eventstarttime": @"Start time *",
                            @"trackmetadata.eventendtime": @"End time *",
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
                            
                            @"sighting.viewcontroller.title": @"Add an animal sign *",
                            @"sighting.animal": @"Which animal made the sign? *",
                            @"sighting.photo": @"Photo",
                            @"sighting.visiblesign": @"What sign did you see?",
                            @"sighting.durationsign": @"How old is the sign?",
                            @"sighting.age": @"How old is the animal?",
                            @"sighting.notfound": @"To add an animal sign, touch the '+' button above.",
                            @"sighting.notfound.helptext": @"You must add at least one animal sign. If no animal sign is found, use the 'No animal found' selection.",
                            @"sighting.save": @"Add",
                            @"sighting.update": @"Update",
                            @"sighting.unknown": @"Please select an animal. This field is mandatory. *",
                            @"sighting.details.sign": @"Sign - %@",
                            @"sighting.details.age": @"Age - %@",
                            
                            @"tracklist.notfound": @"No saved tracks",
                            @"tracklist.notfound.helptext": @"To add a track, go back to the main menu and select 'Create a new track'.",
                            
                            @"trackmetadata.modal.title": @"",
                            @"trackmetadata.modal.content": @"Click 'Record my route' if you want to continue tracking. Otherwise, click 'Edit track data' to edit track information you submitted.",
                            @"trackmetadata.modal.record": @"Record my route",
                            @"trackmetadata.modal.cancel": @"Edit track data",
                            
                            @"uploading.message": @"Uploading tracks...",
                            @"uploaded.message": @"Uploaded %d of %d",
                            @"uploaded.noTracksToUpload": @"No valid tracks to upload",
                            @"uploadfinish.message": @"Successfully uploaded %d track(s)",
                            
                            @"upload.error": @"Some of the tracks are not submitted, please try again later.",
                            @"upload.accessDenied": @"You are not authorised to submit tracks, please contact our support team at biocollect-support@ala.org.au",
                            
                            @"tracklistviewcontroller.title": @"Upload or edit saved tracks",
                            @"trackviewcontroller.button.back": @"Back",
                            
                            @"trackmetadata.confirmexit.title": @"Delete this track?",
                            @"trackmetadata.confirmexit.message": @"Click 'Yes' to delete this track and go to main menu. Otherwise, click 'No' to remain on this page.",
                            @"trackmetadata.confirmexit.no": @"No",
                            @"trackmetadata.confirmexit.yes": @"Yes",
                            
                            @"camera.error.title": @"Error",
                            @"camera.error.message": @"Device has no camera",
                            @"camera.error.ok": @"Ok",
                            
                            @"trackmetadata.confirmsave.title": @"",
                            @"trackmetadata.confirmsave.message": @"Click 'Save' to save track to device and continue working on it. Otherwise, Click 'Save & go back' to save this track to device and go back to main menu.",
                            @"trackmetadata.confirmsave.message.gotolist": @"Click 'Save' to save track to device and continue working on it. Otherwise, Click 'Save & go back' to save this track to device and go back to page showing list of saved tracks.",
                            @"trackmetadata.confirmsave.continue": @"Save",
                            @"trackmetadata.confirmsave.exit": @"Save & go back",

                            @"nointernetconnectivity.title": @"No internet connection",
                            @"nointernetconnectivity.message": @"Cannot upload tracks since there is no internet connection. Try again later.",
                            @"nointernetconnectivity.ok": @"Ok",
                            
                            @"animalFormat": @"Animals - %d;",
                            @"durationFormat": @"Duration - %@;",
                            @"distanceTravlledFormat": @"Distance travelled - %@;",
                            
                            @"tracks.upload": @"Upload all"
                            }
                    };
    return self;
}

- (NSString *)get:(NSString *) label {
    return translation[language][label];
}

@end
