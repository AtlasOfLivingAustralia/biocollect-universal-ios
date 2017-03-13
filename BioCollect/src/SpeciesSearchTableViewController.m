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

@interface SpeciesSearchTableViewController ()
@end


@implementation SpeciesSearchTableViewController

#define SEARCH_PAGE_SIZE 20;

@synthesize speciesTableView, displayItems, selectedSpecies, searchBar;

#pragma mark - init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.navigationItem.title = @"Search species";
    }
    
    // add done button
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDonePressed)];
    self.navigationItem.rightBarButtonItem = btnDone;
    btnDone.enabled=TRUE;

    // add cancel button
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(btnCancelPressed)];
    self.navigationItem.leftBarButtonItem = btnCancel;
    btnCancel.enabled=TRUE;

    // spinner to show searching
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    }
    
    NSDictionary *species = [displayItems objectAtIndex:indexPath.row];
    NSString *thumbnail;
    cell.textLabel.text = species[@"displayName"];
    cell.detailTextLabel.text = species[@"rank"];
    
    if(self.noImage == nil){
        self.noImage = [UIImage imageNamed:@"table-place-holder"];
    }
    
    thumbnail = (([species objectForKey:@"thumbnailUrl"] != nil) && (species[@"thumbnailUrl"] != [NSNull null]))? species[@"thumbnailUrl"] :@"";
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
    
    // Push the view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if(self.isSearching) {
        title = @"Loading...";
    } else if(self.loadingFinished){
        if(self.totalResults > 0){
            title = [NSString stringWithFormat:@"Found %d results", self.totalResults];
        } else{
            title = @"No results found";
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

#pragma mark - Navigation controller
- (void) searchBarSearchButtonClicked:(UISearchBar*) theSearchBar{
    [theSearchBar resignFirstResponder];
    [displayItems removeAllObjects];
    self.loadingFinished = NO;
    self.isSearching = YES;
    [self loadFirstPage];
}

- (void) btnDonePressed {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIESSEARCH SELECTED" object: self.selectedSpecies];
    [self.navigationController popViewControllerAnimated:YES];
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
    [displayItems addObjectsFromArray:result];
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
@end
