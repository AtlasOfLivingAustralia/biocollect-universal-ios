//
//  GAFormJSInterface.m
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 15/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import "GAFormJSInterface.h"
#import "GAAppDelegate.h"
#import "MRProgressOverlayView.h"
#import "GASite.h"
#import "GACreateSiteModalViewController.h"
#import "GAActivitiesJSON.h"
#import "GASettings.h"

@implementation GAFormJSInterface
@synthesize activity, project;

//Feed activity JSON to the java script form
- (NSString*) loadActivity {
    DebugLog(@"[INFO] GAFormJSInterface:loadActivity - Feeding the activityJSON to javascript");
    return activity.activityJSON;
}

-(NSString *) supportsNewSite{
    return false;
}

-(NSString*) loadSites {

    DebugLog(@"[INFO] GAFormJSInterface:loadSites - Passing site JSON to javascript.");
    NSMutableArray *siteArray = [[NSMutableArray alloc]init];
    
    for(GASite *site in self.project.sites) {
        NSMutableDictionary *siteDic = [[NSMutableDictionary alloc] init];
        [siteDic setObject:[site.name length] > 0 ? site.name: @"" forKey:@"name"];
        [siteDic setObject:[site.siteId length] > 0 ? site.siteId: @"" forKey:@"siteId"];
        [siteDic setObject:[site.description length] > 0 ? site.description: @"" forKey:@"description"];
        NSString *temp = [site.latitude length] > 0 ? site.latitude: @"";
        [siteDic setObject:temp forKey:@"centroidLat"];
        [siteDic setObject:[site.longitude length] > 0 ? site.longitude: @"" forKey:@"centroidLon"];
        [siteArray addObject:siteDic];
    }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:siteArray
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

-(NSString*) loadThemes {
    if(activity.themes == nil)
        return @"[]";
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:activity.themes
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

- (void) createNewSite{

}

// Call back to the form content changes made by the user,
- (void) onSaveActivity : (NSString *) status : (NSString *) savedJSON {

    // status = -1 if the page was not modified, 0 if validation failed, 1 if validation succeeded (or was not requested).
    if([status length] > 0 && [status isEqualToString:@"0"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                        message:@"Please enter all the required fields."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
    if([status length] > 0 && [status isEqualToString:@"-1"]){
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate goBackToDetailViewController];
    }
    else if(savedJSON != nil && [status length] > 0 && ![savedJSON isEqualToString:@"null"] && ![savedJSON isEqualToString:@"NULL"] &&
            [status isEqualToString:@"1"]) {
        DebugLog(@"[INFO] GAFormJSInterface:loadSites - Received Activity JSON value from Javascript");
        activity.activityJSON = savedJSON;
        GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
        activity.status = ACTIVITY_CHANGED;
        [GASettings setDataToSync:kDataToSyncTrue];
        
        NSError *error;
        NSDictionary *parsedValues = [NSJSONSerialization JSONObjectWithData:[activity.activityJSON dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        NSString *siteId = [parsedValues objectForKey:@"siteId"];
        if ([siteId length] > 0)
            activity.siteId = siteId;
        else
            activity.siteId = @"";
        
        [appDelegate.sqlLite insertOrUpdateActivity:activity : activity.projectId];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:@"Successfully saved the changes.\nWould you like to sync the changes?"
                                                       delegate:self
                                              cancelButtonTitle:@"Sync later"
                                              otherButtonTitles:@"Sync now",nil];
        [alert show];
        
    }
    
}

#pragma mark UIAlertDelegate.
- (void)alertView:(UIAlertView *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    GAAppDelegate *appDelegate = (GAAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(buttonIndex == 0) {
        //Refresh the app with the new data.
        NSMutableArray *p = [appDelegate.sqlLite loadProjectsAndActivities];
        [appDelegate updateTableModelsAndViews:p];
        [appDelegate goBackToDetailViewController];
    }else {
        [appDelegate uploadAndDownload:true];
    }
}

@end
