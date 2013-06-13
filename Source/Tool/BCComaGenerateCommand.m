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

	return result;
}

@end
