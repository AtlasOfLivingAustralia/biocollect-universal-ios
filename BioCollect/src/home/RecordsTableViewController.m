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
#import "GAAppDelegate.h"

#import "GASettingsConstant.h"
#import "GASettings.h"
#import "ProjectActivity.h"
#import "RKDropdownAlert.h"

@interface RecordsTableViewController ()
    @property (nonatomic, strong) GAAppDelegate *appDelegate;
    @property (strong, nonatomic) JGActionSheet *menu;
    @property (strong, nonatomic) JGActionSheetSection *surveyListMenu;
    @property (strong, nonatomic) JGActionSheetSection *cancelGroup;
@end

@implementation RecordsTableViewController
#define DEFAULT_MAX     20
#define DEFAULT_OFFSET  0
#define SEARCH_LENGTH   3
@synthesize  webViewController, records, appDelegate, bioProjectService, totalRecords, offset, loadingFinished, isSearching, query, spinner, myRecords, projectId, pActivties;


- (id)initWithNibNameAndUserActions:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.menu = nil;
    if (self) {
        self.records = [[NSMutableArray alloc]init];
        self.pActivties = [[NSMutableArray alloc] init];
        self.offset = DEFAULT_OFFSET;
        self.loadingFinished = TRUE;
        self.query = @"";
        self.isSearching = NO;

        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc]
                                       initWithImage: [UIImage imageNamed:@"sync-25"]
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(resetAndDownloadProjects)];
       
        UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectActivity)];
        NSArray *btns = [NSArray arrayWithObjects:plusButton, syncButton,nil];
        btns = [NSArray arrayWithObjects:plusButton, syncButton,nil];
        self.navigationItem.rightBarButtonItems = btns;
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.menu = nil;
    if (self) {
        self.records = [[NSMutableArray alloc]init];
        self.pActivties = [[NSMutableArray alloc] init];
        self.offset = DEFAULT_OFFSET;
        self.loadingFinished = TRUE;
        self.query = @"";
        self.isSearching = NO;
        
        UIBarButtonItem *syncButton = [[UIBarButtonItem alloc]
                                       initWithImage: [UIImage imageNamed:@"sync-25"]
                                       style:UIBarButtonItemStyleBordered
                                       target:self
                                       action:@selector(resetAndDownloadProjects)];
        
        NSArray *btns = [NSArray arrayWithObjects:syncButton,nil];
        self.navigationItem.rightBarButtonItems = btns;
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}


-(void) selectActivity
{
    // Load all project activityIds.
    NSError *error;
    [self.pActivties removeAllObjects];
    [self.bioProjectService getProjectActivities:pActivties projectId: self.project.projectId error: &error];
    if(error == nil && [pActivties count] > 0) {
    
        self.surveyListMenu = nil;
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (int i = 0; i <[pActivties count]; i++) {
            ProjectActivity *pa = pActivties[i];
            [list addObject:pa.name];
        }
        NSArray *arrayList = [NSArray arrayWithArray:list];
        self.surveyListMenu = [JGActionSheetSection sectionWithTitle:nil message:@"Select Survey" buttonTitles:arrayList buttonStyle:JGActionSheetButtonStyleGreen];

        self.cancelGroup = [JGActionSheetSection sectionWithTitle:nil
                                                          message:nil
                                                     buttonTitles:@[@"Cancel"]
                                                      buttonStyle:JGActionSheetButtonStyleDefault];
        [self.cancelGroup setButtonStyle:JGActionSheetButtonStyleDefault forButtonAtIndex:0];
        
        NSArray *sections = @[self.surveyListMenu,  self.cancelGroup];
        self.menu = [JGActionSheet actionSheetWithSections: sections];
        
        //Assign delegate.
         [self.menu setDelegate:self];
        if([self.tableView isDescendantOfView:self.view]){
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self.menu showInView:self.tableView animated:YES];
        } else {
            [self.menu showInView:self.view animated:YES];
        }

    }
}

- (void)actionSheet:(JGActionSheet *)actionSheet pressedButtonAtIndexPath:(NSIndexPath *)indexPath {
    
    switch(indexPath.section) {
        case 0:
            if(indexPath.row >= 0) {
                ProjectActivity *pa = self.pActivties[indexPath.row];
                                                      
                NSString *url = [[NSString alloc] initWithFormat:@"%@/bioActivity/mobileCreate/%@", BIOCOLLECT_SERVER, pa.projectActivityId];
                NSMutableURLRequest *request = [self loadRequest: url];
                self.webViewController = [[SVModalWebViewController alloc] initWithURLRequest: request];
                self.webViewController.title = [[NSString alloc] initWithFormat:@"%@", pa.name];
                self.webViewController.webViewDelegate = self;
                
                [self presentViewController: webViewController animated:YES completion: nil];
            }
            break;
        case 1:
        default:
            break;
    }
    
    [actionSheet dismissAnimated:YES];
    self.menu = nil;
}
-(NSMutableURLRequest *) loadRequest: (NSString*) url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[GASettings getEmailAddress] forHTTPHeaderField:@"userName"];
    [request setValue:[GASettings getAuthKey] forHTTPHeaderField:@"authKey"];
    [request setTimeoutInterval: DEFAULT_TIMEOUT];
    return request;
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
        
        if([activity.records count] > 0) {
            NSDictionary *item = [activity.records objectAtIndex:0];
            NSString *speciesName = [item objectForKey:@"name"];
            cell.textLabel.text = ((speciesName != (id)[NSNull null]) && [speciesName length] > 0) ? [item objectForKey:@"name"] : @"No species name";
        } else {
            cell.textLabel.text = activity.projectActivityName;
        }
        
        NSString *description = [[NSString alloc] initWithFormat:@"Submitted by:%@, on:%@, Activity type:%@ ", activity.activityOwnerName, lastUpdated, activity.activityName];
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", description];
        
        NSString *url = [[NSString alloc] initWithFormat: @"%@", activity.thumbnailUrl];
        NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:escapedUrlString]
                          placeholderImage:[UIImage imageNamed:@"table-place-holder.png"]];
       
        if(self.showUserActions) {
            UIImage *image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"edit"]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(44.0, 44.0, image.size.width, image.size.height);
            button.frame = frame;
            self.selectedActivity = activity;
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(accessoryButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(void) accessoryButtonTapped:(id)sender event:(id)event{
    // Open web view with
    if(self.selectedActivity &&  self.selectedActivity.url){
        NSString *url = [[NSString alloc] initWithFormat:@"%@",self.selectedActivity.editUrl];
        NSMutableURLRequest *request = [self loadRequest: url];
        self.webViewController = [[SVModalWebViewController alloc] initWithURLRequest: request];
        self.webViewController.title = [[NSString alloc] initWithFormat:@"Edit"];
        self.webViewController.webViewDelegate = self;
        
        [self presentViewController: webViewController animated:YES completion: nil];
    }
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
        NSString *pId = self.project ? self.project.projectId : nil;
        if(self.projectId){
            pId = self.projectId;
        }
        NSInteger total = [self.bioProjectService getActivities: records offset:self.offset max:DEFAULT_MAX projectId: pId query:self.query myRecords:self.myRecords error:&error];
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

// Webview Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *currentUrl = webView.request.URL.absoluteString;
    if([currentUrl hasSuffix: @"#successfully-posted"]) {
        [RKDropdownAlert title:@"" message:@"Successfully posted." backgroundColor:[UIColor greenColor] textColor:[UIColor whiteColor] time:10];
        [self.webViewController dismissViewControllerAnimated:false completion:NULL];
        [self resetAndDownloadProjects];
    }
}
    
@end
