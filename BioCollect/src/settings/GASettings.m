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
#define kAccessToken @"accessToken"
#define kIDToken @"idToken"
#define kExpiresIn @"expiresIn"
#define kExpiresDateTime @"expiresDateTime"
#define kAccessDateTime @"accessDateTime"
#define kTokenType @"tokenType"
#define kRefreshToken @"refreshToken"
#define kOpenIDConfig @"OIDCDiscovery"
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
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kIDToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kExpiresIn];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kExpiresDateTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessDateTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTokenType];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRefreshToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kOpenIDConfig];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:kEULA];
    [[NSUserDefaults standardUserDefaults]synchronize];    
}

+(NSString*) getEmailAddress{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kEmailAddress];
}

//+(NSString*) getAuthKey{
//    return [[NSUserDefaults standardUserDefaults] objectForKey:kAuthKey];
//}

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

+(NSString*) getAuthorizationHeader {
    return  [[NSString alloc] initWithFormat:@"Bearer %@", [self getAccessToken]];
}

+(NSString*) getAccessToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAccessToken];
}

+(NSString*) getRefreshToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kRefreshToken];
}

+(long) getExpiresIn{
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kExpiresIn];
}

+(NSString*) getAccessDateTime{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAccessDateTime];
}

+(NSString*) getExpiresDateTime{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kExpiresDateTime];
}

+(NSString*) getTokenType{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kTokenType];
}

+(NSString*) getIDToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kIDToken];
}

+(OIDServiceConfiguration*) getOpenIDConfig{
    NSError *e = nil;
    NSDictionary* discoveryDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kOpenIDConfig];
    OIDServiceDiscovery* discovery = [[OIDServiceDiscovery alloc] initWithDictionary:discoveryDict error:&e];
    return [[OIDServiceConfiguration alloc] initWithDiscoveryDocument:discovery];
}

+(NSDictionary*) getUserProfile: (NSString *) accessToken {
    NSError * e;
    NSArray *parts = [accessToken componentsSeparatedByString:@"."];
    NSData *decoded = [[NSData alloc] initWithBase64EncodedString:[[NSString alloc] initWithFormat:@"%@==", parts[1]] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSDictionary* profile =  [NSJSONSerialization JSONObjectWithData:decoded
                                                              options:kNilOptions error:&e];
    
    return profile;
}

+(Boolean) isAccessTokenExpired {
    NSTimeInterval bufferInSeconds = 5.0 * 60.0; // 5 minutes

    NSDate * expires = [self getExpiresDateTime];
    expires = [[NSDate alloc] initWithTimeInterval:bufferInSeconds sinceDate:expires];
    NSDate * now = [NSDate date];
    if ([now compare:expires] == NSOrderedDescending)
        return TRUE;
    else
        return FALSE;
}

+(void) setAccessToken: (NSString *) accessToken{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kAccessToken];
    [[NSUserDefaults standardUserDefaults]synchronize];
};
+(void) setRefreshToken: (NSString *) refreshToken{
    [[NSUserDefaults standardUserDefaults] setObject:refreshToken forKey:kRefreshToken];
    [[NSUserDefaults standardUserDefaults]synchronize];
};
+(void) setTokenType: (NSString *) tokenType{
    [[NSUserDefaults standardUserDefaults] setObject:tokenType forKey:kTokenType];
    [[NSUserDefaults standardUserDefaults]synchronize];

};

+(void) setIDToken: (NSString *) idToken {
    [[NSUserDefaults standardUserDefaults] setObject:idToken forKey:kIDToken];
    [[NSUserDefaults standardUserDefaults]synchronize];
};

+(void) setCredentials: (NSDictionary *) credentials{
    NSString * accessToken = [credentials valueForKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kAccessToken];
    [[NSUserDefaults standardUserDefaults] setObject:[credentials valueForKey:@"id_token"] forKey:kIDToken];
    [[NSUserDefaults standardUserDefaults] setObject:[credentials valueForKey:@"token_type"]  forKey:kTokenType];
    [[NSUserDefaults standardUserDefaults] setObject:[credentials valueForKey:@"refresh_token"]  forKey:kRefreshToken];
    
    NSDictionary * profile = [self getUserProfile: accessToken];
    [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:@"email"]  forKey:kEmailAddress];
    [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:@"userid"]  forKey:kUserId];
    if ([profile objectForKey:@"firstname"] && [profile objectForKey:@"lastname"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:@"firstname"]  forKey:kFirstName];
        [[NSUserDefaults standardUserDefaults] setObject:[profile valueForKey:@"lastname"]  forKey:kLastName];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kFirstName];
        [[NSUserDefaults standardUserDefaults] setObject:@""  forKey:kLastName];
    }
    long expiresIn = [[credentials valueForKey:@"expires_in"] integerValue];
    [self setExpiryDate: expiresIn];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
};

+(void) setExpiryDate:(long) periodInSeconds {
    NSString *periodInString = [[NSString alloc] initWithFormat:@"%ld", periodInSeconds];
    
    NSTimeInterval period = [periodInString doubleValue];
    NSDate* now = [NSDate date];
    NSDate* expiry = [[NSDate alloc] initWithTimeInterval:period sinceDate: now];
    [[NSUserDefaults standardUserDefaults] setObject:now  forKey:kAccessDateTime];
    [[NSUserDefaults standardUserDefaults] setInteger:periodInSeconds  forKey:kExpiresIn];
    [[NSUserDefaults standardUserDefaults] setObject:expiry  forKey:kExpiresDateTime];
};


+(void) setEmailAddress : (NSString *) emailAddress{
    [[NSUserDefaults standardUserDefaults] setObject:emailAddress forKey:kEmailAddress];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

//+(void) setAuthKey: (NSString *) authKey{
//    [[NSUserDefaults standardUserDefaults] setObject:authKey forKey:kAuthKey];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//}

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
    // [configDict setValue:@"" forKey:@""];
    // Create the updated end session request configuration
    NSString *endSessionURL = [serviceConfig.tokenEndpoint.absoluteString stringByReplacingOccurrencesOfString:@"oauth2/token" withString:@"logout"];
    [configDict setValue:endSessionURL forKey:@"end_session_endpoint"];
    
    [[NSUserDefaults standardUserDefaults] setObject:configDict forKey:kOpenIDConfig];
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
