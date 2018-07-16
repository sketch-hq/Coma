
//
//  BCMomConverter.m
//  Coma
//
//  Created by Sam Deane on 13/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaMomConverter.h"

@interface BCComaMomConverter ()
@property (strong, nonatomic) NSString* origModelBasePath;
@end

@implementation BCComaMomConverter

ECDefineDebugChannel(MomConverterChannel);

// TODO: this method came from Mogenerator; either credit it's use or replace it

- (NSString*)xcodeSelectPrintPath
{
	NSString* result = @"";

	@try
	{
		NSTask* task = [[NSTask alloc] init];
		[task setLaunchPath:@"/usr/bin/xcode-select"];

		[task setArguments:[NSArray arrayWithObject:@"-print-path"]];

		NSPipe* pipe = [NSPipe pipe];
		[task setStandardOutput:pipe];
		//  Ensures that the current tasks output doesn't get hijacked
		[task setStandardInput:[NSPipe pipe]];

		NSFileHandle* file = [pipe fileHandleForReading];

		[task launch];

		NSData* data = [file readDataToEndOfFile];
		result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		result = [result substringToIndex:[result length]-1]; // trim newline
	}
	@catch(NSException* ex)
	{
		NSLog(@"WARNING couldn't launch /usr/bin/xcode-select");
	}

	return result;
}

// TODO: this method came from Mogenerator; either credit it's use or replace it

- (NSManagedObjectModel*)loadModel:(NSURL*)momOrXCDataModelURL error:(NSError* __autoreleasing*)error
{
	NSString* momOrXCDataModelFilePath = [momOrXCDataModelURL path];
	NSFileManager* fm = [NSFileManager defaultManager];

	if (![fm fileExistsAtPath:momOrXCDataModelFilePath])
	{
		NSDictionary* info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"error loading file at %@: no such file exists", momOrXCDataModelFilePath] };
		if (error)
		{
			*error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:info];
		}

		return nil;
	}

	self.origModelBasePath = [momOrXCDataModelFilePath stringByDeletingLastPathComponent];

	// If given a data model bundle (.xcdatamodeld) file, assume its "current" data model file.
	if ([[momOrXCDataModelFilePath pathExtension] isEqualToString:@"xcdatamodeld"])
	{
		// xcdatamodeld bundles have a ".xccurrentversion" plist file in them with a
		// "_XCCurrentVersionName" key representing the current model's file name.
		NSString* xccurrentversionPath = [momOrXCDataModelFilePath stringByAppendingPathComponent:@".xccurrentversion"];
		if ([fm fileExistsAtPath:xccurrentversionPath])
		{
			NSDictionary* xccurrentversionPlist = [NSDictionary dictionaryWithContentsOfFile:xccurrentversionPath];
			NSString* currentModelName = [xccurrentversionPlist objectForKey:@"_XCCurrentVersionName"];
			if (currentModelName)
			{
				momOrXCDataModelFilePath = [momOrXCDataModelFilePath stringByAppendingPathComponent:currentModelName];
			}
		}
		else
		{
			// Freshly created models with only one version do NOT have a .xccurrentversion file, but only have one model
			// in them.  Use that model.
			NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self endswith %@", @".xcdatamodel"];
			NSArray* contents = [[fm contentsOfDirectoryAtPath:momOrXCDataModelFilePath error:nil]
			                     filteredArrayUsingPredicate:predicate];
			if (contents.count == 1)
			{
				momOrXCDataModelFilePath = [momOrXCDataModelFilePath stringByAppendingPathComponent:[contents lastObject]];
			}
		}
	}

	NSString* tempGeneratedMomFilePath = nil;
	NSString* momFilePath = nil;
	if ([[momOrXCDataModelFilePath pathExtension] isEqualToString:@"xcdatamodel"])
	{
		//  We've been handed a .xcdatamodel data model, transparently compile it into a .mom managed object model.
		NSString* momcTool = nil;
		if ([fm fileExistsAtPath:@"/usr/bin/xcrun"])
		{
			// Cool, we can just use Xcode 3.2.6/4.x's xcrun command to find and execute momc for us.
			momcTool = @"/usr/bin/xcrun momc";
		}
		else
		{
			// Rats, don't have xcrun. Hunt around for momc in various places where various versions of Xcode stashed it.
			NSString* xcodeSelectMomcPath = [NSString stringWithFormat:@"%@/usr/bin/momc", [self xcodeSelectPrintPath]];
			if ([fm fileExistsAtPath:xcodeSelectMomcPath])
			{
				momcTool = [NSString stringWithFormat:@"\"%@\"", xcodeSelectMomcPath]; // Quote for safety.
			}
			else if ([fm fileExistsAtPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/momc"])
			{
				// Xcode 4.3 - Command Line Tools for Xcode
				momcTool = @"/Applications/Xcode.app/Contents/Developer/usr/bin/momc";
			}
			else if ([fm fileExistsAtPath:@"/Developer/usr/bin/momc"])
			{
				// Xcode 3.1.
				momcTool = @"/Developer/usr/bin/momc";
			}
			else if ([fm fileExistsAtPath:@"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"])
			{
				// Xcode 3.0.
				momcTool = @"\"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc\"";
			}
			else if ([fm fileExistsAtPath:@"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"])
			{
				// Xcode 2.4.
				momcTool = @"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc";
			}
			assert(momcTool && "momc not found");
		}
		// NSString* momcOptions = @" -MOMC_NO_WARNINGS -MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS -MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR";
    NSString *momcOptions = @" --no-warnings --no-inverse-relationship-warnings";
    NSString* momcIncantation = nil;

		NSString* tempGeneratedMomFileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mom"];
		tempGeneratedMomFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempGeneratedMomFileName];
		momcIncantation = [NSString stringWithFormat:@"%@ %@ \"%@\" \"%@\"",
		                   momcTool,
		                   momcOptions,
		                   momOrXCDataModelFilePath,
		                   tempGeneratedMomFilePath];

		system([momcIncantation UTF8String]); // Ignore system() result since momc sadly doesn't return any relevent error codes.
		momFilePath = tempGeneratedMomFilePath;
	}
	else
	{
		momFilePath = momOrXCDataModelFilePath;
	}

	NSManagedObjectModel* result = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:momFilePath]];

	return result;
}

