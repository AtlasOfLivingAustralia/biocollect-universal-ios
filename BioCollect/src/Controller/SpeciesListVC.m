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
#import "RKDropdownAlert.h"

@interface SpeciesListVC ()
@property (nonatomic, assign) BOOL isSearching;
@property (strong, nonatomic) GAAppDelegate *appDelegate;
@property (strong, nonatomic, setter=setSelectedSpecies:) Species *selectedSpecies;
@property (nonatomic, strong) UIAlertView *animalView;
@end

@implementation SpeciesListVC
@synthesize speciesTableView, displayItems, isSearching, searchController, selectedSpecies, searchBar, spinner;

#pragma mark - init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        self.navigationItem.title = @"Search Animals";
    }

    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed)];
    btnDone.enabled=TRUE;
    
    UIBarButtonItem *plusButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newAnimal)];
    plusButton.enabled=TRUE;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(downloadSpeciesImage)];
    plusButton.enabled=TRUE;
    
    self.navigationItem.rightBarButtonItems = @[btnDone, plusButton, refreshButton];
    self.animalView = [[UIAlertView alloc]initWithTitle:@"Animal name" message:@"Enter the animal name that are not in animal list" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.animalView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.animalView textFieldAtIndex:0].delegate = self;
    
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.isSearching = NO;
    displayItems = [[NSMutableArray alloc] initWithCapacity:0];
    self.enableSearchController = true;
    return  self;
}

- (instancetype) init {
    self = [super init];
    self = [self initWithNibName:@"SpeciesListVC" bundle: nil];
    return self;
}

