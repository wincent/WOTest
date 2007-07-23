//
//  NSInvocation+WOTest.m
//  WOTest
//
//  Created by Wincent Colaiuta on 30 January 2006.
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

#import "NSInvocation+WOTest.h"
#import "WOTest.h"

@implementation NSInvocation (WOTest)

- (BOOL)WOTest_isEqualToInvocation:(NSInvocation *)anInvocation
{
    // first do a basic comparison without arguments
    if (![self WOTest_isEqualToInvocationIgnoringArguments:anInvocation]) return NO;

    // compare arguments (skip first two: self and _cmd)
    NSMethodSignature *aSignature = [self methodSignature];
    NSMethodSignature *otherSignature = [anInvocation methodSignature];
    for (unsigned i = 2, max = [aSignature numberOfArguments]; i < max; i++)
    {
        const char *aType = [aSignature getArgumentTypeAtIndex:i];
        const char *otherType = [otherSignature getArgumentTypeAtIndex:i];
        if (strcmp(aType, otherType) != 0) return NO;

        // compare the two values
        return [[self WOTest_valueForArgumentAtIndex:i] isEqual:[anInvocation WOTest_valueForArgumentAtIndex:i]];
    }

    return YES; // if get this far, all equality tests passed (no arguments)
}

- (BOOL)WOTest_isEqualToInvocationIgnoringArguments:(NSInvocation *)anInvocation
{
    // basic checks: compare against nil and against self
    if (!anInvocation) return NO;
    if (anInvocation == self) return YES;

    // compare selectors
    if ([self selector] != [anInvocation selector]) return NO;

    // compare signatures
    NSMethodSignature *aSignature = [self methodSignature];
    NSMethodSignature *otherSignature = [anInvocation methodSignature];
    if (![aSignature isEqual:otherSignature]) return NO;

    return YES; // if get this far, all equality tests passed (no arguments)
}

- (NSValue *)WOTest_valueForArgumentAtIndex:(unsigned)index
{
    NSMethodSignature *methodSignature = [self methodSignature];
    NSParameterAssert(index < [methodSignature numberOfArguments]);
    const char *type = [methodSignature getArgumentTypeAtIndex:index];

    // no way to find out size needed for argument, so allocate enough for all
    size_t bufferSize = (size_t)[methodSignature frameLength];
    void *buffer = malloc(bufferSize);
    NSAssert1((buffer != NULL), @"malloc() failed (size %d)", bufferSize);
    [self getArgument:&buffer atIndex:index];
    NSValue *aValue = [NSValue value:&buffer withObjCType:type];

    // following line yields a runtime error:
    // malloc: ***  Deallocation of a pointer not malloced: 0x26a45c; This could be a double free(), or free() called with the middle of an allocated block; Try setting environment variable MallocHelp to see tools to help debug
    //free(buffer); // is NSValue freeing automatically?
    return aValue;
}

- (void)WOTest_setArgumentValue:(NSValue *)aValue atIndex:(unsigned)index
{
    NSMethodSignature *methodSignature = [self methodSignature];
    NSParameterAssert(index < [methodSignature numberOfArguments]);
    NSParameterAssert(aValue != nil);
    size_t bufferSize = [aValue WOTest_bufferSize];
    void *buffer = malloc(bufferSize);
    NSAssert1((buffer != NULL), @"malloc() failed (size %d)", bufferSize);
    [aValue getValue:buffer];
    [self setArgument:buffer atIndex:index];
    free(buffer);
}

@end
