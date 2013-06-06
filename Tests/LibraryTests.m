//
//  LibraryTests.m
//  LibraryTests
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "LibraryTests.h"
#import <Coma/Coma.h>

@implementation LibraryTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    BCComaEngine* engine = [BCComaEngine new];
    [engine doStuff];
}

@end
