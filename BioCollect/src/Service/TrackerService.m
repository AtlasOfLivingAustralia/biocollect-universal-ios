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
#import "GAAppDelegate.h"
#define kTracksStorageLocation @"TRACKS_SAVED"

@implementation TrackerService
- (instancetype) init {
    self = [super init];
    
    self.tracks = [NSMutableArray new];
    NSArray<NSURL *> *urls = [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains: NSUserDomainMask];
    if([urls count] > 0){
        self.tracksSavedUrl = [urls[0] URLByAppendingPathComponent:kTracksStorageLocation];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrganisationOfAllTracks:) name:@"PROJECT-UPDATED" object:nil];
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
        NSLog(@"Failed to save to species list from local storage.");
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
        [track deleteImages];
        
        [self.tracks removeObject: track];
        return [self saveTracks];
    }
    
    return NO;
}

- (BOOL) removeTracks: (NSArray<MetadataForm*>*) tracks {
    if (tracks != nil) {
        for( int i=0; i < [tracks count]; i++) {
            MetadataForm* form = tracks[i];
            [form deleteImages];
        }

        [self.tracks removeObjectsInArray: tracks];
        return [self saveTracks];
    }
    
    return NO;
}

- (BOOL) removeAllTracks {
    for( int i=0; i < [self.tracks count]; i++) {
        MetadataForm* form = self.tracks[i];
        [form deleteImages];
    }
    
    self.tracks = [NSMutableArray new];
    return [self saveTracks];
}

- (void) updateOrganisationOfAllTracks: (NSNotification*) notification {
    NSString* organisationName = notification.object;
    if (organisationName) {
        for (int i=0; i < [self.tracks count]; i++) {
            MetadataForm* form = self.tracks[i];
            form.organisationName = organisationName;
        }
        
        [self saveTracks];
    }
}

@end
