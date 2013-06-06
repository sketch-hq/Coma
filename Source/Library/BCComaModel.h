//
//  BCComaModel.h
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCComaModel : NSObject

+ (BCComaModel*)modelWithContentsOfURL:(NSURL*)url;
- (id)initWithContentsOfURL:(NSURL*)url;
- (id)initWithModelDictionary:(NSDictionary*)modelDictionary;

- (void)generateWithTemplatesAtURL:(NSURL*)templatesURL;

@end
