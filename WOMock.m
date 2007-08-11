//
//  WOMock.m
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
#import "WOMock.h"

// system headers
#import <objc/objc-class.h>

// framework headers
#import "NSInvocation+WOTest.h"
#import "NSMethodSignature+WOTest.h"
#import "NSObject+WOTest.h"
#import "NSProxy+WOTest.h"
#import "NSValue+WOTest.h"
#import "WOClassMock.h"
#import "WOObjectMock.h"
#import "WOProtocolMock.h"

@implementation WOMock

#pragma mark -
#pragma mark Creation

+ (id)mockForObjectClass:(Class)aClass
{
    // avoid infinite loops if called by subclass
    if (self != [WOMock class])
        [NSException raise:NSInternalInconsistencyException format:@"mockForObjectClass: called from WOMock subclass"];

    return [WOObjectMock mockForClass:aClass];
}

+ (id)mockForClass:(Class)aClass
{
    // avoid infinite loops if called by subclass
    if (self != [WOMock class])
        [NSException raise:NSInternalInconsistencyException format:@"mockForClass: called from WOMock subclass"];

    return [WOClassMock mockForClass:aClass];
}

+ (id)mockForProtocol:(Protocol *)aProtocol
{
    // avoid infinite loops if called by subclass
    if (self != [WOMock class])
        [NSException raise:NSInternalInconsistencyException format:@"mockForProtocol: called from WOMock subclass"];

    return [WOProtocolMock mockForProtocol:aProtocol];
}

// a true Apple-style cluster would do this by allocating a placeholder object
- (id)initWithObjectClass:(Class)aClass
{
    // avoid infinite loops if called by subclass
    if ([self class] != [WOMock class])
        [NSException raise:NSInternalInconsistencyException format:@"initWithObjectClass: called from WOMock subclass"];

    return [[WOObjectMock allocWithZone:[self zone]] initWithClass:aClass];
}

// a true Apple-style cluster would do this by allocating a placeholder object
- (id)initWithClass:(Class)aClass
{
    // avoid infinite loops if called by subclass
    if ([self class] != [WOMock class])
        [NSException raise:NSInternalInconsistencyException format:@"initWithClass: called from WOMock subclass"];

    return [[WOClassMock allocWithZone:[self zone]] initWithClass:aClass];
}

// a true Apple-style cluster would do this by allocating a placeholder object
- (id)initWithProtocol:(Protocol *)aProtocol
{
    // avoid infinite loops if called by subclass
    if ([self class] != [WOMock class])
        [NSException raise:NSInternalInconsistencyException format:@"initWithProtocol: called from WOMock subclass"];

    return [[WOProtocolMock allocWithZone:[self zone]] initWithProtocol:aProtocol];
}

- (id)init
{
    // super (NSProxy) has no init method
    expectedInOrder     = [NSMutableArray array];               // there are no accessors (to avoid namespace pollution)
    accepted            = [NSMutableSet set];
    acceptedOnce        = [NSMutableSet set];
    expected            = [NSMutableSet set];
    expectedOnce        = [NSMutableSet set];
    rejected            = [NSMutableSet set];
    methodSignatures    = [NSMutableDictionary dictionary];
    return self;
}

// TODO: given that the time at which finalize is called is indeterminate consider coming up with some other mechanism for
// triggering verification
- (void)finalize
{
    [self verify];
    [super finalize];
}

- (id)accept
{
    [NSException raise:NSInternalInconsistencyException format:@"accept invoked on WOMock abstract class"];
    return nil;
}

- (id)acceptOnce
{
    [NSException raise:NSInternalInconsistencyException format:@"acceptOnce invoked on WOMock abstract class"];
    return nil;
}

- (id)reject
{
    [NSException raise:NSInternalInconsistencyException format:@"reject invoked on WOMock abstract class"];
    return nil;
}

- (id)expect
{
    [NSException raise:NSInternalInconsistencyException format:@"expect invoked on WOMock abstract class"];
    return nil;
}

- (id)expectOnce
{
    [NSException raise:NSInternalInconsistencyException format:@"expectOnce invoked on WOMock abstract class"];
    return nil;
}

- (id)expectInOrder
{
    [NSException raise:NSInternalInconsistencyException format:@"expectInOrder invoked on WOMock abstract class"];
    return nil;
}

- (void)clear
{
    [accepted           removeAllObjects];
    [acceptedOnce       removeAllObjects];
    [expected           removeAllObjects];
    [expectedOnce       removeAllObjects];
    [expectedInOrder    removeAllObjects];
    [rejected           removeAllObjects];
}

- (void)verify
{
    NSAssert(([expected count] == 0),           @"verification failure ('expected' set not empty)");
    NSAssert(([expectedOnce count] == 0),       @"verification failure ('expectedOnce' set not empty)");
    NSAssert(([expectedInOrder count] == 0),    @"verification failure ('expectedInOrder' set not empty)");
}

#pragma mark -
#pragma mark Utility methods

- (void)storeReturnValue:(NSValue *)aValue forInvocation:(NSInvocation *)invocation
{
    NSParameterAssert(invocation != nil);
    if (!aValue) return; // nothing to do
    const char *returnType = [[invocation methodSignature] methodReturnType];
    const char *storedType = [aValue objCType];
    NSAssert2((strcmp(returnType, storedType) == 0),
             @"Cannot store mismatched return type in invocation (%s, %s)", returnType, storedType);

    size_t bufferSize = [aValue WOTest_bufferSize];
    void *buffer = malloc(bufferSize);
    NSAssert1((buffer != NULL), @"malloc() failed (size %d)", bufferSize);
    [aValue getValue:buffer];
    [invocation setReturnValue:buffer];
}

- (void)setObjCTypes:(NSString *)types forSelector:(SEL)aSelector
{
    [methodSignatures setObject:[NSMethodSignature WOTest_signatureBasedOnObjCTypes:[types UTF8String]]
                         forKey:NSStringFromSelector(aSelector)];
}

#pragma mark -
#pragma mark NSProxy (private)

- forward:(SEL)sel :(marg_list)args
{
    // let standard event flow take place (but note that NSProxy implementation raises so subclasses must do the real work)
    if ([self methodSignatureForSelector:sel])
        return [super forward:sel :args];

    // fallback to internal lookup
    NSMethodSignature *signature = [methodSignatures objectForKey:NSStringFromSelector(sel)];

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

        // TODO: finish version in WOStub and copy it here
        // leave the compiler warnings about "unused variable 'type'" and "unused variable 'offset'" to remind me to do it
        // may be able to use libffi to help here

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
    [self forwardInvocation:forwardInvocation]; // stores return value in invocation

    unsigned bufferSize = [signature methodReturnLength];
    void *returnBuffer = malloc(bufferSize);
    NSAssert1((returnBuffer != NULL), @"malloc() failed (size %d)", bufferSize);
    [forwardInvocation getReturnValue:&returnBuffer];
    return returnBuffer; // TODO: cast according to the return type
}

#pragma mark -
#pragma mark Accessors

- (BOOL)acceptsByDefault
{
    return acceptsByDefault;
}

- (void)setAcceptsByDefault:(BOOL)flag
{
    acceptsByDefault = flag;
}

- (NSMutableDictionary *)methodSignatures
{
    return methodSignatures;
}

@end
