//
//  HomeTableViewController.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 3/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeTableViewController.h"


@implementation HomeTableViewController
@synthesize  bioProjects, appDelegate, bioProjectService, totalProjects;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *) nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.bioProjectService = self.appDelegate.bioProjectService;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //Load project
    self.bioProjects = [[NSMutableArray alloc]init];
    NSError *error = nil;
    self.totalProjects = [self.bioProjectService getBioProjects: bioProjects offset:0 max:10 error:&error];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection: (NSInteger)section {
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Projects";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        //Show next level depth.
    }
}

@end