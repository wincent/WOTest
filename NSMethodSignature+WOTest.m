//
//  NSMethodSignature+WOTest.m
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

#import "NSMethodSignature+WOTest.h"
#import <objc/objc-class.h>

/*

 The real 10.4 NSMethodSignature API (obtained using class-dump; TODO: run class-dump to get 10.5 API):

@interface NSMethodSignature : NSObject
{
    char *_types;
    int _nargs;
    unsigned int _sizeofParams;
    unsigned int _returnValueLength;
    void *_parmInfoP;
    int *_fixup;
    void *_reserved;
}

+ (id)signatureWithObjCTypes:(const char *)fp8;
- (BOOL)_isReturnStructInRegisters;
- (id)retain;
- (void)release;
- (unsigned int)retainCount;
- (const char *)methodReturnType;  // PUBLIC
- (unsigned int)methodReturnLength; // PUBLIC
- (BOOL)isOneway; // PUBLIC
- (const char *)getArgumentTypeAtIndex:(unsigned int)fp8; // PUBLIC
- (struct _arginfo)_argumentInfoAtIndex:(unsigned int)fp8;
- (unsigned int)frameLength; // PUBLIC
- (unsigned int)numberOfArguments; // PUBLIC
- (id)description;
- (id)debugDescription;

@end

The public API:

@interface NSMethodSignature : NSObject {
    @private
    const char  *_types;
    int         _nargs;
    unsigned    _sizeofParams;
    unsigned    _returnValueLength;
    void        *_parmInfoP;
    int         *_fixup;
    void        *_reserved;
}

- (unsigned)numberOfArguments;
- (const char *)getArgumentTypeAtIndex:(unsigned)index;
- (unsigned)frameLength;
- (BOOL)isOneway;
- (const char *)methodReturnType;
- (unsigned)methodReturnLength;

@end

Many public implementations of that use NSProxy subclasses to implement trampolines make use of the signatureWithObjCTypes: private API.

Examples: OCMock
http://www.cocoadev.com/index.pl?LSTrampoline
http://www.cocoadev.com/index.pl?BSTrampoline

See also http://www.stuffonfire.com/2005/12/signaturewithobjctypes_is_stil.html

 */

@interface NSMethodSignature (WOApplePrivate)

/*! Private Apple API. */
+ (id)signatureWithObjCTypes:(const char *)fp8;

@end

@interface NSMethodSignature (WOPrivate)

- (id)initWithObjCTypes:(const char *)types;

@end

@implementation NSMethodSignature (WOTest)

+ (id)WOTest_signatureBasedOnObjCTypes:(const char *)types
{
    NSParameterAssert(types != NULL);

#ifdef WO_USE_OWN_METHOD_SIGNATURE_IMPLEMENTATION

    return [[[self alloc] initWithObjCTypes:types] autorelease];

#else /* use private Apple API */

    NSAssert([self respondsToSelector:@selector(signatureWithObjCTypes:)],
             @"signatureWithObjCTypes: selector not recognized");
    return [self signatureWithObjCTypes:types];

#endif

}

- (id)initWithObjCTypes:(const char *)types
{
    NSParameterAssert(types != NULL);
    if ((self = [super init]))
    {
        // TODO: finish implementation
        // loop through args
/*        unsigned method_getNumberOfArguments(Method);
        unsigned method_getSizeOfArguments(Method); */

        // I hate using private Apple APIs, even ones that appear stable, but
        // not sure that meddling with these instance variables is a good idea
    }
    return self;
}

@end
