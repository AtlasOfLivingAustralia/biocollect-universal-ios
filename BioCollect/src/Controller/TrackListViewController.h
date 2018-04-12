//
//  TrackListViewController.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 22/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackerService.h"
#import "GAAppDelegate.h"
#import "MRProgressOverlayView.h"

@interface TrackListViewController: UITableViewController<UITableViewDelegate> {
    NSInteger totalTracksToUpload;
    NSInteger totalTracksUploaded;
    MRProgressOverlayView* overlay;
}

@property (nonatomic, strong) TrackerService* service;
@property (nonatomic, strong) GAAppDelegate* appDelegate;

@end
