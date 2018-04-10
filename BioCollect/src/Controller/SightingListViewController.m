//
//  SightingListViewController.m
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 7/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAAppDelegate.h"
#import "SightingListViewController.h"
#import "SpeciesCell.h"
#import "SightingForm.h"
#import "SightingViewController.h"

@implementation SightingListViewController
- (void) viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewStylePlain;
    self.tableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sightingSaved:) name:@"SPECIES-SIGHTING-SAVED" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger size = [_animals count] == 0 ? 1 : [_animals count];
    
    return size;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    if(!cell){
        // Configure the cell...
        cell = [[SpeciesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.autoresizesSubviews = YES;
    }
    
    if ([_animals count] == 0) {
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;

        cell.textLabel.text = [locale get: @"sighting.notfound"];
        cell.detailTextLabel.text = [locale get: @"sighting.notfound.helptext"];
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        SightingForm *form = (SightingForm *)_animals[indexPath.row];
        Species *species = form.animal;
        NSString *commonName = species.commonName;
        if (commonName == (id)[NSNull null] || commonName.length == 0 ) {
            commonName = @"N/A";
        }
        
        cell.textLabel.text = species.displayName;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@",commonName,species.scientificName];
        cell.imageView.image = [form getImage];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ( [_animals count] > 0 ) {
        SightingForm *form = _animals[indexPath.row];
        SightingViewController *vc = [[SightingViewController alloc] initWithForm:form];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) sightingSaved: (NSNotification *) notice {
    [self.tableView reloadData];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  [_animals count] == 0 ? NO : YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SightingForm * animal = _animals[indexPath.row];
        [animal deleteImages];
        [_animals removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SPECIES-REMOVED" object: animal];
    }
}

@end
