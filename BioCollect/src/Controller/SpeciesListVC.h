
#import <UIKit/UIKit.h>
#import "Species.h"
#import "FXForms.h"

@interface SpeciesListVC : UITableViewController<UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UIAlertViewDelegate>
    @property (strong, nonatomic) IBOutlet UITableView *speciesTableView;
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
    @property (weak, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
    @property (nonatomic, strong) UIActivityIndicatorView *spinner;
    @property (nonatomic, strong) NSMutableArray * displayItems;
    @property (strong, nonatomic) UIImage *noImage;
    @property (nonatomic, strong) FXFormField *field;
@end
