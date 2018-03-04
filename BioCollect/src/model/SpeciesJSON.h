//  SpeciesJSON.h
#import <Foundation/Foundation.h>

@interface SpeciesJSON : NSObject
- (id) initWithData:(NSData *)jsonData;

- (NSString *) speciesListId;
- (NSString *) name;
- (NSString *) commonName;
- (NSString *) scientificName;
- (NSString *) lsid;
- (NSArray *)  kvpValues;

- (NSDictionary*)getSpecies;
- (NSDictionary*)nextSpecies;
- (NSDictionary*)firstSpecies;
- (int) getSpeciesCount;
- (BOOL) hasNext;
@end
