//
//  TrackViewController.m
//  Tracker
//
//  Created by Varghese, Temi (PI, Black Mountain) on 23/2/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "TrackViewController.h"
#import "MapViewController.h"
#import "TrackMetadataViewController.h"
#import "SightingViewController.h"
#import "GAAppDelegate.h"

@interface TrackViewController ()

@end

@implementation TrackViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        Locale* locale = appDelegate.locale;
        self.title = [locale get: @"trackviewcontroller.title"];
        
        TrackMetadataViewController *meta = [TrackMetadataViewController new];
        meta.tabBarItem.title = [locale get: @"trackmetadataviewcontroller.title"];
        
        SightingViewController *sight = [SightingViewController new];
        sight.tabBarItem.title = [locale get: @"sighting.title"];
        
        UIViewController *map = [MapViewController new];
        map.tabBarItem.title = [locale get: @"map.title"];
        
        [self setViewControllers: @[meta, sight, map]];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
