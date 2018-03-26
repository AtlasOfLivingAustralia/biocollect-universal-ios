//
//  Project.h
//  Oz Atlas
//
@interface Project : NSObject <NSCoding> {
    int _id;
    
    NSString *projectId;
    NSString *projectActivityId;
    NSString *name;
    NSString *urlImage;
}

@property (nonatomic, assign) int _id;
@property (nonatomic, strong) NSString * projectId;
@property (nonatomic, strong) NSString * projectActivityId;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * urlImage;
- (NSComparisonResult)sortByDisplayName:(Project *)otherObject;
@end
