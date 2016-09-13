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

@interface HomeTableViewController()
@property (strong, nonatomic) JGActionSheet *menu;
@property (strong, nonatomic) JGActionSheetSection *projectStatus;
@property (strong, nonatomic) JGActionSheetSection *dataShared;
@property (strong, nonatomic) JGActionSheetSection *actionSection;
@end

@implementation HomeTableViewController
#define DEFAULT_MAX     20
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
#define FILTER_SECTION_SHARING  FILTER_SECTION_STATUS   + 1
#define FILTER_SECTION_DONE     FILTER_SECTION_SHARING  + 1

#define FILTER_STATUS_ACTIVE    0
#define FILTER_STATUS_COMPLETED FILTER_STATUS_ACTIVE + 1

#define FILTER_SHARING    0

#define FILTER_SECTION_RESET 0
#define FILTER_SECTION_OK FILTER_SECTION_RESET + 1

@synthesize  bioProjects, appDelegate, bioProjectService, totalProjects, offset, query, loadingFinished, isSearching, spinner, activeChecked, completedChecked, searchParams, dataSharingChecked,isUserPage;

- (id) initWithNibNameForMyProjects :(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        //Initialise
        [self initialise];
        self.isUserPage = TRUE;
        
        UIBarButtonItem *menuSheet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action-25"]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self action:@selector(showMenu:)];
        
        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync-25"] style:UIBarButtonItemStyleBordered target:self action:@selector(resetAndDownloadProjects)];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: syncButton, menuSheet,nil];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        
        //Initialise
        [self initialise];
        self.isUserPage = FALSE;
        
        //Set bar button.
        UIBarButtonItem *menuSheet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"action-25"]
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self action:@selector(showMenu:)];
        
        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync-25"] style:UIBarButtonItemStyleBordered target:self action:@selector(resetAndDownloadProjects)];
        UIBarButtonItem *signout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"lock_filled-25"] style:UIBarButtonItemStyleBordered target:self.appDelegate.loginViewController action:@selector(logout)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: signout,syncButton, menuSheet,nil];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BioCollect-text-small"]];
        imageView.contentMode = UIViewContentModeCenter;
        self.navigationItem.titleView = imageView;
        
    }
    
    return self;
}

-(void) initialise {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.recordsTableView = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
    self.bioProjects = [[NSMutableArray alloc]init];
    self.offset = DEFAULT_OFFSET;
    self.loadingFinished = TRUE;
    self.query = @"";
    self.searchParams = @"";
    self.activeChecked = FALSE;
    self.completedChecked = FALSE;
    self.dataSharingChecked = FALSE;
    self.isSearching = NO;
}

-(void)showMenu:(id)sender
{
    if(self.menu == nil) {
       
        self.projectStatus = [JGActionSheetSection sectionWithTitle:@"Filter by"
                                                                message:@"Project Status"
                                                                buttonTitles:@[PROJECT_ACTIVE_CROSS_STR, PROJECT_COMPLETED_CROSS_STR]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
        [self.projectStatus setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0];
        [self.projectStatus setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:1];
        
        self.dataShared = [JGActionSheetSection sectionWithTitle:nil
                                                                 message:@"Data Sharing"
                                                                 buttonTitles:@[DATA_SHARING_CROSS_STR]
                                                                 buttonStyle:JGActionSheetButtonStyleDefault];
        [self.dataShared setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0];
        
        
        self.actionSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"RESET", @"DONE"] buttonStyle:JGActionSheetButtonStyleGreen];
        [self.actionSection setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0];
        [self.actionSection setButtonStyle:JGActionSheetButtonStyleGreen forButtonAtIndex:1];
        
        NSArray *sections = @[self.projectStatus, self.dataShared, self.actionSection];
        self.menu = [JGActionSheet actionSheetWithSections: sections];
        
        //Assign delegate.
        [self.menu setDelegate:self];
    }
    
    // Fix to prevent menu disappearing from the screen. 
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.menu showInView:self.view animated:YES];
    
}

