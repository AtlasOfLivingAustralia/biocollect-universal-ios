//
//  GADetailFormVIewController.m
//  GreenArmy
//
//  Created by Sathish Babu Sathyamoorthy on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GADetailFormVIewController.h"
#import "GAAppDelegate.h"
#import "GACreateSiteModalViewController.h"
#import "MRProgressOverlayView.h"

@interface GADetailFormVIewController ()

@end

@implementation GADetailFormVIewController

#define JS_FORM_INTERFACE @"mobileBindings"
#define JS_FORM_INITATE_SAVE @"master.save()"
#define kDETAIL_HTML_EXTENSION @"html"
#define kDETAIL_DIRECTORY @"StaticWebPages"

#define kDetailMapOpeningAlert 0

@synthesize activity, project, formJS, activityIndicator,siteButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Done" style:UIBarButtonItemStylePlain
                                         target:self action:@selector(onClickDone)];
        siteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"geo_fence-25"]
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self action:@selector(launchAppleMap)];
        NSArray *buttons = [[NSArray alloc] initWithObjects:doneButton, siteButton, nil];
        self.navigationItem.rightBarButtonItems = buttons;
    }
    return self;
}
-(void) launchAppleMap {
    
    if(activity.site == nil){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                        message:@"Select and save a valid site."
                                                       delegate:self
                                              cancelButtonTitle:@"Try again later"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    

    NSString *message = [[NSString alloc] initWithFormat:@"Open \"%@\" site wth \"Apple Maps\"?",activity.site.name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES",nil];
    alert.tag = kDetailMapOpeningAlert;
    [alert show];
        
    
}

- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == kDetailMapOpeningAlert && buttonIndex == 1)
    {
        NSString *str = [[NSString alloc] initWithFormat:
                         @"http://maps.apple.com/maps?z=100&q=%f,%f",
                         [activity.site.latitude doubleValue],
                         [activity.site.longitude doubleValue]];
        NSURL *URL = [NSURL URLWithString:str];
        [[UIApplication sharedApplication] openURL:URL];
    }
}

-(void) onClickDone{
    // Execute Java script save call.
    [self.view endEditing:YES];

    // -1 if the page was not modified, 0 if validation failed, 1 if validation succeeded (or was not requested).
    [self.easyWebView stringByEvaluatingJavaScriptFromString:JS_FORM_INITATE_SAVE];

   
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [activityIndicator startAnimating];
    DebugLog(@"[INFO] GADetailFormVIewController:viewDidLoad - Stopping user inputs");
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self loadHtmlFile];
}

-(void) loadHtmlFile{
    NSString *fileName = [self.activity.activityName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *file  = [[NSBundle mainBundle]
                       pathForResource:fileName
                       ofType:kDETAIL_HTML_EXTENSION
                       inDirectory:kDETAIL_DIRECTORY
                       forLocalization:kDETAIL_DIRECTORY];
    
    if([file length] > 0){
        NSURL *url = [NSURL fileURLWithPath:file];
        self.formJS = [GAFormJSInterface new];
        formJS.activity = self.activity;
        formJS.project = self.project;
        [self.easyWebView  addJavascriptInterfaces:formJS WithName: JS_FORM_INTERFACE];
        [self.easyWebView setScalesPageToFit:YES];
        [self.easyWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    else{
        NSString *file  = [[NSBundle mainBundle]
                           pathForResource:@"error"
                           ofType:kDETAIL_HTML_EXTENSION
                           inDirectory:kDETAIL_DIRECTORY
                           forLocalization:kDETAIL_DIRECTORY];
        if([file length] > 0){
            NSURL *url = [NSURL fileURLWithPath:file];
            self.formJS = [GAFormJSInterface new];
            [self.easyWebView setScalesPageToFit:YES];
            [self.easyWebView loadRequest:[NSURLRequest requestWithURL:url]];
        }
    }
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(void) viewDidDisappear:(BOOL)animated{
    [self.easyWebView addJavascriptInterfaces:nil WithName: @""];
}

- (void)webViewDidFinishLoad{
    [self performSelectorOnMainThread:@selector(closeModal:) withObject:nil waitUntilDone:YES];
}
-(void) closeModal : (id) object{
    [activityIndicator stopAnimating];
   [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    DebugLog(@"[INFO] GADetailFormVIewController:closeModal - Enabling user inputs");    
}


@end