#pragma mark - standard functions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.enableSearchController) {
        SpeciesListVC *speciesListVC = [[SpeciesListVC alloc] initWithNibName:@"SpeciesListVC" bundle:nil];
        speciesListVC.enableSearchController = false;
        speciesListVC.selectedSpecies = self.selectedSpecies;
        speciesListVC.parentSpeciesListVC = self;
        speciesListVC.tableView.delegate = speciesListVC;
        searchController = [[UISearchController alloc] initWithSearchResultsController: speciesListVC];
        searchController.delegate = speciesListVC;
        searchController.searchResultsUpdater = speciesListVC;
        searchController.searchBar.delegate = speciesListVC;
        searchController.hidesNavigationBarDuringPresentation = false;
        
        if (@available(iOS 11.0, *) ) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            self.navigationItem.searchController = searchController;

            // Make the search bar always visible.
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            self.tableView.tableHeaderView = searchController.searchBar;
        }
    }
    
    speciesTableView.rowHeight = 60;
    speciesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self searchBar].text = @"";
    [self load];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [super dismissViewControllerAnimated:flag completion:completion];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIES-SEARCH-CLOSING" object: self.selectedSpecies];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger rows = self.displayItems != nil ? [self.displayItems count] : 0;
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.isSearching) {
        return @"";
    } else {
        return [[NSString alloc] initWithFormat:@"Found %ld Animals", [self.displayItems count]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[SpeciesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.autoresizesSubviews = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if([self.displayItems count] > indexPath.row) {
        Species *species = [displayItems objectAtIndex:indexPath.row];
        NSString *commonName = species.commonName;
        if (commonName == (id)[NSNull null] || commonName.length == 0 ) {
            commonName = @"N/A";
        }
        
        NSString *scientificName = species.scientificName;
        if (scientificName == (id)[NSNull null] || scientificName.length == 0 ) {
            scientificName = @"N/A";
        }
        cell.textLabel.text = species.displayName;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@",commonName,scientificName];
        
        if(self.noImage == nil){
            self.noImage = [UIImage imageNamed:@"noImage85.jpg"];
        }
        
        NSArray *kvp = species.kvpValues;
        NSString *thumbnail;
        for(int i = 0; i < [kvp count]; i++) {
            NSDictionary *item =  kvp[i];
            if([item[@"key"] isEqualToString: @"Image"]) {
                thumbnail = [[NSString alloc] initWithFormat:@"%@",item[@"value"]];
                break;
            }
        }
        if(![thumbnail isEqualToString:@""]){
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString: thumbnail] placeholderImage:[UIImage imageNamed:@"noImage85.jpg"] options:SDWebImageRefreshCached ];
        } else {
            cell.imageView.image = self.noImage;
        }
        
        if ([[NSString stringWithFormat:@"%@",self.selectedSpecies.speciesListId] isEqualToString:[NSString stringWithFormat:@"%@",species.speciesListId]]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && [self.displayItems count] >= indexPath.row){
        Species *species =  [self.displayItems objectAtIndex:indexPath.row];
        self.selectedSpecies = species;
        self.field.value = self.selectedSpecies;
        if(self.isSearching){
            [self.searchController setActive:false];
        }
        
        [self.tableView reloadData];
        [self doneBtnPressed];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}

#pragma mark - Navigation controller
-(void) doneBtnPressed {
    if(self.selectedSpecies) {
        if (self.parentSpeciesListVC != nil){
            [self.parentSpeciesListVC.navigationController popViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIES_SEARCH_SELECTED" object: self.selectedSpecies];
    } else {
        [RKDropdownAlert title:@"Error" message:@"Please select the animal" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    }
}

#pragma mark - UIAlert view delegate.
- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if( buttonIndex != 0 ) {
        Species *newAnimal = [[Species alloc] init];
        NSString *input = [self.animalView textFieldAtIndex: 0].text;
        if (input == (id)[NSNull null] || [input isEqualToString:@""] || input.length == 0 ) {
            input = @"No Animal Found";
        }
        newAnimal.displayName = input;
        newAnimal.name = input;
        newAnimal.lsid = @"";

        self.selectedSpecies = newAnimal;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIES_SEARCH_SELECTED" object: self.selectedSpecies];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UISearchResultUpdating
- (void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchSpecies:searchString cancelTriggered:FALSE];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText {
//        [self.tableView reloadData];
}

#pragma mark - class functions
- (void) setField:(FXFormField *)field {
    _field = field;
    self.selectedSpecies = field.value;
}

- (Species *) getSelectedSpecies {
    SpeciesListVC * vc = self;
    if ( self.parentSpeciesListVC != nil){
        vc = self.parentSpeciesListVC;
    }
    
    return vc.selectedSpecies;
}

- (void) setSelectedSpecies: (Species*) species {
    _field.value = species;
    selectedSpecies = species;
    
    if ( self.parentSpeciesListVC != nil){
        self.parentSpeciesListVC.selectedSpecies = species;
    }
}

-(void) downloadSpeciesImage {
    if([[self.appDelegate restCall] notReachable]) {
        [RKDropdownAlert title:@"Device offline" message:@"Error downloading species images" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    } else {
        for (Species *species in self.displayItems) {
            NSArray *kvp = species.kvpValues;
            for(int i = 0; i < [kvp count]; i++) {
                NSDictionary *item =  kvp[i];
                if([item[@"key"] isEqualToString: @"Image"]) {
                    [[SDImageCache sharedImageCache] removeImageForKey:item[@"value"] fromDisk:YES];
                }
            }
        }
        [self.tableView reloadData];
        [RKDropdownAlert title:@"Updated animal images" message:@"" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    }
}

/**
 * load first page
 */
- (void) load {
    [self.displayItems removeAllObjects];
    [self.displayItems addObjectsFromArray:[self.appDelegate.speciesListService loadSpeciesList]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) searchSpecies :(NSString*) searchString cancelTriggered: (BOOL) cancelTriggered {
    [self searchIndicator:TRUE];
    [self.displayItems removeAllObjects];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self load];
        if (searchString != (id)[NSNull null] && searchString.length > 0 ) {
            NSMutableArray *filteredSpecies = [[NSMutableArray alloc] init];
            for (Species *obj in self.displayItems) {
                NSRange nameRange = [ obj.displayName rangeOfString:searchString options:NSCaseInsensitiveSearch];
                if(nameRange.location != NSNotFound) {
                    [filteredSpecies addObject:obj];
                }
            }
            [self.displayItems removeAllObjects];
            [self.displayItems addObjectsFromArray:filteredSpecies];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self searchIndicator:FALSE];
            if(cancelTriggered) {
                [self.tableView reloadData];
            } else {
                [self.speciesTableView reloadData];
            }
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
            UILabel *lbl = (UILabel*) [subview.subviews firstObject];
            lbl.text = searching ? @"Searching..." : @"No Results";
        }
    }
}

-(void) newAnimal {
    [self.animalView show];
}
@end
