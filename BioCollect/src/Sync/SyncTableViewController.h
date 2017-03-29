//
//  SyncTableViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 28/10/16.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SyncTableViewController : UITableViewController
@property(weak, nonatomic) NSMutableArray * displayItems;
@property(strong, nonatomic) NSString * cellIdentifier;
@end
