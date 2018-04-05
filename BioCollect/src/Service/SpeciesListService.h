//
//  SpeciesListService.h
//  Oz Atlas
//
#import "Species.h"

@interface SpeciesListService : NSObject
- (void) getSpeciesFromList : (NSError**) error;
- (NSMutableArray *) loadSpeciesList;
- (NSString *) getWarlpiriName : (Species *) species;
@end
