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
#import "SpeciesGroupTableViewController.h"
#import "HomeViewController.h"
#import "GASettings.h"
#import "HomeTableViewController.h"
#import "RecordsTableViewController.h"

@interface OzHomeVCDelegate()
    @property (nonatomic, strong) RecordsTableViewController *recordsTableView;
    @property (nonatomic, strong) SyncTableViewController *syncViewController;
@end

@implementation OzHomeVCDelegate

-(id) init{
    // location manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // Check authorization status (with class method)
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // User has never been asked to decide on location authorization
    if (status == kCLAuthorizationStatusNotDetermined) {
        //Requesting when in use auth"
        [_locationManager requestWhenInUseAuthorization];
    }
    // User has denied location use (either for this app or for all apps
    else if (status == kCLAuthorizationStatusDenied) {
        // Location services denied"
        // Alert the user and send them to the settings to turn on location
    }

    return self;
}

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

- (void)spotyViewController:(MGSpotyViewController *)spotyViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([HUB_VIEW isEqualToString: [GASettings appView]]) {
        [self hubViewController:spotyViewController didSelectRowAtIndexPath:indexPath];
    } else {
        [self ozAtlasViewController:spotyViewController didSelectRowAtIndexPath:indexPath];
    }
}

- (void)spotyViewController:(MGSpotyViewController *)spotyViewController didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"deselected row");
}

#pragma location delegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_locationManager stopUpdatingLocation];
    NSString *message = nil;
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
            message = @"Please check your network connection";
            break;
        case kCLErrorDenied:
            message = @"Please go to Settings and turn on Location Service for this app.";
            break;
        default:
            message = @"Network error";
            break;
    }

    [RKDropdownAlert title:@"Location Service Error" message:message backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];

}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.curentLocation = newLocation;
}
#pragma mark MKMapViewDelegate

