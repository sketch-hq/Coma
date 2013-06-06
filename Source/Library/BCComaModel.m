//
//  BCComaModel.m
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaModel.h"
#import "BCComaTemplates.h"

#import <GRMustache.h>

@interface BCComaModel()

@property (strong, nonatomic) NSMutableDictionary* data;
@property (strong, nonatomic) BCComaTemplates* templates;
@property (strong, nonatomic) NSDictionary* types;
@property (strong, nonatomic) NSDictionary* metas;

@end

@implementation BCComaModel

+ (BCComaModel*)modelWithContentsOfURL:(NSURL*)url templates:(BCComaTemplates *)templates
{
    BCComaModel* model = [[BCComaModel alloc] initWithContentsOfURL:url templates:templates];
    return model;
}

- (id)initWithContentsOfURL:(NSURL*)url templates:(BCComaTemplates *)templates
{
    if ((self = [super init]) != nil)
    {
        self.root = [url URLByDeletingLastPathComponent];
        self.templates = templates;
        NSMutableDictionary* modelDictionary = [self loadDictionaryAtURL:url];
        [self setupWithModelDictionary:modelDictionary];
    }

    return self;
}

- (id)initWithModelDictionary:(NSMutableDictionary*)modelDictionary templates:(BCComaTemplates *)templates
{
    if ((self = [super init]) != nil)
    {
        self.templates = templates;
        [self setupWithModelDictionary:modelDictionary];
    }

    return self;
}

- (void)setupWithModelDictionary:(NSMutableDictionary*)modelDictionary
{
    self.data = modelDictionary;
    self.types = [self loadItemsWithInheritance:modelDictionary[@"types"]];
    self.metas = [self loadItemsWithInheritance:modelDictionary[@"metas"]];

    [self preprocessClasses];
}

- (NSMutableDictionary*)loadDictionaryAtURL:(NSURL*)url
{
    NSMutableDictionary* result = nil;
    NSData* data = [NSData dataWithContentsOfURL:url];
    if (data)
    {
        NSError* error;
        result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (!result)
        {
            NSLog(@"error %@", error); // TODO: EClogging...
        }
    }

    return result;
}

- (NSMutableDictionary*)loadItemsWithInheritance:(NSDictionary*)dictionary
{
    NSMutableDictionary* items = dictionary[@"items"];
    NSString* base = dictionary[@"base"];
    if (base)
    {
        NSURL* baseURL = [[self.root URLByAppendingPathComponent:base] URLByAppendingPathExtension:@"json"];
        NSMutableDictionary* baseDictionary = [self loadDictionaryAtURL:baseURL];
        if (baseDictionary)
        {
            NSMutableDictionary* baseItems = [self loadItemsWithInheritance:baseDictionary];
            [baseItems addEntriesFromDictionary:items];
            items = baseItems;
        }
    }
    
    return items;
}

- (void)enumerateTemplates:(TemplateBlock)block
{
    NSArray* templates = self.data[@"templates"];
    for (NSString* template in templates)
    {
        block(template);
    }
}

- (void)preprocessClasses
{
    NSMutableDictionary* classes = self.data[@"classes"];
    [classes enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
        info[@"name"] = key;
        NSMutableDictionary* properties = info[@"properties"];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
            [self preprocessProperty:info name:key];
        }];
        info[@"properties"] = [properties allValues];
    }];
    self.data[@"classes"] = [classes allValues];
}

- (void)preprocessProperty:(NSMutableDictionary*)info name:(NSString*)name
{
    info[@"name"] = name;

    NSString* type = info[@"type"];
    if (type)
    {
        NSDictionary* typeInfo = self.types[type];
        if (!typeInfo)
        {
            typeInfo = self.types[@"«default»"];
        }
        
        NSString* requires = typeInfo[@"requires"];
        if (requires)
        {
            info[@"requires"] = @{@"import" : requires };
        }
        NSString* meta = typeInfo[@"metatype"];
        NSDictionary* metaInfo = self.metas[meta];
        [info addEntriesFromDictionary:metaInfo];

        NSDictionary* propertyTemplates = metaInfo[@"templates"];
        [propertyTemplates enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* templateName, BOOL *stop) {
            GRMustacheTemplate* template = [self.templates templateNamed:templateName];
            if (template)
            {
                info[key] = template;
            }
        }];
    }
}

- (void)enumerateClasses:(ClassBlock)block
{
    NSArray* classes = self.data[@"classes"];
    for (NSDictionary* class in classes)
    {
        block(class[@"name"], class);
    }
}

@end
