//
//  BCLazyLoadingTemplate.h
//  Coma
//
//  Created by Sam Deane on 07/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GRMustache/GRMustache.h>

@class BCComaTemplates;

@interface BCComaLazyLoadingTemplate : NSObject<GRMustacheRendering>

+ (BCComaLazyLoadingTemplate*)templateWithName:(NSString*)name templates:(BCComaTemplates*)templates;

@end
