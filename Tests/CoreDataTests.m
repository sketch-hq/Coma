//
//  CoreDataTests.m
//  CoreDataTests
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <ECUnitTests/ECUnitTests.h>

#import <Coma/Coma.h>

#import "Person.h"
#import "Job.h"

@interface CoreDataTests : ECTestCase

@end

ECDeclareDebugChannel(ComaEngineChannel);
ECDeclareDebugChannel(ComaTemplatesChannel);
ECDeclareDebugChannel(ComaModelChannel);


@interface CoreDataTests()
@property (strong, nonatomic) NSDate* date;
@property (strong, nonatomic) NSManagedObjectContext* context;
@property (strong, nonatomic) NSManagedObjectModel* model;
@property (strong, nonatomic) NSPersistentStoreCoordinator* coordinator;
@end

@implementation CoreDataTests

+ (void)setUp
{
    // turn on some logging for the tests
    ECEnableChannel(ComaEngineChannel);
    ECEnableChannel(ComaModelChannel);
    ECEnableChannel(ComaTemplatesChannel);
}

- (void)setupCoreData
{
    // create a new model and coordinator
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSBundle* thisBundle = [NSBundle bundleForClass:[self class]];
    NSArray* bundles = (mainBundle == thisBundle) ? @[thisBundle] : @[thisBundle, mainBundle];
    self.model = [NSManagedObjectModel mergedModelFromBundles:bundles];
    NSPersistentStoreCoordinator* coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: self.model];
    [coordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:nil];
    NSManagedObjectContext* context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = coordinator;
    context.undoManager = nil;

    self.context = context;
    self.coordinator = coordinator;
    
}

#if TEST_MOGENERATED

- (void)testCoreDataClasses
{
    [self setupCoreData];

    Person* person = [[Person alloc] initWithEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    Job* job = [[Job alloc] initWithEntity:[NSEntityDescription entityForName:@"Job" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];

    person.job = job;

    ECTestAssertTrue([job.staff containsObject:person]);
}

#else
- (void)testComaClasses
{
    Person* person = [[Person alloc] init];
    Job* job = [[Job alloc] init];

    person.job = job;

    ECTestAssertTrue([job.staff containsObject:person]);
}

#endif

#define WRITE_TO_DESKTOP 1

- (void)testGeneratingComaClasses
{
    NSURL* modelURL = [self URLForTestResource:@"CoreData" withExtension:@"xcdatamodeld" subdirectory:@"Data/coredata"];
    BCComaMomConverter* converter = [BCComaMomConverter new];

    NSError* error;
    NSURL* coreDataURL = [self URLForTestResource:@"CoreDataBase" withExtension:@"json" subdirectory:@"Data/coredata"];
    NSData* coreDataData = [NSData dataWithContentsOfURL:coreDataURL];
    NSDictionary* coreDataBase = [NSJSONSerialization JSONObjectWithData:coreDataData options:0 error:&error];

    NSDictionary* coreDataMerged = [converter mergeModelAtURL:modelURL into:coreDataBase error:&error];
    ECTestAssertNotNil(coreDataMerged);

    NSURL* mergedURL = [modelURL URLByAppendingPathExtension:@"json"];
    NSData* mergedData = [NSJSONSerialization dataWithJSONObject:coreDataMerged options:NSJSONWritingPrettyPrinted error:&error];
    [mergedData writeToURL:mergedURL atomically:YES];

    BCComaEngine* engine = [BCComaEngine new];

    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSURL* templates = [bundle URLForResource:@"templates" withExtension:@"" subdirectory:@"Data/coredata"];

    NSArray* expectedNames = @[@"Person.h", @"Person.m", @"Job.h", @"Job.m"];
    NSMutableDictionary* expected = [NSMutableDictionary dictionary];
    for (NSString* expectedName in expectedNames)
    {
        NSString* expectedValue = [NSString stringWithContentsOfURL:[bundle URLForResource:[expectedName stringByDeletingPathExtension] withExtension:[expectedName pathExtension]] encoding:NSUTF8StringEncoding error:&error];
        if (expectedValue)
            expected[expectedName] = expectedValue;
    }

    [engine generateModelAtURL:mergedURL withTemplatesAtURL:templates outputBlock:^(NSString *name, NSString *output, NSError* error) {

        if (output)
        {
            NSString* expectedOutput = expected[name];
            [self assertString:output matchesString:expectedOutput mode:ECAssertStringTestShowLinesIgnoreWhitespace];

#if WRITE_TO_DESKTOP
            NSURL* outputURL = [NSURL fileURLWithPath:[[@"~/Desktop" stringByStandardizingPath] stringByAppendingPathComponent:name]];
            [output writeToURL:outputURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
#endif

        }
        else
        {
            STFail(@"rendering error %@", error);
        }
        
    }];

}

@end