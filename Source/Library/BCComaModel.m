//
//  BCComaModel.m
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaModel.h"
#import "BCComaTemplates.h"
#import "BCComaLazyLoadingTemplate.h"

#import <GRMustache.h>

@interface BCComaModel()

@property (strong, nonatomic) NSMutableDictionary* data;
@property (strong, nonatomic) BCComaTemplates* templates;
@property (strong, nonatomic) NSDictionary* types;
@property (strong, nonatomic) NSDictionary* metas;
@property (strong, nonatomic) NSDictionary* classes;

@end

@implementation BCComaModel

ECDefineDebugChannel(ComaModelChannel);

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

/**
 Set things up.
 
 We load the types and metas from the dictionary, processing any inheritance.
 We then preprocess the classes to tidy them up and add some dynamically generated keys.
 
 */

- (void)setupWithModelDictionary:(NSMutableDictionary*)modelDictionary
{
    ECDebug(ComaModelChannel, @"setting up");
    
    self.data = modelDictionary;
    self.types = [self loadItemsWithInheritance:modelDictionary[@"types"]];
    self.metas = [self loadItemsWithInheritance:modelDictionary[@"metas"]];

    [self preprocessTypes];
    [self preprocessClasses];
}

#pragma mark - Dictionary Support

/**
 Load a dictionary from a json file.
 */

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
            [ECErrorReporter reportError:error message:@"error loading dictionary from %@", url];
        }
    }

    return result;
}

/** 
 Return some items from a dictionary.
 
 The items are expected to be under a key called "items".

 If a "base" key is present, this is treated as the name of another JSON file to inherit values from. 
 The contents of this file are loaded and this routine is called recursively to get items from it. 
 These inherited items are then merged in to the original dictionary.
 If the original and inhertied dictionaries both contain a particular key, the original one wins.
 */

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

#pragma mark - Enumeration

- (void)enumerateTemplates:(TemplateBlock)block
{
    NSArray* templates = self.data[@"templates"];
    for (NSString* template in templates)
    {
        ECDebug(ComaModelChannel, @"enumerating template %@", template);
        block(template);
    }
}


- (void)enumerateClasses:(ClassBlock)block
{
    NSArray* classes = [self.classes allValues];
    for (NSDictionary* class in classes)
    {
        NSString* name = class[@"name"];
        ECDebug(ComaModelChannel, @"enumerating class %@", name);
        block(name, class);
    }
}

#pragma mark - Preprocessing

/**
 Perform some processing on the types.
 We resolve aliases, and add names to the type info
 */

- (void)preprocessTypes
{
    NSDictionary* types = self.types;
    [types enumerateKeysAndObjectsUsingBlock:^(NSString* typeName, NSMutableDictionary* typeInfo, BOOL *stop) {
        NSString* alias;
        NSString* resolvedTypeName = typeName;
        while ((alias = typeInfo[@"alias"]) != nil)
        {
            if (alias)
            {
                [typeInfo removeObjectForKey:@"alias"];
                NSMutableDictionary* resolvedInfo = self.types[alias];
                [typeInfo addEntriesFromDictionary:resolvedInfo];
                resolvedTypeName = alias;
            }
        }

        if (![typeName isEqualToString:@"«default»"])
        {
            typeInfo[@"originalTypeName"] = typeName;
            typeInfo[@"resolvedTypeName"] = resolvedTypeName;
        }
    }];
}

/**
 Perform some processing on the classes.
 
 When loaded from the json file, the classes are a dictionary, with the key being the name of the class, and
 the value being another dictionary describing the class.

 This is a cleaner format from the point of view of authoring the file, but at the top level we really want a list instead.
 
 So we run through each entry in the top level dictionary. Since the top level key for each class is the only thing that gives its
 name, we add these to the dictionary for the class so that we can use it later.
 
 Whilst we're at it, we run through the properties dictionary in the class and process that a bit too, turning it into a list.

 We then turn the top level dictionary into a list.
 */

