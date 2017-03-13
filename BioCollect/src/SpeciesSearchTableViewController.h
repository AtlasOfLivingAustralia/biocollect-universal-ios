//
//  SpeciesSearchTableViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 17/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeciesSearchTableViewController : UITableViewController
{
    NSMutableArray *displayItems;
    NSDictionary *selectedSpecies;
}
@property (strong, nonatomic) IBOutlet UITableView *speciesTableView;
@property (strong, nonatomic) NSMutableArray *displayItems;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSDictionary *selectedSpecies;
@property (strong, nonatomic) UIImage *noImage;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

//pagination flags
@property (nonatomic, assign) int totalResults;
@property (nonatomic, assign) int offset;

//Search flag
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, assign) BOOL loadingFinished;

-(void)updateDisplayItems: (NSMutableArray *)data totalRecords: (int) total;
@end
