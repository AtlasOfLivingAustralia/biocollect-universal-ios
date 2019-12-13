
#import <UIKit/UIKit.h>
#import "Species.h"
#import "FXForms.h"

@interface SpeciesListVC : UITableViewController<UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIAlertViewDelegate>
    @property (strong, nonatomic) IBOutlet UITableView *speciesTableView;
    @property (nonatomic) Boolean enableSearchController;
    @property (strong, nonatomic) UISearchBar *searchBar;
    @property (strong, nonatomic) UISearchController *searchController;
    @property (strong, nonatomic) SpeciesListVC *parentSpeciesListVC;
    @property (nonatomic, strong) UIActivityIndicatorView *spinner;
    @property (nonatomic, strong) NSMutableArray * displayItems;
    @property (strong, nonatomic) UIImage *noImage;
    @property (nonatomic, strong, setter=setField:) FXFormField *field;

- (void) setField: (FXFormField*) field;
- (void) setSelectedSpecies: (Species*) species;
@end
