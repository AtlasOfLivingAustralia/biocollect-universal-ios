//
//  SpeciesList
//  Oz Atlas

#import "SpeciesListVC.h"
#import "GAAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "SpeciesCell.h"
#import "RKDropdownAlert.h"
#import "SVModalWebViewController.h"
#import "MRProgressOverlayView.h"
#import "Species.h"

@interface SpeciesListVC ()
@property (nonatomic, assign) BOOL isSearching;
@end


@implementation SpeciesListVC

#define SEARCH_PAGE_SIZE 50;

@synthesize speciesTableView, displayItems, sortedDisplayItems, selectedSpecies, searchBar;

#pragma mark - init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.navigationItem.title = @"Search Animals";
    }

    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnCancelPressed)];
    self.navigationItem.rightBarButtonItem = btnDone;
    btnDone.enabled=TRUE;

    UIBarButtonItem *filterBtn = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(btnRefreshPressed)];
    self.navigationItem.leftBarButtonItem = filterBtn;
    filterBtn.enabled=false;

    
    return  self;
}

#pragma mark - standard functions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    displayItems = [[NSMutableArray alloc] initWithCapacity:0];
    sortedDisplayItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self searchBar].text = @"";
    [self populateTableView];
    
    // table view settings
    speciesTableView.rowHeight = 60;
    speciesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    #warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    #warning Incomplete implementation, return the number of rows
    return _isSearching ? [sortedDisplayItems count] : [displayItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    if(!cell){
        // Configure the cell...
        cell = [[SpeciesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.autoresizesSubviews = YES;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    Species *species = _isSearching ? [sortedDisplayItems objectAtIndex:indexPath.row] : [displayItems objectAtIndex:indexPath.row];
    NSString *commonName = species.commonName;
    if (commonName == (id)[NSNull null] || commonName.length == 0 ) {
        commonName = @"N/A";
    }
    
    cell.textLabel.text = species.displayName;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@",commonName,species.scientificName];
    
    if(self.noImage == nil){
        self.noImage = [UIImage imageNamed:@"noImage85.jpg"];
    }
    
    NSArray *kvp = species.kvpValues;
    NSString *thumbnail;
    for(int i = 0; i < [kvp count]; i++) {
        NSDictionary *item =  kvp[i];
        if([item[@"key"] isEqualToString: @"Image"]) {
            thumbnail = item[@"value"];
            break;
        }
    }
    if(![thumbnail isEqualToString:@""]){
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString: thumbnail] placeholderImage:[UIImage imageNamed:@"ajax_loader.gif"] options:SDWebImageRefreshCached ];
    } else {
        cell.imageView.image = self.noImage;
    }
    
    return cell;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Pass the selected object to the new view controller.
    self.selectedSpecies = displayItems[indexPath.row];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIESSEARCH SELECTED" object: self.selectedSpecies];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    int count = _isSearching ? (int)[self.sortedDisplayItems count] : (int)[self.displayItems count];
    if(count > 0){
        //NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        //[fmt setNumberStyle:NSNumberFormatterDecimalStyle];
        //[fmt setMaximumFractionDigits:0];
        title = [NSString stringWithFormat:@"Found %d animals", count];
    } else if(count == 0) {
        title = @"Enter animal name on the above text field.";
    }
    return title;
}

#pragma mark - Table view display
- (void)showOrHideActivityIndicator {
}



- (void) btnRefreshPressed {
    [displayItems removeAllObjects];
    [self populateTableView];
}

- (void)btnCancelPressed {
    [searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * update display items after asynchronous search
 */
-(void)updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total{
    [displayItems addObjectsFromArray:data];
    
    // run reload data on main thread. otherwise, table rendering will be very slow.
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    
    [self showOrHideActivityIndicator];
}

#pragma mark - Utility functions
/**
 * load first page
 */
- (void) populateTableView {
    [self.displayItems removeAllObjects];
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.displayItems = [appDelegate.speciesListService loadSpeciesList];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
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



- (void)searchSpecies:(NSString *)searchText
{
    [self.sortedDisplayItems removeAllObjects];
    for (Species *obj in self.displayItems) {
        NSRange nameRange = [obj.displayName rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (nameRange.location != NSNotFound) {
            [self.sortedDisplayItems addObject:obj];
        }
    }
}

#pragma mark - Navigation controller
- (void) searchBarSearchButtonClicked:(UISearchBar*) theSearchBar{
    [theSearchBar resignFirstResponder];
    if([self.searchBar.text isEqualToString:@""]) {
        _isSearching = FALSE;
        [self populateTableView];
    } else {
        _isSearching = TRUE;
        [self searchSpecies:self.searchBar.text];
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}
@end
