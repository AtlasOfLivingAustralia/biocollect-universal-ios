//
//  GAProject.h
//  GreenArmy
//
//  Created by Sathya Moorthy, Sathish (Atlas of Living Australia) on 9/04/2014.
//  Copyright (c) 2014 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAProject : NSObject {
    int _id;
    NSString *projectId;
    NSString *projectName;
    NSString *lastUpdated;
    NSString *description;
    NSString *urlImage;
    NSString *urlWeb;
    int isExternal;
    NSMutableArray *projectActivities;
    NSMutableArray *activities;
    NSMutableArray *sites;    
}

@property (nonatomic, assign) int _id;
@property (nonatomic, assign) int isExternal;
@property (nonatomic, strong) NSString * projectId;
@property (nonatomic, strong) NSString * projectName;
@property (nonatomic, strong) NSString * lastUpdated;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * urlImage;
@property (nonatomic, strong) NSString * urlWeb;
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) NSMutableArray *projectActivities;
@property (nonatomic, strong) NSMutableArray *sites;

@end
