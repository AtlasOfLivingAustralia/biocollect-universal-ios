//
//  GASettings.m
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import "GASettings.h"
#import "GASettingsConstant.h"

#define kEmailAddress @"emailAddress"
#define kSortBy @"sortBy"
#define kDataToSync @"dataToSync"
#define kEULA @"EULA"
#define kFirstName @"firstName"
#define kLastName @"lastName"
#define kUserId @"userId"
#define kOpenIDConfig @"OIDCDiscovery"
#define kAuthState @"authState"
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSortBy];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDataToSync];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kFirstName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kOpenIDConfig];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAuthState];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kEULA];
    [[NSUserDefaults standardUserDefaults]synchronize];    
}

+(NSString*) getEmailAddress{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEmailAddress];
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

+(OIDServiceConfiguration*) getOpenIDConfig{
    NSError *e = nil;
    NSDictionary* discoveryDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kOpenIDConfig];
    OIDServiceDiscovery* discovery = [[OIDServiceDiscovery alloc] initWithDictionary:discoveryDict error:&e];
    return [[OIDServiceConfiguration alloc] initWithDiscoveryDocument:discovery];
}

+(OIDAuthState*) getAuthState {
    NSData *authStateData = [[NSUserDefaults standardUserDefaults] objectForKey:kAuthState];
    NSError *error;
    
    // Check that the encoded data is not nil
    if (authStateData) {

        // Decode the encoded `OIDAuthState` object
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:authStateData error:&error];
        [unarchiver setRequiresSecureCoding:true];
        OIDAuthState *authState = [[OIDAuthState alloc] initWithCoder:unarchiver];

        if (authState) {
            return authState;
        } else {
            NSLog(@"Failed to decode OIDAuthState: %@", error);
        }
    } else {
        NSLog(@"Encoded OIDAuthState not found in NSUserDefaults");
    }
    
    return nil;
}

+(NSDictionary*) getUserProfile: (NSString *) token {
    NSError * e;
    NSString *payload = [token componentsSeparatedByString:@"."][1];
    
    int len = (int)(4 * ceil((float)[payload length] / 4.0));
    int pad = len - [payload length];
    
    // Add Base64 padding
    if (pad > 0) {
        NSString *padding = [[NSString string] stringByPaddingToLength:pad withString:@"=" startingAtIndex:0];
        payload = [payload stringByAppendingString:padding];
    }
    
    NSData *decoded = [[NSData alloc] initWithBase64EncodedString:payload options:0];
    NSDictionary* profile =  [NSJSONSerialization JSONObjectWithData:decoded
                                                              options:kNilOptions error:&e];
    
    return profile;
}

+(void) setEmailAddress : (NSString *) emailAddress{
    [[NSUserDefaults standardUserDefaults] setObject:emailAddress forKey:kEmailAddress];
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

+(void) setOpenIDConfig:(OIDServiceConfiguration *)serviceConfig{
    NSMutableDictionary* configDict = [[serviceConfig.discoveryDocument discoveryDictionary] mutableCopy];
    if (COGNITO_ENABLED) {
        NSString *endSessionURL = [serviceConfig.tokenEndpoint.absoluteString stringByReplacingOccurrencesOfString:@"oauth2/token" withString:@"logout"];
        [configDict setValue:endSessionURL forKey:@"end_session_endpoint"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:configDict forKey:kOpenIDConfig];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(void) setAuthState:(OIDAuthState *)authState {
    // Encode the authState data
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:true];
    [authState encodeWithCoder:archiver];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:[archiver encodedData] forKey:kAuthState];
    
    NSDictionary * profile = [self getUserProfile: COGNITO_ENABLED ? authState.lastTokenResponse.idToken : authState.lastTokenResponse.accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:@"email"]  forKey:kEmailAddress];
    [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:COGNITO_ENABLED ? @"custom:userid" : @"userid"]  forKey:kUserId];
    [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:@"given_name"]  forKey:kFirstName];
    [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:@"family_name"]  forKey:kLastName];
    
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+(NSString*) appVersion {
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
