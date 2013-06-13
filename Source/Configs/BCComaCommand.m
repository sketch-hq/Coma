//
//  BCComaCommand.m
//  Coma
//
//  Created by Sam Deane on 13/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import "BCComaCommand.h"

@implementation BCComaCommand

- (ECCommandLineResult)outputFileWithName:(NSString*)name engine:(ECCommandLineEngine*)engine URL:(NSURL**)url
{
    ECAssertNonNil(url);

    ECCommandLineResult result;
    BOOL overwriting = [[engine optionForKey:@"overwriting"] boolValue];
    NSString* outputOption = [[engine optionForKey:@"output"] stringByStandardizingPath];
    NSURL* outputURL = [NSURL fileURLWithPath:outputOption ? outputOption : [@"./" stringByStandardizingPath]];
    NSFileManager* fm = [NSFileManager defaultManager];

    NSURL* fileURL = [outputURL URLByAppendingPathComponent:name];
    BOOL fileExists = [fm fileExistsAtPath:[fileURL path]];
    BOOL okToWrite = overwriting || !fileExists;
    if (okToWrite)
    {
        result = ECCommandLineResultOK;
        if (url)
            *url = fileURL;
    }
    else
    {
        NSError* error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteFileExistsError userInfo:@{}];
        [engine outputError:error format:@"Could not overwrite %@ -- file already exists. Use option --overwriting to force overwriting.", name];
        result = ECCommandLineResultImplementationReturnedError;
    }

    return result;
}
@end
