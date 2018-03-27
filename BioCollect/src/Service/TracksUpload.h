#import "Project.h"
#import "MetadataForm.h"

@interface TracksUpload : NSObject
- (void) uploadTracks: (NSMutableArray<MetadataForm*>*) uploadItems andUpdateError: (NSError **) error;
@end
