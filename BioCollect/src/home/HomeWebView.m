//
//  HomeWebView.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 9/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeWebView.h"

@implementation HomeWebView
@synthesize project, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    self.webView.delegate = self;
    [self.activityIndicator startAnimating];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            NSString *loadingError = [[NSString alloc] initWithFormat:@"%@", error];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:loadingError
                                                           delegate:self
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];

        });
    });

}

- (void)viewDidLayoutSubviews {
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
        });
    });

}

@end
