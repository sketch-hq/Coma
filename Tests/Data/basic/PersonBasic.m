// Generated Person.m

#import "PersonBasic.h"
#import "CustomClass.h"

@implementation PersonBasic

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeInteger:self.age forKey:@"age"];
    [coder encodeObject:self.custom forKey:@"custom"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _name = [coder decodeObjectForKey:@"name"];
        _age = [coder decodeIntegerForKey:@"age"];
		_custom = [coder decodeObjectForKey:@"custom"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    PersonBasic* copy = [super copyWithZone:zone];

    copy.name = [self.name copyWithZone:zone];
    copy.age = self.age;
    copy.custom = [self.custom deepCopyWithZone:zone];
    return copy;
}

@end
