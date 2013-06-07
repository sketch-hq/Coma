//
//  BCLazyLoadingTemplate.m
//  Coma
//
//  Created by Sam Deane on 07/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaLazyLoadingTemplate.h"
#import "BCComaTemplates.h"

@interface BCComaLazyLoadingTemplate()

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) BCComaTemplates* templates;
@property (strong, nonatomic) GRMustacheTemplate* template;

@end

@implementation BCComaLazyLoadingTemplate

+ (BCComaLazyLoadingTemplate*)templateWithName:(NSString*)name templates:(BCComaTemplates*)templates
{
    BCComaLazyLoadingTemplate* template = [[BCComaLazyLoadingTemplate alloc] initWithName:name templates:templates];

    return template;
}

- (id)initWithName:(NSString*)name templates:(BCComaTemplates*)templates
{
    if ((self = [super init]) != nil)
    {
        self.name = name;
        self.templates = templates;
    }

    return self;
}

- (NSString *)renderForMustacheTag:(GRMustacheTag *)tag context:(GRMustacheContext *)context HTMLSafe:(BOOL *)HTMLSafe error:(NSError **)error AVAILABLE_GRMUSTACHE_VERSION_6_0_AND_LATER;
{
    if (!self.template)
    {
        self.template = [self.templates templateNamed:self.name];
    }

    NSString* result;
    id<GRMustacheRendering> templateAsRenderer = (id<GRMustacheRendering>)self.template;
    if (templateAsRenderer)
        result = [templateAsRenderer renderForMustacheTag:tag context:context HTMLSafe:HTMLSafe error:error];
    else
        result = @"";

    return result;
}

@end
