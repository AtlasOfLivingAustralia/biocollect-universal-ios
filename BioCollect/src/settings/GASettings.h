//
//  GASettings.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 11/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDataToSyncFalse @"FALSE"
#define kDataToSyncTrue @"TRUE"
#define kEULAAgreed @"TRUE"

@interface GASettings : NSObject
+(void) setDataToSync: (NSString *) dataToSync;
+(void) setSortBy: (NSString *) sortBy;
+(void) setAuthKey: (NSString *) authKey;
+(void) setEmailAddress : (NSString *) emailAddress;
+(void) setEULA : (NSString *) EULA;
+(void) setFirstName : (NSString *) firstName;
+(void) setLastName : (NSString *) secondName;
+(void) setUserId : (NSString *) userId;
+(void) resetAllFields;
+(NSString*) getAuthKey;
+(NSString*) getEmailAddress;
+(NSString*) getSortBy;
+(NSString*) getDataToSync;
+(NSString*) getEULA;
+(NSString*) getLastName;
+(NSString*) getFirstName;
+(NSString*) getFullName;
+(NSString*) getUserId;
@end
