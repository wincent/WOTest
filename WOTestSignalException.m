//
//  WOTestSignalException.m
//  WOTest
//
//  Created by Wincent Colaiuta on 22 October 2006.
//
//  Copyright 2006-2007 Wincent Colaiuta.
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  $Id: WOTestSignalException.m 208 2007-07-07 19:02:28Z wincent $

#import "WOTestSignalException.h"

@implementation WOTestSignalException

+ (WOTestSignalException *)exceptionWithSignal:(int)signal
{
    NSString *reason = [NSString stringWithFormat:
        @"a %@ signal was caught during execution: the most likely cause is a programming error in the software being tested; be "
        @"aware that the reliability of the most recent test and all subsequent tests may be adversely affected", 
        [self nameForSignal:signal]];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:signal], WOTestSignalExceptionSignalNumber, nil];
    
    return [[self alloc] initWithName:WOTestSignalExceptionName reason:reason userInfo:userInfo];
}

+ (NSString *)nameForSignal:(int)sig
{
    NSString *name = nil;
    switch (sig)
    {
        case SIGILL:    name = @"SIGILL";   break;
        case SIGTRAP:   name = @"SIGTRAP";  break;
        case SIGABRT:   name = @"SIGABRT";  break;
        case SIGEMT:    name = @"SIGEMT";   break;
        case SIGFPE:    name = @"SIGFPE";   break;
        case SIGBUS:    name = @"SIGBUS";   break;
        case SIGSEGV:   name = @"SIGSEGV";  break;
        case SIGSYS:    name = @"SIGSYS";   break;
        case SIGXCPU:   name = @"SIGXCPU";  break;
        case SIGXFSZ:   name = @"SIGXFSZ";  break;
        case SIGUSR1:   name = @"SIGUSR1";  break;
        case SIGUSR2:   name = @"SIGUSR2";  break;
        default:        name = @"UNKNOWN";
    }
    return name;
}

@end

__attribute__((used)) __attribute__((visibility("default"))) NSString *WOTestSignalExceptionName = @"WOTestSignalException";
__attribute__((used)) __attribute__((visibility("default")))
NSString *WOTestSignalExceptionSignalNumber = @"WOTestSignalExceptionSignalNumber";
