//
//  BCComaConvertCommand.m
//  Coma
//
//  Created by Sam Deane on 13/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaConvertCommand.h"

#import <Coma/Coma.h>

@interface BCComaConvertCommand()

@end

@implementation BCComaConvertCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
    ECCommandLineResult result = ECCommandLineResultOK;
    NSURL* modelURL = [NSURL fileURLWithPath:arguments[0]];

    NSURL* mergeURL = [NSURL fileURLWithPath:arguments[1]];
    NSError* error;
    NSData* mergeData = [[NSData alloc] initWithContentsOfURL:mergeURL options:0 error:&error];
    if (!mergeData)
    {
        [engine outputError:error format:@"Couldn't find template to merge into."];
        result = ECCommandLineResultImplementationReturnedError;
    }
    else
    {
        NSDictionary* modelDictionary = [NSJSONSerialization JSONObjectWithData:mergeData options:0 error:&error];
        if (!modelDictionary)
        {
            [engine outputError:error format:@"Couldn't parse template to merge into."];
            result = ECCommandLineResultImplementationReturnedError;
        }
        else
        {
            NSString* inputName = [modelURL lastPathComponent];
            NSString* name = [[inputName stringByDeletingPathExtension] stringByAppendingPathExtension:@"json"];
            NSURL* fileURL = nil;
            NSString* existing = nil;
            result = [self outputFileWithName:name engine:engine URL:&fileURL existing:&existing];

            if (result == ECCommandLineResultOK)
            {
                BCComaMomConverter* generator = [BCComaMomConverter new];
                NSDictionary* mergedDictionary = [generator mergeModelAtURL:modelURL into:modelDictionary error:&error];
                if (mergedDictionary)
                {
                    NSData* data = [NSJSONSerialization dataWithJSONObject:mergedDictionary options:NSJSONWritingPrettyPrinted error:&error];
                    if (data)
                    {
                        NSString* dataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        if ([existing isEqualToString:dataAsString])
                        {
                            [engine outputFormat:@"Converted %@ to %@ - Unchanged\n", inputName, name];
                        }
                        else if ([data writeToURL:fileURL options:NSDataWritingAtomic error:&error])
                        {
                            [engine outputFormat:@"Converted %@ to %@\n", inputName, name];
                        }
                        else
                        {
                            [engine outputError:error format:@"Failed to write %@", name];
                            result = ECCommandLineResultImplementationReturnedError;
                        }
                    }
                    else
                    {
                        [engine outputError:error format:@"Failed to generate JSON for %@", name];
                        result = ECCommandLineResultImplementationReturnedError;
                    }
                }
                else
                {
                    [engine outputError:error format:@"Failed to convert %@", inputName];
                    result = ECCommandLineResultImplementationReturnedError;
                }
            }
        }
    }
    
	return result;
}

@end
