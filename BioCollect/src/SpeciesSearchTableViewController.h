//
//  SpeciesSearchTableViewController.h
//  Oz Atlas

#import <UIKit/UIKit.h>

@interface SpeciesSearchTableViewController : UITableViewController<UITableViewDelegate>
{
    NSMutableArray *displayItems;
    NSDictionary *selectedSpecies;
}
@property (strong, nonatomic) IBOutlet UITableView *speciesTableView;
@property (strong, nonatomic) NSMutableArray *displayItems;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSDictionary *selectedSpecies;
@property (strong, nonatomic) UIImage *noImage;

//pagination flags
@property (nonatomic, assign) int totalResults;
@property (nonatomic, assign) int offset;

//Search flag
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL loadingFinished;

-(void)updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total;
-(instancetype) initWithNibNameForDownload:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
@end
