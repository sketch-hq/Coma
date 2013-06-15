// ----------------------------------------
// _Person.h
// Generated by Coma 1.0.
// Do not edit this file - it is automatically generated and your changes will be overwritten.
// ----------------------------------------

@class Job;

@interface _Person : NSObject

/**
 Returns a list of NSStrings with the names of the properties in it.
 @return Array of property names.
 */

+ (NSArray*)propertyNames;

/**
 Returns a list of NSStrings with the names of the relationship properties in it.
 @return Array of relationship names.
 */

+ (NSArray*)relationshipNames;

/**
 Returns a list of NSStrings with the names of the attribute properties in it.
 @return Array of attribute names.
 */

+ (NSArray*)attributeNames;





@property (strong, nonatomic) NSString* name;






/**
 Set value of job.
 Also updates the inverse property staff on the Job object; this
 should generated KVO notifications for changes to Job.staff as well as to job.
 */

@property (strong, nonatomic) Job* job;

/**
 Set value of job without sending notifications or updating inverse relationships.
 */

- (void)primitiveSetJob:(id)job;



/**
 Fake version of the CoreData init method. It actually just calls init.
 */

- (id)initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
