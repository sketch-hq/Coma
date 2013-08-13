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

#import <GRMustache/GRMustache.h>

@interface BCComaModel()

@property (strong, nonatomic) NSMutableDictionary* data;
@property (strong, nonatomic) BCComaTemplates* templates;
@property (strong, nonatomic) NSDictionary* types;
@property (strong, nonatomic) NSDictionary* defaultTypeInfo;
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

 We load the types from the dictionary, processing any inheritance.
 We then preprocess the classes to tidy them up and add some dynamically generated keys.

 */

- (void)setupWithModelDictionary:(NSMutableDictionary*)modelDictionary
{
  ECDebug(ComaModelChannel, @"setting up");

  self.data = modelDictionary;
  self.types = [self loadItemsWithInheritance:modelDictionary[@"types"]];
  self.defaultTypeInfo = self.types[@"«default»"];

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
      [baseItems mergeEntriesFromDictionary:items];
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

 Whilst we're at it, we run through the attributes and relationships dictionaries in the class and process that a bit too, turning it into a list.

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

  // initial pass through the classes to update some basic info
  // need to do this first so that the typeInfo for all classes have been processed before we start working on the attributes and relationships
  [classes enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
    info[@"name"] = key;
    info[@"coma"] = comaInfo;
    // merge in any default values that are missing
    [defaults enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
      if (![info objectForKey:key])
      {
        info[key] = value;
      }
    }];
  }];

  // second pass through classes to process the attribute and relationship values
  [classes enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {

    // process attributes
    NSMutableDictionary* attributes = info[@"attributes"];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
      [self preprocessProperty:info name:key];
    }];

    NSArray* sortedAttributes = [[attributes allValues] sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSDictionary* prop1, NSDictionary* prop2) {
      NSString* name1 = prop1[@"name"];
      NSString* name2 = prop2[@"name"];
      return [name1 compare:name2];
    }];
    info[@"attributes"] = sortedAttributes;

    NSMutableArray* properties = [NSMutableArray arrayWithArray:sortedAttributes];

    // process relationships
    NSMutableDictionary* relationships = info[@"relationships"];
    if (relationships)
    {
      [relationships enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
        [self preprocessProperty:info name:key];
      }];

      NSArray* sortedRelationships = [[relationships allValues] sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSDictionary* prop1, NSDictionary* prop2) {
        NSString* name1 = prop1[@"name"];
        NSString* name2 = prop2[@"name"];
        return [name1 compare:name2];
      }];
      info[@"relationships"] = sortedRelationships;

      [properties addObjectsFromArray:sortedRelationships];
    }

    // combine attributes and relationships into a properties list
    NSArray* sortedProperties = [properties sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSDictionary* prop1, NSDictionary* prop2) {
      NSString* name1 = prop1[@"name"];
      NSString* name2 = prop2[@"name"];
      return [name1 compare:name2];
    }];
    info[@"properties"] = sortedProperties;


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
  NSDictionary* typeInfo = [self infoForTypeNamed:type useDefault:YES];
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
    // this allows templates to pick up and use these attributes directly
    info[@"typeInfo"] = typeInfo;

    // merge in any type info keys that don't have values set in the property
    [typeInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
      if (!info[key])
        info[key] = obj;
    }];

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

- (NSDictionary*)infoForTypeNamed:(NSString*)name useDefault:(BOOL)useDefault
{
  // try to get the basic info
  NSDictionary* result = nil;
  if (name)
  {
    result = self.types[name];
  }

  // if this is a class we're generating, merge in the info from the class definition
  NSDictionary* classInfo = self.classes[name];
  if (classInfo)
  {
    if (result)
    {
      NSMutableDictionary* merged = [NSMutableDictionary dictionaryWithDictionary:classInfo];
      [merged addEntriesFromDictionary:result];
      result = merged;
    }
    else
    {
      result = classInfo;
    }
  }

  // if there's no entry for this class, use the default info
  if (!result && useDefault)
  {
    NSMutableDictionary* defaultInfo = [NSMutableDictionary dictionaryWithDictionary:self.defaultTypeInfo];
    if (name)
      defaultInfo[@"originalTypeName"] = defaultInfo[@"resolvedTypeName"] = name;
    result = defaultInfo;
  }


  if (result)
  {
    id superclass = result[@"super"];
    if (superclass)
    {
      // may be a string, or a dictionary with "class" and "include" keys
      if ([superclass isKindOfClass:[NSDictionary class]])
        superclass = superclass[@"class"];

      NSDictionary* superinfo = [self infoForTypeNamed:superclass useDefault:NO];
      NSMutableDictionary* merged = [NSMutableDictionary dictionaryWithDictionary:superinfo];
      [merged removeObjectForKey:@"originalTypeName"];
      [merged removeObjectForKey:@"resolvedTypeName"];
      [merged addEntriesFromDictionary:result];
      result = merged;
    }
  }

  return result;
}

@end
