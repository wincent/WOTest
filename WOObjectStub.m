//
//  WOObjectStub.m
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
#import "WOObjectStub.h"

// framework headers

#import "NSInvocation+WOTest.h"
#import "NSObject+WOTest.h"

@implementation WOObjectStub

#pragma mark -
#pragma mark Creation

+ (id)stubForClass:(Class)aClass withDelegate:(id)aDelegate
{
    NSParameterAssert(aClass != NULL);
    return [[[self alloc] initWithClass:aClass delegate:aDelegate] autorelease];
}

- (id)initWithClass:(Class)aClass delegate:(id)aDelegate
{
    NSParameterAssert(aClass != NULL);
    if ((self = [super init]))
    {
        mockedClass = aClass;
        delegate    = aDelegate;
    }
    return self;
}

#pragma mark -
#pragma mark NSProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // avoid an infinite loop (docs warn "Be sure to avoid an infinite loop when necessary by checking that aSelector isn't the 
    // selector for this method itself and by not sending any message that might invoke this method.")
    if (([self mockedClass] == [self class]) && (aSelector == _cmd)) return nil;
    
    // see if method really exists in mocked class, if not forward:: will have to do something special
    return [[self mockedClass] instanceMethodSignatureForSelector:aSelector];
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
            
            if ([self mockedClass] != [anObject mockedClass])
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
    return (unsigned)mockedClass;
}

#pragma mark -
#pragma mark Accessors

- (Class)mockedClass
{
    return mockedClass;
}

@end
