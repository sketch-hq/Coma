//
//  BCComaMomConverter.h
//  Coma
//
//  Created by Sam Deane on 13/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCComaMomConverter : NSObject

- (NSManagedObjectModel*)loadModel:(NSURL*)momOrXCDataModelURL error:(NSError**)error;

@end
