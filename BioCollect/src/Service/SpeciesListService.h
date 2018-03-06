//
//  SpeciesListService.h
//  Oz Atlas
//

@interface SpeciesListService : NSObject
- (void) getSpeciesFromList : (NSError**) error;
- (NSMutableArray *) loadSpeciesList;
@end
