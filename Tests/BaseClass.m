//
//  BaseClass.m
//  Coma
//
//  Created by Sam Deane on 07/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BaseClass.h"

@implementation BaseClass

- (id)copyWithZone:(NSZone *)zone
{
    return [[self class] new];
}

@end
