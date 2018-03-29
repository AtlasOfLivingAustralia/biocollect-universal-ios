//
//  TrackViewController.h
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 23/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetadataForm.h"
#import "SightingListViewController.h"
#import "RouteViewController.h"

@interface TrackViewController : UITabBarController<UIImagePickerControllerDelegate, UITabBarControllerDelegate> {
    BOOL disableSaveButton;
}

@property (nonatomic, strong) MetadataForm* trackForm;
@property (nonatomic, strong) SightingListViewController *sighingtListViewController;
@property (nonatomic, strong) RouteViewController *route;

- (instancetype) initWithForm: (MetadataForm*) form;
- (instancetype) initWithSaveDisabled;
@end
