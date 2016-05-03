//
//  HomeWebView.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 9/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAAppDelegate.h"
#import <UIKit/UIWebView.h>

@interface HomeWebView :  UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) GAProject * project;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

