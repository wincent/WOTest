//
//  WOObjectMock.m
//  WOTest
//
//  Created by Wincent Colaiuta on 10 February 2006.
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

// class header
#import "WOObjectMock.h"

// framework headers
#import "NSInvocation+WOTest.h"
#import "NSObject+WOTest.h"
#import "WOObjectStub.h"

@implementation WOObjectMock

#pragma mark -
#pragma mark Creation

+ (id)mockForClass:(Class)aClass
{
    NSParameterAssert(aClass != NULL);
    NSParameterAssert([NSObject WOTest_isRegisteredClass:aClass]);     // only registered classes pass (do not pass meta classes)
    return [[self alloc] initWithClass:aClass];
}

- (id)initWithClass:(Class)aClass
{
    NSParameterAssert(aClass != NULL);
    NSParameterAssert([NSObject WOTest_isRegisteredClass:aClass]);     // only registered classes pass (do not pass meta classes)

    if ((self = [super init]))
        [self setMockedClass:aClass];
    return self;
}

#pragma mark -
#pragma mark Recording

- (id)accept
{
    WOObjectStub *stub = [WOObjectStub stubForClass:[self mockedClass] withDelegate:self];
    [accepted addObject:stub];
    return stub;
}

- (id)acceptOnce
{
    WOObjectStub *stub = [WOObjectStub stubForClass:[self mockedClass] withDelegate:self];
    [acceptedOnce addObject:stub];
    return stub;
}

- (id)reject
{
    WOObjectStub *stub = [WOObjectStub stubForClass:[self mockedClass] withDelegate:self];
    [rejected addObject:stub];
    return stub;
}

- (id)expect
{
    WOObjectStub *stub = [WOObjectStub stubForClass:[self mockedClass] withDelegate:self];
    [expected addObject:stub];
    return stub;
}

- (id)expectOnce
{
    WOObjectStub *stub = [WOObjectStub stubForClass:[self mockedClass] withDelegate:self];
    [expectedOnce addObject:stub];
    return stub;
}

- (id)expectInOrder
{
    WOObjectStub *stub = [WOObjectStub stubForClass:[self mockedClass] withDelegate:self];
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
        if ([stub matchesInvocation:anInvocation])
        {
            [NSException raise:NSInternalInconsistencyException format:@"Rejected selector %@ for class %@",
                NSStringFromSelector([anInvocation selector]), NSStringFromClass([self mockedClass])];
            return;
        }

    // check if expectedInOrder
    for (WOStub *stub in expectedInOrder)
        if ([stub matchesInvocation:anInvocation])
        {
            NSAssert2(([expectedInOrder objectAtIndex:0] == stub), @"Invocation selector %@ class %@ received out of order",
                      NSStringFromSelector([anInvocation selector]), NSStringFromClass([self mockedClass]));

            [expectedInOrder removeObjectAtIndex:0];    // if in order, remove from head of list

            // and move to "accepted"
            [accepted addObject:stub];
            [self storeReturnValue:[stub returnValue] forInvocation:anInvocation];
            if ([stub exception]) @throw [stub exception];
            return;
        }

    // check if expected once
    for (WOStub *stub in expectedOnce)
        if ([stub matchesInvocation:anInvocation])
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
        if ([stub matchesInvocation:anInvocation])
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
        if ([stub matchesInvocation:anInvocation])
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
        if ([stub matchesInvocation:anInvocation])
        {
            [self storeReturnValue:[stub returnValue] forInvocation:anInvocation];
            if ([stub exception]) @throw [stub exception];
            return;
        }

    if ([self acceptsByDefault]) return;

    // no matches! (should never get here)
    [NSException raise:NSInternalInconsistencyException format:@"No matching invocations found (selector %@, class %@)",
        NSStringFromSelector([anInvocation selector]), NSStringFromClass([self mockedClass])];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // avoid an infinite loop (docs warn "Be sure to avoid an infinite loop when necessary by checking that aSelector isn't the
    // selector for this method itself and by not sending any message that might invoke this method.")
    if (([self mockedClass] == [self class]) && (aSelector == _cmd)) return nil;

    // search only for instance methods here; forcing the programmer to use WOClassMock for searching for class methods avoids
    // ambiguity in cases where an instance method and a class method share the same name
    return [[self mockedClass] instanceMethodSignatureForSelector:aSelector];
}

#pragma mark -
#pragma mark Accessors

- (Class)mockedClass
{
    return mockedClass;
}

- (void)setMockedClass:(Class)aMockedClass
{
    mockedClass = aMockedClass;
}

@end
