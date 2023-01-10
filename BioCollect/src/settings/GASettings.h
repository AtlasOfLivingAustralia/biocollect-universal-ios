//
//  GASettings.h
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppAuth/AppAuth.h>

#define kDataToSyncFalse @"FALSE"
#define kDataToSyncTrue @"TRUE"
#define kEULAAgreed @"TRUE"

@interface GASettings : NSObject
+(void) setDataToSync: (NSString *) dataToSync;
+(void) setSortBy: (NSString *) sortBy;
//+(void) setAuthKey: (NSString *) authKey;
+(void) setEmailAddress : (NSString *) emailAddress;
+(void) setEULA : (NSString *) EULA;
+(void) setFirstName : (NSString *) firstName;
+(void) setLastName : (NSString *) secondName;
+(void) setUserId : (NSString *) userId;
+(void) setOpenIDConfig: (OIDServiceConfiguration *_Nullable) serviceConfig;
+(void) setAuthState: (OIDAuthState *_Nonnull) authState;
+(void) resetAllFields;
//+(NSString*) getAuthKey;
+(NSString *) getEmailAddress;
+(NSString *) getSortBy;
+(NSString *) getDataToSync;
+(NSString *) getEULA;
+(NSString *) getLastName;
+(NSString *) getFirstName;
+(NSString *) getFullName;
+(NSString *) getUserId;
+(OIDServiceConfiguration *_Nullable) getOpenIDConfig;
+(OIDAuthState *_Nullable) getAuthState;
+(NSString *) appVersion;
+(NSString *) appView;
+(NSString *) appTheme;
+(NSString *) appHomeBkBig;
+(NSString *) appHomeBkSmall;
+(NSString *) appLoginImage;
+(NSString *) appHubName;
+(NSString *) appLoginLogo;
+(NSString *) appProjectID;
+(NSString *) appProjectActivityID;
+(NSString *) appProjectName;
+(NSString *) appAboutUrl;
+(NSString*) appContactUrl;
+(NSString*) appLoadSpeciesListUrl;

@end
