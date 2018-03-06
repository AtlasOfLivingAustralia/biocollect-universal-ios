//
//  SpeciesListService.m
//  Oz Atlas

#import <Foundation/Foundation.h>
#import "SpeciesListService.h"
#import "GASettingsConstant.h"
#import "SpeciesJSON.h"
#import "Species.h"
#import "GASettings.h"

@interface SpeciesListService ()
@property (nonatomic, strong) NSURL *speciesFileUrlPath;
@property (nonatomic, retain) NSMutableArray *speciesList;
@end

@implementation SpeciesListService
#define kSpeciesListKey @"SpeciesListKey"
#define kTracksSpeciesStorageLocation @"TRACKS_SPECIES_LIST_1"
#define kEnglish @"ENGLISH"
#define kWarlpiri @"WARLPIRI"

@synthesize speciesList;

-(id) init {
    self.speciesList = [[NSMutableArray alloc]init];
    NSArray<NSURL *> *urls = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask];
    if([urls count] > 0){
        self.speciesFileUrlPath = [urls[0] URLByAppendingPathComponent:kTracksSpeciesStorageLocation];
    }
    NSError *error;
    [self getSpeciesFromList:&error];
    return self;
}


- (void) getSpeciesFromList : (NSError**) error {
    NSString *listUrl = [GASettings appLoadSpeciesListUrl];
    if (listUrl == (id)[NSNull null] || listUrl.length == 0 ) {
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = [[NSString alloc] initWithFormat: @"%@%@", LISTS_SERVER, listUrl];
    NSString *escapedUrlString =[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [request setURL:[NSURL URLWithString:escapedUrlString]];
    [request setHTTPMethod:@"GET"];
    NSURLResponse *response;
    
    NSData *nsData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];
    if(*error == nil) {
        self.speciesList = [[NSMutableArray alloc] init];
        SpeciesJSON  *speciesJSON = [[SpeciesJSON alloc] initWithData:nsData];
        while([speciesJSON hasNext]) {
            [speciesJSON nextSpecies];
            Species *speciesObj = [[Species alloc] init];
            speciesObj.speciesListId = speciesJSON.speciesListId;
            speciesObj.name = speciesJSON.name;
            speciesObj.commonName = speciesJSON.commonName;
            speciesObj.scientificName = speciesJSON.scientificName;
            speciesObj.lsid = speciesJSON.lsid;
            speciesObj.kvpValues = speciesJSON.kvpValues;
            [speciesList addObject:speciesObj];
        }
        [self storeSpeciesList: nsData];
    }
}

-(BOOL) storeSpeciesList : (NSData *) jsonData {
    [self updateDisplayName];
    BOOL archived = [NSKeyedArchiver archiveRootObject: self.speciesList toFile: self.speciesFileUrlPath.path];
    if (!archived) {
        NSLog(@"Failed to load to species list from local storage.");
    }
    return archived;
}

- (NSMutableArray *) loadSpeciesList {
    NSArray<Species*> *speciesObj = [NSKeyedUnarchiver unarchiveObjectWithFile: self.speciesFileUrlPath.path];
    [self.speciesList removeAllObjects];
    [self.speciesList addObjectsFromArray:speciesObj];
    
    if([self.speciesList count] == 0) {
        NSError *error;
        [self getSpeciesFromList:&error];
    }
    //[self.speciesList sortUsingSelector:@selector(sortByDisplayName:)];
    return [self speciesList];
}

-(void) updateDisplayName {
    NSString *language = kEnglish;
    for(int i = 0; i<  [self.speciesList count]; i++) {
        Species *species = self.speciesList[i];
        for(int j=0; j < [species.kvpValues count]; j++){
            NSDictionary *kvp = species.kvpValues[j];
            if([language isEqualToString:kEnglish] && [kvp[@"key"] isEqualToString:@"vernacular name"]) {
                species.displayName = kvp[@"value"];
                break;
            } else if([language isEqualToString:kWarlpiri] && [kvp[@"key"] isEqualToString:@"Warlpiri name"]) {
                species.displayName = kvp[@"value"];
                break;
            }
        }
    }
}

@end
