//
//  GAAppDelegate.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "GAAppDelegate.h"
#import "GALogin.h"
#import "GADetailActivitiesTableViewController.h"
#import "GASettingsConstant.h"
#import "MRProgress.h"
#import "MRProgressOverlayView.h"
#import "GASettings.h"
#import "GAHelpVC.h"
#import "HomeTableViewController.h"
#import "MRProgressOverlayView.h"
#import "ContactVC.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@interface GAAppDelegate ()
@property (strong, nonatomic) GAMasterProjectTableViewController *masterProjectVC;
@property (strong, nonatomic) HomeTableViewController *homeVC;
@property (strong, nonatomic) RecordsTableViewController *recordsVC;
@property (strong, nonatomic) HomeTableViewController *myProjectsVC;
@property (strong, nonatomic) RecordsTableViewController *myRecordsVC;

@property (strong, nonatomic) GADetailActivitiesTableViewController *detailVC;
@property (nonatomic, retain) GAActivity *updatedActivity;

@property (nonatomic, retain) NSMutableArray *projects;

@end
@implementation GAAppDelegate

@synthesize splitViewController, projects,masterProjectVC, detailVC, restCall, sqlLite, loginViewController, eulaVC, homeVC, recordsVC, myProjectsVC, myRecordsVC, bioProjectService,tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ( IDIOM == IPAD ) {
        self.eulaVC = [[GAEULAViewController alloc] initWithNibName:@"GAEULAViewController" bundle:nil];
        self.loginViewController = [[GALogin alloc] initWithNibName:@"GALogin" bundle:nil];
    } else {
        self.eulaVC = [[GAEULAViewController alloc] initWithNibName:@"EULAiPhoneViewController" bundle:nil];
        self.loginViewController = [[GALogin alloc] initWithNibName:@"LoginiPhoneView" bundle:nil];
    }

    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    self.projects = [[NSMutableArray alloc] init];

    //Singleton instantiation.
    restCall = [[GARestCall alloc]init];
    sqlLite = [[GASqlLiteDatabase alloc] init];
    bioProjectService = [[BioProjectService alloc] init];
    
    [self addSplitViewtoRoot];
    
    [[UITabBar appearance] setTintColor: [UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:47.0/255.0 alpha:1]];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:47.0/255.0 alpha:1]];

    [[MRProgressOverlayView appearance] setTintColor:[UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:47.0/255.0 alpha:1]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) addSplitViewtoRoot {
    // BioCollect Home page
    homeVC = [[HomeTableViewController alloc] initWithNibName:@"HomeTableViewController" bundle:nil];
    UINavigationController *homeNC = [[UINavigationController alloc] initWithRootViewController: homeVC];
    homeNC.tabBarItem.title = @"BioCollect";
    homeNC.tabBarItem.image = [UIImage imageNamed:@"home_filled-25"];
    homeNC.navigationBar.topItem.title = @"BioCollect";

    // Records view
    recordsVC = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
    UINavigationController *recordsNC = [[UINavigationController alloc] initWithRootViewController: recordsVC];
    recordsNC.tabBarItem.title = @"All Records";
    recordsNC.tabBarItem.image = [UIImage imageNamed:@"box_filled-25"];
    recordsNC.navigationBar.topItem.title = @"All Records";
    
    // My projects
    myProjectsVC = [[HomeTableViewController alloc] initWithNibNameForMyProjects:@"HomeTableViewController" bundle:nil];
    UINavigationController *myProjectsNC = [[UINavigationController alloc] initWithRootViewController: myProjectsVC];
    myProjectsNC.tabBarItem.title = @"My Projects";
    myProjectsNC.tabBarItem.image = [UIImage imageNamed:@"brief_filled-25"];
    myProjectsNC.navigationBar.topItem.title = @"My Projects";

    // My Records
    myRecordsVC = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
    myRecordsVC.myRecords = TRUE;
    UINavigationController *myRecordsNC = [[UINavigationController alloc] initWithRootViewController: myRecordsVC];
    myRecordsNC.tabBarItem.title = @"My Records";
    myRecordsNC.tabBarItem.image = [UIImage imageNamed:@"box_filled-25"];
    myRecordsNC.navigationBar.topItem.title = @"My Records";
    
    
    //Help
    ContactVC  *contactVC = nil;

    //About
    UIViewController *aboutVC = nil;
    if ( IDIOM == IPAD ){
        contactVC = [[ContactVC alloc] initWithNibName:@"ContactVC" bundle:nil];
        aboutVC = [[UIViewController alloc] initWithNibName:@"GAAboutVC" bundle:nil];
    } else {
        contactVC = [[ContactVC alloc] initWithNibName:@"ContactiPhoneVC" bundle:nil];
        aboutVC = [[UIViewController alloc] initWithNibName:@"AboutiPhoneView" bundle:nil];
    }
    
    UINavigationController *contactNC =  [[UINavigationController alloc] initWithRootViewController:contactVC];
    contactNC.tabBarItem.image = [UIImage imageNamed:@"contact_filled-25"];
    contactNC.tabBarItem.title = @"Contact";
    contactNC.navigationBar.topItem.title = @"Contact";
    
    UINavigationController *aboutNC =  [[UINavigationController alloc] initWithRootViewController:aboutVC];
    aboutNC.tabBarItem.title = @"About";
    aboutNC.tabBarItem.image = [UIImage imageNamed:@"about_filled-25"];
    aboutNC.navigationBar.topItem.title = @"About";
    
    //Tab bars
    tabBarController = [[UITabBarController alloc] init];
    NSArray* controllers = [NSArray arrayWithObjects:homeNC, recordsNC, myProjectsNC, myRecordsNC, aboutNC,contactNC, nil];
    tabBarController.viewControllers = controllers;

    [self.window setRootViewController:tabBarController];
    [self.window makeKeyAndVisible];
    
    /*
    if([[GASettings getEULA] length] == 0 && ![[GASettings getEULA]isEqualToString:kEULAAgreed]){
        [self.window.rootViewController presentViewController:eulaVC animated:NO completion:nil];
    }
    else
    */
    
    if([GASettings getAuthKey] == 0){
        [self displaySigninPage];
        
    }else{
        DebugLog(@"[INFO] GAAppDelegate:addSplitViewtoRoot - loading data from db.");
        [self updateTableModelsAndViews:[self.sqlLite loadProjectsAndActivities]];
    }
}


