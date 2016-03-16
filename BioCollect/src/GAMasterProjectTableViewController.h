//
//  GAMasterProjectViewController.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAAppDelegate.h"
#import "GARestCall.h"

@class GADetailActivitiesTableViewController;
@interface GAMasterProjectTableViewController :  UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) GADetailActivitiesTableViewController *detailFormViewController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * projects;
@property (nonatomic, strong) NSString * version;
-(void) updateProjectTableModel : (NSMutableArray *) p;
@end
