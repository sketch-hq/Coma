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
@end

@implementation CoreDataTests

+ (void)setUp
{
    // turn on some logging for the tests
    ECEnableChannel(ComaEngineChannel);
    ECEnableChannel(ComaModelChannel);
    ECEnableChannel(ComaTemplatesChannel);
}

- (void)testCoreDataClasses
{
    Person* person = [[Person alloc] init];
    Job* job = [[Job alloc] init];

    person.job = job;

    ECTestAssertTrue([job.staff containsObject:person]);
}

@end