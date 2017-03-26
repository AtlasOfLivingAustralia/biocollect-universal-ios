//
//  ProjectActivity.h
//  BioCollect
//
//  Created by Sathish Babu Sathyamoorthy on 9/03/2016.
//  Copyright © 2016 Sathya Moorthy, Sathish (Atlas of Living Australia). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectActivity : NSObject {
    int _id;
    NSString *projectId;
    NSString *projectActivityId;
    NSString *name;
    NSString *description;
    NSString *published;
}

@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString * projectId;
@property (nonatomic, strong) NSString * projectActivityId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * description;
@property (nonatomic, strong) NSString * published;


@end

