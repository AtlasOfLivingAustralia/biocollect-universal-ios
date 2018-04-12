//
//  Species.c
//  Oz Atlas

#include "Project.h"
@implementation Project
@synthesize _id,projectId,projectActivityId, name,urlImage;

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.projectId forKey:@"projectIdKey"];
    [aCoder encodeObject:self.projectActivityId forKey:@"projectActivityIdKey"];
    [aCoder encodeObject:self.name forKey:@"nameKey"];
    [aCoder encodeObject:self.urlImage forKey:@"urlImageKey"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    self.projectId = [aDecoder decodeObjectForKey: @"projectIdKey"];
    self.projectActivityId = [aDecoder decodeObjectForKey: @"projectActivityIdKey"];
    self.name = [aDecoder decodeObjectForKey: @"nameKey"];
    self.urlImage = [aDecoder decodeObjectForKey: @"urlImageKey"];
    return self;
}

- (NSComparisonResult)sortByDisplayName:(Project *)otherObject {
    return otherObject.name > self.name;
}

@end

