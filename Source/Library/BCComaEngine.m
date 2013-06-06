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

@implementation BCComaEngine


- (void)generateModelAtURL:(NSURL*)modelURL withTemplatesAtURL:(NSURL*)templatesURL outputBlock:(OutputBlock)outputBlock
{
    // we want to generate text, not HTML (don't need to escape stuff)
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;

    // load the templates
    BCComaTemplates* templates = [BCComaTemplates templatesWithURL:templatesURL];

    // load and set up the model
    BCComaModel* model = [BCComaModel modelWithContentsOfURL:modelURL templates:templates];

    // enumerate each top-level template in the model
    [model enumerateTemplates:^(NSString *templateName) {

        // get the actual template
        GRMustacheTemplate* template = [templates templateNamed:templateName];

        // enumerate each class in the mode, applying it to the template
        [model enumerateClasses:^(NSString *name, NSDictionary *info) {
            NSError* error = nil;

            // render the text from the template
            NSString* text = [template renderObject:info error:&error];
            outputBlock(templateName, text, error);
        }];
    }];
}

@end