- (void)preprocessClasses
{
    NSDictionary* comaInfo = @{
                               @"name" : @"Coma",
                               @"version" : @"1.0",
                               @"date": [NSDate date]
                               };

    NSDictionary* defaults = self.data[@"defaults"];
    NSMutableDictionary* classes = self.data[@"classes"];
    self.classes = classes;
    [classes enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
        info[@"name"] = key;
        info[@"coma"] = comaInfo;
        NSMutableDictionary* properties = info[@"properties"];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
            [self preprocessProperty:info name:key];
        }];
        info[@"properties"] = [properties allValues];

        NSMutableDictionary* relationships = info[@"relationships"];
        if (relationships)
        {
            [relationships enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
                [self preprocessProperty:info name:key];
            }];
            info[@"relationships"] = [relationships allValues];
        }

        // merge in any default values that are missing
        [defaults enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            if (![info objectForKey:key])
            {
                info[key] = value;
            }
        }];

        [self addFiltersToDictionary:info];
    }];
}

/**
 Perform some processing on a property dictionary.
 */

- (void)preprocessProperty:(NSMutableDictionary*)info name:(NSString*)name
{
    // add the name of the property to the info dictionary, so we can fetch it later
    info[@"name"] = name;

    // look up the property type and try to obtain some type info for it
    NSString* type = info[@"type"];
    NSDictionary* typeInfo = [self infoForTypeNamed:type];
    if (typeInfo)
    {
        NSString* resolvedName = typeInfo[@"resolvedTypeName"];
        if (resolvedName)
            info[@"type"] = resolvedName;
        
        // if the type is one of our classes, add it to the requires property
        if ([self.classes objectForKey:type])
        {
            info[@"requires"] = [NSString stringWithFormat:@"%@.h", type];
        }

        // add the type and metatype entries to the property info
        // this allows templates to pick up and use these properties directly
        info[@"typeInfo"] = typeInfo;

        // merge in any type info keys that don't have values set in the property
        [typeInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (!info[key])
                info[key] = obj;
        }];


        // try to get the metatype data associated with the type
        // (for convenience, mutliple types share the same metatype - eg most basic types will have a metatype of "Basic")
        NSString* meta = typeInfo[@"metatype"];
        NSDictionary* metaInfo = self.metas[meta];
        if (metaInfo)
        {
            info[@"metaInfo"] = metaInfo;

            // process the list of dynamic template names in the meta info
            // for each of these, we try to load the corresponding template
            // if successful, we add the template as an entry in the property dictionary
            // this allows the top-level templates to "include" one of these type-specific templates just by referring to it
            // (eg a type-specific template called "getters" is expanded by an entry in a top-level template of {{gettters}})
            //
            // the purpose of all this is to allow top-level templates to refer to a sub-template by name (eg "getters") but to have the
            // engine actually use a different template depending on the type of the property being processed.
            // this is how, for example, we can have one template for copying objects using [object copy], and another for copying basic members like integers using assignment.
            NSDictionary* propertyTemplates = metaInfo[@"dynamicTemplates"];
            [propertyTemplates enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* templateName, BOOL *stop) {
                BCComaLazyLoadingTemplate* template = [BCComaLazyLoadingTemplate templateWithName:templateName templates:self.templates];
                if (template)
                {
                    info[key] = template;
                }
            }];

            // merge in any meta info keys that don't have values set in the property or the type info
            [metaInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if (!info[key])
                    info[key] = obj;
            }];
        }
        else
        {
            NSLog(@"error - meta info missing for %@ in type %@", meta, type);
            // TODO: better error reporting
        }
    }
    else
    {
        NSLog(@"error - type info missing for %@", type);
        // TODO: better error reporting
    }
}

- (void)addFiltersToDictionary:(NSMutableDictionary*)dictionary
{
    dictionary[@"mixedcaps"] = [GRMustacheFilter filterWithBlock:^id(id value) {
        NSString* string = [value description];
        return [string mixedcaseStringFromMixedCaseWithInitialCapital];
    }];

    dictionary[@"mixedcapsInitialCapital"] = [GRMustacheFilter filterWithBlock:^id(id value) {
        NSString* string = [value description];
        return [string mixedcaseStringInitialCapitalFromMixedCase];
    }];

}

/**
 Return information from the types dictionary for a type of a given name.
 If an entry for the given type isn't found, we use the default entry instead.
 */

- (NSDictionary*)infoForTypeNamed:(NSString*)name
{
    NSDictionary* result = nil;
    if (name)
    {
        result = self.types[name];
    }

    if (!result)
    {
        result = self.types[@"«default»"];
    }
    
    return result;
}

@end
