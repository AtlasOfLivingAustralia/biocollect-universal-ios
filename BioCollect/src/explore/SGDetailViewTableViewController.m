
#import "SGDetailViewTableViewController.h"
#import "SpeciesCell.h"
#import "UIImageView+WebCache.h"
#import "RKDropdownAlert.h"
#import "SVModalWebViewController.h"
#import "GAAppDelegate.h"
#import "GASettingsConstant.h"
#import "RecordViewController.h"

@interface SGDetailViewTableViewController ()
@property (nonatomic, assign) int fixedTotal;
@end

@implementation SGDetailViewTableViewController
#define SEARCH_PAGE_SIZE 20;

@synthesize speciesTableView, displayItems, selectedSpecies, selectedGroup;

#pragma mark - init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.navigationItem.title = @"Select Species";
    }
    // spinner to show searching
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    return  self;
}

- (instancetype)initWithSelectedGroupNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil selectedGroup:(NSDictionary *) dictionary{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        selectedGroup = dictionary;
        self.navigationItem.title = dictionary[@"name"];
        self.fixedTotal =  [dictionary[@"speciesCount"]  intValue] ;
    }
    
    // spinner to show searching
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    
    return  self;
}

#pragma mark - standard functions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    displayItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    // search settings
    self.totalResults = self.fixedTotal;
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
    
    NSString *detailLabelText = [[NSString alloc] initWithFormat:@"%@, %@",  [species[@"commonName"] length] > 0 ? species[@"commonName"] : @"N/A", [species[@"kingdom"] length] > 0 ? species[@"kingdom"] : @"N/A"];
    
    cell.textLabel.text = labelText;
    cell.detailTextLabel.text = detailLabelText;
    
    thumbnail = [[NSString alloc] initWithFormat:@"%@%@/%@", PROXY_SERVER, SPECIES_THUMBNAIL, species[@"guid"]];
    if(![thumbnail isEqualToString:@""]){
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString: thumbnail] placeholderImage:[UIImage imageNamed:@"noImage85.jpg"] options:SDWebImageRefreshCached];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"noImage85.jpg"];
    }

    
    UIImage *image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"icon_about"]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(44.0, 44.0, image.size.width, image.size.height);
    button.frame = frame;
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(accessoryButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    cell.accessoryView = button;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *species = [displayItems objectAtIndex:indexPath.row];
    NSString *url = [[NSString alloc] initWithFormat:@"http://bie.ala.org.au/species/%@",species[@"guid"]];
    NSString *encoded =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress: encoded];
    webViewController.title = [[NSString alloc] initWithFormat: species[@"name"]];
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

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *species = [displayItems objectAtIndex:indexPath.row];
    RecordViewController *recordViewController = [[RecordViewController alloc] init];
    recordViewController.title = @"Record a Sighting";
    [recordViewController setRecordSpecies: species];
    [self.navigationController pushViewController:recordViewController animated:TRUE];
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
            title = @"3. Record or explore species";
        }
        [self.spinner stopAnimating];
    }
    
    return title;
}

#pragma mark - Table view display
- (void)showOrHideActivityIndicator {
    if(self.isSearching){
        self.spinner.center = speciesTableView.center;
        [speciesTableView addSubview : self.spinner];
        [self.spinner startAnimating];
    } else {
        [self.spinner performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO ];
        [self.spinner stopAnimating];
    }
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
    self.totalResults = self.fixedTotal;
    [displayItems addObjectsFromArray:data];
    
    // run reload data on main thread. otherwise, table rendering will be very slow.
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [self showOrHideActivityIndicator];
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
    [appDelegate.speciesService getSpecies:selectedGroup[@"name"] numberOfItemsPerPage: 20 fromSerialNumber: self.offset viewController: self];
}

/**
 * load first page
 */
- (void) loadFirstPage {
    self.offset = 0;
    self.totalResults = self.fixedTotal;
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
    myLabel.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1];
    myLabel.textAlignment = UITextAlignmentCenter;
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor whiteColor];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}
@end
