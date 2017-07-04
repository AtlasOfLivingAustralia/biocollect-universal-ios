//
//  OzHomeDelegate.m
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 14/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "OzHomeVCDelegate.h"
#import "MGSpotyViewController.h"
#import "RecordViewController.h"
#import "RecordsTableViewController.h"
#import "GASettingsConstant.h"
#import "RecordsTableViewController.h"
#import "SyncTableViewController.h"
#import "GAAppDelegate.h"
#import "RKDropdownAlert.h"

@interface OzHomeVCDelegate()
    @property (nonatomic, strong) RecordsTableViewController *recordsTableView;
    @property (nonatomic, strong) SyncTableViewController *syncViewController;
@end

@implementation OzHomeVCDelegate

#pragma mark - MGSpotyViewControllerDelegate


- (CGFloat)spotyViewController:(MGSpotyViewController *)spotyViewController
       heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (CGFloat)spotyViewController:(MGSpotyViewController *)spotyViewController
      heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (NSString *)spotyViewController:(MGSpotyViewController *)spotyViewController
          titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (void)spotyViewController:(MGSpotyViewController *)spotyViewController scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%1.2f", scrollView.contentOffset.y);
}

- (void)spotyViewController:(MGSpotyViewController *)spotyViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        RecordViewController *recordViewController = [[RecordViewController alloc] init];
        recordViewController.title = @"Record a Sighting";
        [spotyViewController.navigationController pushViewController:recordViewController animated:TRUE];
        NSLog(@"selected row");
        [spotyViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if(indexPath.row == 1) {
        [RKDropdownAlert title:@"Explore Species - Under development." message:@"" backgroundColor:[UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    } else if(indexPath.row == 2) {
        self.recordsTableView = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
        self.recordsTableView.title = @"My Sightings";
        self.recordsTableView.totalRecords = 0;
        self.recordsTableView.myRecords = 0;
        self.recordsTableView.offset = 0;
        self.recordsTableView.myRecords = TRUE;
        [self.recordsTableView.records removeAllObjects];
        [spotyViewController.navigationController pushViewController:self.recordsTableView animated:TRUE];
    } else if(indexPath.row == 3) {
        self.recordsTableView = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
        self.recordsTableView.projectId = SIGHTINGS_PROJECT_ID;
        self.recordsTableView.title = @"All Sightings";
        self.recordsTableView.totalRecords = 0;
        self.recordsTableView.offset = 0;
        self.recordsTableView.myRecords = FALSE;
        [self.recordsTableView.records removeAllObjects];
        [spotyViewController.navigationController pushViewController:self.recordsTableView animated:TRUE];
        
    } else if(indexPath.row == 4) {
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        if([appDelegate.records count] == 0) {
            [RKDropdownAlert title:@"No draft sightings available" message:@"" backgroundColor:[UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];

        } else {
            if(self.syncViewController == nil){
                self.syncViewController = [[SyncTableViewController alloc] initWithNibName:@"SyncTableViewController" bundle:nil];
                self.syncViewController.title = @"Draft Sightings";
            }
            
            [spotyViewController.navigationController pushViewController:self.syncViewController animated:TRUE];
            
            if(appDelegate.projectsModified){
                appDelegate.projectsModified = NO;
                [self.syncViewController.tableView reloadData];
            }
            [spotyViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else if(indexPath.row == 5) {
        NSString *url = [[NSString alloc] initWithFormat:@"https://www.ala.org.au/about-the-atlas"];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: url];
        webViewController.title = @"About the ALA";
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.ozHomeNC presentViewController:webViewController animated:YES completion:NULL];
        
    } else if(indexPath.row == 6) {
        NSString *url = [[NSString alloc] initWithFormat:@"https://www.ala.org.au/about-the-atlas/contact-us/"];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: url];
        webViewController.title = @"Contact the ALA";
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.ozHomeNC presentViewController:webViewController animated:YES completion:NULL];
    }    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Invalid selection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)spotyViewController:(MGSpotyViewController *)spotyViewController didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselected row");
}

@end
