//
//  WOProtocolMock.m
//  WOTest
//
//  Created by Wincent Colaiuta on 28 January 2007.
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

#import "WOProtocolMock.h"

// system headers

#import <objc/Protocol.h>

// framework headers

#import "NSInvocation+WOTest.h"
#import "WOProtocolStub.h"

#pragma mark -
#pragma mark C function implementations

NSString *WOStringFromProtocol(Protocol *aProtocol)
{
    if (aProtocol == NULL) return nil;
    return [NSString stringWithUTF8String:protocol_getName(aProtocol)];
}

@implementation WOProtocolMock

#pragma mark -
#pragma mark Creation

+ (id)mockForProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aProtocol != NULL);
    return [[self alloc] initWithProtocol:aProtocol];
}

- (id)initWithProtocol:(Protocol *)aProtocol
{
    NSParameterAssert(aProtocol != NULL);

    // TODO: test for validity of the Protocol by checking with the runtime

    if ((self = [super init]))
        [self setMockedProtocol:aProtocol];
    return self;
}

#pragma mark -
#pragma mark Recording

- (id)accept
{
    WOProtocolStub *stub = [WOProtocolStub stubForProtocol:[self mockedProtocol] withDelegate:self];
    [accepted addObject:stub];
    return stub;
}

- (id)acceptOnce
{
    WOProtocolStub *stub = [WOProtocolStub stubForProtocol:[self mockedProtocol] withDelegate:self];
    [acceptedOnce addObject:stub];
    return stub;
}

- (id)reject
{
    WOProtocolStub *stub = [WOProtocolStub stubForProtocol:[self mockedProtocol] withDelegate:self];
    [rejected addObject:stub];
    return stub;
}

- (id)expect
{
    WOProtocolStub *stub = [WOProtocolStub stubForProtocol:[self mockedProtocol] withDelegate:self];
    [expected addObject:stub];
    return stub;
}

- (id)expectOnce
{
    WOProtocolStub *stub = [WOProtocolStub stubForProtocol:[self mockedProtocol] withDelegate:self];
    [expectedOnce addObject:stub];
    return stub;
}

- (id)expectInOrder
{
    WOProtocolStub *stub = [WOProtocolStub stubForProtocol:[self mockedProtocol] withDelegate:self];
    [expectedInOrder addObject:stub];
    return stub;
}

#pragma mark -
#pragma mark Proxy methods

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSParameterAssert(anInvocation != nil);

    // check if in reject list
    for (WOStub *stub in rejected)
        if ([anInvocation WOTest_isEqualToInvocation:[stub recordedInvocation]])
        {
            [NSException raise:NSInternalInconsistencyException format:@"Rejected selector %@ for protocol %@",
                NSStringFromSelector([anInvocation selector]), WOStringFromProtocol([self mockedProtocol])];
            return;
        }

    // check if expectedInOrder
    for (WOStub *stub in expectedInOrder)
        if ([anInvocation WOTest_isEqualToInvocation:[stub recordedInvocation]])
        {
            NSAssert(([expectedInOrder objectAtIndex:0] != stub), @"invocation received out of order");

            // if in order, remove from head of list
            [expectedInOrder removeObjectAtIndex:0];

            // and move to "accepted"
            [accepted addObject:stub];
            [self storeReturnValue:[stub returnValue] forInvocation:anInvocation];
            if ([stub exception]) @throw [stub exception];
            return;
        }

    // check if expected once
    for (WOStub *stub in expectedOnce)
        if ([anInvocation WOTest_isEqualToInvocation:[stub recordedInvocation]])
        {
            // move object from "expectedOnce" to "rejected"
            [rejected addObject:stub];
            [expectedOnce removeObject:stub];
            [self storeReturnValue:[stub returnValue] forInvocation:anInvocation];
            if ([stub exception]) @throw [stub exception];
            return;
        }

    // check if expected
    for (WOStub *stub in expected)
        if ([anInvocation WOTest_isEqualToInvocation:[stub recordedInvocation]])
        {
            // move from "expected" to "accepted"
            [accepted addObject:stub];
            [expected removeObject:stub];
            [self storeReturnValue:[stub returnValue] forInvocation:anInvocation];
            if ([stub exception]) @throw [stub exception];
            return;
        }

    // check if accepted once
    for (WOStub *stub in acceptedOnce)
        if ([anInvocation WOTest_isEqualToInvocation:[stub recordedInvocation]])
        {
            // move from "acceptedOnce" to "rejected"
            [rejected addObject:stub];
            [acceptedOnce removeObject:stub];
            [self storeReturnValue:[stub returnValue] forInvocation:anInvocation];
            if ([stub exception]) @throw [stub exception];
            return;
        }

    // check if accepted
    for (WOStub *stub in accepted)
        if ([anInvocation WOTest_isEqualToInvocation:[stub recordedInvocation]])
        {
            [self storeReturnValue:[stub returnValue] forInvocation:anInvocation];
            if ([stub exception]) @throw [stub exception];
            return;
        }


    if ([self acceptsByDefault]) return;

    // no matches! (should never get here)
    [NSException raise:NSInternalInconsistencyException format:@"No matching invocations found (selector %@, protocol %@)",
        NSStringFromSelector([anInvocation selector]), WOStringFromProtocol([self mockedProtocol])];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // avoid an infinite loop (docs warn "Be sure to avoid an infinite loop when necessary by checking that aSelector isn't the
    // selector for this method itself and by not sending any message that might invoke this method.")
    if (aSelector == _cmd) return nil;

    BOOL isRequiredMethod = YES;    // no idea what to pass here
    struct objc_method_description description = protocol_getMethodDescription([self mockedProtocol], aSelector, isRequiredMethod, YES);
    return [NSMethodSignature signatureWithObjCTypes:description.types];
}

#pragma mark -
#pragma mark Accessors

- (Protocol *)mockedProtocol
{
    return mockedProtocol;
}

- (void)setMockedProtocol:(Protocol *)aMockedProtocol
{
    mockedProtocol = aMockedProtocol;
}

@end
