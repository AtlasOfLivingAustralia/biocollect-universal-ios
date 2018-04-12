#import "Project.h"

@interface ProjectService : NSObject
- (void) wsGetProjects : (NSError**) error;
- (NSMutableArray *) loadProjects;
- (BOOL) storeSelectedProject : (Project *) project;
- (Project *) loadSelectedProject;
@end
