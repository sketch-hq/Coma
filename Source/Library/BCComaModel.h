//
//  BCComaModel.h
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PassBlock)(NSString* pass);
typedef void (^ClassBlock)(NSString* name, NSDictionary* info);

@interface BCComaModel : NSObject

+ (BCComaModel*)modelWithContentsOfURL:(NSURL*)url;
- (id)initWithContentsOfURL:(NSURL*)url;
- (id)initWithModelDictionary:(NSMutableDictionary*)modelDictionary;

- (void)enumeratePasses:(PassBlock)block;
- (void)enumerateClasses:(ClassBlock)block;

@end
