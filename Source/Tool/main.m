//
//  main.m
//  Coma
//
//  Created by Sam Deane on 06/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Coma/Coma.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        BCComaEngine* engine = [BCComaEngine new];
        [engine doStuff];

        // insert code here...
        NSLog(@"Hello, World!");
        
    }
    return 0;
}

