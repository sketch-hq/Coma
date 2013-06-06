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

    BCComaModel* model = [BCComaModel modelWithContentsOfURL:modelURL];
    BCComaTemplates* templates = [BCComaTemplates templatesWithURL:templatesURL];

    [model enumeratePasses:^(NSString *pass) {

        GRMustacheTemplate* template = [templates templateNamed:pass];

        [model enumerateClasses:^(NSString *name, NSDictionary *info) {
            NSError* error;
            NSString* text = [template renderObject:info error:&error];
            
            if (text)
            {
                outputBlock(pass, text);
            }
            else
            {
                NSLog(@"rendering error %@", error);
            }
        }];
    }];
}

@end
