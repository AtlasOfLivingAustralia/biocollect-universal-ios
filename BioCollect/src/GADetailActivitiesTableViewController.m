//
//  GADetailFormViewController.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GADetailActivitiesTableViewController.h"
#import "GADetailFormViewController.h"
#import "GAAppDelegate.h"
#import "GAActivity.h"
#import "GAProjectsUtil.h"
#import "MRProgressOverlayView.h"
#import "GASettings.h"
#import <CoreLocation/CLLocation.h>
#import "GACreateSiteModalViewController.h"


@interface GADetailActivitiesTableViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) GAProjectsUtil *projectsUtil;
@property (strong, nonatomic) UIActionSheet *actionSheetShare;
- (void)configureView;
@end

@implementation GADetailActivitiesTableViewController

#define TOTAL_SECTION 3
#define kUI_ALERT_SIGNOUT_CONFIRMATION_TAG 1
#define kUI_ALERT_SIGNOUT_WARNING_TAG kUI_ALERT_SIGNOUT_CONFIRMATION_TAG + 1
#define kUI_ALERT_SIGNOUT_SECOND_CONFIRMATION_TAG kUI_ALERT_SIGNOUT_WARNING_TAG + 1
#define kUI_ALERT_SIGNOUT_THIRD_CONFIRMATION_TAG kUI_ALERT_SIGNOUT_SECOND_CONFIRMATION_TAG +1

#define kDetailLargeDistanceNumber @"99999999999999999999999999999"

@synthesize projects, projectIndex, project, projectsUtil,isSearching,filteredActivityList,locationMgr,tempLocation,formWebView;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
     // Update the view.
    [self configureView];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle: (NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Activities", @"Activities");
        self.projects = [[NSMutableArray alloc]init];
        self.filteredActivityList = [[NSMutableArray alloc] init];
        self.isSearching = NO;
        
        locationMgr = [[CLLocationManager alloc] init];
        locationMgr.distanceFilter = kCLDistanceFilterNone;
        locationMgr.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationMgr.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationMgr requestWhenInUseAuthorization];
        }
        [locationMgr startUpdatingLocation];
        
        UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Recalculating distance between your location and site"];
        [refresh addTarget:self action:@selector(refreshProjects)
          forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refresh;
        
        UIBarButtonItem *createSite = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"site_map"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self action:@selector(createSite)];
        UIBarButtonItem *signout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"lock_filled-25"]
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self action:@selector(checkWithUserBeforeSignout)];
        UIBarButtonItem *actionSheet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action-25"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self action:@selector(actionPhotoShare:)];
        
        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync-25"] style:UIBarButtonItemStyleBordered
                                                                      target:self action:@selector(syncProjects)];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:signout,createSite,syncButton,actionSheet, nil];

    }
    projectsUtil = [[GAProjectsUtil alloc]init];
    return self;
}

- (void)refreshProjects {
    [self updateActivityTableModel: [self.projects mutableCopy]];
    [self.refreshControl endRefreshing];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //[self updateActivityTableModel:self.projects];
   
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

-(void) syncProjects{
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate uploadAndDownload:false];
}
-(void) viewWillAppear:(BOOL)animated{
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([locationMgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationMgr requestWhenInUseAuthorization];
    }
    [locationMgr startUpdatingLocation];
}

