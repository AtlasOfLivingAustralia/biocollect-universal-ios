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
#import "OzHomeVC.h"

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
@property (nonatomic, strong, readonly) NSMutableArray *records;
@property (nonatomic, strong, readonly) NSURL *recordArchivePath;
@property (nonatomic, assign) BOOL projectsModified;

-(void) updateTableModelsAndViews : (NSMutableArray *) p;
-(void) displaySigninPage;
-(NSString *) uploadChangedActivities :(NSError **)e;
-(void) uploadAndDownload : (BOOL) enablePop;
-(void) goBackToDetailViewController;
-(void) closeDetailModal;
-(void) addRecord:(RecordForm *) record;
-(void) removeRecords:(NSArray *) records;
@end

