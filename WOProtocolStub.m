//
//  WOProtocolStub.m
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
#import "WOProtocolStub.h"

// system headers

#import <objc/Protocol.h>

// framework headers

#import "NSInvocation+WOTest.h"
#import "NSObject+WOTest.h"
#import "WOProtocolMock.h"  /* for WOStringFromProtocol() */

@implementation WOProtocolStub

#pragma mark -
#pragma mark Creation

/*! Factory method. */
+ (id)stubForProtocol:(Protocol *)aProtocol withDelegate:(id)aDelegate
{
    NSParameterAssert(aProtocol != NULL);
    return [[self alloc] initWithProtocol:aProtocol delegate:aDelegate];
}

/*! Designated initializer. */
- (id)initWithProtocol:(Protocol *)aProtocol delegate:(id)aDelegate
{
    NSParameterAssert(aProtocol != NULL);
    if ((self = [super init]))
    {
        mockedProtocol  = aProtocol;
        delegate        = aDelegate;
    }
    return self;
}

#pragma mark -
#pragma mark NSProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // avoid an infinite loop (docs warn "Be sure to avoid an infinite loop when necessary by checking that aSelector isn't the
    // selector for this method itself and by not sending any message that might invoke this method.")
    if (aSelector == _cmd) return nil;

    Protocol *protocol = [self mockedProtocol];
    BOOL isRequiredMethod = YES;    // no idea what to pass here
    struct objc_method_description description = protocol_getMethodDescription(protocol, aSelector, isRequiredMethod, YES);

    // TODO: not sure how to test for missing method signatures... protocol_getMethodDescription() is not documented
    if (description.name == NULL)
        [NSException raise:NSInternalInconsistencyException format:@"No method signature for selector %@ in %@ protocol",
            NSStringFromSelector(aSelector), WOStringFromProtocol(protocol)];
    return [NSMethodSignature signatureWithObjCTypes:description.types];
}

#pragma mark -
#pragma mark NSObject protocol

- (BOOL)isEqual:(id)anObject
{
    if (anObject == self) return YES;
    @try
    {
        if ([NSObject WOTest_object:anObject isKindOfClass:[self class]])
        {
            BOOL            invocationsAreEqual     = NO;
            BOOL            returnValuesAreEqual    = NO;
            BOOL            exceptionsAreEqual      = NO;
            NSInvocation    *thisInvocation         = [self invocation];
            NSInvocation    *otherInvocation        = [anObject invocation];
            NSValue         *thisValue              = [self returnValue];
            NSValue         *otherValue             = [anObject returnValue];
            id              thisException           = [self exception];
            id              otherException          = [anObject exception];

            if ([self mockedProtocol] != [anObject mockedProtocol])
                return NO;

            if ([self acceptsAnyArguments] != [anObject acceptsAnyArguments])
                return NO;

            if (!thisInvocation && !otherInvocation) // both nil
                invocationsAreEqual = YES;
            else if (thisInvocation && otherInvocation) // both non-nil
            {
                if ([self acceptsAnyArguments])
                    invocationsAreEqual = [thisInvocation WOTest_isEqualToInvocationIgnoringArguments:otherInvocation];
                else
                    invocationsAreEqual = [thisInvocation WOTest_isEqualToInvocation:otherInvocation];
            }

            if (!thisValue && !otherValue) // both nil
                returnValuesAreEqual = YES;
            else if (thisValue && otherValue) // both non-nil
                returnValuesAreEqual = [thisValue isEqual:otherValue];

            if (!thisException && !otherException) // both nil
                exceptionsAreEqual = YES;
            else if (thisException && otherException) // both non-nil
                exceptionsAreEqual = [thisException isEqual:otherException];

            if (invocationsAreEqual && returnValuesAreEqual &&
                exceptionsAreEqual)
                return YES;
        }
    }
    @catch (id e) {}
    return NO;
}

- (unsigned)hash
{
    // hash must not rely on the object's internal state information (see docs)
    // hash must not change while in a collection
    return (unsigned)mockedProtocol;
}

#pragma mark -
#pragma mark Accessors

- (Protocol *)mockedProtocol
{
    return mockedProtocol;
}

@end
