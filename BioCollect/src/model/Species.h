#import <Foundation/Foundation.h>

@interface Species : NSObject {
    int _id;
    
    NSString *speciesListId;
    NSString *name;
    NSString *commonName;
    NSString *scientificName;
    NSString *lsid;
    NSArray *kvpValues;
}

@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString * speciesListId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * commonName;
@property (nonatomic, strong) NSString * scientificName;
@property (nonatomic, strong) NSString * lsid;
@property (nonatomic, strong) NSArray * kvpValues;
@end
