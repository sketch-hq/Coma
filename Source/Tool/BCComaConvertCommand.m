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
        if (modelDictionary)
        {
            [engine outputError:error format:@"Couldn't parse template to merge into."];
            result = ECCommandLineResultImplementationReturnedError;
        }
        else
        {
            BOOL overwriting = [[engine optionForKey:@"overwriting"] boolValue];
            NSString* outputOption = [[engine optionForKey:@"output"] stringByStandardizingPath];
            NSURL* outputURL = [NSURL fileURLWithPath:outputOption ? outputOption : [@"./" stringByStandardizingPath]];
            BCComaMomConverter* generator = [BCComaMomConverter new];

            NSFileManager* fm = [NSFileManager defaultManager];
            NSString* name = [modelURL lastPathComponent];

            NSDictionary* mergedDictionary = [generator mergeModelAtURL:modelURL into:modelDictionary error:&error];
            if (mergedDictionary)
            {
                NSData* data = [NSJSONSerialization dataWithJSONObject:mergedDictionary options:NSJSONWritingPrettyPrinted error:&error];
                if (data)
                {
                    NSURL* fileURL = [outputURL URLByAppendingPathComponent:name];
                    BOOL fileExists = [fm fileExistsAtPath:[outputURL path]];
                    BOOL okToWrite = overwriting || !fileExists;
                    if (okToWrite && [data writeToURL:fileURL options:NSDataWritingAtomic error:&error])
                    {
                        [engine outputFormat:@"Converted %@\n", name];
                    }
                    else if (!okToWrite)
                    {
                        [engine outputError:error format:@"Could not overwrite %@ -- file already exists. Use option --overwrite to force overwriting.", name];
                        result = ECCommandLineResultImplementationReturnedError;
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
                [engine outputError:error format:@"Failed to convert %@", name];
                result = ECCommandLineResultImplementationReturnedError;
            }
        }
    }
    
	return result;
}

@end
