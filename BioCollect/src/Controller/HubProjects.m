//  HomeTableViewController.m
#import <Foundation/Foundation.h>
#import "UIImageView+WebCache.h"
#import "HubProjects.h"
#import "HomeCustomCell.h"
#import "HomeWebView.h"
#import "MRProgressOverlayView.h"
#import "GASettingsConstant.h"
#import "Project.h"
#import "RKDropdownAlert.h"

@interface HubProjects()
@property (strong, nonatomic) GAAppDelegate *appDelegate;
@property (strong, nonatomic) Project *selectedProject;
@property (nonatomic, assign) BOOL isSearching;
@end

@implementation HubProjects
@synthesize  tableView, hubProjects, isSearching, searchBar, searchController;

#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialise];
        self.navigationItem.title = @"Ranger Groups";
    }
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed)];
    self.navigationItem.rightBarButtonItem = btnDone;
    btnDone.enabled=TRUE;
    _enableSearchController = true;
    
    return self;
}

-(void) initialise {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.hubProjects = [[NSMutableArray alloc]init];
    self.isSearching = NO;
}

#pragma mark - standard functions
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    if (_enableSearchController) {
        HubProjects *hubProjectsVC = [[HubProjects alloc] initWithNibName:@"HubProjects" bundle:nil];
        hubProjectsVC.enableSearchController = false;
        hubProjectsVC.tableView.delegate = hubProjectsVC;
        searchController = [[UISearchController alloc] initWithSearchResultsController: hubProjectsVC];
        searchController.delegate = self;
        searchController.searchResultsUpdater = hubProjectsVC;
        searchController.searchBar.delegate = self;
        searchController.hidesNavigationBarDuringPresentation = false;
        
        if (@available(iOS 11.0, *) ){
            // For iOS 11 and later, place the search bar in the navigation bar.
            self.navigationItem.searchController = searchController;

            // Make the search bar always visible.
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar;
            self.definesPresentationContext = true;
        }
    }
    
    [self load];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableViewDelegae
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    NSUInteger rows = self.hubProjects != nil ? [self.hubProjects count] : 0;
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(self.isSearching) {
        return @"";
    } else {
        return [[NSString alloc] initWithFormat:@"Found %ld Ranger groups", [self.hubProjects count]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[HomeCustomCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryNone;

    if([self.hubProjects count] > indexPath.row) {
        Project *project = [self.hubProjects objectAtIndex:indexPath.row];;
        cell.textLabel.text = project.name;
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString: project.urlImage] placeholderImage:[UIImage imageNamed:@"noImage85.jpg"] options:SDWebImageRefreshCached ];
        self.selectedProject = [self.appDelegate.projectService loadSelectedProject];
        if(self.selectedProject && [self.selectedProject.projectId isEqualToString: project.projectId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if(indexPath.section == 0 && [self.hubProjects count] >= indexPath.row){
        Project *project =  [self.hubProjects objectAtIndex:indexPath.row];
        [self.appDelegate.projectService storeSelectedProject:project];
        self.selectedProject = [self.appDelegate.projectService loadSelectedProject];
        if(self.isSearching){
            [self.searchController setActive:false];
        }
        [self.tableView reloadData];
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
    if(self.selectedProject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PROJECT-UPDATED" object:self.selectedProject.name];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [RKDropdownAlert title:@"Error" message:@"Please select the organisation" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    }
}

#pragma mark - UISearchControllerDelegate
- (void)didDismissSearchController:(UISearchController *)searchController {
    [self.tableView reloadData];
}

#pragma mark - UISearchResultUpdating
- (void) updateSearchResultsForSearchController:(UISearchController *)searchController
{
        NSString *searchString = searchController.searchBar.text;
        [self searchProjects:searchString cancelTriggered:FALSE];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(nonnull NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        [self.tableView reloadData];
    }
}

#pragma mark - class functions
- (void) load {
    [self.hubProjects removeAllObjects];
    [self.hubProjects addObjectsFromArray:[self.appDelegate.projectService loadProjects]];
    self.selectedProject = [self.appDelegate.projectService loadSelectedProject];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void) searchProjects :(NSString*) searchString cancelTriggered: (BOOL) cancelTriggered {
    [self searchIndicator:TRUE];
    [self.hubProjects removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self load];
        if (searchString != (id)[NSNull null] && searchString.length > 0 ) {
            NSMutableArray *filteredProjects = [[NSMutableArray alloc] init];
            for (Project *obj in self.hubProjects) {
                NSRange nameRange = [ obj.name rangeOfString:searchString options:NSCaseInsensitiveSearch];
                if(nameRange.location != NSNotFound) {
                    [filteredProjects addObject:obj];
                }
            }
            [self.hubProjects removeAllObjects];
            [self.hubProjects addObjectsFromArray:filteredProjects];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self searchIndicator:FALSE];
            [self.tableView reloadData];
        });
    });
}

- (void) searchIndicator: (BOOL) searching {
    if(searching) {
        self.spinner.center = self.view.center;
        [self.tableView addSubview : self.spinner];
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

@end

