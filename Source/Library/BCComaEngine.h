//
//  Library.h
//  Library
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OutputBlock)(NSString* name, NSString* output);

@interface BCComaEngine : NSObject

- (void)generateModelAtURL:(NSURL*)modelURL withTemplatesAtURL:(NSURL*)templatesURL outputBlock:(OutputBlock)outputBlock;

@end
