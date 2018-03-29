//
//  TrackerService.h
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 22/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MetadataForm.h"

@interface TrackerService : NSObject
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, strong) NSURL *tracksSavedUrl;

-(BOOL) saveTracks;
-(NSMutableArray*) loadTracks;
-(BOOL) addTrack: (MetadataForm*) track;
-(BOOL) removeTrack: (MetadataForm*) track;
-(BOOL) removeTracks: (MetadataForm*) tracks;
@end
