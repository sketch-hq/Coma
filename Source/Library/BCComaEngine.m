//
//  Library.m
//  Library
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaEngine.h"

#import <GRMustache.h>

@implementation BCComaEngine

- (void)doStuff
{
    NSString *rendering = [GRMustacheTemplate renderObject:@{ @"name": @"Arthur" }
                                                fromString:@"Hello {{name}}!"
                                                     error:NULL];

    NSLog(@"rendering was %@", rendering);
}

@end
