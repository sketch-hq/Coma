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
    [GRMustacheConfiguration defaultConfiguration].contentType = GRMustacheContentTypeText;

    BCComaTemplates* templates = [BCComaTemplates templatesWithURL:templatesURL];
    BCComaModel* model = [BCComaModel modelWithContentsOfURL:modelURL templates:templates];

    [model enumerateTemplates:^(NSString *templateName) {
        GRMustacheTemplate* template = [templates templateNamed:templateName];

        [model enumerateClasses:^(NSString *name, NSDictionary *info) {
            NSError* error = nil;
            NSString* text = [template renderObject:info error:&error];
            
            if (text)
            {
                outputBlock(templateName, text);
            }
            else
            {
                NSLog(@"rendering error %@", error);
            }
        }];
    }];
}

@end
