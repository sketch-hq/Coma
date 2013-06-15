//
//  Library.m
//  Library
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaEngine.h"
#import "BCComaModel.h"
#import "BCComaTemplates.h"

#import <GRMustache.h>

NSString *const BCComaEngineErrorDomain = @"BCComaEngineErrorDomain";

@implementation BCComaEngine

ECDefineDebugChannel(ComaEngineChannel);

- (void)generateModelAtURL:(NSURL*)modelURL withTemplatesAtURL:(NSURL*)templatesURL outputBlock:(OutputBlock)outputBlock
{
    ECDebug(ComaEngineChannel, @"rendering model %@ with templates %@", [modelURL lastPathComponent], [templatesURL lastPathComponent]);

    self.filterNewlines = YES;

    // we want to generate text, not HTML (don't need to escape stuff)
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;

    // load the templates
    BCComaTemplates* templates = [BCComaTemplates templatesWithURL:templatesURL];
    templates.engine = self;
    
    // load and set up the model
    BCComaModel* model = [BCComaModel modelWithContentsOfURL:modelURL templates:templates];

    // enumerate each top-level template in the model
    [model enumerateTemplates:^(NSString *templateName) {

        // get the actual template
        GRMustacheTemplate* template = [templates templateNamed:templateName];
        NSString* nameTemplateName = [NSString stringWithFormat:@"%@.name", templateName];
        GRMustacheTemplate* nameTemplate = [templates templateNamed:nameTemplateName];
        if (!template || !nameTemplate)
        {
            NSDictionary* info = @{
                                   NSLocalizedDescriptionKey : @"Template missing",
                                   @"TemplateName" : template ? nameTemplateName : templateName,
                                   @"TemplatesURL" : templatesURL
                                   };
            NSError* error = [NSError errorWithDomain:BCComaEngineErrorDomain code:BCComaEngineErrorMissingTemplate userInfo:info];
            outputBlock(templateName, nil, error);
        }
        else
        {
            // enumerate each class in the mode, applying it to the template
            [model enumerateClasses:^(NSString *name, NSDictionary *info) {
                NSError* error = nil;

                // render the text from the template
                NSString* output = [template renderObject:info error:&error];

                if (self.filterNewlines)
                {
                    output = [output stringByReplacingOccurrencesOfString:@"\n[ \t\n]*\n" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, [output length])];
                    output = [output stringByReplacingOccurrencesOfString:@"\n¶\n" withString:@"\n\n"];
                    output = [output stringByReplacingOccurrencesOfString:@"¶" withString:@"\n"];
                }
                
                NSString* outputName = templateName;
                if (output)
                {
                    // use the name template to figure out the final name for the output
                    outputName = [nameTemplate renderObject:info error:&error];
                }

                outputBlock(outputName, output, error);
            }];
        }
    }];
}

@end
