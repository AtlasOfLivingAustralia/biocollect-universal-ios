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
                            @"sighting.animal": @"Which animal did you see? *",
                            @"sighting.photo": @"Photo",
                            @"sighting.visiblesign": @"What sign did you see?",
                            @"sighting.durationsign": @"How old is the sign?",
                            @"sighting.age": @"How old is the animal?",
                            @"sighting.notfound": @"To add an animal sign, touch the '+' button above.",
                            @"sighting.notfound.helptext": @"You must add at least one animal sign. If no animal signs were found, use the 'No animal found' selection.",
                            @"sighting.save": @"Done",
                            
                            @"tracklist.notfound": @"No tracks found",
                            @"tracklist.notfound.helptext": @"To add a track, go back to the main menu and select 'Add a track' menu item.",
                            
                            @"trackmetadata.modal.title": @"Continue your journey?",
                            @"trackmetadata.modal.content": @"Click 'Yes' if you want to continue recording your journey. Otherwise, click 'No' to edit submitted information.",
                            @"trackmetadata.modal.record": @"Yes",
                            @"trackmetadata.modal.cancel": @"No",
                            
                            @"uploading.message": @"Uploading tracks...",
                            @"uploaded.message": @"Uploaded %d of %d",
                            @"uploaded.noTracksToUpload": @"No valid tracks to upload",
                            @"uploadfinish.message": @"Successfully uploaded %d tracks",
                            
                            @"upload.error": @"Some of the tracks are not submitted, please try again later.",
                            @"upload.accessDenied": @"You are not authorised to submit tracks, please contact our support team at biocollect-support@ala.org.au",
                            
                            @"tracklistviewcontroller.title": @"Upload or edit saved tracks",
                            
                            @"trackmetadata.confirmexit.title": @"Go back without saving?",
                            @"trackmetadata.confirmexit.message": @"Click 'No' to continue recording your journey. Click 'Save & exit' to save and go back to previous page. Otherwise, click 'Yes' to delete this track and go back to previous page.",
                            @"trackmetadata.confirmexitwithoutdelete.message": @"Click 'No' to continue on this page. Click 'Save & exit' to save and go back to previous page.",
                            @"trackmetadata.confirmexit.no": @"No",
                            @"trackmetadata.confirmexit.yes": @"Yes",
                            @"trackmetadata.confirmexit.exit": @"Save & exit",
                            
                            @"camera.error.title": @"Error",
                            @"camera.error.message": @"Device has no camera",
                            @"camera.error.ok": @"Ok",
                            
                            @"trackmetadata.confirmsave.title": @"Save your track to disk?",
                            @"trackmetadata.confirmsave.message": @"Click 'Save & continue' to save to disk and continue your journey. Click 'Save & exit' to save your track to disk and go back to previous page.",
                            @"trackmetadata.confirmsave.continue": @"Save & continue",
                            @"trackmetadata.confirmsave.exit": @"Save & exit",

                            @"nointernetconnectivity.title": @"No internet connectivity",
                            @"nointernetconnectivity.message": @"Cannot upload tracks due to no internet connectivity. Try again later.",
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
