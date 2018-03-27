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
@property (strong, nonatomic) Species *selectedSpecies;
@property (nonatomic, strong) UIAlertView *animalView;
@end

@implementation SpeciesListVC
@synthesize speciesTableView, displayItems, isSearching, searchBarController, selectedSpecies, searchBar, spinner;

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
    
    self.navigationItem.rightBarButtonItems = @[btnDone, plusButton];
    self.animalView = [[UIAlertView alloc]initWithTitle:@"Animal name" message:@"Enter the animal name that are not in animal list" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    self.animalView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [self.animalView textFieldAtIndex:0].delegate = self;
    
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.isSearching = NO;
    displayItems = [[NSMutableArray alloc] initWithCapacity:0];
    
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
            [self.searchBarController setActive:false];
        }
        
        [self.tableView reloadData];
    }
}

/**
 * load first page
 */
- (void) load {
    [self.displayItems removeAllObjects];
    self.displayItems = [self.appDelegate.speciesListService loadSpeciesList];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.tableView reloadData];
}

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //When the user taps the search bar, this means that the controller will begin searching.
    isSearching = YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //When the user taps the Cancel Button, or anywhere aside from the view.
    isSearching = NO;
    [self searchSpecies :@"" cancelTriggered:TRUE];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(isSearching) {
        [self searchSpecies:searchString cancelTriggered:FALSE];
    }
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Return YES to cause the search result table view to be reloaded.
    return YES;
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
                [self.searchDisplayController.searchResultsTableView reloadData];
            }
        });
    });
}

- (void) searchIndicator: (BOOL) searching {
    if(searching) {
        self.spinner.center = self.view.center;
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
#pragma mark - Navigation controller
-(void) doneBtnPressed {
    if(self.selectedSpecies) {
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIES_SEARCH_SELECTED" object: self.selectedSpecies];
    } else {
        [RKDropdownAlert title:@"Error" message:@"Please select the animal" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    }
}

-(void) newAnimal {
    [self.animalView show];
}

#pragma mark - UIAlert view delegate.
- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if( buttonIndex != 0 ) {
        Species *newAnimal = [[Species alloc] init];
        newAnimal.displayName = [self.animalView textFieldAtIndex: 0].text;
        newAnimal.name = [self.animalView textFieldAtIndex: 0].text;
        newAnimal.lsid = @"";
        self.selectedSpecies = newAnimal;
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"SPECIES_SEARCH_SELECTED" object: self.selectedSpecies];
    }
}

@end
