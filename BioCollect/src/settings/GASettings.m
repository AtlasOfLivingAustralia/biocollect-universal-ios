//
//  GASettings.m
//  GreenArmy
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


@end
