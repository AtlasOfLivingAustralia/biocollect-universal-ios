//
//  GAProject.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (CSIRO IM&T, Clayton) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAProject : NSObject {
    int _id;
    NSString *projectId;
    NSString *projectName;
    NSString *lastUpdated;
    NSString *description;
    NSMutableArray *activities;
    NSMutableArray *sites;    
}

@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString * projectId;
@property (nonatomic, strong) NSString * projectName;
@property (nonatomic, strong) NSString * lastUpdated;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) NSMutableArray *sites;

@end
