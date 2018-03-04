//
//  SpeciesListService.m
//  Oz Atlas
//
//  Created by Sathish Babu Sathyamoorthy on 4/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeciesListService.h"
#import "GASettingsConstant.h"
#import "SpeciesJSON.h"
#import "Species.h"
#import "GASettings.h"


@implementation SpeciesListService
#define kSpeciesListKey @"SpeciesListKey"
@synthesize speciesList;

-(id) init {
    self.speciesList = [[NSMutableArray alloc]init];
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
    
    NSData *GETReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&*error];
    if(*error == nil) {
        self.speciesList = [[NSMutableArray alloc] init];
        SpeciesJSON  *speciesJSON = [[SpeciesJSON alloc] initWithData:GETReply];
        while([speciesJSON hasNext]) {
            [speciesJSON nextSpecies];
            Species *speciesObj = [[Species alloc] init];
            speciesObj.speciesListId = speciesJSON.speciesListId;
            speciesObj.name = speciesJSON.name;
            speciesObj.commonName = speciesJSON.commonName;
            speciesObj.scientificName = speciesJSON.scientificName;
            speciesObj.lsid = speciesJSON.lsid;
            [speciesList addObject:speciesObj];
        }
    }
    [self storeSpeciesList];
}


-(void) storeSpeciesList {
}

-(void) loadSpeciesList {
}
@end
