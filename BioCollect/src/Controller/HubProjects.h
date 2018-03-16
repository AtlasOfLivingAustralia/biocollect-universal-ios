//  HubProjects.h
@interface HubProjects :  UITableViewController <UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray * hubProjects;
- (void) resetProjects;
@end
