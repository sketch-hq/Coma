//
//  BCComaTemplates.h
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GRMustacheTemplate;
@class BCComaEngine;

/**
 Represents a collection of templates.
 */

@interface BCComaTemplates : NSObject

@property (weak, nonatomic) BCComaEngine* engine;

/**
 Return a new template collection, using the given url to locate the templates.
 
 @param url A directory containing the templates.
 @return The new templates
 */

+ (BCComaTemplates*)templatesWithURL:(NSURL*)url;

/**
 Initialise a new template collection, using the given url to locate the templates.

 @param url A directory containing the templates.
 @return The new templates
 */

- (id)initWithURL:(NSURL*)url;

/**
 Return the template with a given name.
 
 @param name Name of the template - without a file extension.
 @return The template, or nil if none was found.
 */

- (GRMustacheTemplate*)templateNamed:(NSString*)name;

@end
