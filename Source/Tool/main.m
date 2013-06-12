//
//  main.m
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Coma/Coma.h>
#import <ECCommandLine/ECCommandLine.h>

int main(int argc, const char * argv[])
{
    int result;
    @autoreleasepool {

        result = ECCommandLineMain(argc, argv);

    }

    return result;
}

