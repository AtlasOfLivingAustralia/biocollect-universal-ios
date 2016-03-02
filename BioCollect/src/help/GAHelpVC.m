//
//  GAHelpVC.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 4/07/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GAHelpVC.h"

@interface GAHelpVC ()

@end

@implementation GAHelpVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *fileName = @"index";
    NSString *file  = [[NSBundle mainBundle]
                       pathForResource:fileName
                       ofType:@"html"
                       inDirectory:@""
                       forLocalization:@""];
    NSURL *url = [NSURL fileURLWithPath:file];
    [self.helpWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
