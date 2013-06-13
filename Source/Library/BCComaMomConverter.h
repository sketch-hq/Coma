//
//  BCComaMomConverter.h
//  Coma
//
//  Created by Sam Deane on 13/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCComaMomConverter;

typedef void (^EntityBlock)(BCComaMomConverter* converter, NSEntityDescription* entity);

@interface BCComaMomConverter : NSObject

- (NSDictionary*)mergeModelAtURL:(NSURL*)momOrXCDataModelURL into:(NSDictionary*)existingInfo;

- (NSManagedObjectModel*)loadModel:(NSURL*)momOrXCDataModelURL error:(NSError**)error;
- (void)enumerateEntitiesInModel:(NSManagedObjectModel*)model block:(EntityBlock)block;
- (NSDictionary*)infoForModel:(NSManagedObjectModel*)model;

@end
