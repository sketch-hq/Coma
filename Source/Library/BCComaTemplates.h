//
//  BCComaTemplates.h
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GRMustacheTemplate;

@interface BCComaTemplates : NSObject

+ (BCComaTemplates*)templatesWithURL:(NSURL*)url;

- (id)initWithURL:(NSURL*)url;

- (GRMustacheTemplate*)templateNamed:(NSString*)name;

@end
