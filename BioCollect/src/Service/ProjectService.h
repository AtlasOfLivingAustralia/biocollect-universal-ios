@interface ProjectService : NSObject
- (void) wsGetProjects : (NSError**) error;
- (NSMutableArray *) loadProjects;
@end
