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

@implementation TrackListViewController

- (instancetype) init {
    self = [super init];
    
    GAAppDelegate* appDelegate = (GAAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.service = appDelegate.trackerService;
    
    return self;
}

#pragma mark - view
- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewStylePlain;
    self.tableView.tableFooterView = [UIView new];
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
        cell.imageView.image = form.countryPhoto;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [self.service.tracks count] == 0 ? NO : YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MetadataForm* form = self.service.tracks[indexPath.row];
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
@end