#pragma view based controller
- (void)ozAtlasViewController:(MGSpotyViewController *)spotyViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.row == 0) {
        [self.locationManager startUpdatingLocation];
        RecordViewController *recordViewController = [[RecordViewController alloc] init];
        recordViewController.title = @"Record a Sighting";
        [spotyViewController.navigationController pushViewController:recordViewController animated:TRUE];
        
        [spotyViewController.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if(indexPath.row == 1) {
        if([[appDelegate restCall] notReachable]) {
            [RKDropdownAlert title:@"Device offline" message:@"Please try later!" backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
            return;
        }
        [self.locationManager startUpdatingLocation];
        HomeViewController *homeMapViewController = [[HomeViewController alloc] init];
        homeMapViewController.customView = @"explore";
        homeMapViewController.clLocation =  self.curentLocation;
        NSMutableDictionary *dict = [NSMutableDictionary new];
        dict[@"lat"] = @"0";
        dict[@"lng"] = @"0";
        dict[@"radius"] = @"5";
        homeMapViewController.locationDetails = dict;
        [spotyViewController.navigationController pushViewController:homeMapViewController animated:TRUE];
        
    } else if(indexPath.row == 2) {
        if([[appDelegate restCall] notReachable]) {
            [RKDropdownAlert title:@"Device offline" message:@"Please try later!" backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
            return;
        }
        self.recordsTableView = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
        self.recordsTableView.title = @"My Sightings";
        self.recordsTableView.totalRecords = 0;
        self.recordsTableView.myRecords = 0;
        self.recordsTableView.offset = 0;
        self.recordsTableView.myRecords = TRUE;
        [self.recordsTableView.records removeAllObjects];
        [spotyViewController.navigationController pushViewController:self.recordsTableView animated:TRUE];
    } else if(indexPath.row == 3) {
        if([[appDelegate restCall] notReachable]) {
            [RKDropdownAlert title:@"Device offline" message:@"Please try later!" backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
            return;
        }
        self.recordsTableView = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
        self.recordsTableView.projectId = SIGHTINGS_PROJECT_ID;
        self.recordsTableView.title = @"All Sightings";
        self.recordsTableView.totalRecords = 0;
        self.recordsTableView.offset = 0;
        self.recordsTableView.myRecords = FALSE;
        [self.recordsTableView.records removeAllObjects];
        [spotyViewController.navigationController pushViewController:self.recordsTableView animated:TRUE];
        
    } else if(indexPath.row == 4) {
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
        if([[appDelegate restCall] notReachable]) {
            [RKDropdownAlert title:@"Device offline" message:@"Please try later!" backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
            return;
        }
        NSString *url = [[NSString alloc] initWithFormat:@"https://www.ala.org.au/who-we-are/"];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: url];
        webViewController.title = @"About";
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.ozHomeNC presentViewController:webViewController animated:YES completion:NULL];
    } else if(indexPath.row == 6) {
        if([[appDelegate restCall] notReachable]) {
            [RKDropdownAlert title:@"Device offline" message:@"Please try later!" backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
            return;
        }
        NSString *url = [[NSString alloc] initWithFormat:@"https://www.ala.org.au/about-the-atlas/contact-us/"];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: url];
        webViewController.title = @"Contact";
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.ozHomeNC presentViewController:webViewController animated:YES completion:NULL];
    } else if(indexPath.row == 7) {
        [RKDropdownAlert title:@"Oz Atlas" message:[GASettings appVersion] backgroundColor:[UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Invalid selection."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

}

- (void)hubViewController:(MGSpotyViewController *)spotyViewController didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Supported hub views
    // Projects home page, web view url's
    // HomeTableViewController === hub_projects
    // SVModalWebViewController === web_url
    // SVModalWebViewController === allrecords
    // SVModalWebViewController === myrecords
    
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *menuItems = [[NSBundle mainBundle] objectForInfoDictionaryKey: APP_MENU];

    if([menuItems count] > indexPath.row) {
        NSDictionary *menuAttributes = menuItems [indexPath.row];
        if([[menuAttributes objectForKey:@"view"] isEqualToString:@"hub_projects"]) {
            HomeTableViewController *homeVC = [[HomeTableViewController alloc] initWithNibName:@"HomeTableViewController" bundle:nil];
            homeVC.title = [menuAttributes objectForKey:@"title"];
            [spotyViewController.navigationController pushViewController: homeVC animated:TRUE];
        } else if([[menuAttributes objectForKey:@"view"] isEqualToString:@"my_hub_projects"]) {
            HomeTableViewController *homeVC = [[HomeTableViewController alloc] initWithNibName:@"HomeTableViewController" bundle:nil];
            homeVC.isUserPage = TRUE;
            homeVC.title = [menuAttributes objectForKey:@"title"];
            [spotyViewController.navigationController pushViewController: homeVC animated:TRUE];
        } else if([[menuAttributes objectForKey:@"view"] isEqualToString:@"hub_all_records"]){
            RecordsTableViewController *recordsVC = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
            recordsVC.title = [menuAttributes objectForKey:@"title"];
            [spotyViewController.navigationController pushViewController: recordsVC animated:TRUE];
        } else if([[menuAttributes objectForKey:@"view"] isEqualToString:@"my_hub_records"]){
            RecordsTableViewController *recordsVC = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
            recordsVC.myRecords = TRUE;
            recordsVC.title = [menuAttributes objectForKey:@"title"];
            [spotyViewController.navigationController pushViewController: recordsVC animated:TRUE];
        } else if([[menuAttributes objectForKey:@"view"] isEqualToString:@"web_url"]) {
            NSString *url = [[NSString alloc] initWithFormat:@"%@%@", BIOCOLLECT_SERVER, [menuAttributes objectForKey:@"url"]];
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: url];
            webViewController.title = [menuAttributes objectForKey:@"title"];
            GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.ozHomeNC presentViewController:webViewController animated:YES completion:NULL];
        } else if([[menuAttributes objectForKey:@"view"] isEqualToString:@"web_external_url"]) {
            NSString *url = [[NSString alloc] initWithFormat:@"%@", [menuAttributes objectForKey:@"url"]];
            SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: url];
            webViewController.title = [menuAttributes objectForKey:@"title"];
            GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.ozHomeNC presentViewController:webViewController animated:YES completion:NULL];
        } else if([[menuAttributes objectForKey:@"view"] isEqualToString:@"version"]) {
            [RKDropdownAlert title:[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"] message:[GASettings appVersion] backgroundColor:[UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
        }else {
            DebugLog(@"ERROR",@"Unsupported hub view.")
        }
    }
}

@end
