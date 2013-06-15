// ----------------------------------------
// _Person.m
// Generated by Coma 1.0.
// Do not edit this file - it is automatically generated and your changes will be overwritten.
// ----------------------------------------
#import "_Person.h"
#import "Job.h"
@implementation _Person

#pragma mark - Introspection
/**
 Some static arrays containing lists of properties. These are populated once at +initialize time.
 */
static NSArray* sPersonProperties = nil;
static NSArray* sPersonRelationships = nil;
static NSArray* sPersonAttributes = nil;

/**
 Returns a list of NSStrings with the names of the properties in it.
 @return Array of property names.
 */
+ (NSArray*)propertyNames {
    if (!sPersonProperties) {
        sPersonProperties = @[
                             @"name",
                             @"job",
              ];
        if ([super respondsToSelector:@selector(propertyNames)])
            sPersonProperties = [sPersonProperties arrayByAddingObjectsFromArray:[super performSelector:@selector(propertyNames)]];
    }
    return sPersonProperties;
}

/**
 Returns a list of NSStrings with the names of the relationship properties in it.
 @return Array of relationship names.
 */
+ (NSArray*)relationshipNames {
    if (!sPersonRelationships) {
        sPersonRelationships = @[
                             @"job",
              ];
        if ([super respondsToSelector:@selector(relationshipNames)])
            sPersonRelationships = [sPersonRelationships arrayByAddingObjectsFromArray:[super performSelector:@selector(relationshipNames)]];
    }
    return sPersonProperties;
}

/**
 Returns a list of NSStrings with the names of the attribute properties in it.
 @return Array of attribute names.
 */
+ (NSArray*)attributeNames {
    if (!sPersonAttributes) {
        sPersonAttributes = @[
                             @"name",
              ];
        if ([super respondsToSelector:@selector(attributeNames)])
            sPersonAttributes = [sPersonAttributes arrayByAddingObjectsFromArray:[super performSelector:@selector(attributeNames)]];
    }
    return sPersonProperties;
}

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    
    return self;
}
#pragma mark - Attributes



#pragma mark - Relationships


/**
 Set value of job.
 Also updates the inverse property staff on the Job object; this
 should generated KVO notifications for changes to Job.staff as well as to job.
 */
- (void)setJob:(Job *)newValue
{
  Job* oldValue = _job;
    if (oldValue != newValue)
    {
        [oldValue willChangeValueForKey:@"staff"];
        [newValue willChangeValueForKey:@"staff"];
    [oldValue primitiveRemoveStaffObject:self];
        _job = newValue;
    [newValue primitiveAddStaffObject:self];
        [oldValue didChangeValueForKey:@"staff"];
        [newValue didChangeValueForKey:@"staff"];
    }
}
/**
 Set value of job without sending notifications or updating inverse relationships.
 */
- (void)primitiveSetJob:(id)job
{
    _job = job;
}


@end