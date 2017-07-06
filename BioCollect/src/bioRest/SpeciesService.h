//SpeciesService.h
#import "SpeciesGroupTableViewController.h"

@interface SpeciesService : NSObject

- (id) init;
- (NSMutableArray *) getSpecies : (NSString *) groupName numberOfItemsPerPage: (int) pageSize fromSerialNumber: (int) offset  viewController: (SpeciesGroupTableViewController *) vc;

@end