-(void) viewWillDisappear:(BOOL)animated {
    [locationMgr stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DebugLog(@"[WARN] DetailActivities:locationManager Location service disabled. %@",[error localizedDescription]);
}

-(void) createSite{
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    GACreateSiteModalViewController *siteVC = [[GACreateSiteModalViewController alloc] initWithNibName:@"GACreateSiteModalViewController" bundle:nil];
    UINavigationController *siteNC =  [[UINavigationController alloc] initWithRootViewController:siteVC];
    
   [siteNC.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    siteNC.navigationBar.shadowImage = [UIImage new];
    siteNC.navigationBar.translucent = YES;
    siteNC.view.backgroundColor = [UIColor clearColor];
    
   
    
    [siteVC setDelegate:self];
    [appDelegate.window.rootViewController presentViewController:siteNC animated:true completion:nil];
}

- (void)siteCreated : (GASite *) site {
    site.projectId = self.project.projectId;
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.sqlLite insertProjectSites:site.projectId :site];
    [appDelegate.sqlLite insertSite:site];
    [appDelegate updateTableModelsAndViews:[appDelegate.sqlLite loadProjectsAndActivities]];
}

-(void)actionPhotoShare:(id)sender
{
    if(self.actionSheetShare == nil){
        self.actionSheetShare = [[UIActionSheet alloc] initWithTitle:@"SORT BY ACTIVITY"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Type", @""),
                                                                NSLocalizedString(@"Status", @""),
                                                                NSLocalizedString(@"Planned start date",@""),
                                                                NSLocalizedString(@"Sync status",@""),
                                                                NSLocalizedString(@"Site",@""),
                                                                nil];
    }
    [self.actionSheetShare showFromBarButtonItem:sender animated:YES];
}
-(void)actionSheetCancel:(UIActionSheet *)actionSheet{
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [GASettings setSortBy: [NSString stringWithFormat: @"%d", (int)buttonIndex]];
    [self updateActivityTableModel : [self.projects mutableCopy]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)filterActivityListForSearchText:(NSString *)searchText
{
    [self.filteredActivityList removeAllObjects];
    
    for (GAActivity *act in self.project.activities) {
        NSRange nameRange = [act.activityName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (nameRange.location != NSNotFound) {
            [self.filteredActivityList addObject:act];
        }
        else {
             NSRange nameRange = [act.plannedStartDate rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (nameRange.location != NSNotFound) {
                [self.filteredActivityList addObject:act];
            }
            else{
                NSRange nameRange = [act.description rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (nameRange.location != NSNotFound) {
                    [self.filteredActivityList addObject:act];
                }
            }
        }
    }
}

-(void) updateActivityTableModel : (NSMutableArray *) p{
    [self.projects removeAllObjects];
    [self.projects addObjectsFromArray:p];

    //Assign the active project
    if([p count] > 0) {
        self.project = [self.projects objectAtIndex:self.projectIndex];
        self.title = [[NSString alloc] initWithFormat:@"%@",project.projectName];
    }
    else
        self.title = [[NSString alloc] initWithFormat:@"No projects available for %@",[GASettings getEmailAddress]];

    //populate distance fields based upon location.
    for (GAActivity *act in self.project.activities) {
        if(act.site != nil) {
            CLLocationDegrees latitude = [act.site.latitude doubleValue];
            CLLocationDegrees longitude = [act.site.longitude doubleValue];
            CLLocation *location = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
            CLLocationDistance distanceMeters = [locationMgr.location distanceFromLocation:location];
            act.distance = [@(distanceMeters) stringValue];
        }
        else{
            act.distance = kDetailLargeDistanceNumber;
        }
    }
    
    //Apply the sorting order.
    int sortBy = (int)[[GASettings getSortBy] integerValue];
    if([self.projects count] > 0){
        for(int i=0; i < [self.projects count]; i++){
            GAProject * act = [self.projects objectAtIndex:i];
            if(sortBy == ACTIVITY_SORT_BY_PROGRESS)
                [act.activities sortUsingSelector:@selector(compareByProgress:)];
            else if (sortBy == ACTIVITY_SORT_BY_PLANNED_STARTING_DATE)
                [act.activities sortUsingSelector:@selector(compareByPlannedStartingDate:)];
            else if (sortBy == ACTIVITY_SORT_BY_SYNC)
                [act.activities sortUsingSelector:@selector(compareBySync:)];
            else if (sortBy == ACTIVITY_SORT_BY_LOCATION)
                [act.activities sortUsingSelector:@selector(compareByDistance:)];
            else
                [act.activities sortUsingSelector:@selector(compareByName:)];
        }
    }
    
    if([GASettings getDataToSync] != nil && [[GASettings getDataToSync] isEqualToString:kDataToSyncTrue]){
        self.searchDisplayController.searchBar.backgroundImage = [UIImage imageNamed:@"search_bk_red"];
    }else{
        self.searchDisplayController.searchBar.backgroundImage = [UIImage imageNamed:@"searchbar_bk"];
    }

    [self.tableView reloadData];
}

#pragma mark - User menu action.

-(void) checkWithUserBeforeSignout{
    
    if([GASettings getDataToSync] != nil && [[GASettings getDataToSync] isEqualToString:kDataToSyncTrue]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                        message:@"Upload the changes and log out?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
        alert.tag = kUI_ALERT_SIGNOUT_CONFIRMATION_TAG;
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                        message:@"Are you sure you want to logout?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes",nil];
        alert.tag = kUI_ALERT_SIGNOUT_WARNING_TAG;
        [alert show];
    }
    
   
}


-(void) signout{
    
    [self.actionSheetShare dismissWithClickedButtonIndex:0 animated:NO];
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [MRProgressOverlayView showOverlayAddedTo:appDelegate.window title:@"Uploading.." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *e;
        NSString *uploadMessage = [appDelegate uploadChangedActivities : &e];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:NO];
            if(e == nil){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                                message:uploadMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Logout",nil];
                alert.tag = kUI_ALERT_SIGNOUT_THIRD_CONFIRMATION_TAG;
                [alert show];
            }else{
                NSString *message = [[NSString alloc] initWithFormat:@"%@\nLogging out now will discard the changes.",[e localizedDescription]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Try again later"
                                                      otherButtonTitles:@"Logout",nil];
                alert.tag = kUI_ALERT_SIGNOUT_SECOND_CONFIRMATION_TAG;
                [alert show];
            }
        });
    });
}

