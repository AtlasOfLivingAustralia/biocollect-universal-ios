//
//  HomeTableViewController.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 3/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GAAppDelegate.h"
#import "BioProjectService.h"
#import "UIImageView+WebCache.h"
#import "RecordsTableViewController.h"

@interface HomeTableViewController :  UITableViewController <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *homeTableView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSMutableArray * bioProjects;

//Pagination info.
@property (nonatomic, strong) NSString * query;
@property (nonatomic, assign) NSInteger totalProjects;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) BOOL loadingFinished;


@property (nonatomic, strong) GAAppDelegate *appDelegate;
@property (nonatomic, strong) BioProjectService *bioProjectService;
@property (nonatomic, strong) RecordsTableViewController *recordsTableView;
-(void) resetProjects;
@end

