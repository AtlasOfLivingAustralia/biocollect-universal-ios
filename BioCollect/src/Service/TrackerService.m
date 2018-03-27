//
//  TrackerService.m
//  Oz Atlas
//
//  Created by Varghese, Temi (PI, Black Mountain) on 22/3/18.
//  Copyright © 2018 Sathya Moorthy, Sathish (CSIRO IM&T, Clayton). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackerService.h"
#import "MetadataForm.h"

#define kTracksStorageLocation @"TRACKS_SAVED"

@implementation TrackerService
- (instancetype) init {
    self = [super init];
    
    self.tracks = [NSMutableArray new];
    NSArray<NSURL *> *urls = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask];
    if([urls count] > 0){
        self.tracksSavedUrl = [urls[0] URLByAppendingPathComponent:kTracksStorageLocation];
    }

    return self;
}

- (NSMutableArray *) loadTracks {
    NSArray<MetadataForm*> *savedTracks = [NSKeyedUnarchiver unarchiveObjectWithFile: self.tracksSavedUrl.path];
    [self.tracks removeAllObjects];
    [self.tracks addObjectsFromArray:savedTracks];
    
    return self.tracks;
}

- (BOOL) saveTracks {
    BOOL archived = [NSKeyedArchiver archiveRootObject: self.tracks toFile: self.tracksSavedUrl.path];
    if (!archived) {
        NSLog(@"Failed to load to species list from local storage.");
    }
    
    return archived;
}

- (BOOL) addTrack: (MetadataForm*) track {
    if (track != nil) {
        NSInteger index = [self.tracks indexOfObject: track];
        if (index == NSNotFound) {
            [self.tracks addObject:track];
        }
        
        return [self saveTracks];
    }
    
    return NO;
}

- (BOOL) removeTrack: (MetadataForm*) track {
    if (track != nil) {
        [self.tracks removeObject: track];
        return [self saveTracks];
    }
    
    return NO;
}
@end
