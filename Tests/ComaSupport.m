//
//  BaseClass.m
//  Coma
//
//  Created by Sam Deane on 07/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "ComaSupport.h"

@implementation NSCoder(ComaSupport)

- (void)encodeRectAsString:(NSRect)rect forKey:(NSString*)key
{
  [self encodeObject:NSStringFromRect(rect) forKey:key];
}

- (void)encodePointAsString:(NSPoint)point forKey:(NSString*)key
{
  [self encodeObject:NSStringFromPoint(point) forKey:key];
}

@end
