//
//  HomeTableViewController.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 3/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GAAppDelegate.h"
#import "BioProjectService.h"

@interface HomeTableViewController :  UITableViewController <UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *homeTableView;

@property (nonatomic, strong) NSMutableArray * bioProjects;
@property (nonatomic, assign) NSInteger totalProjects;

@property (nonatomic, strong) GAAppDelegate *appDelegate;
@property (nonatomic, strong) BioProjectService *bioProjectService;
@end

