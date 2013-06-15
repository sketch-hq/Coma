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
@property (assign, nonatomic) BOOL filterNewlines;

@end

@implementation BCComaTemplates

ECDefineDebugChannel(ComaTemplatesChannel);

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
        self.filterNewlines = YES;
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
            if (self.filterNewlines)
            {
                NSString* filtered = [self filterContentsOfURL:url error:&error];
                template = [GRMustacheTemplate templateFromString:filtered error:&error];
            }
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
                    [ECErrorReporter reportError:error message:@"error loading template %@", url];
                }
                else
                {
                    ECDebug(ComaTemplatesChannel, @"Template %@ missing (this may not be a problem)", name);
                }
            }
        }
    }

    return template;
}

- (NSString*)filterContentsOfURL:(NSURL*)url error:(NSError**)error
{
    NSString* result = nil;
    NSString* raw = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:error];
    if (raw)
    {
        NSMutableString* modified = [NSMutableString stringWithString:@""];
        __block NSUInteger position = 0;
        NSUInteger length = [raw length];
        NSRegularExpression* exp = [[NSRegularExpression alloc] initWithPattern:@"\\}\\}[ \\t]*\n" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:error];
        [exp enumerateMatchesInString:raw options:0 range:NSMakeRange(position, length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSRange match = [result rangeAtIndex:0];
            [modified appendString:[raw substringWithRange:NSMakeRange(position, match.location - position)]];
            [modified appendString:@"}}"];
            position = match.location + match.length;
        }];
        if (position < length)
        {
            [modified appendString:[raw substringFromIndex:position]];
        }

        
        result = modified;
    }

    return result;
}
@end
