//
//  BCComaTemplates.m
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaTemplates.h"
#import <GRMustache.h>

@interface BCComaTemplates()

@property (strong, nonatomic) NSURL* url;
@property (strong, nonatomic) NSMutableDictionary* templates;

@end

@implementation BCComaTemplates

+ (BCComaTemplates*)templatesWithURL:(NSURL*)url
{
    BCComaTemplates* result = [[BCComaTemplates alloc] initWithURL:url];

    return result;
}

- (id)initWithURL:(NSURL*)url
{
    if ((self = [super init]) != nil)
    {
        self.url = url;
    }

    return self;
}

- (GRMustacheTemplate*)templateNamed:(NSString*)name
{
    GRMustacheTemplate* template = nil;
    if (name)
    {
        // create the cache if we haven't already
        NSMutableDictionary* templates = self.templates;
        if (!templates)
        {
            templates = self.templates = [NSMutableDictionary dictionary];
        }

        // look it up in the cache
        template = templates[name];
        if (!template)
        {
            // not in the cache, so try to load it
            NSError* error;
            NSURL* url = [[self.url URLByAppendingPathComponent:name] URLByAppendingPathExtension:@"mustache"];
            template = [GRMustacheTemplate templateFromContentsOfURL:url error:&error];
            if (template)
            {
                templates[name] = template;
            }
            else
            {
                templates[name] = [NSNull null];
                if (error.code != 260)
                {
                    NSLog(@"error loading template %@", error);
                }
                else
                {
                    NSLog(@"Template %@ missing (this may not be a problem)", name);
                }
            }
        }
    }

    return template;
}

@end
