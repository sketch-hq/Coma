//
//  BaseClass.h
//  Coma
//
//  Created by Sam Deane on 07/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCoder(ComaSupport)
- (void)encodeRectAsString:(NSRect)rect forKey:(NSString*)key;
- (void)encodePointAsString:(NSPoint)point forKey:(NSString*)key;
- (NSRect)decodeRectFromStringForKey:(NSString *)key;
- (NSPoint)decodePointFromStringForKey:(NSString *)key;
@end
