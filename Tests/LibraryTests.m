//
//  LibraryTests.m
//  LibraryTests
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "LibraryTests.h"
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

    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSURL* input = [bundle URLForResource:@"example" withExtension:@"json" subdirectory:@"Data"];
    NSURL* templates = [bundle URLForResource:@"templates" withExtension:@"" subdirectory:@"Data/basic"];

    NSError* error;
    NSString* expectedHeader = [NSString stringWithContentsOfURL:[bundle URLForResource:@"PersonBasic" withExtension:@"h"] encoding:NSUTF8StringEncoding error:&error];
    NSString* expectedSource = [NSString stringWithContentsOfURL:[bundle URLForResource:@"PersonBasic" withExtension:@"m"] encoding:NSUTF8StringEncoding error:&error];
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
                STFail(@"output didn't match:\n%@\n\nwas:\n%@\n\nexpected:\n%@\n\nfull:\n%@", [common lastLines:1], outputDiverged, expectedDiverged, output);
            }
        }
        else
        {
            STFail(@"rendering error %@", error);
        }

    }];
    
}

@end
