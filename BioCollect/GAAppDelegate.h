//
//  GAAppDelegate.h
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AppAuth/AppAuth.h>
#import "GAMasterProjectTableViewController.h"
#import "GARestCall.h"
#import "GASqlLiteDatabase.h"
#import "GALogin.h"
#import "BioProjectService.h"
#import "GAEULAViewController.h"
#import "OzHomeVC.h"
#import "SpeciesService.h"
#import "ALAWKWebView.h"
#import "SpeciesListService.h"
#import "ProjectService.h"
#import "Locale.h"
#import "TrackerService.h"
#import "TracksUpload.h"
#import "UtilService.h"

@interface GAAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) UITabBarController  *tabBarController;
@property (strong, nonatomic) UINavigationController *ozHomeNC;
@property (strong, nonatomic) ALAWKWebView *alaWKWebView;
@property (strong, nonatomic, nullable) id<OIDExternalUserAgentSession> currentAuthorizationFlow;


//All Singleton classes
@property (nonatomic, retain) GARestCall *restCall;
@property (nonatomic, retain) SpeciesService *speciesService;
@property (nonatomic, retain) BioProjectService *bioProjectService;
@property (nonatomic, retain) GASqlLiteDatabase *sqlLite;
@property (nonatomic, retain) SpeciesListService *speciesListService;
@property (nonatomic, retain) ProjectService *projectService;
@property (nonatomic, strong) TrackerService *trackerService;
@property (nonatomic, strong) TracksUpload *tracksUpload;
@property (nonatomic, strong) UtilService *utilService;

@property (nonatomic, retain) GALogin *loginViewController;
@property (nonatomic, retain) GAEULAViewController * eulaVC;
@property (nonatomic, strong, readonly) NSMutableArray *records;
@property (nonatomic, strong, readonly) NSURL *recordArchivePath;
@property (nonatomic, assign) BOOL projectsModified;
@property (nonatomic, retain) Locale *locale;

-(void) updateTableModelsAndViews : (NSMutableArray *) p;
-(void) displaySigninPage;
-(NSString *) uploadChangedActivities :(NSError **)e;
-(void) uploadAndDownload : (BOOL) enablePop;
-(void) goBackToDetailViewController;
-(void) closeDetailModal;
-(void) addRecord:(RecordForm *) record;
-(void) removeRecords:(NSArray *) records;
@end

