//
//  BCMomConverter.m
//  Coma
//
//  Created by Sam Deane on 13/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaMomConverter.h"

@interface BCComaMomConverter()
@property (strong, nonatomic) NSString* origModelBasePath;
@end

@implementation BCComaMomConverter

- (NSString*)xcodeSelectPrintPath {
    NSString *result = @"";

    @try {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/xcode-select"];

        [task setArguments:[NSArray arrayWithObject:@"-print-path"]];

        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        //  Ensures that the current tasks output doesn't get hijacked
        [task setStandardInput:[NSPipe pipe]];

        NSFileHandle *file = [pipe fileHandleForReading];

        [task launch];

        NSData *data = [file readDataToEndOfFile];
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        result = [result substringToIndex:[result length]-1]; // trim newline
    } @catch(NSException *ex) {
        NSLog(@"WARNING couldn't launch /usr/bin/xcode-select");
    }

    return result;
}

- (NSManagedObjectModel*)loadModel:(NSURL *)momOrXCDataModelURL error:(NSError *__autoreleasing *)error
{
    NSString* momOrXCDataModelFilePath = [momOrXCDataModelURL path];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:momOrXCDataModelFilePath]) {
        NSDictionary* info = @{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"error loading file at %@: no such file exists", momOrXCDataModelFilePath] };
        if (error)
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:info];

        return nil;
    }

    self.origModelBasePath = [momOrXCDataModelFilePath stringByDeletingLastPathComponent];

    // If given a data model bundle (.xcdatamodeld) file, assume its "current" data model file.
    if ([[momOrXCDataModelFilePath pathExtension] isEqualToString:@"xcdatamodeld"]) {
        // xcdatamodeld bundles have a ".xccurrentversion" plist file in them with a
        // "_XCCurrentVersionName" key representing the current model's file name.
        NSString *xccurrentversionPath = [momOrXCDataModelFilePath stringByAppendingPathComponent:@".xccurrentversion"];
        if ([fm fileExistsAtPath:xccurrentversionPath]) {
            NSDictionary *xccurrentversionPlist = [NSDictionary dictionaryWithContentsOfFile:xccurrentversionPath];
            NSString *currentModelName = [xccurrentversionPlist objectForKey:@"_XCCurrentVersionName"];
            if (currentModelName) {
                momOrXCDataModelFilePath = [momOrXCDataModelFilePath stringByAppendingPathComponent:currentModelName];
            }
        }
        else {
            // Freshly created models with only one version do NOT have a .xccurrentversion file, but only have one model
            // in them.  Use that model.
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self endswith %@", @".xcdatamodel"];
            NSArray *contents = [[fm contentsOfDirectoryAtPath:momOrXCDataModelFilePath error:nil]
                                 filteredArrayUsingPredicate:predicate];
            if (contents.count == 1) {
                momOrXCDataModelFilePath = [momOrXCDataModelFilePath stringByAppendingPathComponent:[contents lastObject]];
            }
        }
    }

    NSString* tempGeneratedMomFilePath = nil;
    NSString *momFilePath = nil;
    if ([[momOrXCDataModelFilePath pathExtension] isEqualToString:@"xcdatamodel"]) {
        //  We've been handed a .xcdatamodel data model, transparently compile it into a .mom managed object model.

        NSString *momcTool = nil;
        {{
            if (NO && [fm fileExistsAtPath:@"/usr/bin/xcrun"]) {
                // Cool, we can just use Xcode 3.2.6/4.x's xcrun command to find and execute momc for us.
                momcTool = @"/usr/bin/xcrun momc";
            } else {
                // Rats, don't have xcrun. Hunt around for momc in various places where various versions of Xcode stashed it.
                NSString *xcodeSelectMomcPath = [NSString stringWithFormat:@"%@/usr/bin/momc", [self xcodeSelectPrintPath]];

                if ([fm fileExistsAtPath:xcodeSelectMomcPath]) {
                    momcTool = [NSString stringWithFormat:@"\"%@\"", xcodeSelectMomcPath]; // Quote for safety.
                } else if ([fm fileExistsAtPath:@"/Applications/Xcode.app/Contents/Developer/usr/bin/momc"]) {
                    // Xcode 4.3 - Command Line Tools for Xcode
                    momcTool = @"/Applications/Xcode.app/Contents/Developer/usr/bin/momc";
                } else if ([fm fileExistsAtPath:@"/Developer/usr/bin/momc"]) {
                    // Xcode 3.1.
                    momcTool = @"/Developer/usr/bin/momc";
                } else if ([fm fileExistsAtPath:@"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"]) {
                    // Xcode 3.0.
                    momcTool = @"\"/Library/Application Support/Apple/Developer Tools/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc\"";
                } else if ([fm fileExistsAtPath:@"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc"]) {
                    // Xcode 2.4.
                    momcTool = @"/Developer/Library/Xcode/Plug-ins/XDCoreDataModel.xdplugin/Contents/Resources/momc";
                }
                assert(momcTool && "momc not found");
            }
        }}

        NSMutableString *momcOptions = [NSMutableString string];
        {{
            NSArray *supportedMomcOptions = [NSArray arrayWithObjects:
                                             @"MOMC_NO_WARNINGS",
                                             @"MOMC_NO_INVERSE_RELATIONSHIP_WARNINGS",
                                             @"MOMC_SUPPRESS_INVERSE_TRANSIENT_ERROR",
                                             nil];
            for (NSString *momcOption in supportedMomcOptions) {
                if ([[[NSProcessInfo processInfo] environment] objectForKey:momcOption]) {
                    [momcOptions appendFormat:@" -%@ ", momcOption];
                }
            }
        }}

        NSString *momcIncantation = nil;
        {{
            NSString *tempGeneratedMomFileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingPathExtension:@"mom"];
            tempGeneratedMomFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempGeneratedMomFileName];
            momcIncantation = [NSString stringWithFormat:@"%@ %@ \"%@\" \"%@\"",
                               momcTool,
                               momcOptions,
                               momOrXCDataModelFilePath,
                               tempGeneratedMomFilePath];
        }}

        {{
            system([momcIncantation UTF8String]); // Ignore system() result since momc sadly doesn't return any relevent error codes.
            momFilePath = tempGeneratedMomFilePath;
        }}
    } else {
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

- (NSDictionary*)infoForEntity:(NSEntityDescription*)entity
{
    __block NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    [entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, NSAttributeDescription* attribute, BOOL *stop) {
        NSString* className = attribute.attributeValueClassName;
        if (!className)
            className = attribute.userInfo[@"attributeValueClassName"];

        NSString* basicType;
        switch (attribute.attributeType)
        {
            case NSInteger16AttributeType:
                basicType = @"int16_t";
                break;

            case NSInteger32AttributeType:
                basicType = @"int32_t";
                break;

            case NSInteger64AttributeType:
                basicType = @"int64_t";
                break;

            case NSDecimalAttributeType:
                basicType = @"NSInteger";
                break;

            case NSDoubleAttributeType:
                basicType = @"double";
                break;

            case NSFloatAttributeType:
                basicType = @"float";
                break;

            case NSBooleanAttributeType:
                basicType = @"BOOL";
                break;

            default:
                basicType = nil;
        }

        NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:
        @{
          @"type" : basicType ? basicType : (className ? className : @"NSObject")
          }];

//        if (basicType)
//        {
//            info[@"basic"] = basicType;
//        }

        properties[attributeName] = info;
    }];

    __block NSMutableDictionary* relationships = [NSMutableDictionary dictionary];
    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString* relationshipName, NSRelationshipDescription* relationship, BOOL *stop) {
        NSString* className = relationship.destinationEntity.name;
        NSMutableDictionary* info = [NSMutableDictionary dictionaryWithDictionary:
        @{
          @"type" : className,
          @"minimum" : @(relationship.minCount),
          @"maximum" : @(relationship.maxCount)
          }];

        if ((relationship.minCount > 1) || (relationship.maxCount > 1))
        {
            info[@"toMany"] = @YES;
        }
        
        NSRelationshipDescription* inverse = relationship.inverseRelationship;
        if (inverse)
        {
            info[@"inverse"] = inverse.name;
        }

        relationships[relationshipName] = info;
    }];

    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithDictionary:
    @{
      @"properties" : properties,
      @"relationships" : relationships,
      }];

    NSString* superName = entity.superentity.name;
    if (superName)
    {
        NSString* superImport = [NSString stringWithFormat:@"%@.h", superName];
        result[@"super"] = @{@"class" : superName, @"import" : superImport };
    }

    return result;
}


- (NSDictionary*)infoForModel:(NSManagedObjectModel*)model
{
    __block NSMutableDictionary* classes = [NSMutableDictionary dictionary];
    [self enumerateEntitiesInModel:model block:^(BCComaMomConverter *converter, NSEntityDescription *entity) {
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
