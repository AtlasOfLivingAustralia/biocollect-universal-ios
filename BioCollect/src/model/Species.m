//
//  Species.c
//  Oz Atlas

#include "Species.h"
@implementation Species
@synthesize _id,speciesListId, name, displayName, commonName, scientificName, lsid, kvpValues;

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.speciesListId forKey:@"speciesListIdKey"];
    [aCoder encodeObject:self.name forKey:@"nameKey"];
    [aCoder encodeObject:self.displayName forKey:@"displayNameKey"];
    [aCoder encodeObject:self.commonName forKey:@"commonNameKey"];
    [aCoder encodeObject:self.scientificName forKey:@"scientificNameKey"];
    [aCoder encodeObject:self.lsid forKey:@"lsidKey"];
    [aCoder encodeObject:self.kvpValues forKey:@"kvpValuesKey"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.speciesListId = [aDecoder decodeObjectForKey: @"speciesListIdKey"];
    self.name = [aDecoder decodeObjectForKey: @"nameKey"];
    self.displayName = [aDecoder decodeObjectForKey: @"displayNameKey"];
    self.commonName = [aDecoder decodeObjectForKey: @"commonNameKey"];
    self.scientificName = [aDecoder decodeObjectForKey: @"scientificNameKey"];
    self.lsid = [aDecoder decodeObjectForKey: @"lsidKey"];
    self.kvpValues = [aDecoder decodeObjectForKey: @"kvpValuesKey"];
    return self;
}

- (NSComparisonResult)sortByDisplayName:(Species *)otherObject {
    return otherObject.displayName > self.displayName;
}

- (NSString *) getImageUrl {
    NSArray *kvp = kvpValues;
    NSString *thumbnail = nil;
    for(int i = 0; i < [kvp count]; i++) {
        NSDictionary *item =  kvp[i];
        if([item[@"key"] isEqualToString: @"Image"]) {
            thumbnail = item[@"value"];
            break;
        }
    }

    return thumbnail;
}

- (NSString*) getSubTitle {
    NSString * cn = commonName;
    if (commonName == (id)[NSNull null] || commonName.length == 0 ) {
        cn = @"N/A";
    }
    
    return [[NSString alloc] initWithFormat:@"%@, %@", cn, scientificName];
}

@end