- (void)actionSheet:(JGActionSheet *)actionSheet pressedButtonAtIndexPath:(NSIndexPath *)indexPath{
    NSString *statusParam;
    NSString *dataSharingParam;
    
    switch(indexPath.section) {
        case FILTER_SECTION_STATUS:
            if(indexPath.row == FILTER_STATUS_ACTIVE) {
                self.activeChecked = self.activeChecked ? FALSE : TRUE;
                [self.projectStatus setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0 newTitle: self.activeChecked ? PROJECT_ACTIVE_STR : PROJECT_ACTIVE_CROSS_STR];
            } else if (indexPath.row == FILTER_STATUS_COMPLETED) {
                self.completedChecked = self.completedChecked ? FALSE : TRUE;
                [self.projectStatus setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:1 newTitle: self.completedChecked ? PROJECT_COMPLETED_STR : PROJECT_COMPLETED_CROSS_STR];
            }
            break;
            
        case FILTER_SECTION_SHARING:
            if(indexPath.row == FILTER_SHARING) {
                self.dataSharingChecked = self.dataSharingChecked ? FALSE : TRUE;
                [self.dataShared setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0 newTitle: self.dataSharingChecked ? DATA_SHARING_STR : DATA_SHARING_CROSS_STR];
                
            }
            break;

        case FILTER_SECTION_DONE:
            if(indexPath.row == FILTER_SECTION_RESET) {
                self.activeChecked = FALSE;
                self.completedChecked = FALSE;
                self.dataSharingChecked = FALSE;
                
                [self.projectStatus setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0 newTitle: self.activeChecked ? PROJECT_ACTIVE_STR : PROJECT_ACTIVE_CROSS_STR];
                [self.projectStatus setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:1 newTitle: self.completedChecked ? PROJECT_COMPLETED_STR : PROJECT_COMPLETED_CROSS_STR];
                [self.dataShared setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0 newTitle: self.dataSharingChecked ? DATA_SHARING_STR : DATA_SHARING_CROSS_STR];
            }
            
            if ((self.activeChecked && self.completedChecked) || (!self.activeChecked && !self.completedChecked)) {
                statusParam = @"";
            } else if(self.activeChecked) {
                statusParam = @"&fq=status:active";
            } else if(self.completedChecked) {
                statusParam = @"&fq=status:completed";
            } else if(self.activeChecked && self.completedChecked) {
                statusParam = @"&fq=status:active&fq=status:completed";
            }
            
            if(self.dataSharingChecked) {
                dataSharingParam = @"fq=tags:isContributingDataToAla";
            } else {
                dataSharingParam = @"";
            }
            
            self.searchParams = [[NSString alloc]initWithFormat:@"%@%@",statusParam,dataSharingParam];
            [actionSheet dismissAnimated:YES];
            [self searchProjects :@"" cancelTriggered:TRUE];

            
            break;
            
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.totalProjects  == 0) {
        [self downloadProjects];
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
    NSString *title = nil;
    if(self.isSearching) {
      title = @"";
    } else if(self.loadingFinished){
        title = [[NSString alloc] initWithFormat:@"Found %ld projects", (long)self.totalProjects];
    } else{
       title = [[NSString alloc] initWithFormat:@"Loading..."];
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    HomeCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[HomeCustomCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if([self.bioProjects count] > 0) {
        GAProject *project = [self.bioProjects objectAtIndex:indexPath.row];
        cell.textLabel.text = project.projectName;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", project.description];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", project.urlImage];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString] placeholderImage:[UIImage imageNamed:@"table-place-holder.png"]];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
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
            [[self navigationController] pushViewController:homeWebView animated:TRUE];
            
        } else if(project && !project.isExternal) {
            self.recordsTableView.project = project;
            self.recordsTableView.title = project.projectName;
            self.recordsTableView.totalRecords = 0;
            self.recordsTableView.offset = 0;
            [self.recordsTableView.records removeAllObjects];
            [[self navigationController] pushViewController:self.recordsTableView animated:TRUE];
            
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
        DebugLog(@"Downloaded all the projects (%ld)", [self.bioProjects count])
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
    myLabel.frame = CGRectMake(20, 8, 320, 20);
    
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:117.0/255.0 alpha:1];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}


#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //When the user taps the search bar, this means that the controller will begin searching.
    isSearching = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //When the user taps the Cancel Button, or anywhere aside from the view.
    isSearching = NO;
    [self searchProjects :@"" cancelTriggered:TRUE];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(isSearching && [searchString length] >= SEARCH_LENGTH) {
        [self searchProjects :searchString cancelTriggered:FALSE];
    }
   
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Return YES to cause the search result table view to be reloaded.
    return YES;
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
            if(cancelTriggered) {
                [self.tableView reloadData];
            } else {
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        });
    });
}

- (void) searchIndicator: (BOOL) searching {
    
    if(searching) {
        self.spinner.center = self.view.center;
        [self.searchDisplayController.searchResultsTableView addSubview : spinner];
        [self.spinner startAnimating];
    } else{
        [self.spinner stopAnimating];
    }
    
    UITableView *tableView = self.searchDisplayController.searchResultsTableView;
    for( UIView *subview in tableView.subviews ) {
        if( [subview class] == [UILabel class] ) {
            UILabel *lbl = (UILabel*)subview;
            lbl.text = searching ? @"Searching..." : @"No Results";
        }
    }
}

@end