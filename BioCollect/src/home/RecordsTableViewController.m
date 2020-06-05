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
#define DEFAULT_MAX     50
#define DEFAULT_OFFSET  0
#define SEARCH_LENGTH   3
@synthesize  webViewController, records, appDelegate, bioProjectService, totalRecords, offset, loadingFinished, isSearching, query, spinner, myRecords, projectId, pActivties, searchController;


- (id)initWithNibNameAndUserActions:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.menu = nil;
    self.enableSearchController = true;
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
        self.showUserActions = TRUE;
    }
    
    return self;
}

- (id)initWithNibNameAndUserActionsAndWithoutPlus:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.menu = nil;
    self.enableSearchController = true;
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
        
        NSArray *btns = [NSArray arrayWithObjects: syncButton,nil];
        btns = [NSArray arrayWithObjects: syncButton,nil];
        self.navigationItem.rightBarButtonItems = btns;
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.showUserActions = TRUE;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.menu = nil;
    self.enableSearchController = true;
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
        for (int i = 0; i < [pActivties count]; i++) {
            ProjectActivity *pa = pActivties[i];
            [list addObject:pa.name];
        }
        NSArray *arrayList = [NSArray arrayWithArray:list];
        self.surveyListMenu = [JGActionSheetSection sectionWithTitle:@"Select survey to add records" message:@"Survey names" buttonTitles:arrayList buttonStyle:JGActionSheetButtonStyleGreen];

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
            self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
            [self.menu showInView:self.appDelegate.window.rootViewController.view animated:YES];
        } else {
            [self.menu showInView:self.appDelegate.window.rootViewController.view animated:YES];
        }
    } else {
        [RKDropdownAlert title:@"Survey not available." message:@"" backgroundColor:[UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
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
                self.webViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                
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
    self.tableView.rowHeight = 60;
    
    if (self.enableSearchController) {
        RecordsTableViewController *recordsTableVC = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
        recordsTableVC.enableSearchController = false;
        recordsTableVC.parent = self;
        recordsTableVC.tableView.delegate = recordsTableVC;
        recordsTableVC.tableView.dataSource = recordsTableVC;
        searchController = [[UISearchController alloc] initWithSearchResultsController: recordsTableVC];
        searchController.delegate = recordsTableVC;
        searchController.searchResultsUpdater = recordsTableVC;
        searchController.searchBar.delegate = recordsTableVC;
        searchController.hidesNavigationBarDuringPresentation = false;
        
        if (@available(iOS 13.0, *) ){
            // For iOS 11 and later, place the search bar in the navigation bar.
            self.navigationItem.searchController = searchController;

            // Make the search bar always visible.
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            self.tableView.tableHeaderView = searchController.searchBar;
            self.definesPresentationContext = true;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.totalRecords  == 0) {
        [self resetAndDownloadProjects];
    }
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
    return [[NSString alloc] initWithFormat:@"Found %ld records", (long)self.totalRecords];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
        
        NSString *description = [[NSString alloc] initWithFormat:@"%@, %@, %@", activity.activityOwnerName, lastUpdated, activity.activityName];
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@", description];
        NSString *url = [[NSString alloc] initWithFormat: @"%@", activity.thumbnailUrl];
        //NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"noImage85.jpg"]];
       
        if(activity.showCrud) {
            UIImage *image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"edit_icon"]];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(44.0, 44.0, image.size.width, image.size.height);
            button.frame = frame;
            //self.selectedActivity = activity;
            [button setBackgroundImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(accessoryButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            cell.accessoryView = button;
        } else {
            cell.accessoryView = nil;
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if([self.records count] > 0) {
        GAActivity *activity = [self.records objectAtIndex:indexPath.row];
        if(activity.url) {
            NSString *url = [[NSString alloc] initWithFormat:@"%@",activity.editUrl];
            NSMutableURLRequest *request = [self loadRequest: url];
            self.webViewController = [[SVModalWebViewController alloc] initWithURLRequest: request];
            self.webViewController.title = [[NSString alloc] initWithFormat:@"Edit"];
            self.webViewController.webViewDelegate = self;
            
            [self presentViewController: webViewController animated:YES completion: nil];
        }
    }
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
            UINavigationController *nc = self.navigationController;
            if (self.parent != nil) {
                nc = self.parent.navigationController;
            }
            
            [nc pushViewController:recordWebView animated:TRUE];
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

-(void) resetRecords
{
    [self.records removeAllObjects];
    self.totalRecords = 0;
    self.offset = DEFAULT_OFFSET;
    dispatch_async(dispatch_get_main_queue(), ^{
        [MRProgressOverlayView dismissOverlayForView:self.appDelegate.window animated:NO];
        [self.tableView reloadData];
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
            [self.tableView reloadData];
        });
    });
}

-(void) searchIndicator: (BOOL) searching {
    if(searching) {
        self.spinner.center = self.view.center;
        [self.tableView addSubview : spinner];
        [self.spinner startAnimating];
    } else{
        [self.spinner stopAnimating];
    }

    UITableView *tableView = self.tableView;
    for( UIView *subview in tableView.subviews ) {
        if( [subview class] == [UIView class] ) {
            UILabel *lbl = (UILabel*) [subview.subviews objectAtIndex:0]; // sv changed to subview.
            lbl.text = searching ? @"Searching..." : @"No Results";
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //When the user taps the search bar, this means that the controller will begin searching.
    isSearching = YES;
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    isSearching = NO;
}

#pragma mark - WebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *currentUrl = webView.request.URL.absoluteString;
    if([currentUrl hasSuffix: @"#successfully-posted"]) {
        [RKDropdownAlert title:@"Successfully Submitted." message:@"Submitted record will be visible in few seconds!" backgroundColor:[UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
        
        [self.webViewController dismissViewControllerAnimated:false completion:NULL];
        [self resetAndDownloadProjects];
    }
}

#pragma mark - UISearchResultUpdating

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    if (isSearching && [searchText length] >= SEARCH_LENGTH) {
        [self searchRecords:searchText cancelTriggered:FALSE];
    }
}
    
@end
