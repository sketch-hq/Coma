// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Job.m instead.

#import "_Job.h"

const struct JobAttributes JobAttributes = {
	.name = @"name",
};

const struct JobRelationships JobRelationships = {
	.staff = @"staff",
};

@implementation JobID
@end

@implementation _Job

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Job";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Job" inManagedObjectContext:moc_];
}

- (JobID*)objectID {
	return (JobID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic name;

@dynamic staff;

- (NSMutableSet*)staffSet {
	[self willAccessValueForKey:@"staff"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"staff"];

	[self didAccessValueForKey:@"staff"];
	return result;
}

@end

