//
//  GADetailFormVIewController.h
//  GreenArmy
//
//  Created by Sathish Babu Sathyamoorthy on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EasyJSWebView.h"
#import "GAActivity.h"
#import "GAFormJSInterface.h"

@interface GADetailFormVIewController : UIViewController

@property (strong, nonatomic) IBOutlet EasyJSWebView *easyWebView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIBarButtonItem *siteButton;
@property (strong, nonatomic) GAActivity *activity;
@property (strong, nonatomic) GAProject *project;
@property (strong, nonatomic) GAFormJSInterface *formJS;
- (void)webViewDidFinishLoad;
@end
