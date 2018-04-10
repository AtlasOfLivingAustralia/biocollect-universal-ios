//
//  TrackListViewController.m
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 22/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "TrackListViewController.h"
#import "GAAppDelegate.h"
#import "TrackViewController.h"
#import "MRProgressOverlayView.h"
#import "RKDropdownAlert.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#define backgroundColour "#f2dede"

@implementation TrackListViewController

- (instancetype) init {
    self = [super init];
    
    self.appDelegate = (GAAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(uploadProgressing) name: @"UPLOADED-TRACK" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(uploadComplete:) name: @"TRACK-UPLOADING-COMPLETE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(uploadErrorNotAuthorized:) name: @"UPLOADING-ERROR-NOT-AUTHORIZED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(uploadCompleteWithError:) name: @"UPLOADING-ERROR-COMPLETE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self.tableView selector: @selector(reloadData) name: @"TRACK-SAVED" object:nil];
    
    return self;
}

#pragma mark - view
- (void) viewDidLoad {
    [super viewDidLoad];
    self.service = [self.appDelegate trackerService];
    
    self.title = [self.appDelegate.locale get: @"tracklistviewcontroller.title"];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewStylePlain;
    self.tableView.tableFooterView = [UIView new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonItemStylePlain target:self action:@selector(uploadData)];
}

#pragma mark - Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger size = [self.service.tracks count] == 0 ? 1 : [self.service.tracks count];
    
    return size;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackList" ];
    if(!cell){
        // Configure the cell...
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TrackList"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.autoresizesSubviews = YES;
    }
    
    if ([self.service.tracks count] == 0) {
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;
        
        cell.textLabel.text = [locale get: @"tracklist.notfound"];
        cell.detailTextLabel.text = [locale get: @"tracklist.notfound.helptext"];
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        MetadataForm *form = (MetadataForm *) self.service.tracks[indexPath.row];
        cell.textLabel.text = form.organisationName;
        cell.detailTextLabel.text = form.leadTracker;
        //cell.imageView.image = form.countryPhoto;
        if ([form isValid]) {
            cell.imageView.image = [UIImage imageNamed:@"yes"];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = [UIImage imageNamed:@"no"];
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [self.service.tracks count] == 0 ? NO : YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MetadataForm* form = self.service.tracks[indexPath.row];
        [form deleteImages];
        [self.service removeTrack:form];
        [self.tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TRACK-REMOVED" object: form];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.service.tracks count] > 0) {
        MetadataForm *form = self.service.tracks[indexPath.row];
        TrackViewController *vc = [[TrackViewController alloc] initWithForm: form];
        [self.navigationController pushViewController:vc animated:YES];
        
        GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: [locale get: @"trackmetadata.modal.title"]
                                                                       message: [locale get: @"trackmetadata.modal.content"]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* recordAction = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.modal.record"] style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 form.endTime = nil;
                                                                 [vc.trackMetadataViewController.formController.tableView reloadData];
                                                                 [form startRecordingLocation];
                                                             }];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle: [locale get: @"trackmetadata.modal.cancel"] style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
        
        [alert addAction:recordAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

# pragma mark - selector
- (void) uploadData {
    if ([self isInternet]) {
        GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray* validForms = [[NSMutableArray alloc] init];
            for( int i = 0; i < [self.service.tracks count]; i++) {
                MetadataForm* form = [self.service.tracks objectAtIndex:i];
                
                if ([form isValid]) {
                    [validForms addObject:form];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
                Locale* locale = appDelegate.locale;
                
                totalTracksToUpload = [validForms count];
                totalTracksUploaded = 0;
                if(totalTracksToUpload == 0) {
                        [RKDropdownAlert title:[locale get: @"uploaded.noTracksToUpload"] message:@"" backgroundColor: [self colorFromHexString:@"#F1582B"] textColor: [UIColor whiteColor] time:5];
                } else {
                    [self updateMessage];
                }
            });
            
            if ([validForms count] > 0) {
                [appDelegate.tracksUpload uploadTracks:validForms andUpdateError:nil];
            }
        });
    } else {
        [self displayNoInternetAlert];
    }
}

- (void) uploadProgressing {
    totalTracksUploaded +=1;
    [self updateMessage];
}

- (void) updateMessage {
    GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    NSString* message = [locale get: @"uploaded.message"];
    message = [NSString stringWithFormat:message, totalTracksUploaded, totalTracksToUpload];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (overlay != nil) {
            [overlay setTitleLabelText:message];
        } else {
            overlay = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view title:message mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        }
    });
}

- (void) uploadComplete: (NSNotification *) notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;

        NSArray<MetadataForm*>* uploadedObjects = notification.object;
        for(int i = 0; i < [uploadedObjects count]; i ++ ) {
            [uploadedObjects[i] deleteImages];
        }

        [self.service removeTracks:uploadedObjects];
        [self.tableView reloadData];
        
        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
        overlay = nil;
        
        NSString* message = [NSString stringWithFormat:[locale get: @"uploadfinish.message"], totalTracksUploaded];
        [RKDropdownAlert title:message message:@"" backgroundColor: [self colorFromHexString:@"#4cbc4c"] textColor: [UIColor whiteColor] time:5];
    });
}

- (void) uploadCompleteWithError: (NSNotification *) notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;
        
        NSArray<MetadataForm*>* uploadedObjects = notification.object;
        for(int i = 0; i < [uploadedObjects count]; i ++ ) {
            [uploadedObjects[i] deleteImages];
        }
        
        [self.service removeTracks:uploadedObjects];
        [self.tableView reloadData];
        
        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
        overlay = nil;
        [[[UIAlertView alloc] initWithTitle:@"ERROR"
                                    message:[locale get: @"upload.error"]
                                   delegate: nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    });
}

- (void) uploadErrorNotAuthorized: (NSNotification *) notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;
        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
        overlay = nil;
        [[[UIAlertView alloc] initWithTitle:@"ERROR"
                                    message:[locale get: @"upload.accessDenied"]
                                   delegate: nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    });
}



#pragma mark - helper function
-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (BOOL) isInternet {
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    return status != NotReachable;
}

- (void) displayNoInternetAlert {
    GAAppDelegate* appDelegate = (GAAppDelegate*) [[UIApplication sharedApplication] delegate];
    Locale* locale = appDelegate.locale;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: [locale get: @"nointernetconnectivity.title"]
                                                                   message: [locale get: @"nointernetconnectivity.message"]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle: [locale get: @"nointernetconnectivity.ok"] style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
