//
//  Library.h
//  Library
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OutputBlock)(NSString* name, NSString* output, NSError* error);

NSString *const BCComaEngineErrorDomain;

typedef NS_ENUM(NSUInteger, BCComaEngineError)
{
    BCComaEngineErrorMissingTemplate = 1
};

@interface BCComaEngine : NSObject

@property (strong, nonatomic) NSString* classNamePrefix;

/**
 Given a model.json file, and a directory containing templates, generate files.
 The given block will be called once for each generated file.
 
 @param modelURL The location of the model file.
 @param templatesURL A directory containing templates.
 @param outputBlock A block to call for each top-level template that is processed.
 */

- (void)generateModelAtURL:(NSURL*)modelURL withTemplatesAtURL:(NSURL*)templatesURL outputBlock:(OutputBlock)outputBlock;

@end