#pragma mark - GARestCall delegate
-(void) updateTableModelsAndViews : (NSMutableArray *) p{
    [self.projects removeAllObjects];
    [self.projects addObjectsFromArray: p];
    [self.masterProjectVC updateProjectTableModel : self.projects];
    [self.detailVC updateActivityTableModel : self.projects];
}

-(void) displaySigninPage {
    [GASettings resetAllFields];
    [self.homeVC resetProjects];
    [self.sqlLite deleteAllTables];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ self.window.rootViewController = self.loginViewController; }
                    completion:nil];
}

-(NSString *) uploadChangedActivities : (NSError **) e{
    int success = 0;
    int failure = 0;

    // Make sure site details are up to date.
    for(GAProject *pro in self.projects) {
        for(GASite *site in pro.sites){
            if([site.permSiteId length] == 0 || site.permSiteId == nil) {
                NSString *newSiteId = [self.restCall uploadSite :site: &*e];
                DebugLog(@"[INFO] GAAppDelegate:uploadChangedActivities Server returned site id %@",newSiteId);
                if([newSiteId length] >0 && *e == nil){
                    site.permSiteId = newSiteId;
                    [self.sqlLite updateProjectSites:site];
                    [self.sqlLite updateSite:site];
                } else{
                    DebugLog(@"[ERROR] GAAppDelegate:uploadChangedActivities Site creation failed.");
                }
                
            }
        }
    }
     
    for(GAProject *pro in self.projects) {
        for(GAActivity *act in pro.activities){
            if(act.status == ACTIVITY_CHANGED) {
                //permSiteId provided by server, make sure we update the activity with the server perm site id.
                if(act.site != nil && act.site.siteId != nil && act.site.permSiteId != nil && ![act.site.permSiteId isEqualToString:act.site.siteId]){
                    DebugLog(@"[INFO] GAAppDelegate:uploadChangedActivities - Replacing temp site id with server provided site id.");
                    act.activityJSON = [act.activityJSON stringByReplacingOccurrencesOfString:act.site.siteId withString:act.site.permSiteId];
                }
                [self.restCall updateActivity:act :&*e];
                if(*e == nil) {
                    success++;
                }else{
                    failure++;
                }
            }
        }
    }
    
    NSString *message = nil;
    if((success+failure) == 0){
        message = @"Successfully synced activities and sites";
        DebugLog(@"[INFO] GAAppDelegate:uploadChangedActivities No changes to upload");
    }
    
    else if (success > 0){
        message = [[NSString alloc] initWithFormat: @"Successfully synced activities and sites."];
        DebugLog(@"[SUCCESS] GAAppDelegate:uploadChangedActivities Sync successfull");
    }
    
    else if (failure > 0){
        message = [[NSString alloc] initWithFormat: @"Failed to sync"];
        DebugLog(@"[ERROR] GAAppDelegate:uploadChangedActivities Faile to sync");
    }
return message;
}

-(void) uploadAndDownload : (BOOL) enablePop{
    [MRProgressOverlayView showOverlayAddedTo:self.window title:@"Syncing.." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *uploadError = nil;
        NSError *downloadError = nil;
        
        // Projects to restore in case of failed uploa or download.
        NSMutableArray *p = [self.sqlLite loadProjectsAndActivities];
        [self updateTableModelsAndViews:p];
        
        NSString *uploadMessage = [self uploadChangedActivities : &uploadError];
        if([[uploadError localizedDescription] length] > 0)
            DebugLog(@"[ERROR] GAAppDelegate:uploadAndDownload Upload Error Message %@",[uploadError localizedDescription]);
        
        NSMutableArray *downloadPro = nil;
        if(uploadError == nil) {
            downloadPro = [self.restCall downloadProjects:&downloadError];
            if(downloadError == nil){
                [self.sqlLite storeProjects:downloadPro];
                [GASettings setDataToSync:kDataToSyncFalse];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MRProgressOverlayView dismissOverlayForView:self.window animated:NO];

            if(downloadError == nil && uploadError == nil) {
                [self updateTableModelsAndViews:downloadPro];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync successful"
                                                                message:uploadMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if (downloadError != nil){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync unsuccessful"
                                                                message:[downloadError localizedDescription]
                                                               delegate:self
                                                      cancelButtonTitle:@"Try again later"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else if (uploadError != nil){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync unsuccessful"
                                                                message:[uploadError localizedDescription]
                                                               delegate:self
                                                      cancelButtonTitle:@"Try again later"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
           if(enablePop)
               [self goBackToDetailViewController];
        });
    });

}

-(void) goBackToDetailViewController{
    [self.detailVC.navigationController popViewControllerAnimated:YES];
}

-(NSString *) GetUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

-(void) closeDetailModal {
   [self.detailVC.formWebView webViewDidFinishLoad];
}
@end
