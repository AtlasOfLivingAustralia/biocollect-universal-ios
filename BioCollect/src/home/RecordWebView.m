//
//  HomeWebView.m
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 9/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RecordWebVIew.h"
#import "GAAppDelegate.h"
#import "GASettings.h"
#import "GASettingsConstant.h"
@interface RecordWebView ()
    @property (nonatomic, strong) GAAppDelegate *appDelegate;
@end


@implementation RecordWebView
@synthesize activity,activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self.appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    self.webView.delegate = self;
    [self.activityIndicator startAnimating];
    NSString *urlWithParameter = [NSString stringWithFormat: @"%@", self.activity.url];
    [self.webView setScalesPageToFit:YES];
    [self.webView  loadRequest: [self loadRequest: urlWithParameter]];
}

-(NSMutableURLRequest *) loadRequest: (NSString*) url {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[self.appDelegate.restCall getAuthorizationHeader] forHTTPHeaderField:@"Authorization"];
    [request setTimeoutInterval: DEFAULT_TIMEOUT];
    return request;
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
