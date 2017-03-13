//
//  GARestCall.h
//  GreenArmy
//
//  Created by Sathish iMac on 12/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAActivity.h"
#import "RecordForm.h"
#import "SpeciesSearchTableViewController.h"

@interface GARestCall : NSObject

-(id) init;
-(void) updateActivity : (GAActivity*) activity :(NSError**) e;
-(NSString *) uploadSite: (GASite*) site :(NSError**) e;
-(void) authenticate : (NSString *)username password:(NSString *) p error:(NSError **) e;
-(NSMutableArray *) downloadProjects : (NSError **) error;
-(NSMutableArray *) autoCompleteSpecies : (NSString *) searchText numberOfItemsPerPage: (int) pageSize fromSerialNumber: (int) offset addSearchText:(BOOL)addUnmatchedTaxon viewController: (SpeciesSearchTableViewController *) vc;
-(NSMutableDictionary * )createRecord: RecordForm;
@end
    
