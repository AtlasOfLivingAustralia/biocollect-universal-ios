//
//  TrackListViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 22/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackerService.h"

@interface TrackListViewController: UITableViewController<UITableViewDelegate>

@property (nonatomic, strong) TrackerService* service;

@end
