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
    NSURL* modelURL = [self URLForTestResource:@"SVGModel" withExtension:@"xcdatamodeld" subdirectory:@"Data/svg"];

    BCComaMomConverter* converter = [BCComaMomConverter new];
    NSError* error;
    NSManagedObjectModel* model = [converter loadModel:modelURL error:&error];

    ECTestAssertNotNil(model);
}

- (void)testEnumerateEntities
{
    NSURL* modelURL = [self URLForTestResource:@"SVGModel" withExtension:@"xcdatamodeld" subdirectory:@"Data/svg"];

    BCComaMomConverter* converter = [BCComaMomConverter new];
    NSError* error;
    NSManagedObjectModel* model = [converter loadModel:modelURL error:&error];
    ECTestAssertNotNil(model);

    [converter enumerateEntitiesInModel:model block:^(BCComaMomConverter *converter, NSEntityDescription *entity) {
        NSLog(@"%@", entity.name);
    }];
}

#define WRITE_TO_DESKTOP 1

- (void)testInfoForModel
{
    NSURL* modelURL = [self URLForTestResource:@"SVGModel" withExtension:@"xcdatamodeld" subdirectory:@"Data/svg"];

    BCComaMomConverter* converter = [BCComaMomConverter new];
    NSError* error;
    NSManagedObjectModel* model = [converter loadModel:modelURL error:&error];
    ECTestAssertNotNil(model);

    NSDictionary* info = [converter infoForModel:model];
    NSURL* expectedURL = [self URLForTestResource:@"SVGConverted" withExtension:@"json" subdirectory:@"Data/svg"];
    NSDictionary* expected = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:expectedURL] options:0 error:&error];

    [self assertCollection:info matchesCollection:expected];
    //    [self assertCollection:info matchesContentsOfURL:expectedURL mode:ECAssertStringDiff];

#if WRITE_TO_DESKTOP
    NSURL* outputURL = [NSURL fileURLWithPath:[@"~/Desktop/SVGConverted.json" stringByStandardizingPath]];
    NSData* output = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    [output writeToURL:outputURL atomically:YES];
#endif
}

- (void)testMerging
{
    NSURL* modelURL = [self URLForTestResource:@"SVGModel" withExtension:@"xcdatamodeld" subdirectory:@"Data/svg"];

    BCComaMomConverter* converter = [BCComaMomConverter new];

    NSError* error;
    NSURL* svgURL = [self URLForTestResource:@"SVGModelBase" withExtension:@"json" subdirectory:@"Data/svg"];
    NSData* svgData = [NSData dataWithContentsOfURL:svgURL];
    NSDictionary* svgBase = [NSJSONSerialization JSONObjectWithData:svgData options:0 error:&error];

    NSDictionary* svgMerged = [converter mergeModelAtURL:modelURL into:svgBase error:&error];
    ECTestAssertNotNil(svgMerged);

    NSURL* expectedURL = [self URLForTestResource:@"SVGModel" withExtension:@"json" subdirectory:@"Data/svg"];
    NSDictionary* expected = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:expectedURL] options:0 error:&error];

    [self assertCollection:svgMerged matchesCollection:expected];
    //    [self assertCollection:svgMerged matchesContentsOfURL:expectedURL mode:ECAssertStringDiff];

#if WRITE_TO_DESKTOP
    NSURL* outputURL = [NSURL fileURLWithPath:[@"~/Desktop/svg.json" stringByStandardizingPath]];
    NSData* output = [NSJSONSerialization dataWithJSONObject:svgMerged options:NSJSONWritingPrettyPrinted error:&error];
    [output writeToURL:outputURL atomically:YES];
#endif
}
@end
