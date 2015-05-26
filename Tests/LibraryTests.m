//
//  LibraryTests.m
//  LibraryTests
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <ECUnitTests/ECUnitTests.h>

#import "ExampleBasic.h"
#import "CustomClass.h"

#import <Coma/Coma.h>

@interface LibraryTests : ECTestCase

@end

ECDeclareDebugChannel(ComaEngineChannel);
ECDeclareDebugChannel(ComaTemplatesChannel);
ECDeclareDebugChannel(ComaModelChannel);


@interface LibraryTests()
@property (strong, nonatomic) NSDate* date;
@end

@implementation LibraryTests

+ (void)setUp
{
    // turn on some logging for the tests
    ECEnableChannel(ComaEngineChannel);
    ECEnableChannel(ComaModelChannel);
    ECEnableChannel(ComaTemplatesChannel);
}

#define WRITE_TO_DESKTOP 0

- (void)doTestForGeneratedName:(NSString*)generatedName withTemplateName:(NSString*)templateName
{
    // Generate the classes, and check that they match the versions linked in to these tests.
    
    BCComaEngine* engine = [BCComaEngine new];

    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSURL* input = [bundle URLForResource:@"example" withExtension:@"json" subdirectory:@"Data"];
    NSURL* templates = [bundle URLForResource:@"templates" withExtension:@"" subdirectory:[NSString stringWithFormat:@"Data/%@", templateName]];

    NSURL* expectedHeader = [bundle URLForResource:generatedName withExtension:@"h"];
    NSURL* expectedSource = [bundle URLForResource:generatedName withExtension:@"m"];
    NSDictionary* expected = @{ [generatedName stringByAppendingPathExtension:@"h"] : expectedHeader, [generatedName stringByAppendingPathExtension:@"m"] : expectedSource };

    [engine generateModelAtURL:input withTemplatesAtURL:templates outputBlock:^(NSString *name, NSString *output, NSError* error) {
        
        if (output)
        {
            NSURL* expectedOutput = expected[name];
            [self assertString:output matchesContentsOfURL:expectedOutput mode:ECTestComparisonShowLinesIgnoreWhitespace];

#if WRITE_TO_DESKTOP
            NSURL* outputURL = [NSURL fileURLWithPath:[[@"~/Desktop" stringByStandardizingPath] stringByAppendingPathComponent:name]];
            [output writeToURL:outputURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
#endif

        }
        else
        {
            ECTestFail(@"rendering error %@", error);
        }

    }];
    
}

- (void)testGeneratedBasicExample
{
    [self doTestForGeneratedName:@"ExampleBasic" withTemplateName:@"basic"];
}

- (void)testGeneratedUndoExample
{
    [self doTestForGeneratedName:@"ExampleUndo" withTemplateName:@"undo"];
}

- (void)checkExample:(ExampleBasic*)example
{
    ECTestAssertTrueFormat([example.string isEqualToString:@"String"], @"unexpected string %@", example.string);
    ECTestAssertTrueFormat(example.integer == -123, @"unexpected integer %ld", example.integer);
    ECTestAssertTrueFormat(example.unsignedInteger == 123, @"unexpected unsigned %ld", example.unsignedInteger);
    ECTestAssertTrueFormat(example.real == 1.234, @"unexpected real %lf", example.real);
    ECTestAssertTrueFormat([example.date isEqualToDate:self.date], @"unexpected date %@", example.date);
    ECTestAssertTrueFormat(example.real == 1.234, @"unexpected real %lf", example.real);
    ECTestAssertTrueFormat([example.custom.string isEqualToString:@"Test"], @"unexpected string %@", example.custom.string);
}

- (void)testExample
{
    // Check that the version of the test classes linked in to this project actually works.
    // This isn't the actual code that is generated (we're not compiling it on the fly or anthing clever like that), but it should be identical to it,
    // so it's a sanity check that we're generating sensible code.
    
    ExampleBasic* test = [ExampleBasic new];

    self.date = [NSDate date];

    test.string = @"String";
    test.integer = -123;
    test.unsignedInteger = 123;
    test.real = 1.234;
    test.date = self.date;
    test.rect = NSMakeRect(1, 2, 3, 4);
    test.point= NSMakePoint(1, 2);
    test.boolean = YES;
    test.custom = [CustomClass new];
    test.custom.string = @"Test";

    ExampleBasic* copy = [test copy];
    [self checkExample:copy];

    NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:test];

    ExampleBasic* decoded = [NSKeyedUnarchiver unarchiveObjectWithData:encoded];
    [self checkExample:decoded];
}

@end
