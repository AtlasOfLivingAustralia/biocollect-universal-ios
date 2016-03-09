//
//  HomeWebView.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 9/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeWebView.h"

@implementation HomeWebView
@synthesize project;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    self.webView.delegate = self;
    NSString *urlWithParameter = [NSString stringWithFormat: @"%@", self.project.urlWeb];
    
    //Do some parsing and determine whether barCodeData is straight url.
    NSURL *url = [NSURL URLWithString: urlWithParameter];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setScalesPageToFit:YES];
    [self.webView  loadRequest: request];
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    DebugLog(@"[ERROR] HomeWebView:didFailLoadWithError Error loading %@", error);
}

- (void)viewDidLayoutSubviews {
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

@end
