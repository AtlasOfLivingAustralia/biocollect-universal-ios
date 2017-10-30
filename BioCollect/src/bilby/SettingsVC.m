#import "SettingsVC.h"
#import "SpeciesCell.h"
#import "SpeciesSearchTableViewController.h"
#import "SGDetailViewTableViewController.h"
#import "HomeViewController.h"
#import "GAAppDelegate.h"
#import "RKDropdownAlert.h"
#import "ListTVC.h"

@interface SettingsVC ()
@property (strong, nonatomic) SpeciesSearchTableViewController *speciesSearchVC;
@property (strong, nonatomic) HomeViewController *homeMapViewController;
@property (strong, nonatomic) GAAppDelegate *appDelegate;
@end

@implementation SettingsVC
@synthesize curentLocation;
#pragma mark - init

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    style = UITableViewStyleGrouped;
    if (self = [super initWithStyle:style]) {
        self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.speciesSearchVC = [[SpeciesSearchTableViewController alloc] initWithNibNameForDownload:@"SpeciesSearchTableViewController" bundle:nil];
        self.homeMapViewController = [[HomeViewController alloc] init];
        self.homeMapViewController.customView = @"Download species by location";
        NSMutableDictionary *dict = [NSMutableDictionary new];
        dict[@"lat"] = @"0.0";
        dict[@"lng"] = @"0.0";
        dict[@"radius"] = @"1";
        self.homeMapViewController.locationDetails = dict;
    }
    
    return self;
}

#pragma mark - standard functions
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 40;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 4;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    if(!cell) {
        // Configure the cell...
        cell = [[SpeciesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.autoresizesSubviews = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if(indexPath.section == 0) {
        switch(indexPath.row) {
            case 0 :
                cell.textLabel.text = @"Search and add";
                break;
            case 1 :
                cell.textLabel.text = @"Download by location";
                break;
            case 2 :
                cell.textLabel.text = @"Group download";
                break;
            case 3 :
                cell.textLabel.text = @"Downloaded species";
                break;
            default:
                cell.textLabel.text = @"Other";
                break;
        }
    } else if (indexPath.section == 1){
        switch(indexPath.row) {
            case 0 :
                cell.textLabel.text = @"Muru - Warinyi Ankkul";
                break;
            case 1 :
                cell.textLabel.text = @"North Tanami";
                break;
            case 2 :
                cell.textLabel.text = @"Anmatyerr";
                
                break;
        }
    } else if (indexPath.section == 2){
        switch(indexPath.row) {
            case 0 :
                cell.textLabel.text = @"Adithinngithigh";
                break;
            case 1 :
                cell.textLabel.text = @"Barngarla";
                break;
            case 2 :
                cell.textLabel.text = @"Burduna";
                break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        switch(indexPath.row) {
            case 0:
                [self.navigationController pushViewController: self.speciesSearchVC animated:TRUE];
                break;
            case 1:
                self.homeMapViewController.clLocation =  self.curentLocation;
                self.homeMapViewController.isDownload = TRUE;
                [self.navigationController pushViewController: self.homeMapViewController animated:TRUE];
                break;
            case 2:
                if([[self.appDelegate restCall] notReachable]) {
                    [RKDropdownAlert title:@"Device offline" message:@"Please try later!" backgroundColor:[UIColor colorWithRed:243.0/255.0 green:156.0/255.0 blue:18.0/255.0 alpha:1] textColor: [UIColor whiteColor] time:5];
                    return;
                }

                ListTVC *listTVC = [[ListTVC alloc] initWithNibName:@"ListTVC" bundle:nil];
                [self.navigationController pushViewController:listTVC animated:TRUE];
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title;
    switch(section){
        case 0 :
            title = @"Species Download";
            break;
        case 1 :
            title = @"Ranger Groups";
            break;
        case 2 :
            title = @"Language Selection";
            break;
        default:
            title = @"Other";
            break;
    }
    return title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *myLabel = [[UILabel alloc] init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    myLabel.frame = CGRectMake(0, 0, screenWidth, 30);
    myLabel.backgroundColor = [UIColor colorWithRed:53/255.0 green:54/255.0 blue:49/255.0 alpha:1];
    myLabel.textAlignment = UITextAlignmentLeft;
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.textColor = [UIColor whiteColor];
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

@end
