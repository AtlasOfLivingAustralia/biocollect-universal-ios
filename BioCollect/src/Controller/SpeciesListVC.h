
#import <UIKit/UIKit.h>

@interface SpeciesListVC : UITableViewController<UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableArray *displayItems;
    NSDictionary *selectedSpecies;
}
@property (strong, nonatomic) IBOutlet UITableView *speciesTableView;
@property (strong, nonatomic) NSMutableArray *displayItems;
@property (strong, nonatomic) NSMutableArray *sortedDisplayItems;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSDictionary *selectedSpecies;
@property (strong, nonatomic) UIImage *noImage;

-(void)updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total;
@end
