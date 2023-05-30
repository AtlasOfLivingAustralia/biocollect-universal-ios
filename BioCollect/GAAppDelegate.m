//
//  GAAppDelegate.m
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
#import "RecordForm.h"
#import "SpeciesListService.h"
#import "Locale.h"
#import "TrackerService.h"
#import "ProjectService.h"
#import "UtilService.h"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
static const NSInteger kARRMaxCacheAge = 60 * 60 * 24 * 365 * 2; // 1 day * 365 days * 2 years

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


@synthesize splitViewController, projects,masterProjectVC, detailVC, restCall, sqlLite, loginViewController, eulaVC, homeVC, recordsVC, myProjectsVC, myRecordsVC, bioProjectService,tabBarController,ozHomeNC, speciesService, alaWKWebView, locale, speciesListService, trackerService, projectService, tracksUpload, utilService;

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
    
    _records = [[NSMutableArray alloc] init];

    //Singleton instantiation.
    locale = [[Locale alloc] init];
    restCall = [[GARestCall alloc]init];
    sqlLite = [[GASqlLiteDatabase alloc] init];
    bioProjectService = [[BioProjectService alloc] init];
    speciesService = [[SpeciesService alloc] init];
    speciesListService = [[SpeciesListService alloc] init];
    projectService = [[ProjectService alloc] init];
    trackerService = [[TrackerService alloc] init];
    tracksUpload = [[TracksUpload alloc] init];
    utilService = [[UtilService alloc] init];
    
    //Set up image cache.
    [self setupSDWebImageCache];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [trackerService loadTracks];
    });
    
    [self addSplitViewtoRoot];

    [[MRProgressOverlayView appearance] setTintColor:[UIColor colorWithRed:200.0/255.0 green:77.0/255.0 blue:47.0/255.0 alpha:1]];
    
    NSArray<NSURL *> *urls = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask];
    if([urls count] > 0){
        _recordArchivePath = [urls[0] URLByAppendingPathComponent:@"record"];
    }
    
    [self loadRecords];
    
    // For Tracks app keep the display on.
    if([[GASettings appHubName] isEqualToString:@"trackshub"]) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }

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
    homeNC.tabBarItem.title = @"Home";
    homeNC.tabBarItem.image = [UIImage imageNamed:@"home_filled-25"];
    homeNC.navigationBar.topItem.title = @"Home";
    

    // My projects
    myProjectsVC = [[HomeTableViewController alloc] initWithNibName:@"HomeTableViewController" bundle:nil];
    UINavigationController *myProjectsNC = [[UINavigationController alloc] initWithRootViewController: myProjectsVC];
    myProjectsNC.tabBarItem.title = @"My Projects";
    myProjectsNC.tabBarItem.image = [UIImage imageNamed:@"brief_filled-25"];
    myProjectsNC.navigationBar.topItem.title = @"My Projects";
    
    // Records view
    recordsVC = [[RecordsTableViewController alloc] initWithNibName:@"RecordsTableViewController" bundle:nil];
    UINavigationController *recordsNC = [[UINavigationController alloc] initWithRootViewController: recordsVC];
    recordsNC.tabBarItem.title = @"All Records";
    recordsNC.tabBarItem.image = [UIImage imageNamed:@"box_filled-25"];
    recordsNC.navigationBar.topItem.title = @"All Records";
    
    // My Records
    myRecordsVC = [[RecordsTableViewController alloc] initWithNibNameAndUserActionsAndWithoutPlus:@"RecordsTableViewController" bundle:nil];
    myRecordsVC.myRecords = TRUE;
    UINavigationController *myRecordsNC = [[UINavigationController alloc] initWithRootViewController: myRecordsVC];
    myRecordsNC.tabBarItem.title = @"My Records";
    myRecordsNC.tabBarItem.image = [UIImage imageNamed:@"box_filled-25"];
    myRecordsNC.navigationBar.topItem.title = @"My Records";
    
    
    //ozHome page
    OzHomeVC *ozHomeVC = [[OzHomeVC alloc] initWithMainImage:[UIImage imageNamed:[GASettings appHomeBkBig]]];
    ozHomeNC = [[UINavigationController alloc] initWithRootViewController: ozHomeVC];
    ozHomeNC.tabBarItem.title = @"Home";
    ozHomeNC.tabBarItem.image = [UIImage imageNamed:@"home_filled-25"];
    ozHomeNC.navigationBar.topItem.title = @"Home";
 
    //Tab bars
    NSArray* controllers = nil;
    NSString *appType = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_AppType"];
    if([appType isEqualToString:@"custom"]) {
        [[UINavigationBar appearance] setBackgroundColor:[self colorFromHexString: @"#000000"]];
        [[UINavigationBar appearance] setTranslucent:NO];
        [[UINavigationBar appearance] setTintColor: [self colorFromHexString: @"#F1582B"]];
        [self.window setRootViewController:ozHomeNC];
        [[UITabBar appearance] setTintColor: [self colorFromHexString: @"#F1582B"]];
        [[UIBarButtonItem appearance] setTintColor: [self colorFromHexString: @"#F1582B"]];
        
    } else if([appType isEqualToString:@"hubview"]) {
        [[UINavigationBar appearance] setBackgroundColor:[self colorFromHexString: @"#ffffff"]];
        [[UINavigationBar appearance] setTranslucent:NO];
        [self.window setRootViewController:ozHomeNC];
        [[UITabBar appearance] setTintColor: [self colorFromHexString: [GASettings appTheme]]];
        [[UIBarButtonItem appearance] setTintColor: [self colorFromHexString: [GASettings appTheme]]];
        
    } else {
        // BioCollect View.
        [[UITabBar appearance] setTintColor: [self colorFromHexString: [GASettings appTheme]]];
        [[UIBarButtonItem appearance] setTintColor: [self colorFromHexString: [GASettings appTheme]]];
        [[UINavigationBar appearance] setTranslucent:NO];
        [self.window setRootViewController:ozHomeNC];
    }
    
    
    [self.window makeKeyAndVisible];

    OIDAuthState *authState = [GASettings getAuthState];
    if (authState == nil || ![authState isAuthorized]){
        [self displaySigninPage];
    } else {
        DebugLog(@"[INFO] GAAppDelegate:addSplitViewtoRoot - loading data from db.");
        [authState performActionWithFreshTokens:^(NSString * _Nullable accessToken, NSString * _Nullable idToken, NSError * _Nullable error) {
            if (error) {
                [self displaySigninPage];
            } else {
                [GASettings setAuthState:authState];
                [self updateTableModelsAndViews:[self.sqlLite loadProjectsAndActivities]];
            }
        }];
    }
}

