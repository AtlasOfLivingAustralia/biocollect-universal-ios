//
//  SpeciesSearchTableViewController.m
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 17/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "SpeciesSearchTableViewController.h"
#import "GAAppDelegate.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "SpeciesCell.h"
#import "RKDropdownAlert.h"
#import "SVModalWebViewController.h"
#import "MRProgressOverlayView.h"

@interface SpeciesSearchTableViewController ()
@end


@implementation SpeciesSearchTableViewController

#define SEARCH_PAGE_SIZE 50;

@synthesize speciesTableView, displayItems, selectedSpecies, searchBar;

#pragma mark - init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.navigationItem.title = @"Search species";
    }
    
   
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStyleBordered target:self action:@selector(btnRefreshPressed)];
    
    self.navigationItem.rightBarButtonItem = reloadButton;
    reloadButton.enabled=TRUE;

    // add cancel button
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelPressed)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    btnCancel.enabled=TRUE;
    
    return  self;
}

#pragma mark - standard functions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    displayItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    // search settings
    self.totalResults = 0;
    self.offset = 0;
    
    [self searchBar].text = @"";
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
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
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
    cell.textLabel.text = species[@"displayName"];
    cell.detailTextLabel.text = species[@"rank"];
    
    if(self.noImage == nil){
        self.noImage = [UIImage imageNamed:@"noImage85.jpg"];
    }
    
    thumbnail = (([species objectForKey:@"thumbnailUrl"] != nil) && (species[@"thumbnailUrl"] != [NSNull null]))? species[@"thumbnailUrl"] :@"";
    if(![thumbnail isEqualToString:@""]){
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString: thumbnail] placeholderImage:[UIImage imageNamed:@"ajax_loader.gif"] options:SDWebImageRefreshCached ];
    } else {
        cell.imageView.image = self.noImage;
    }
   
    if(![species[@"rank"] isEqualToString: @"unmatched taxon"] ) {
        //http://bie.ala.org.au/species/Rattus rattus
        UIImage *image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"icon_about_2"]];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(320.0 - 44.0, 0.0, 44, 44);
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
    if(![species[@"rank"] isEqualToString: @"unmatched taxon"] ) {
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
    self.selectedSpecies = displayItems[indexPath.row];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIESSEARCH SELECTED" object: self.selectedSpecies];
    [self.navigationController popViewControllerAnimated:YES];
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
            title = [NSString stringWithFormat:@"Found %@ results", [fmt stringFromNumber:@(self.totalResults)]];
        } else if([self.displayItems count] == 0){
            title = @"Enter species name on the above text field.";
        } else if([self.displayItems count] == 1 && self.totalResults == 0){
            title = @"Select unmatched taxon";
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
    [searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * update display items after asynchronous search
 */
-(void)updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total{
    self.loadingFinished = YES;
    self.isSearching = NO;
    self.totalResults = total;
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
    int limit = SEARCH_PAGE_SIZE;
    NSMutableArray *result = [appDelegate.restCall autoCompleteSpecies:self.searchBar.text numberOfItemsPerPage: limit fromSerialNumber: self.offset addSearchText:YES viewController:self];
    if(result != nil && [result count] > 0) {
        [displayItems addObjectsFromArray:result];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

/**
 * load first page
 */
- (void) loadFirstPage{
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
    myLabel.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:88.0/255.0 blue:43.0/255.0 alpha:1];
    myLabel.textAlignment = UITextAlignmentCenter;
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor whiteColor];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}
@end
