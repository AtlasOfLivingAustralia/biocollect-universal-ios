#import <UIKit/UIKit.h>

@interface ListTVC : UITableViewController<UITableViewDelegate>
{
    NSMutableArray *displayItems;
    NSDictionary *listsItems;
}

@property (strong, nonatomic) IBOutlet UITableView *listTableView;
@property (strong, nonatomic) NSMutableArray *displayItems;
@property (strong, nonatomic) UIImage *noImage;

// Pagination flags
@property (nonatomic, assign) int totalResults;
@property (nonatomic, assign) int offset;

// Search flag
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL loadingFinished;

- (void) updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total;

@end

