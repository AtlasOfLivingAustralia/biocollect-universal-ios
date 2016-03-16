//
//  GAFormJSInterface.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 15/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyJSDataFunction.h"
#import "GAActivity.h"
#import "GAProject.h"

@interface GAFormJSInterface : NSObject <UIAlertViewDelegate>

@property (strong, nonatomic) GAActivity *activity;
@property (strong, nonatomic) GAProject *project;

- (NSString *) loadActivity;
- (void) createNewSite;
- (void) onSaveActivity : (NSString *) status : (NSString *) savedJSON;
@end
