//
//  WOTestLowLevelException.m
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

#import "WOTestLowLevelException.h"

@implementation WOTestLowLevelException

+ (WOTestLowLevelException *)exceptionWithType:(ExceptionKind)kind
{
    NSString *reason = [NSString stringWithFormat:
        @"a low-level exception (\"%@\") was caught during execution: the most likely cause is a programming error in the software "
        @"being tested; be aware that the reliability of the most recent test and all subsequent tests may be adversely affected",
        [self nameForType:kind]];

    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:kind], WOTestLowLevelExceptionKind, nil];

    return [[[self alloc] initWithName:WOTestLowLevelExceptionName reason:reason userInfo:userInfo] autorelease];
}

+ (NSString *)nameForType:(ExceptionKind)kind
{
    NSString *name = nil;
    switch (kind)
    {
        case kUnknownException:                 name = @"unknown exception"; break;
        case kIllegalInstructionException:      name = @"illegal instruction exception"; break;
        case kTrapException:                    name = @"trap exception"; break;
        case kAccessException:                  name = @"access exception exception"; break;
        case kUnmappedMemoryException:          name = @"unmapped memory exception"; break;
        case kExcludedMemoryException:          name = @"excluded memory exception"; break;
        case kReadOnlyMemoryException:          name = @"read only memory exception"; break;
        case kUnresolvablePageFaultException:   name = @"unresolvable page fault exception"; break;
        case kPrivilegeViolationException:      name = @"privilege violation exception"; break;
        case kTraceException:                   name = @"trace exception"; break;
        case kInstructionBreakpointException:   name = @"instruction breakpoint exception"; break;
        case kDataBreakpointException:          name = @"data breakpoint exception"; break;
        case kIntegerException:                 name = @"integer exception"; break;
        case kFloatingPointException:           name = @"floating point exception"; break;
        case kStackOverflowException:           name = @"stack overflow exception"; break;
        case kTaskTerminationException:         name = @"task termination exception"; break;
        case kTaskCreationException:            name = @"task creation exception"; break;
        case kDataAlignmentException:           name = @"data alignment exception"; break;
        default:                                name = @"UNKNOWN";
    }
    return name;
}

@end

__attribute__((used)) __attribute__((visibility("default"))) NSString *WOTestLowLevelExceptionName = @"WOTestLowLevelException";
__attribute__((used)) __attribute__((visibility("default"))) NSString *WOTestLowLevelExceptionKind = @"WOTestLowLevelExceptionKind";
