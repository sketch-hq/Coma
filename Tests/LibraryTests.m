//
//  LibraryTests.m
//  LibraryTests
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "LibraryTests.h"
#import "ExampleBasic.h"
#import "CustomClass.h"

#import <Coma/Coma.h>

@interface NSString(Extras)
- (NSString*)lastLines:(NSUInteger)count;
- (NSString*)firstLines:(NSUInteger)count;
@end

@implementation NSString(Extras)

- (NSString*)lastLines:(NSUInteger)count
{
    NSArray* lines = [self componentsSeparatedByString:@"\n"];
    NSUInteger lineCount = [lines count];
    NSUInteger n = MIN(lineCount, count);

    NSArray* linesToReturn = [lines subarrayWithRange:NSMakeRange(lineCount - n, n)];
    return [linesToReturn componentsJoinedByString:@"\n"];
}

- (NSString*)firstLines:(NSUInteger)count
{
    NSArray* lines = [self componentsSeparatedByString:@"\n"];
    NSUInteger lineCount = [lines count];
    NSUInteger n = MIN(lineCount, count);

    NSArray* linesToReturn = [lines subarrayWithRange:NSMakeRange(0, n)];
    return [linesToReturn componentsJoinedByString:@"\n"];
}

@end

@implementation LibraryTests

- (void)testGeneratedExample
{
    // Generate the classes, and check that they match the versions linked in to these tests.
    
    BCComaEngine* engine = [BCComaEngine new];

    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSURL* input = [bundle URLForResource:@"example" withExtension:@"json" subdirectory:@"Data"];
    NSURL* templates = [bundle URLForResource:@"templates" withExtension:@"" subdirectory:@"Data/basic"];

    NSError* error;
    NSString* expectedHeader = [NSString stringWithContentsOfURL:[bundle URLForResource:@"ExampleBasic" withExtension:@"h"] encoding:NSUTF8StringEncoding error:&error];
    NSString* expectedSource = [NSString stringWithContentsOfURL:[bundle URLForResource:@"ExampleBasic" withExtension:@"m"] encoding:NSUTF8StringEncoding error:&error];
    NSDictionary* expected = @{ @"header" : expectedHeader, @"source" : expectedSource };

    [engine generateModelAtURL:input withTemplatesAtURL:templates outputBlock:^(NSString *name, NSString *output, NSError* error) {
        
        if (output)
        {
            NSString* expectedOutput = expected[name];
            if (![output isEqualToString:expectedOutput])
            {
                NSString* common = [output commonPrefixWithString:expectedOutput options:0];
                NSString* outputDiverged = [[output substringFromIndex:[common length]] firstLines:2];
                NSString* expectedDiverged = [[expectedOutput substringFromIndex:[common length]] firstLines:2];
                STFail(@"output didn't match:\n%@\n\nwas:'%@'\n\nexpected:'%@'\n\nfull:\n%@", [common lastLines:1], outputDiverged, expectedDiverged, output);
            }
        }
        else
        {
            STFail(@"rendering error %@", error);
        }

    }];
    
}

- (void)checkExample:(ExampleBasic*)example
{
    STAssertTrue([example.string isEqualToString:@"String"], @"unexpected string %@", example.string);
    STAssertTrue(example.integer == -123, @"unexpected integer %ld", example.integer);
    STAssertTrue(example.unsignedInteger == 123, @"unexpected unsigned %ld", example.unsignedInteger);
    STAssertTrue(example.real == 1.234, @"unexpected real %lf", example.real);
    STAssertTrue([example.date isEqualToDate:[NSDate dateWithString:@"1969-11-12"]], @"unexpected date %@", example.date);
    STAssertTrue(example.real == 1.234, @"unexpected real %lf", example.real);
    STAssertTrue([example.custom.string isEqualToString:@"Test"], @"unexpected string %@", example.custom.string);
}

- (void)testExample
{
    // Check that the version of the test classes linked in to this project actually works.
    // This isn't the actual code that is generated (we're not compiling it on the fly or anthing clever like that), but it should be identical to it,
    // so it's a sanity check that we're generating sensible code.
    
    ExampleBasic* test = [ExampleBasic new];

    test.string = @"String";
    test.integer = -123;
    test.unsignedInteger = 123;
    test.real = 1.234;
    test.date = [NSDate dateWithString:@"1969-11-12"];
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
