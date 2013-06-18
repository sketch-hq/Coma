//
//  BCComaCommand.h
//  Coma
//
//  Created by Sam Deane on 13/06/2013.
//  Copyright (c) 2013 Bohemian Coding. All rights reserved.
//

#import <ECCommandLine/ECCommandLine.h>

@interface BCComaCommand : ECCommandLineCommand

- (ECCommandLineResult)outputFileWithName:(NSString*)name engine:(ECCommandLineEngine*)engine URL:(NSURL**)url existing:(NSString**)existing;

@end