-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
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
    [self.recordsVC resetRecords];
    [GASettings resetAllFields];
    [self.sqlLite deleteAllTables];
    [self.trackerService removeAllTracks];
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ self.window.rootViewController = self.loginViewController; }
                    completion:nil];
}

-(NSString *) uploadChangedActivities : (NSError **) e{
    return @"";
}

-(void) uploadAndDownload : (BOOL) enablePop{
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

# pragma mark - utility functions
- (void)saveRecords{
    BOOL archived = [NSKeyedArchiver archiveRootObject:self.records toFile:self.recordArchivePath.path];

    if (!archived) {
        NSLog(@"Failed to records to file");
    }
}

 - (void) loadRecords{
     NSArray<RecordForm*> *records = [NSKeyedUnarchiver unarchiveObjectWithFile: self.recordArchivePath.path];
     [self.records addObjectsFromArray:records];
}

-(void) addRecord:(RecordForm *) record{
    if(![self.records containsObject: record]){
        [self.records addObject:record];
    }
    
    self.projectsModified = YES;
    [self saveRecords];
}

-(void) removeRecords:(NSArray *) records{
    if(records){
        self.projectsModified = YES;
        [self.records removeObjectsInArray:records];
        [self saveRecords];
    }
}

- (void)setupSDWebImageCache {
     [[SDImageCache sharedImageCache] setMaxCacheAge:kARRMaxCacheAge];
}

@end