- (void)enumerateEntitiesInModel:(NSManagedObjectModel*)model block:(EntityBlock)block
{
	NSArray* entities = model.entities;
	for (NSEntityDescription* entity in entities)
	{
		block(self, entity);
	}
}

- (NSMutableDictionary*)infoForAttributeNamed:(NSString*)attributeName attribute:(NSAttributeDescription*)attribute entity:(NSEntityDescription*)entity
{
	NSString* className = attribute.attributeValueClassName;
	if (!className)
	{
		className = attribute.userInfo[@"attributeValueClassName"];
	}

	NSString* basicType;
	NSString* explicitScalarType = attribute.userInfo[@"scalarAttributeType"];
	NSString* explicitObjectType = attribute.userInfo[@"objectAttributeType"];
	switch (attribute.attributeType)
	{
		case NSInteger16AttributeType:
		{
			basicType = @"CoreDataScalarInt16";
			break;
		}

		case NSInteger32AttributeType:
		{
			basicType = @"CoreDataScalarInt32";
			break;
		}

		case NSInteger64AttributeType:
		{
			basicType = @"CoreDataScalarInt64";
			break;
		}

		case NSDecimalAttributeType:
		{
			basicType = @"CoreDataScalarDecimal";
			break;
		}

		case NSDoubleAttributeType:
		{
			basicType = @"CoreDataScalarDouble";
			break;
		}

		case NSFloatAttributeType:
		{
			basicType = @"CoreDataScalarFloat";
			break;
		}

		case NSBooleanAttributeType:
		{
			basicType = @"CoreDataScalarBoolean";
			break;
		}

		case NSTransformableAttributeType:
		{
			if (explicitScalarType)
			{
				basicType = explicitScalarType;
			}
			else if (!className)
			{
				className = @"id";
			}
			break;
		}

		default:
		basicType = nil;
	}


	NSString* explicitType;
	NSString* type = nil;
	if (basicType)
	{
		explicitType = explicitScalarType;
		type = basicType;
	}
	else if (className)
	{
		explicitType = explicitObjectType;
		type = className;
	}

	if (explicitType)
	{
		type = explicitType;
	}

	if (!type)
	{
		type = explicitObjectType;
	}

	if (!type)
	{
		type = explicitScalarType;
	}

	if (!type)
	{
		type = @"NSObject";
	}

	NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:
	                             @{
	                                 @"type" : type,
	                                 @"optional" : @(attribute.isOptional),
	                                 @"transient" : @(attribute.isTransient),
	                                 @"indexed" : @(attribute.isIndexed),
	                                 @"external" : @(attribute.isStoredInExternalRecord),
								 }];


	if (attribute.valueTransformerName)
	{
		info[@"transformer"] = attribute.valueTransformerName;
	}

	// add any unused userInfo from the model to the property
	[attribute.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop)
	 {
	     if (!info[key])
	     {
	         info[key] = value;
		 }
	 }];

    if (attribute.defaultValue)
	{
        if (info[@"default"])
        {
            ECDebug(MomConverterChannel, @"default from userInfo overrides %@", attribute.defaultValue);
        }
        else
        {
            info[@"default"] = attribute.defaultValue;
        }
	}
    
    // we set a defaultSupplied key if default was set
    // (this is to allow templates to distinguish between default being absent and default being zero)
    if (info[@"default"])
        info[@"defaultSupplied"] = @(YES);

	return info;
}

