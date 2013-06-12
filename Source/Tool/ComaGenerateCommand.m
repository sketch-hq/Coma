//
//  ComaGenerateCommand.m
//  Coma
//
//  Created by Sam Deane on 12/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "ComaGenerateCommand.h"
#import <Coma/Coma.h>

@interface ComaGenerateCommand()

@end

@implementation ComaGenerateCommand

- (ECCommandLineResult)engine:(ECCommandLineEngine*)engine didProcessWithArguments:(NSMutableArray *)arguments
{
    NSURL* inputURL = [NSURL fileURLWithPath:arguments[0]];
    NSURL* templatesURL = [NSURL fileURLWithPath:arguments[1]];

    BOOL overwriting = [[engine optionForKey:@"overwriting"] boolValue];
    NSString* outputOption = [[engine optionForKey:@"output"] stringByStandardizingPath];
    NSURL* outputURL = [NSURL fileURLWithPath:outputOption ? outputOption : [@"./" stringByStandardizingPath]];
    BCComaEngine* generator = [BCComaEngine new];

    NSFileManager* fm = [NSFileManager defaultManager];
    
    __block ECCommandLineResult result = ECCommandLineResultOK;
    [generator generateModelAtURL:inputURL withTemplatesAtURL:templatesURL outputBlock:^(NSString *name, NSString *output, NSError* error) {

        if (output)
        {
            NSURL* fileURL = [outputURL URLByAppendingPathComponent:name];
            BOOL fileExists = [fm fileExistsAtPath:[outputURL path]];
            BOOL okToWrite = overwriting || !fileExists;
            if (okToWrite && [output writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:&error])
            {
                [engine outputFormat:@"Generated %@\n", name];
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
            [engine outputError:error format:@"Failed to generate %@", name];
            result = ECCommandLineResultImplementationReturnedError;
        }
    }];

	return result;
}

@end
