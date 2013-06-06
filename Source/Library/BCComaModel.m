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

@property (strong, nonatomic) NSMutableDictionary* data;

@end

@implementation BCComaModel

+ (BCComaModel*)modelWithContentsOfURL:(NSURL*)url
{
    BCComaModel* model = [[BCComaModel alloc] initWithContentsOfURL:url];
    return model;
}

- (id)initWithContentsOfURL:(NSURL*)url
{
    NSMutableDictionary* modelDictionary = [self loadDictionaryAtURL:url];
    return [self initWithModelDictionary:modelDictionary];
}

- (id)initWithModelDictionary:(NSMutableDictionary*)modelDictionary
{
    if ((self = [super init]) != nil)
    {
        self.data = modelDictionary;
        [self preprocessClasses];
    }

    return self;
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


- (void)enumeratePasses:(PassBlock)block
{
    NSArray* passes = self.data[@"passes"];
    for (NSString* pass in passes)
    {
        block(pass);
    }

}

- (void)preprocessClasses
{
    NSDictionary* types = (self.data[@"types"])[@"items"];
    NSDictionary* metas = (self.data[@"metas"])[@"items"];

    NSMutableDictionary* classes = self.data[@"classes"];
    [classes enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
        info[@"name"] = key;
        NSMutableDictionary* properties = info[@"properties"];
        [properties enumerateKeysAndObjectsUsingBlock:^(id key, NSMutableDictionary* info, BOOL *stop) {
            [self preprocessProperty:info name:key types:types metas:metas];
        }];
        info[@"properties"] = [properties allValues];
    }];
    self.data[@"classes"] = [classes allValues];
}

- (void)preprocessProperty:(NSMutableDictionary*)info name:(NSString*)name types:(NSDictionary*)types metas:(NSDictionary*)metas
{
    info[@"name"] = name;

    NSString* type = info[@"type"];
    if (type)
    {
        NSDictionary* typeInfo = types[type];
        NSString* requires = typeInfo[@"requires"];
        if (requires)
        {
            info[@"requires"] = @{@"import" : requires };
        }
//        NSString* meta = typeInfo[@"metatype"];
//        NSDictionary* metaInfo = metas[meta];
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
