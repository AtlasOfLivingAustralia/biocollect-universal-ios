#import <UIKit/UIKit.h>

@interface SpeciesGroupTableViewController : UITableViewController<UITableViewDelegate>
{
    NSMutableArray *displayItems;
    NSDictionary *selectedSpecies;
}
@property (strong, nonatomic) IBOutlet UITableView *speciesTableView;
@property (strong, nonatomic) NSMutableArray *displayItems;
@property (strong, nonatomic) NSDictionary *selectedSpecies;
@property (strong, nonatomic) UIImage *noImage;

//pagination flags
@property (nonatomic, assign) int totalResults;
@property (nonatomic, assign) int offset;

//Search flag
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL loadingFinished;

//Location details [lat, lng, radius]
@property (strong, nonatomic) NSMutableDictionary *locationDetails;

-(void)updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total setKm: (int) kilometer;
@end