- (NSMutableDictionary*)infoForRelationshipNamed:(NSString*)relationshipName relationship:(NSRelationshipDescription*)relationship entity:(NSEntityDescription*)entity
{
	NSString* className = relationship.destinationEntity.name;


	NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:
	                             @{
	                                 @"type" : className,
	                                 @"minimum" : @(relationship.minCount),
	                                 @"maximum" : @(relationship.maxCount),
	                                 @"optional" : @(relationship.isOptional),
	                                 @"transient" : @(relationship.isTransient),
	                                 @"indexed" : @(relationship.isIndexed),
	                                 @"external" : @(relationship.isStoredInExternalRecord),
								 }];

	NSString* deleteRule;
	switch (relationship.deleteRule)
	{
		case NSNullifyDeleteRule:
		{
			deleteRule = @"nullify";
			break;
		}

		case NSCascadeDeleteRule:
		{
			deleteRule = @"cascade";
			break;
		}

		case NSDenyDeleteRule:
		{
			deleteRule = @"deny";
			break;
		}

		default:
		deleteRule = nil;
	}

	if (deleteRule)
	{
		info[@"delete"] = deleteRule;
	}

	if (relationship.maxCount == 0)
	{
		info[@"toMany"] = @YES;
	}

	NSRelationshipDescription* inverse = relationship.inverseRelationship;
	if (inverse)
	{
		info[@"inverse"] = inverse.name;
	}

	// add any unused userInfo from the relationship to the property
	[relationship.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop)
	 {
	     if (!info[key])
	     {
	         info[key] = value;
		 }
	 }];

	return info;
}

- (NSDictionary*)infoForEntity:(NSEntityDescription*)entity
{
	NSEntityDescription* superEntity = entity.superentity;
	__block NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
	[entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, NSAttributeDescription* attribute, BOOL* stop)
	 {
	     if (!superEntity.attributesByName[attributeName])  // don't process attributes that are part of the superclass

	     {
	         attributes[attributeName] = [self infoForAttributeNamed:attributeName attribute:attribute entity:entity];
		 }
	 }];

	__block NSMutableDictionary* relationships = [NSMutableDictionary dictionary];
	[entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString* relationshipName, NSRelationshipDescription* relationship, BOOL* stop)
	 {
	     if (!superEntity.relationshipsByName[relationshipName])  // don't process relationships that are part of the superclass

	     {
	         relationships[relationshipName] = [self infoForRelationshipNamed:relationshipName relationship:relationship entity:entity];
		 }
	 }];

	NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:
	                               @{
	                                   @"attributes" : attributes,
	                                   @"relationships" : relationships,
								   }];

	NSString* superName = entity.superentity.name;
	if (superName)
	{
		NSString* superImport = [NSString stringWithFormat:@"%@.h", superName];
		result[@"super"] = @{@"class" : superName, @"import" : superImport };
	}

    // add any userInfo entries that we don't already have values for
    [entity.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (!result[key])
            result[key] = value;
    }];

	return result;
}


- (NSDictionary*)infoForModel:(NSManagedObjectModel*)model
{
	__block NSMutableDictionary* classes = [NSMutableDictionary dictionary];
	[self enumerateEntitiesInModel:model block:^(BCComaMomConverter* converter, NSEntityDescription* entity)
	 {
	     classes[entity.name] = [self infoForEntity:entity];
	 }];

	return classes;
}

- (NSDictionary*)mergeModelAtURL:(NSURL*)momOrXCDataModelURL into:(NSDictionary*)existingInfo error:(NSError**)error
{
	NSDictionary* result = nil;

	NSManagedObjectModel* model = [self loadModel:momOrXCDataModelURL error:error];
	if (model)
	{
		NSDictionary* classInfo = [self infoForModel:model];
		NSMutableDictionary* merged = [NSMutableDictionary dictionaryWithDictionary:existingInfo];
		merged[@"classes"] = classInfo;
		result = merged;
	}

	return result;
}

@end
