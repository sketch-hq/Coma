//
//  BCComaModel.h
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TemplateBlock)(NSString* templateName);
typedef void (^ClassBlock)(NSString* name, NSDictionary* info);

@class BCComaTemplates;

/**
 Encapsulates the model that is loaded in from a JSON file.
 Doesn't actually do any generation for the model - that's handled by passing blocks into various enumeration methods on the model.

 */

@interface BCComaModel : NSObject

/**
 Root directory to look in for additional JSON files.
 Some items in the model dictionary can specify JSON files to "inherit" values from - this is where those files are found.
*/

@property (strong, nonatomic) NSURL* root;

/** 
 Return a new model, loaded from the supplied file, using the supplied templates.
 @param url The location of the model json file.
 @param templates The templates to use.
 @return A new model.
 */

+ (BCComaModel*)modelWithContentsOfURL:(NSURL*)url templates:(BCComaTemplates*)templates;

/**
 Initialise a new model, loaded from the supplied file, using the supplied templates.
 The root property, which is used to locate other json files, will be set to the containing directory of the model.
 @param url The location of the model json file.
 @param templates The templates to use.
 @return A new model.
 */

- (id)initWithContentsOfURL:(NSURL*)url templates:(BCComaTemplates*)templates;

/**
 Initialise a new model from a dictionary, using the supplied templates.
 @param modelDictionary Dictionary describing the model.
 @param templates The templates to use.
 @return A new model.
 */

- (id)initWithModelDictionary:(NSMutableDictionary*)modelDictionary templates:(BCComaTemplates*)templates;

/**
 Perform a block for each of the high-level templates in the model.

 @note In theory this could happen in parallel, so the block might not be executed on the main thread.
 @param block The block to perform.
 */

- (void)enumerateTemplates:(TemplateBlock)block;

/**
 Perform a block for each of the classes described in the model.
 
 @note In theory this could happen in parallel, so the block might not be executed on the main thread.
 @param block The block to perform.
 */

- (void)enumerateClasses:(ClassBlock)block;

@end
