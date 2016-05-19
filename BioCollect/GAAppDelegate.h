//
//  GAAppDelegate.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAMasterProjectTableViewController.h"
#import "GARestCall.h"
#import "GASqlLiteDatabase.h"
#import "GALogin.h"
#import "BioProjectService.h"
#import "GAEULAViewController.h"

@interface GAAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) UITabBarController  *tabBarController;


//All Singleton classes
@property (nonatomic, retain) GARestCall *restCall;
@property (nonatomic, retain) BioProjectService *bioProjectService;
@property (nonatomic, retain) GASqlLiteDatabase *sqlLite;
@property (nonatomic, retain) GALogin *loginViewController;
@property (nonatomic, retain) GAEULAViewController * eulaVC;

-(void) updateTableModelsAndViews : (NSMutableArray *) p;
-(void) displaySigninPage;
-(NSString *) uploadChangedActivities :(NSError **)e;
-(void) uploadAndDownload : (BOOL) enablePop;
-(void) goBackToDetailViewController;
-(void) closeDetailModal;
@end

