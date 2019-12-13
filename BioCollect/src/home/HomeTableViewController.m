//
//  HomeTableViewController.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 3/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeTableViewController.h"
#import "HomeCustomCell.h"
#import "HomeWebView.h"
#import "MRProgressOverlayView.h"
#import "GASettingsConstant.h"

@interface HomeTableViewController()
@property (strong, nonatomic) JGActionSheet *menu;
@property (strong, nonatomic) JGActionSheetSection *projectStatus;
@property (strong, nonatomic) JGActionSheetSection *dataShared;
@property (strong, nonatomic) JGActionSheetSection *actionSection;
@end

@implementation HomeTableViewController
#define DEFAULT_MAX     50
#define DEFAULT_OFFSET  0
#define SEARCH_LENGTH   3

#define PROJECT_ACTIVE @"active"
#define PROJECT_COMPLETED @"completed"

#define PROJECT_ACTIVE_STR @"Active ✅"
#define PROJECT_COMPLETED_STR @"Completed ✅"
#define PROJECT_ACTIVE_CROSS_STR @"Active"
#define PROJECT_COMPLETED_CROSS_STR @"Completed" // ❌

#define DATA_SHARING_STR @"Contributing data to the ALA ✅"
#define DATA_SHARING_CROSS_STR @"Contributing data to the ALA"

#define FILTER_SECTION_STATUS   0
#define FILTER_SECTION_DONE     FILTER_SECTION_STATUS  + 1

#define FILTER_STATUS_ACTIVE    0
#define FILTER_STATUS_COMPLETED FILTER_STATUS_ACTIVE + 1

#define FILTER_SHARING    0

#define FILTER_SECTION_RESET 0
#define FILTER_SECTION_OK FILTER_SECTION_RESET + 1

@synthesize  bioProjects, appDelegate, bioProjectService, totalProjects, offset, query, loadingFinished, isSearching, spinner,  searchParams, isUserPage, searchController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        //Initialise
        self.showUserActions = TRUE;
        [self initialise];
        self.isUserPage = FALSE;
        
        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync-25"] style:UIBarButtonItemStyleBordered target:self action:@selector(resetAndDownloadProjects)];
        UIBarButtonItem *signout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"lock_filled-25"] style:UIBarButtonItemStyleBordered target:self.appDelegate.loginViewController action:@selector(logout)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: signout,syncButton, nil];
        self.navigationItem.title = @"Projects";
    }
    
    return self;
}

