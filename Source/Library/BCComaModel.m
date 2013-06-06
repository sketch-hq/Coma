//
//  BCComaModel.m
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaModel.h"
#import <GRMustache.h>

@interface BCComaModel()

@property (strong, nonatomic) NSDictionary* data;

@end

@implementation BCComaModel

+ (BCComaModel*)modelWithContentsOfURL:(NSURL*)url
{
    BCComaModel* model = [[BCComaModel alloc] initWithContentsOfURL:url];
    return model;
}

- (id)initWithContentsOfURL:(NSURL*)url
{
    NSDictionary* modelDictionary = [self loadDictionaryAtURL:url];
    return [self initWithModelDictionary:modelDictionary];
}

- (id)initWithModelDictionary:(NSDictionary*)modelDictionary
{
    if ((self = [super init]) != nil)
    {
        self.data = modelDictionary;
    }

    return self;
}

- (NSDictionary*)loadDictionaryAtURL:(NSURL*)url
{
    NSDictionary* result = nil;
    NSData* data = [NSData dataWithContentsOfURL:url];
    if (data)
    {
        NSError* error;
        result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (!result)
        {
            NSLog(@"error %@", error); // TODO: EClogging...
        }
    }

    return result;
}

- (void)generateWithTemplatesAtURL:(NSURL*)templatesURL
{
    NSArray* passes = self.data[@"passes"];
    for (NSString* pass in passes)
    {
        [self generatePass:pass withTemplatesAtURL:templatesURL];
    }

}

- (void)generatePass:(NSString*)pass withTemplatesAtURL:(NSURL*)templatesURL
{
    NSString *rendering = [GRMustacheTemplate renderObject:@{ @"name": @"Arthur" }
                                                fromString:@"Hello {{name}}!"
                                                     error:NULL];

}

@end
