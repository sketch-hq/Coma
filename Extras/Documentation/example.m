// Generated Person.m

#import "Person.h"
#import "CustomClass.h"

@implementation Person

- (NSString*)name {
	return _name;
}

- (void)setName:(NSString*)name {
	if (_name != name) {
		_name = name;
	}
}

- (NSInteger)age {
	return _age;
}

- (void)setAge:(NSInteger)age {
	if (_age != age) {
		_age = age;
	}
}

- (CustomClass) {
	return _custom;
}

- (void)setCustom:(CustomClass*)custom {
	if (_custom != custom) {
		_custom = custom;
	}
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [self encodeObject:name forKey:@"name"];
    [self encodeInteger:age forKey:@"age"];
    [self encodeObject:custom forKey:@"custom"];
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
        id copy = [self new];
        copy.name = [self.name copy];
        copy.age = self.age;
		copy.custom = [self.custom deepCopy];
        return copy;
    }
}

@end
