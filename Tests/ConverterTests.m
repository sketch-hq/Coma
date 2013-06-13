//
//  ConverterTests.m
//  LibraryTests
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <ECUnitTests/ECUnitTests.h>
#import <Coma/Coma.h>

#import "ExampleBasic.h"
#import "CustomClass.h"


@interface ConverterTests : ECTestCase

@end

ECDeclareDebugChannel(ComaEngineChannel);
ECDeclareDebugChannel(ComaTemplatesChannel);
ECDeclareDebugChannel(ComaModelChannel);


@interface ConverterTests()
@property (strong, nonatomic) NSDate* date;
@end

@implementation ConverterTests

+ (void)setUp
{
    // turn on some logging for the tests
    ECEnableChannel(ComaEngineChannel);
    ECEnableChannel(ComaModelChannel);
    ECEnableChannel(ComaTemplatesChannel);
}


- (void)testLoadModel
{
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSURL* modelURL = [bundle URLForResource:@"SVGModel" withExtension:@"xcdatamodeld" subdirectory:@"Data"];

    BCComaMomConverter* converter = [BCComaMomConverter new];
    NSError* error;
    NSManagedObjectModel* model = [converter loadModel:modelURL error:&error];

    ECTestAssertNotNil(model);
}


@end
