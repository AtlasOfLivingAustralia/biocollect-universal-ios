#import <Foundation/Foundation.h>

@interface Species : NSObject <NSCoding> {
    int _id;
    
    NSString *speciesListId;
    NSString *displayName; // For english use kvp: vernacular name.
    NSString *name;
    NSString *commonName;
    NSString *scientificName;
    NSString *lsid;
    NSArray *kvpValues;
}

@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString * speciesListId;
@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * commonName;
@property (nonatomic, strong) NSString * scientificName;
@property (nonatomic, strong) NSString * lsid;
@property (nonatomic, strong) NSArray  * kvpValues;
- (NSComparisonResult)sortByDisplayName:(Species *)otherObject;
@end