#pragma mark - UIAlert view delegate.

- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if(actionSheet.tag == kUI_ALERT_SIGNOUT_CONFIRMATION_TAG){
        if( buttonIndex == 0 ) {
            /*Do nothing*/
        }
        else {
            [self signout];
        }
    }
    else if(actionSheet.tag == kUI_ALERT_SIGNOUT_SECOND_CONFIRMATION_TAG ||
            actionSheet.tag == kUI_ALERT_SIGNOUT_THIRD_CONFIRMATION_TAG ||
            actionSheet.tag == kUI_ALERT_SIGNOUT_WARNING_TAG
            ){
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        if( buttonIndex == 0 ) {
            /*Do nothing*/
        }
        else {
            [appDelegate displaySigninPage];
        }
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem: (UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    
    UIBarButtonItem *newBut = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-25"] style:UIBarButtonItemStyleBordered target: barButtonItem.target action: barButtonItem.action];
    barButtonItem = newBut;
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view,
    //invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    // Return the number of rows in the section.
    if (isSearching) {
        return [self.filteredActivityList count];
    }
    else {
        return [self.project.activities count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.isSearching) {
        return @"";
    }
    
    int sortBy = (int)[[GASettings getSortBy] integerValue];
    switch (sortBy) {
        case ACTIVITY_SORT_BY_PLANNED_STARTING_DATE:
            return [[NSString alloc]initWithFormat:@"%lu %@",(unsigned long)[self.project.activities count], @"ACTIVITIES SORTED BY PLANNED START DATE"];
            break;
        case ACTIVITY_SORT_BY_PROGRESS:
            return [[NSString alloc]initWithFormat:@"%d %@",(int)[self.project.activities count], @"ACTIVITIES SORTED BY PROGRESS STATUS"];
            break;
        case ACTIVITY_SORT_BY_NAME:
            return [[NSString alloc]initWithFormat:@"%d %@",(int)[self.project.activities count], @"ACTIVITIES SORTED BY TYPE"];
            break;
        case ACTIVITY_SORT_BY_SYNC:
            return [[NSString alloc]initWithFormat:@"%d %@",(int)[self.project.activities count], @"ACTIVITIES SORTED BY SYNC STATUS"];
            break;
        case ACTIVITY_SORT_BY_LOCATION:
            return [[NSString alloc]initWithFormat:@"%d %@",(int)[self.project.activities count], @"ACTIVITIES SORTED BY SITE"];
            break;
        default:
            return @"ACTIVITIES";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    GAActivity *activity = nil;
    if (isSearching && [self.filteredActivityList count]) {
        activity = [self.filteredActivityList objectAtIndex:indexPath.row];
    } else {
        activity = [self.project.activities objectAtIndex:indexPath.row];
    }

    cell.textLabel.text = [[NSString alloc]initWithFormat:@"%@",activity.activityName];
    NSArray *plannedDateArray = [activity.plannedStartDate componentsSeparatedByString: @"T"];
    NSString *plannedDateStr = [plannedDateArray objectAtIndex: 0];

    NSString *detailText = nil;
    
    if(activity.site != nil && [activity.distance length] > 0){
        NSString *distance = activity.distance;
        double km = [distance doubleValue]/1000;
        NSString *kmStr = [[NSString alloc] initWithFormat:@"%.2f km", km];

        if([activity.distance isEqualToString:kDetailLargeDistanceNumber])
            detailText = [[NSString alloc]initWithFormat:@"%@, %@",plannedDateStr,activity.description];
        else{
            detailText = [[NSString alloc]initWithFormat:@"%@, %@",plannedDateStr,activity.description];
            cell.textLabel.text = [[NSString alloc]initWithFormat:@"%@ - %@ ",cell.textLabel.text,kmStr];
        }
    }
    else {
        detailText = [[NSString alloc]initWithFormat:@"%@, %@",plannedDateStr,activity.description];
    }
    
    cell.detailTextLabel.text = detailText;
    
    NSString *fileName = nil;

    if(activity.status == ACTIVITY_CHANGED)
        fileName = @"changed";
    else
        fileName = @"nochange";
    
    if([activity.distance length] > 0 && ![activity.distance isEqualToString:kDetailLargeDistanceNumber] && activity.status == ACTIVITY_CHANGED)
        fileName = @"loc1_changed";
    else if([activity.distance length] > 0 && ![activity.distance isEqualToString:kDetailLargeDistanceNumber] && activity.status == ACTIVITY_NO_CHANGE)
        fileName = @"loc1_nochange";
     
    cell.imageView.image = [UIImage imageNamed:fileName];

    cell.accessoryView = [[UIImageView alloc ]
                            initWithImage:[UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@",activity.progress]]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; // Return NO if you do not want the specified item to be editable.
}

- (void)tableView:(UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into
        //the array, and add a new row to the table view.
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:
 (NSIndexPath *) fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:
 (NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    self.formWebView = [[GADetailFormVIewController alloc] initWithNibName:@"GADetailFormVIewController" bundle:nil];
    GAActivity *activity = nil;
    if (isSearching && [self.filteredActivityList count]) {
        activity = [self.filteredActivityList objectAtIndex:indexPath.row];
    } else {
        activity = [self.project.activities objectAtIndex:indexPath.row];
    }
    self.formWebView.activity = activity;
    self.formWebView.project = project;
    [[self navigationController] pushViewController:self.formWebView animated:TRUE];
}

#pragma mark - Masterview caller to update

-(void) setSelectedProjectIndex : (int) selectedProjectIndex
{
    self.projectIndex = selectedProjectIndex;
    self.project = [self.projects objectAtIndex:self.projectIndex];

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    self.title = [[NSString alloc] initWithFormat:@"%@",project.projectName];
//    [self.tableView reloadData];
    [self updateActivityTableModel:[self.projects mutableCopy]];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return YES;
}

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //When the user taps the search bar, this means that the controller will begin searching.
    isSearching = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //When the user taps the Cancel Button, or anywhere aside from the view.
    isSearching = NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterActivityListForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterActivityListForSearchText:[self.searchDisplayController.searchBar text]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
