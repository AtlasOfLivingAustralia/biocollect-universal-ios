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
@synthesize  tableView, hubProjects, isSearching, searchBar, searchBarController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialise];
        self.navigationItem.title = @"Ranger Groups";
    }
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed)];
    self.navigationItem.rightBarButtonItem = btnDone;
    btnDone.enabled=TRUE;
    
    return self;
}

-(void) initialise {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.hubProjects = [[NSMutableArray alloc]init];
    self.isSearching = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
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
            [self.searchBarController setActive:false];
        }
        [self.tableView reloadData];
    }
}

- (void) load {
    [self.hubProjects removeAllObjects];
    self.hubProjects = [self.appDelegate.projectService loadProjects];
    self.selectedProject = [self.appDelegate.projectService loadSelectedProject];
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
    [self searchProjects :@"" cancelTriggered:TRUE];
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if(isSearching) {
        [self searchProjects:searchString cancelTriggered:FALSE];
    }
    return NO;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


# pragma Project Results Handler

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

-(void) doneBtnPressed {
    if(self.selectedProject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PROJECT-UPDATED" object:self.selectedProject.name];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [RKDropdownAlert title:@"Error" message:@"Please select the organisation" backgroundColor:[UIColor colorWithRed:231.0/255.0 green:76.0/255.0 blue:60.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
    }
}
@end

