//
//  WOStub.m
//  WOTest
//
//  Created by Wincent Colaiuta on 14 June 2005.
//
//  Copyright 2005-2007 Wincent Colaiuta.
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

// class header
#import "WOStub.h"

// system headers
#import <objc/objc-class.h>

// framework headers
#import "NSInvocation+WOTest.h"
#import "NSObject+WOTest.h"
#import "NSProxy+WOTest.h"
#import "NSValue+WOTest.h"
#import "WOMock.h"

@implementation WOStub

- (id)init
{
    return self; // super (NSProxy) has no init method
}

- (id)anyArguments
{
    [self setAcceptsAnyArguments:YES];
    return self;
}

#pragma mark -
#pragma mark Recording

- (id)returning:(NSValue *)aValue
{
    NSAssert(([self returnValue] == nil), @"WOStub returning: invoked but return value already recorded");
    [self setReturnValue:aValue];
    return self;
}

- (id)raising:(id)anException
{
    NSAssert(([self exception] == nil), @"WOStub raising: invoked but exception already recorded");
    [self setException:anException];
    return self;
}

#pragma mark -
#pragma mark Testing equality

- (BOOL)matchesInvocation:(NSInvocation *)anInvocation
{
    NSParameterAssert(anInvocation != nil);
    NSInvocation *recordedInvocation = [self invocation];
    NSAssert((recordedInvocation != nil), @"WOStub sent matchesInvocation but no invocation yet recorded");
    return ([anInvocation WOTest_isEqualToInvocation:recordedInvocation] ||
            ([self acceptsAnyArguments] && [anInvocation WOTest_isEqualToInvocationIgnoringArguments:recordedInvocation]));
}

#pragma mark -
#pragma mark Proxy methods

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSAssert(([self invocation] == nil), @"WOStub sent message but message previously recorded");
    [self setInvocation:anInvocation];
    [anInvocation retainArguments];
}

/*

 http://lists.apple.com/archives/cocoa-dev/2004/Jun/msg00990.html

 "On PPC, the prearg area is used to store the 13 floating-point parameter registers, which may contain method parameters that need to be restored when the marg_list is used. The i386 function call ABI has no additional registers to be saved, so its prearg area is empty. The implementations of _objc_msgForward() and objc_msgSendv() in objc4's objc-msg-ppc.s contain more details that may be useful to you.

 In general, you probably want to avoid marg_list and objc_msgSendv(). Together they are primarily an implementation detail of forward:: ."

 (Greg Parker, Apple)

 */

- forward:(SEL)sel :(marg_list)args
{
    NSAssert(([self invocation] == nil), @"WOStub sent message but message previously recorded");

    // let standard event flow take place (but note that NSProxy implementation raises so subclasses must do the real work)
    if ([self methodSignatureForSelector:sel])
      return [super forward:sel :args];

    // fallback to internal lookup
    NSMethodSignature *signature = [[delegate methodSignatures] objectForKey:NSStringFromSelector(sel)];

    // at this point it would be great to be able to improvise but it's not possible to figure out an accurate method signature
    NSAssert((signature != nil), ([NSString stringWithFormat:@"no method signature for selector %@", NSStringFromSelector(sel)]));

    NSInvocation *forwardInvocation = [NSInvocation invocationWithMethodSignature:signature];
    [forwardInvocation setSelector:sel];


    // store arguments in invocation
    int offset = 0;
    for (unsigned i = 0, max = [signature numberOfArguments]; i < max; i++)
    {
        const char *type = [signature getArgumentTypeAtIndex:i];    // always id, SEL, ...

#if defined(__ppc__)

        // TODO: finish this implementation and copy it (or otherwise make it available) to WOMock.m
        // leave the compiler warnings about "unused variable 'type'" and "unused variable 'offset'" to remind me to do it

        // the PPC ABI has special conventions for floats, doubles, structs

        // contents of floating point registers f1 through f13 stored at args + 0 through args + 96
        // register based params go in r3 (receiver id), r4 (SEL), and r5 through r10
        // these params are respectively at:
        // 1st param: r3 (receiver id) args + (13 * 8) + 24 (24 bytes in the linkage area not sure what it's for)
        // 2nd param: r4 (SEL) args + (13 * 8) + 28
        // 3rd param: r5 args + (13 * 8) + 32
        // 4th param: r6 args + (13 * 8) + 36
        // 5th param: r7 args + (13 * 8) + 40
        // 6th param: r8 args + (13 * 8) + 44
        // 7th param: r9 args + (13 * 8) + 48
        // 8th param: r10 args + (13 * 8) + 52
        // the remaining parameters are on the stack (starting at args + (13 * 8) + 56)
        // note that marg_prearg_size is defined in the headers for ppc and equals 128 (13 * 8 + 24 bytes for linkage area)

        // from http://darwinsource.opendarwin.org/10.4.3/objc4-267/runtime/Messengers.subproj/objc-msg-ppc.s
//        typedef struct objc_sendv_margs {
//            double    floatingPointArgs[13];
//            int       linkageArea[6];
//            int       registerArgs[8];
//            int       stackArgs[variable];
//        };
//
//        if (strcmp(type, @encode(float)) == 0)
//        {}
//        else if (strcmp(type, @encode(double)) == 0)
//        {}
//        else

#elif defined(__i386__)

        // on i386 the marg_getRef macro and its helper, marg_adjustedOffset, should work fine
        if (strcmp(type, @encode(id)) == 0)
        {
            id *ref = marg_getRef(args, offset, id);
            [forwardInvocation WOTest_setArgumentValue:[NSValue valueWithBytes:ref objCType:type] atIndex:i];
        }
        else if (strcmp(type, @encode(SEL)) == 0)
        {
            SEL *ref = marg_getRef(args, offset, SEL);
            [forwardInvocation WOTest_setArgumentValue:[NSValue valueWithBytes:ref objCType:type] atIndex:i];
        }
        else
            [NSException raise:NSGenericException format:@"type %s not supported", type];

        offset += [NSValue WOTest_sizeForType:[NSString stringWithUTF8String:type]];

#elif defined(__ppc64__)
        // there is no objc-msg-ppc.s so for now just omit support rather than make assumptions
#error ppc64 not supported yet

#else

#error Unsupported architecture

#endif

    }
    [self forwardInvocation:forwardInvocation];
    return nil; // nobody cares what a stub returns
}

#pragma mark -
#pragma mark Accessors

- (NSInvocation *)recordedInvocation
{
    NSInvocation *recordedInvocation = [self invocation];
    NSAssert((recordedInvocation != nil), @"WOStub sent recordedInvocation but no invocation yet recorded");
    return recordedInvocation;
}

@synthesize invocation;
@synthesize returnValue;
@synthesize acceptsAnyArguments;
@synthesize exception;

@end
