//
//  CustomClass.m
//  Coma
//
//  Created by Sam Deane on 07/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "CustomClass.h"

@implementation CustomClass

- (id)copyWithZone:(NSZone *)zone
{
    CustomClass* copy = [[self class] alloc];
    copy.string = self.string;

    return copy;
}

- (id)deepCopyWithZone:(NSZone *)zone
{
    // this is a bit pointless - it's just an example of a class that has a non-standard way of copying, to illustrate that the copy generation code works properly
    // (in the generated class, the copy method should call deepCopy for the member of this type, instead of copy)
    CustomClass* copy = [[self class] alloc];
    copy.string = [self.string copy];

    return copy;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.string forKey:@"string"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init]) != nil) {
        _string = [coder decodeObjectForKey:@"string"];
    }

    return self;
}

@end
