//
//  RecordsTableViewController.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 10/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "RecordsTableViewController.h"
#import "HomeCustomCell.h"
#import "RecordWebVIew.h"
#import "MRProgressOverlayView.h"

@implementation RecordsTableViewController
#define DEFAULT_MAX     20
#define DEFAULT_OFFSET  0
#define SEARCH_LENGTH   3
@synthesize  records, appDelegate, bioProjectService, totalRecords, offset, loadingFinished, isSearching, query, spinner, myRecords;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.records = [[NSMutableArray alloc]init];
        self.offset = DEFAULT_OFFSET;
        self.loadingFinished = TRUE;
        self.query = @"";
        self.isSearching = NO;

        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync-25"] style:UIBarButtonItemStyleBordered
                                                                      target:self action:@selector(resetAndDownloadProjects)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:syncButton,nil];
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    NSUInteger retValue = 0;
    if(self.records != nil){
        retValue = [self.records count];
    }
    return retValue;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if(self.isSearching) {
        title = @"";
    } else if(self.loadingFinished){
        title = [[NSString alloc] initWithFormat:@"Found %ld records", (long)self.totalRecords];
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
    
    if([self.records count] > 0) {
        GAActivity *activity = [self.records objectAtIndex:indexPath.row];
        NSArray *dateArray = [activity.lastUpdated componentsSeparatedByString: @"T"];
        NSString *lastUpdated = [dateArray objectAtIndex: 0];
        
        cell.textLabel.text = activity.projectActivityName;
        NSString *description = [[NSString alloc] initWithFormat:@"Submitted by:%@, on:%@, Activity type:%@ ", activity.activityOwnerName, lastUpdated, activity.activityName];
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", description];
        
        NSString *url = [[NSString alloc] initWithFormat: @"%@", activity.thumbnailUrl];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString]
                          placeholderImage:[UIImage imageNamed:@"table-place-holder.png"]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height)) {
        [self downloadProjects];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        //Show next level depth.
        GAActivity *activity =  [self.records objectAtIndex:indexPath.row];
        
        if(activity && activity.url) {
            RecordWebView *recordWebView = [[RecordWebView alloc] initWithNibName:@"RecordWebView" bundle:nil];
            recordWebView.activity =  activity;
            
            recordWebView.title = activity.activityName;
            [recordWebView.webView setScalesPageToFit:YES];
            [[self navigationController] pushViewController:recordWebView animated:TRUE];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Invalid record"
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}


- (void) load {
    if(self.totalRecords != 0 && [self.records count] != 0 && self.totalRecords  == [self.records count]) {
        //Reached the max.
        DebugLog(@"Downloaded all the projects (%ld)", [self.bioProjects count])
    } else if(self.loadingFinished){
        self.loadingFinished = FALSE;
        NSError *error = nil;
        NSString *projectId = self.project ? self.project.projectId : nil;
        NSInteger total = [self.bioProjectService getActivities: records offset:self.offset max:DEFAULT_MAX projectId: projectId query:self.query myRecords:self.myRecords error:&error];
        DebugLog(@"%lu || %ld || %ld",(unsigned long)[self.bioProjects count], self.offset, total);
        if(error == nil && total > 0) {
            self.totalRecords = total;
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


-(void) resetAndDownloadProjects {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView showOverlayAddedTo:self.appDelegate.window title:@"Downloading.." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        });
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.records removeAllObjects];
        self.totalRecords = 0;
        self.offset = DEFAULT_OFFSET;
        [self load];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView dismissOverlayForView:self.appDelegate.window animated:NO];
            [self.tableView reloadData];
        });
    });
}

-(void) downloadProjects {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self load];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

# pragma Records Handler
- (void) searchRecords :(NSString*) searchString cancelTriggered : (BOOL) cancelTriggered{
    
    //UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self searchIndicator:TRUE];
    [self.records removeAllObjects];
    self.totalRecords = 0;
    self.offset = DEFAULT_OFFSET;
    self.query = searchString;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self load];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self searchIndicator:FALSE];
            if(cancelTriggered){
                [self.tableView reloadData];
            } else {
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        });
    });
}

-(void) searchIndicator: (BOOL) searching {
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
            UILabel *lbl = (UILabel*)subview; // sv changed to subview.
            lbl.text = searching ? @"Searching..." : @"No Results";
        }
    }
}

#pragma mark - UISearchDisplayControllerDelegate
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //When the user taps the search bar, this means that the controller will begin searching.
    isSearching = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //When the user taps the Cancel Button, or anywhere aside from the view.
    isSearching = NO;
    [self searchRecords :@"" cancelTriggered:TRUE];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(isSearching && [searchString length] >= SEARCH_LENGTH) {
        [self searchRecords :searchString cancelTriggered:FALSE];
    }
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end