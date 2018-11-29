//
//  GASettings.m
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "GASettings.h"

#define kEmailAddress @"emailAddress"
#define kAuthKey @"authKey"
#define kSortBy @"sortBy"
#define kDataToSync @"dataToSync"
#define kEULA @"EULA"
#define kFirstName @"firstName"
#define kLastName @"lastName"
#define kUserId @"userId"
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

@implementation GASettings

-(id) init{
    self = [super init];
    if(self){
    }
    return self;
}

+(void) resetAllFields{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEmailAddress];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAuthKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSortBy];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDataToSync];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserId];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kEULA];
    [[NSUserDefaults standardUserDefaults]synchronize];    
}

+(NSString*) getEmailAddress{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEmailAddress];
}

+(NSString*) getAuthKey{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAuthKey];
}

+(NSString*) getSortBy{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSortBy];
}
+(NSString*) getEULA{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEULA];
}

+(NSString*) getDataToSync{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kDataToSync];
}

+(NSString*) getFirstName{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kFirstName];
}

+(NSString*) getLastName{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLastName];
}

+(NSString*) getUserId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
}


+(NSString*) getFullName{
    NSString *firstName =[[NSUserDefaults standardUserDefaults] objectForKey: kFirstName]?:@"";
    NSString *lastName =[[NSUserDefaults standardUserDefaults] objectForKey: kLastName]?:@"";
    
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

+(void) setEmailAddress : (NSString *) emailAddress{
    [[NSUserDefaults standardUserDefaults] setObject:emailAddress forKey:kEmailAddress];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setAuthKey: (NSString *) authKey{
    [[NSUserDefaults standardUserDefaults] setObject:authKey forKey:kAuthKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setSortBy: (NSString *) sortBy{
    [[NSUserDefaults standardUserDefaults] setObject:sortBy forKey:kSortBy];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setDataToSync: (NSString *) dataToSync{
    [[NSUserDefaults standardUserDefaults] setObject:dataToSync forKey:kDataToSync];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setEULA: (NSString *) EULA{
    [[NSUserDefaults standardUserDefaults] setObject:EULA forKey:kEULA];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setFirstName:(NSString *)firstName{
    [[NSUserDefaults standardUserDefaults] setObject:firstName forKey:kFirstName];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setLastName:(NSString *)lastName{
    [[NSUserDefaults standardUserDefaults] setObject:lastName forKey:kLastName];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setUserId:(NSString *)userId{
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:kUserId];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(NSString*) appVersion{
    NSString * ver = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    return [[NSString alloc] initWithFormat:@"%@ (%@)",ver,build];
}

+(NSString*) appView {
   return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_AppType"];
}

+(NSString*) appTheme {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Theme"];
}

+(NSString*) appHomeBkBig {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Home_BK_Big"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"OzHome2";
    }
    return value;
}

+(NSString*) appHomeBkSmall {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Home_BK_Small"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"ala_logo_3";
    }
    
    return value;
}

+(NSString*) appLoginImage {
    NSString *imageName = nil;
    NSString *value = nil;
    if ( IDIOM == IPAD ) {
        value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Home_Login_Image_iPad"];
    } else {
        value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Home_Login_Image_iPhone"];
    }
    return value;
}

+(NSString*) appLoginLogo {
    NSString *imageName = nil;
    NSString *value = nil;
    value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Home_Login_Image_Logo"];
    
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"biocontrol_logo.png";
    }
    return value;
}

+(NSString*) appHubName {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_HubName"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"";
    }
    return value;
}



+(NSString*) appProjectID {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Project_ID"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"";
    }
    return value;
}
+(NSString*) appProjectActivityID {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Project_Activity_ID"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"";
    }
    return value;
}
+(NSString*) appProjectName {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Project_Name"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"";
    }
    return value;
}

+(NSString*) appAboutUrl {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_About_Url"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"";
    }
    return value;
}

+(NSString*) appContactUrl{
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_Contact_Url"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"";
    }
    return value;
}

+(NSString*) appLoadSpeciesListUrl {
    NSString *value = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"Bio_List_Url"];
    if (value == (id)[NSNull null] || value.length == 0 ) {
        value = @"";
    }
    return value;
}

@end
