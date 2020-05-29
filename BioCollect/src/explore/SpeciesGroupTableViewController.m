
#import "SpeciesGroupTableViewController.h"
#import "SpeciesCell.h"
#import "UIImageView+WebCache.h"
#import "RKDropdownAlert.h"
#import "SVModalWebViewController.h"
#import "GAAppDelegate.h"
#import "SGDetailViewTableViewController.h"
#import "RKDropdownAlert.h"
#import "MRProgressOverlayView.h"

@interface SpeciesGroupTableViewController ()
@end

@implementation SpeciesGroupTableViewController
#define SEARCH_PAGE_SIZE 20;

@synthesize speciesTableView, displayItems, selectedSpecies;

#pragma mark - init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.navigationItem.title = @"Species Group";
    }
    
    return  self;
}

#pragma mark - standard functions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    displayItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    // search settings
    self.totalResults = 0;
    self.offset = 0;
    
    [self loadFirstPage];
    
    // table view settings
    speciesTableView.rowHeight = 60;
    speciesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [displayItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    if(!cell){
        // Configure the cell...
        cell = [[SpeciesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.autoresizesSubviews = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *species = [displayItems objectAtIndex:indexPath.row];
    NSString *thumbnail;
    
    NSString *labelText = [[NSString alloc] initWithFormat:@"%@",species[@"name"]];
    NSString *detailLabelText = [[NSString alloc] initWithFormat:@"%@ species around %@ km", species[@"speciesCount"], self.locationDetails[@"radius"]];
    
    cell.textLabel.text = labelText;
    cell.detailTextLabel.text = detailLabelText;
    
    thumbnail = [[NSBundle mainBundle] pathForResource:species[@"name"] ofType:@"jpg"];;
    if(thumbnail != nil) {
        [cell.imageView sd_setImageWithURL:nil placeholderImage:[UIImage imageNamed:thumbnail] options:SDWebImageRefreshCached ];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"noImage85.jpg"];
    }
    
    if(![species[@"rank"] isEqualToString: @"unmatched taxon"] ) {
        UIImage *image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"icon_right"]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(44.0, 44.0, image.size.width, image.size.height);
        button.frame = frame;
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(accessoryButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
    }
    
    if(self.isDownload) {
        UIImage *image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"icon_download"]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(44.0, 44.0, image.size.width, image.size.height);
        button.frame = frame;
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(accessoryButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *species = [displayItems objectAtIndex:indexPath.row];
    if([species[@"speciesCount"] intValue] == 0) {
        [RKDropdownAlert title:@"" message:@"No species found!" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    } else if(self.isDownload){
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView showOverlayAddedTo:self.tableView title:@"Downloading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
            [self performBlock:^{
                [MRProgressOverlayView dismissOverlayForView:self.tableView animated:YES];
                GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
                MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:appDelegate.window animated:YES];
                progressView.mode = MRProgressOverlayViewModeCheckmark;
                progressView.titleLabelText = @"Downloaded";
                [self performBlock:^{
                    [progressView dismiss:YES];
                } afterDelay:2.0];
            } afterDelay:2.0];
        });
    } else if(![species[@"rank"] isEqualToString: @"unmatched taxon"] ) {
        NSString *url = [[NSString alloc] initWithFormat:@"http://bie.ala.org.au/species/%@",species[@"guid"]];
        NSString *encoded =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: encoded];
        webViewController.title = [[NSString alloc] initWithFormat:species[@"displayName"]];
        webViewController.webViewDelegate = self;
        [self presentViewController: webViewController animated:YES completion: nil];
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

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Pass the selected object to the new view controller.
    NSDictionary *species = displayItems[indexPath.row];
    if([species[@"speciesCount"] intValue] == 0) {
        [RKDropdownAlert title:@"" message:@"No species found!" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    } else if(self.isDownload){
        dispatch_async(dispatch_get_main_queue(), ^{
            [MRProgressOverlayView showOverlayAddedTo:self.tableView title:@"Downloading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
            [self performBlock:^{
                [MRProgressOverlayView dismissOverlayForView:self.tableView animated:YES];
                GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
                MRProgressOverlayView *progressView = [MRProgressOverlayView showOverlayAddedTo:appDelegate.window animated:YES];
                progressView.mode = MRProgressOverlayViewModeCheckmark;
                progressView.titleLabelText = @"Downloaded";
                [self performBlock:^{
                    [progressView dismiss:YES];
                } afterDelay:1.0];
            } afterDelay:0.5];
        });
    } else {
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        if([[appDelegate restCall] notReachable]) {
            [RKDropdownAlert title:@"Device offline" message:@"Please try later!" backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
            return;
        }
        SGDetailViewTableViewController *speciesGroup = [[SGDetailViewTableViewController alloc] initWithSelectedGroupNibName:@"SGDetailViewTableViewController" bundle:nil selectedGroup:species];
        speciesGroup.locationDetails =  self.locationDetails;
        [self.navigationController pushViewController:speciesGroup animated:TRUE];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if(self.isSearching) {
        title = @"Loading...";
    } else if(self.loadingFinished){
        if(self.totalResults > 0){
            NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
            [fmt setNumberStyle:NSNumberFormatterDecimalStyle]; // to get commas (or locale equivalent)
            [fmt setMaximumFractionDigits:0]; // to avoid any decimal
            title = self.isDownload ? @"Download species group" :  @"2. Select species group";
        }
    }
    
    return title;
}

#pragma mark - Table view display
- (void)showOrHideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.loadingFinished){
            [MRProgressOverlayView showOverlayAddedTo:self.tableView title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        } else {
            [MRProgressOverlayView dismissOverlayForView:self.tableView animated:YES];
        }
    });
}

#pragma mark - Search bar delegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [displayItems removeAllObjects];
    self.loadingFinished = NO;
    self.isSearching = YES;
    [self loadFirstPage];
}

#pragma mark - Navigation controller
- (void) searchBarSearchButtonClicked:(UISearchBar*) theSearchBar{
    [theSearchBar resignFirstResponder];
    [displayItems removeAllObjects];
    self.loadingFinished = NO;
    self.isSearching = YES;
    [self loadFirstPage];
}

- (void) btnRefreshPressed {
    /*if(self.selectedSpecies != nil) {
     [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIESSEARCH SELECTED" object: self.selectedSpecies];
     [self.navigationController popViewControllerAnimated:YES];
     } else {
     
     [RKDropdownAlert title:@"ERROR" message:@"Please select the species" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
     }
     */
    [displayItems removeAllObjects];
    self.loadingFinished = NO;
    self.isSearching = YES;
    [self loadFirstPage];
}

- (void)btnCancelPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * update display items after asynchronous search
 */
-(void)updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total setKm: (int) kilometer {
    self.loadingFinished = YES;
    self.isSearching = NO;
    self.totalResults = total;
    [displayItems addObjectsFromArray:data];
    
    // For species group, nopagination is required.
    self.offset = self.totalResults + 1;
    
    // run reload data on main thread. otherwise, table rendering will be very slow.
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        [self showOrHideActivityIndicator];
    });
}

/**
 * check if scroll has reached the end of table. This method is used to get the next page.
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.bounds.size.height + 30) ) {
        [self loadNextPage];
    }
}

#pragma mark - Utility functions
/**
 * search for species
 */
- (void) lookup {
    [self showOrHideActivityIndicator];
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.speciesService getSpecies:@"" numberOfItemsPerPage: 20 fromSerialNumber: 0 viewController: self];
}

/**
 * load first page
 */
- (void) loadFirstPage {
    self.offset = 0;
    self.totalResults = 0;
    [self lookup];
}

/**
 * load next page
 */
- (void) loadNextPage{
    self.offset = self.offset + SEARCH_PAGE_SIZE;
    if(self.offset < self.totalResults){
        [self lookup];
    }
}

/**
 * Custom table header skin.
 */
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    myLabel.frame = CGRectMake(0, 0, screenWidth, 30);
    myLabel.backgroundColor = [UIColor colorWithRed:53/255.0 green:54/255.0 blue:49/255.0 alpha:1];
    myLabel.textAlignment = UITextAlignmentCenter;
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor grayColor];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}


- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}


@end