-(void) initialise {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    if(self.showUserActions) {
        self.recordsTableView = [[RecordsTableViewController alloc] initWithNibNameAndUserActions:@"RecordsTableViewController" bundle:nil];
    } else {
        self.recordsTableView = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
    }
    self.bioProjects = [[NSMutableArray alloc]init];
    self.offset = DEFAULT_OFFSET;
    self.loadingFinished = TRUE;
    self.query = @"";
    self.searchParams = @"";
    self.enableSearchController = true;
    self.isSearching = NO;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 60;
    
    if (self.enableSearchController) {
        HomeTableViewController *homeTableVC = [[HomeTableViewController alloc] initWithNibName:@"HomeTableViewController" bundle:nil];
        homeTableVC.enableSearchController = false;
        homeTableVC.parent = self;
        homeTableVC.tableView.delegate = homeTableVC;
        homeTableVC.tableView.dataSource = homeTableVC;
        searchController = [[UISearchController alloc] initWithSearchResultsController: homeTableVC];
        searchController.delegate = homeTableVC;
        searchController.searchResultsUpdater = homeTableVC;
        searchController.searchBar.delegate = homeTableVC;
        searchController.hidesNavigationBarDuringPresentation = false;
        
        if (@available(iOS 11.0, *) ){
            // For iOS 11 and later, place the search bar in the navigation bar.
            self.navigationItem.searchController = searchController;

            // Make the search bar always visible.
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            self.tableView.tableHeaderView = searchController.searchBar;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.totalProjects  == 0) {
        [self resetAndDownloadProjects];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - TableViewDelegae

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    NSUInteger retValue = 0;
    if(self.bioProjects != nil){
        retValue = [self.bioProjects count];
    }
    return retValue;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[NSString alloc] initWithFormat:@"Found %ld projects", (long)self.totalProjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HomeCustomCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if([self.bioProjects count] > 0) {
        GAProject *project = [self.bioProjects objectAtIndex:indexPath.row];
        cell.textLabel.text = project.projectName;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", project.description];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", project.urlImage];
        //NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"noImage85.jpg"]];
    }
    
    UIImage *image = [UIImage imageNamed:@"icon_about_square"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(320.0 - 44.0, 0.0, 50, 50);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(accessoryButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    GAProject *project = [self.bioProjects objectAtIndex:indexPath.row];
    NSString *url = [[NSString alloc] initWithFormat:@"%@/project/index/%@?mobile=true",BIOCOLLECT_SERVER, project.projectId];
    NSString *encoded =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: encoded];
    webViewController.title = [[NSString alloc] initWithFormat:project.projectName];
    webViewController.webViewDelegate = self;
    [self presentViewController: webViewController animated:YES completion: nil];
}

-(void) accessoryButtonTapped:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil) {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        //Show next level depth.
        GAProject *project =  [self.bioProjects objectAtIndex:indexPath.row];
      
        if(project && project.isExternal && ![project.urlWeb isEqual: [NSNull null]]) {
            HomeWebView *homeWebView = [[HomeWebView alloc] initWithNibName:@"HomeWebView" bundle:nil];
            homeWebView.project =  project;

            homeWebView.title = homeWebView.project.projectName;
            [homeWebView.webView setScalesPageToFit:YES];
            UINavigationController *nc = self.navigationController;
            if (self.parent != nil) {
                nc = self.parent.navigationController;
            }
            
            [nc pushViewController:homeWebView animated:TRUE];
        } else if(project && !project.isExternal) {
            self.recordsTableView.project = project;
            self.recordsTableView.title = project.projectName;
            self.recordsTableView.totalRecords = 0;
            self.recordsTableView.offset = 0;
            [self.recordsTableView.records removeAllObjects];
            self.recordsTableView.showUserActions = self.showUserActions;
            UINavigationController *nc = self.navigationController;
            if (self.parent != nil) {
                nc = self.parent.navigationController;
            }
            
            [nc pushViewController:self.recordsTableView animated:TRUE];
        } else if(project && project.isExternal && [project.urlWeb isEqual: [NSNull null]]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                            message:@"Project external web link not available"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Invalid Project"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
        [self downloadProjects];
    }
}

- (void) load {
    //Reached the max.
    if(self.totalProjects != 0 && [self.bioProjects count] != 0 && self.totalProjects  == [self.bioProjects count]) {
        DebugLog(@"Downloaded all the projects (%ld)", [self.bioProjects count]);
    } else if(self.loadingFinished){
        self.loadingFinished = FALSE;
        NSError *error = nil;
        NSInteger total = [self.bioProjectService getBioProjects: bioProjects offset:self.offset max:DEFAULT_MAX query: self.query params:self.searchParams isUserPage:self.isUserPage error:&error];
        DebugLog(@"%lu || %ld || %ld",(unsigned long)[self.bioProjects count], self.offset, total);
        if(error == nil && total > 0) {
            self.totalProjects = total;
            self.offset = self.offset + DEFAULT_MAX;
        }

        self.loadingFinished = TRUE;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    myLabel.frame = CGRectMake(0, 0, screenWidth, 30);
    myLabel.backgroundColor = [UIColor lightGrayColor];
    myLabel.textAlignment = UITextAlignmentCenter;
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor blackColor];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //When the user taps the search bar, this means that the controller will begin searching.
    isSearching = YES;
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    isSearching = NO;
}

#pragma mark - Project table view handler

-(void) resetAndDownloadProjects
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView showOverlayAddedTo:self.appDelegate.window title:@"Downloading.." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.bioProjects removeAllObjects];
        self.totalProjects = 0;
        self.offset = DEFAULT_OFFSET;
        [self load];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView dismissOverlayForView:self.appDelegate.window animated:NO];
            [self.tableView reloadData];
        });
    });
    
}


-(void) downloadProjects
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self load];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
}

-(void) resetProjects
{
    [self.bioProjects removeAllObjects];
    self.totalProjects = 0;
    self.offset = DEFAULT_OFFSET;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MRProgressOverlayView dismissOverlayForView:self.appDelegate.window animated:NO];
        [self.tableView reloadData];
    });
}

# pragma Project Results Handler

- (void) searchProjects :(NSString*) searchString cancelTriggered: (BOOL) cancelTriggered {
    [self searchIndicator:TRUE];
    [self.bioProjects removeAllObjects];
    self.totalProjects = 0;
    self.offset = DEFAULT_OFFSET;
    self.query = searchString;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self load];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self searchIndicator:FALSE];
            [self.tableView reloadData];
        });
    });
}

- (void) searchIndicator: (BOOL) searching {
    
    if(searching) {
        self.spinner.center = self.view.center;
        [self.tableView addSubview : spinner];
        [self.spinner startAnimating];
    } else{
        [self.spinner stopAnimating];
    }
    
    UITableView *tableView = self.tableView;
    for( UIView *subview in tableView.subviews ) {
        if([subview class] == [UIView class]) {
            UILabel *lbl = (UILabel*) [subview.subviews firstObject]; // sv changed to subview.
            lbl.text = searching ? @"Searching..." : @"No Results";
        }
    }
}

#pragma mark - UISearchResultUpdating

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    if(isSearching && [searchString length] >= SEARCH_LENGTH) {
        [self searchProjects :searchString cancelTriggered:FALSE];
    }
}

@end
