//
//  SpeciesListService.h
//  Oz Atlas
//

@interface SpeciesListService : NSObject
@property (nonatomic, retain) NSMutableArray *speciesList;
- (void) getSpeciesFromList : (NSError**) error;
- (void) loadSpeciesList;
@end
