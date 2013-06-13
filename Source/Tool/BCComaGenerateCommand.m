//
//  ComaGenerateCommand.m
//  Coma
//
//  Created by Sam Deane on 12/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaGenerateCommand.h"
#import <Coma/Coma.h>

@interface BCComaGenerateCommand()

@end

@implementation BCComaGenerateCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
    __block ECCommandLineResult result = ECCommandLineResultOK;

    NSURL* inputURL = [NSURL fileURLWithPath:arguments[0]];
    NSURL* templatesURL = [NSURL fileURLWithPath:arguments[1]];

    if ([[inputURL pathExtension] isEqualToString:@"xcdatamodeld"])
    {
        NSURL* converted = [self convertToTemporaryFileFromCoreDataModel:inputURL];
        if (!converted)
        {
            [engine outputError:nil format:@"Failed to convert %@", [inputURL lastPathComponent]];
            result = ECCommandLineResultImplementationReturnedError;
        }
        else
        {
            inputURL = converted;
        }
    }

    if (result == ECCommandLineResultOK)
    {
        BCComaEngine* generator = [BCComaEngine new];
        [generator generateModelAtURL:inputURL withTemplatesAtURL:templatesURL outputBlock:^(NSString *name, NSString *output, NSError* error) {

            if (output)
            {
                NSURL* fileURL = nil;
                result = [self outputFileWithName:name engine:engine URL:&fileURL];
                if (result == ECCommandLineResultOK)
                {
                    if ([output writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error])
                    {
                        [engine outputFormat:@"Generated %@\n", name];
                    }
                    else
                    {
                        [engine outputError:error format:@"Failed to write %@", name];
                        result = ECCommandLineResultImplementationReturnedError;
                    }
                }
            }

            else
            {
                [engine outputError:error format:@"Failed to generate %@", name];
                result = ECCommandLineResultImplementationReturnedError;
            }
        }];
    }

	return result;
}

- (NSURL*)convertToTemporaryFileFromCoreDataModel:(NSURL*)inputURL
{
    // we've been given a model - try to convert it
    NSError* error;
    NSURL* result = nil;
    NSString* name = [[inputURL lastPathComponent] stringByDeletingPathExtension];
    NSURL* baseURL = [[[inputURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@Base", name]] URLByAppendingPathExtension:@"json"];
    NSData* baseData = [[NSData alloc] initWithContentsOfURL:baseURL options:0 error:&error];
    if (baseData)
    {
        NSDictionary* baseDictionary = [NSJSONSerialization JSONObjectWithData:baseData options:0 error:&error];
        if (baseDictionary)
        {
            BCComaMomConverter* generator = [BCComaMomConverter new];
            NSDictionary* mergedDictionary = [generator mergeModelAtURL:inputURL into:baseDictionary error:&error];
            if (mergedDictionary)
            {
                //                NSURL* tempURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"ComaTemp.json"];
                NSURL* tempURL = [inputURL URLByAppendingPathExtension:@"json"];
                NSData* tempData = [NSJSONSerialization dataWithJSONObject:mergedDictionary options:NSJSONWritingPrettyPrinted error:&error];
                if ([tempData writeToURL:tempURL atomically:YES])
                {
                    result = tempURL;
                }
            }
        }
    }

    return result;
}

@end
