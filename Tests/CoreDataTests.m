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

- (void)testCoreDataClasses
{
    [self setupCoreData];

    Person* person = [[Person alloc] initWithEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];
    Job* job = [[Job alloc] initWithEntity:[NSEntityDescription entityForName:@"Job" inManagedObjectContext:self.context] insertIntoManagedObjectContext:self.context];

    person.job = job;

    ECTestAssertTrue([job.staff containsObject:person]);
}

@end