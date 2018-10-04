#import "SpeciesService.h"
#import "GASettingsConstant.h"

@interface SpeciesService()

@end

@implementation SpeciesService

-(id) init {
    return self;
}

-(void) getSpecies:  (NSMutableArray *) speciesArray {
}

-(NSMutableArray *) getSpecies : (NSString *) groupName numberOfItemsPerPage: (int) pageSize fromSerialNumber: (int) offset  viewController: (SpeciesGroupTableViewController *) vc {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url = nil;
    NSMutableDictionary *dictionary = vc.locationDetails;
    
    float lat = [dictionary[@"lat"] floatValue];
    float lng = [dictionary[@"lng"] floatValue];
    int radius = [dictionary[@"radius"] intValue];;
    offset = offset ?: 0;
    pageSize = pageSize ?: 10;
    
    if(groupName != nil && [groupName length] > 0 ) {
        url = [[NSString alloc] initWithFormat:@"%@%@?group=%@&lat=%f&lon=%f&radius=%d&start=%d&pageSize=%d&common=true", PROXY_SERVER, SPECIES_GROUP, groupName, lat, lng, radius, offset, pageSize];
    } else {
        url = [[NSString alloc] initWithFormat:@"%@%@?lat=%f&lon=%f&radius=%d", PROXY_SERVER, SPECIES_GROUPS, lat, lng, radius];
    }
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *e) {
        NSMutableArray *results = [[NSMutableArray alloc] init];
        int total = 0;
        
        if((e == nil) && (data != nil)){
            results = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:nil];
            // Remove ALL SPECIES entry
            [results count] > 0 ? [results removeObjectAtIndex:0] : nil;
            total = (int)[results count];
        }
        
        if(vc != nil){
            [vc updateDisplayItems:results totalRecords: total setKm:radius];
        }
        
    }];
    
    NSMutableArray *initialResult = [[NSMutableArray alloc] init];
    return initialResult;
}

@end
