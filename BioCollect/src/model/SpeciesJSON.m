//
//  SpeciesJSON.m

#import "SpeciesJSON.h"
@interface SpeciesJSON ()

@property (strong, nonatomic) NSMutableArray *speciesJSONArray;
@property (strong, nonatomic) NSDictionary *speciesJSONDictionary;
@property (assign, nonatomic) int index;
@property (assign, nonatomic) BOOL hasNext;
@property (assign, nonatomic) int totalSpecies;
@end

@implementation SpeciesJSON

#define kId @"id"
#define kName @"name"
#define kCommonName @"commonName"
#define kScientificName @"scientificName"
#define kLsid @"lsid"
#define kKvpValues @"kvpValues"

- (id)initWithData:(NSData *)jsonData {
    self = [super init];
    if(self) {
        NSError *jsonParsingError = nil;
        self.speciesJSONArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonParsingError];
        self.totalSpecies = (int)[self.speciesJSONArray count];
        self.speciesJSONDictionary = [[NSDictionary alloc] init];
        self.index = 0;
    }
    return self;
}

- (NSDictionary*)firstSpecies {
    self.index = 0;
    if(self.index < [self.speciesJSONArray count])
        return [self.speciesJSONArray objectAtIndex:self.index];
    return nil;
}

- (int) getSpeciesCount {
    return (int)[self.speciesJSONArray count];
}

- (BOOL) hasNext {
    return (self.index < [self.speciesJSONArray count]);
}

- (NSDictionary*)nextSpecies {
    
    if(self.index < [self.speciesJSONArray count]){
        self.speciesJSONDictionary = [self.speciesJSONArray objectAtIndex:self.index];
        self.index++;
        return self.speciesJSONDictionary;
    }
    
    return nil;
}

- (NSDictionary*) getSpecies {
    return self.speciesJSONDictionary;
}

-(NSString *) speciesListId {
    return [self.speciesJSONDictionary objectForKey:kId];
}

-(NSString *) name {
    return [self.speciesJSONDictionary objectForKey:kName];
}

-(NSString *) commonName {
    return [self.speciesJSONDictionary objectForKey:kCommonName];
}

-(NSString *) scientificName {
    return [self.speciesJSONDictionary objectForKey:kScientificName];
}

-(NSString *) lsid {
    return [self.speciesJSONDictionary objectForKey:kLsid];
}

-(NSMutableArray *) kvpValues {
    return [self.speciesJSONDictionary objectForKey:kKvpValues];
}

@end

