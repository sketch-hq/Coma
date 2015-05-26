// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Job.h instead.

#import <CoreData/CoreData.h>

extern const struct JobAttributes {
	__unsafe_unretained NSString *name;
} JobAttributes;

extern const struct JobRelationships {
	__unsafe_unretained NSString *staff;
} JobRelationships;

@class Person;

@interface JobID : NSManagedObjectID {}
@end

@interface _Job : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) JobID* objectID;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *staff;

- (NSMutableSet*)staffSet;

@end

@interface _Job (StaffCoreDataGeneratedAccessors)
- (void)addStaff:(NSSet*)value_;
- (void)removeStaff:(NSSet*)value_;
- (void)addStaffObject:(Person*)value_;
- (void)removeStaffObject:(Person*)value_;

@end

@interface _Job (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSMutableSet*)primitiveStaff;
- (void)setPrimitiveStaff:(NSMutableSet*)value;

@end
