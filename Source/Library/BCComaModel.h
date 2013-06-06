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
@interface BCComaModel : NSObject

+ (BCComaModel*)modelWithContentsOfURL:(NSURL*)url templates:(BCComaTemplates*)templates;
- (id)initWithContentsOfURL:(NSURL*)url templates:(BCComaTemplates*)templates;
- (id)initWithModelDictionary:(NSMutableDictionary*)modelDictionary templates:(BCComaTemplates*)templates;

- (void)enumerateTemplates:(TemplateBlock)block;
- (void)enumerateClasses:(ClassBlock)block;

@end
