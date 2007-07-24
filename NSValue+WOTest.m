//
//  NSValue+WOTest.m
//  WOTest
//
//  Created by Wincent Colaiuta on 09 June 2005.
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

// category header
#import "NSValue+WOTest.h"

// system headers
#import <objc/objc-runtime.h>

// framework headers
#import "WOTest.h"
#import "NSObject+WOTest.h"
#import "NSScanner+WOTest.h"
#import "NSString+WOTest.h"

@implementation NSValue (WOTest)

#pragma mark -
#pragma mark Value creation methods

+ (NSValue *)WOTest_valueWithChar:(char)aChar
{
    return [NSValue value:&aChar withObjCType:@encode(char)];
}

+ (NSValue *)WOTest_valueWithInt:(int)anInt
{
    return [NSValue value:&anInt withObjCType:@encode(int)];
}

+ (NSValue *)WOTest_valueWithShort:(short)aShort
{
    return [NSValue value:&aShort withObjCType:@encode(short)];
}

+ (NSValue *)WOTest_valueWithLong:(long)aLong
{
    return [NSValue value:&aLong withObjCType:@encode(long)];
}

+ (NSValue *)WOTest_valueWithLongLong:(long long)aLongLong
{
    return [NSValue value:&aLongLong withObjCType:@encode(long long)];
}

+ (NSValue *)WOTest_valueWithUnsignedChar:(unsigned char)anUnsignedChar
{
    return [NSValue value:&anUnsignedChar withObjCType:@encode(unsigned char)];
}

+ (NSValue *)WOTest_valueWithUnsignedInt:(unsigned int)anUnsignedInt
{
    return [NSValue value:&anUnsignedInt withObjCType:@encode(unsigned int)];
}

+ (NSValue *)WOTest_valueWithUnsignedShort:(unsigned short)anUnsignedShort
{
    return [NSValue value:&anUnsignedShort withObjCType:@encode(unsigned short)];
}

+ (NSValue *)WOTest_valueWithUnsignedLong:(unsigned long)anUnsignedLong
{
    return [NSValue value:&anUnsignedLong withObjCType:@encode(unsigned long)];
}

+ (NSValue *)WOTest_valueWithUnsignedLongLong:(unsigned long long)anUnsignedLongLong
{
    return [NSValue value:&anUnsignedLongLong withObjCType:@encode(unsigned long long)];
}

+ (NSValue *)WOTest_valueWithFloat:(float)aFloat
{
    return [NSValue value:&aFloat withObjCType:@encode(float)];
}

+ (NSValue *)WOTest_valueWithDouble:(double)aDouble
{
    return [NSValue value:&aDouble withObjCType:@encode(double)];
}

+ (NSValue *)WOTest_valueWithC99Bool:(_Bool)aC99Bool
{
    return [NSValue value:&aC99Bool withObjCType:@encode(_Bool)];
}

+ (NSValue *)WOTest_valueWithConstantCharacterString:(const char *)aConstantCharString
{
    return [NSValue value:&aConstantCharString withObjCType:@encode(const char *)];
}

+ (NSValue *)WOTest_valueWithCharacterString:(char *)aCharacterString
{
    return [NSValue value:&aCharacterString withObjCType:@encode(char *)];
}

+ (NSValue *)WOTest_valueWithObject:(id)anObject
{
    return [NSValue value:&anObject withObjCType:@encode(id)];
}

+ (NSValue *)WOTest_valueWithClass:(Class)aClass
{
    return [NSValue value:&aClass withObjCType:@encode(Class)];
}

+ (NSValue *)WOTest_valueWithSelector:(SEL)aSelector
{
    return [NSValue value:&aSelector withObjCType:@encode(SEL)];
}

#pragma mark -
#pragma mark Parsing type strings

// TODO: investigate whether NSGetSizeAndAlignment() could save some code here...
+ (size_t)WOTest_maximumEmbeddedSizeForType:(NSString *)typeString
{
    NSParameterAssert(typeString != nil);
    size_t size = 16; // worst case scenario

    if ([self WOTest_typeIsCompound:typeString])
        return [self WOTest_sizeForType:typeString];

    if ([self WOTest_typeIsBitfield:typeString])
        return sizeof(int);

#if defined (__i386__)

    if ([self WOTest_typeIsC99Bool:typeString]                         ||
        [self WOTest_typeIsUnsignedChar:typeString]                    ||
        [self WOTest_typeIsChar:typeString]                            ||
        [self WOTest_typeIsUnsignedChar:typeString])
        size = 1;   // scalars of size/alignment 1
    else if ([self WOTest_typeIsUnsignedShort:typeString]              ||
             [self WOTest_typeIsShort:typeString])
        size = 2;   // scalars of size/alignment 2
    else if ([self WOTest_typeIsUnsignedInt:typeString]                ||
             [self WOTest_typeIsInt:typeString]                        ||
             [self WOTest_typeIsUnsignedLong:typeString]               ||
             [self WOTest_typeIsLong:typeString]                       ||
             [self WOTest_typeIsFloat:typeString])
        size = 4;   // scalars of size/alignment 4
    else if ([self WOTest_typeIsUnsignedLongLong:typeString]           ||
             [self WOTest_typeIsLongLong:typeString]                   ||
             [self WOTest_typeIsDouble:typeString])
        size = 8;   // scalars of size/alignment 8
    else if ([self WOTest_typeIsPointer:typeString]                    ||
             [self WOTest_typeIsPointerToVoid:typeString]              ||
             [self WOTest_typeIsObject:typeString]                     ||
             [self WOTest_typeIsClass:typeString]                      ||
             [self WOTest_typeIsSelector:typeString]                   ||
             [self WOTest_typeIsCharacterString:typeString]            ||
             [self WOTest_typeIsConstantCharacterString:typeString])
        size = 4;   // pointers (size/alignment 4)
    else
        // documented in "Mac OS X ABI Function Call Guide" but not supported:
        // long double        16 bytes
        // vector (64 bits)   8 bytes
        // vector (128 bits)  16 bytes
        [NSException raise:NSInternalInconsistencyException
                    format:@"Type %@ not supported by WOTest_maximumEmbeddedSizeForType:", typeString];

#elif defined (__ppc__)

    if ([self WOTest_typeIsUnsignedChar:typeString]                    ||
        [self WOTest_typeIsChar:typeString])
        size = 1;   // scalars of size/alignment 1
    else if ([self WOTest_typeIsUnsignedShort:typeString]              ||
             [self WOTest_typeIsShort:typeString])
        size = 2;   // scalars of size/alignment 2
    else if ([self WOTest_typeIsC99Bool:typeString]                    ||
             [self WOTest_typeIsUnsignedInt:typeString]                ||
             [self WOTest_typeIsInt:typeString]                        ||
             [self WOTest_typeIsUnsignedLong:typeString]               ||
             [self WOTest_typeIsLong:typeString]                       ||
             [self WOTest_typeIsFloat:typeString])
        size = 4;   // scalars of size/alignment 4
    else if ([self WOTest_typeIsUnsignedLongLong:typeString]           ||
             [self WOTest_typeIsLongLong:typeString]                   ||
             [self WOTest_typeIsDouble:typeString])
        size = 8;   // scalars of size/alignment 8
    else if ([self WOTest_typeIsPointer:typeString]                    ||
             [self WOTest_typeIsPointerToVoid:typeString]              ||
             [self WOTest_typeIsObject:typeString]                     ||
             [self WOTest_typeIsClass:typeString]                      ||
             [self WOTest_typeIsSelector:typeString]                   ||
             [self WOTest_typeIsCharacterString:typeString]            ||
             [self WOTest_typeIsConstantCharacterString:typeString])
        size = 4;   // pointers (size/alignment 4)
    else
        // documented in "Mac OS X ABI Function Call Guide" but not supported:
        // long double  8 bytes (Mac OS X < 10.4, GCC < 4.0)
        // long double  16 bytes (Mac OS X >= 10.4, GCC >= 4.0)
        // vector       16 bytes
        [NSException raise:NSInternalInconsistencyException
                    format:@"Type %@ not supported by WOTest_maximumEmbeddedSizeForType:", typeString];

#elif defined (__ppc64__)

    if ([self WOTest_typeIsC99Bool:typeString]                         ||
        [self WOTest_typeIsUnsignedChar:typeString]                    ||
        [self WOTest_typeIsChar:typeString])
        size = 1;   // scalars of size/alignment 1
    else if ([self WOTest_typeIsUnsignedShort:typeString]              ||
             [self WOTest_typeIsShort:typeString])
        size = 2;   // scalars of size/alignment 2
    else if ([self WOTest_typeIsUnsignedInt:typeString]                ||
             [self WOTest_typeIsInt:typeString]                        ||
             [self WOTest_typeIsFloat:typeString])
        size = 4;   // scalars of size/alignment 4
    else if ([self WOTest_typeIsUnsignedLong:typeString]               ||
             [self WOTest_typeIsLong:typeString]                       ||
             [self WOTest_typeIsUnsignedLongLong:typeString]           ||
             [self WOTest_typeIsLongLong:typeString]                   ||
             [self WOTest_typeIsDouble:typeString])
        size = 8;   // scalars of size/alignment 8
    else if ([self WOTest_typeIsPointer:typeString]                    ||
             [self WOTest_typeIsPointerToVoid:typeString]              ||
             [self WOTest_typeIsObject:typeString]                     ||
             [self WOTest_typeIsClass:typeString]                      ||
             [self WOTest_typeIsSelector:typeString]                   ||
             [self WOTest_typeIsCharacterString:typeString]            ||
             [self WOTest_typeIsConstantCharacterString:typeString])
        size = 8;   // pointers (size/alignment 8)
    else
        // documented in "Mac OS X ABI Function Call Guide" but not supported:
        // long double  16 bytes
        // vector       16 bytes
        [NSException raise:NSInternalInconsistencyException
                    format:@"Type %@ not supported by WOTest_maximumEmbeddedSizeForType:", typeString];

#else

#error Unsupported architecture

#endif

    return size;
}

+ (size_t)WOTest_sizeForType:(NSString *)typeString
{
    NSParameterAssert(typeString != nil);
    size_t size = 0;

    if ([self WOTest_typeIsChar:typeString])
        size = sizeof(char);
    else if ([self WOTest_typeIsInt:typeString])
        size = sizeof(int);
    else if ([self WOTest_typeIsShort:typeString])
        size = sizeof(short);
    else if ([self WOTest_typeIsLong:typeString])
        size = sizeof(long);
    else if ([self WOTest_typeIsLongLong:typeString])
        size = sizeof(long long);
    else if ([self WOTest_typeIsUnsignedChar:typeString])
        size = sizeof(unsigned char);
    else if ([self WOTest_typeIsUnsignedInt:typeString])
        size = sizeof(unsigned int);
    else if ([self WOTest_typeIsUnsignedShort:typeString])
        size = sizeof(unsigned short);
    else if ([self WOTest_typeIsUnsignedLong:typeString])
        size = sizeof(unsigned long);
    else if ([self WOTest_typeIsUnsignedLongLong:typeString])
        size = sizeof(unsigned long long);
    else if ([self WOTest_typeIsFloat:typeString])
        size = sizeof(float);
    else if ([self WOTest_typeIsDouble:typeString])
        size = sizeof(double);
    else if ([self WOTest_typeIsC99Bool:typeString])
        size = sizeof(_Bool);
    else if ([self WOTest_typeIsVoid:typeString])
        size = sizeof(void);
    else if ([self WOTest_typeIsConstantCharacterString:typeString])
        size = sizeof(const char *);
    else if ([self WOTest_typeIsCharacterString:typeString])
        size = sizeof(char *);
    else if ([self WOTest_typeIsObject:typeString])
        size = sizeof(id);
    else if ([self WOTest_typeIsClass:typeString])
        size = sizeof(Class);
    else if ([self WOTest_typeIsSelector:typeString])
        size = sizeof(SEL);
    else if ([self WOTest_typeIsPointerToVoid:typeString])
        size = sizeof(void *);
    else // handle complex types and special cases
    {
        // if is pointer
        if ([self WOTest_typeIsPointer:typeString])
            size = sizeof(void *);
        else if ([self WOTest_typeIsArray:typeString])
        {
            NSScanner *scanner = [NSScanner scannerWithString:typeString];
            unichar startMarker, endMarker;
            int count;
            NSString *elementType;
            if ([scanner WOTest_scanCharacter:&startMarker] &&
                (startMarker == _C_ARY_B) && [scanner scanInt:&count] &&
                [scanner WOTest_scanTypeIntoString:&elementType] &&
                [scanner WOTest_scanCharacter:&endMarker] && (endMarker == _C_ARY_E) &&
                [scanner isAtEnd])
            {
                // recursion
                size = [self WOTest_sizeForType:elementType] * count;
            }
            else
                [NSException raise:NSInternalInconsistencyException
                            format:@"scanner error in sizeForType for type %@", typeString];
        }
        else if ([self WOTest_typeIsStruct:typeString])
        {
            NSScanner *scanner = [NSScanner scannerWithString:typeString];
            unichar startMarker, endMarker;

            if ([scanner WOTest_scanCharacter:&startMarker] &&
                (startMarker == _C_STRUCT_B))
            {
                // scan optional identifier
                if ([scanner WOTest_scanIdentifierIntoString:nil])
                    [scanner WOTest_scanCharacter:NULL]; // scan past "="

                NSString    *memberType;
                size_t      largestMember   = 0;
                while ([scanner WOTest_scanTypeIntoString:&memberType])
                {
                    size_t memberSize = [self WOTest_maximumEmbeddedSizeForType:memberType];
                    largestMember = MAX(largestMember, memberSize);

                    if (memberSize != 0) // watch out for division by zero
                    {
                        // check for alignment gap
                        size_t modulo = (size % memberSize);
                        if (modulo != 0) // fill alignment gap
                            size += (memberSize - modulo);
                    }

                    size += memberSize;
                }

#if defined (__i386__) || defined (__ppc64)

                // Special rules for i386:
                // 1. Composite data types (structs/arrays/unions) take on the alignment of the member with the highest alignment
                // 2. Size of composite type is a multiple of its alignment

                // Special rules for ppc64 (equivalent):
                // 1. Embedding alignment of composite types (array/struct) is same as largest embedding align of members.
                // 2. Total size of the composite is rounded up to multiple of its embedding alignment.

                // Special rules for ppc: None.

                if (largestMember != 0) // watch out for division by zero
                {
                    // check for alignment gap
                    size_t modulo = (size % largestMember);
                    if (modulo != 0) // fill alignment gap
                        size += (largestMember - modulo);
                }

#endif

                if ([scanner WOTest_scanCharacter:&endMarker] && (endMarker == _C_STRUCT_E) && [scanner isAtEnd])
                    return size; // all done
            }

            [NSException raise:NSInternalInconsistencyException format:@"scanner error in sizeForType for type %@", typeString];
        }
        else if ([self WOTest_typeIsUnion:typeString])
        {
            NSScanner *scanner = [NSScanner scannerWithString:typeString];
            unichar startMarker, endMarker;

            if ([scanner WOTest_scanCharacter:&startMarker] && (startMarker == _C_UNION_B))
            {
                // scan optional identifier
                if ([scanner WOTest_scanIdentifierIntoString:nil])
                    [scanner WOTest_scanCharacter:NULL]; // scan past "="

                NSString *memberType;
                while ([scanner WOTest_scanTypeIntoString:&memberType])
                    // size of union is size of largest type in the union
                    size = MAX(size, [self WOTest_maximumEmbeddedSizeForType:memberType]);

                if ([scanner WOTest_scanCharacter:&endMarker] && (endMarker == _C_UNION_E) && [scanner isAtEnd])
                    return size; // all done
            }

            [NSException raise:NSInternalInconsistencyException format:@"scanner error in sizeForType for type %@", typeString];
        }
        else if ([self WOTest_typeIsBitfield:typeString])
            size = sizeof(int);
        else if ([self WOTest_typeIsUnknown:typeString])
        {
            // could be a function pointer, but could be something else
            [NSException raise:NSInternalInconsistencyException format: @"Cannot calculate buffer size for type %@", typeString];
        }
        else // we officially have no idea whatsoever
            [NSException raise:NSInternalInconsistencyException
                        format:@"Cannot calculate buffer size for unknown type %@", typeString];
    }

    return size;
}

/*! Returns YES if \p typeString contains a numeric scalar value (char, int, short, long, long long, unsigned char, unsigned int, unsigned short, unsigned long, unsigned long long, float, double, C99 _Bool). Returns NO if the receiver contains any other type, object or pointer (id, Class, SEL, void, char *, as well as arrays, structures and pointers). */
+ (BOOL)WOTest_typeIsNumericScalar:(NSString *)typeString
{
    if (!typeString) return NO;
    return ([self WOTest_typeIsChar:typeString]                ||
            [self WOTest_typeIsInt:typeString]                 ||
            [self WOTest_typeIsShort:typeString]               ||
            [self WOTest_typeIsLong:typeString]                ||
            [self WOTest_typeIsLongLong:typeString]            ||
            [self WOTest_typeIsUnsignedChar:typeString]        ||
            [self WOTest_typeIsUnsignedInt:typeString]         ||
            [self WOTest_typeIsUnsignedShort:typeString]       ||
            [self WOTest_typeIsUnsignedLong:typeString]        ||
            [self WOTest_typeIsUnsignedLongLong:typeString]    ||
            [self WOTest_typeIsFloat:typeString]               ||
            [self WOTest_typeIsDouble:typeString]              ||
            [self WOTest_typeIsC99Bool:typeString]);
}

+ (BOOL)WOTest_typeIsCompound:(NSString *)typeString
{
    if (!typeString) return NO;
    return ([self WOTest_typeIsStruct:typeString] || [self WOTest_typeIsUnion:typeString] || [self WOTest_typeIsArray:typeString]);
}

+ (BOOL)WOTest_typeIsChar:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_CHR);
}

+ (BOOL)WOTest_typeIsInt:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_INT);
}

+ (BOOL)WOTest_typeIsShort:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_SHT);
}

+ (BOOL)WOTest_typeIsLong:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_LNG);
}

+ (BOOL)WOTest_typeIsLongLong:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_LNGLNG);
}

+ (BOOL)WOTest_typeIsUnsignedChar:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_UCHR);
}

+ (BOOL)WOTest_typeIsUnsignedInt:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_UINT);
}

+ (BOOL)WOTest_typeIsUnsignedShort:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_USHT);
}

+ (BOOL)WOTest_typeIsUnsignedLong:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_ULNG);
}

+ (BOOL)WOTest_typeIsUnsignedLongLong:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_ULNGLNG);
}

+ (BOOL)WOTest_typeIsFloat:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_FLT);
}

+ (BOOL)WOTest_typeIsDouble:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_DBL);
}

+ (BOOL)WOTest_typeIsC99Bool:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_99BOOL);
}

+ (BOOL)WOTest_typeIsVoid:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_VOID);
}

+ (BOOL)WOTest_typeIsConstantCharacterString:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 2) && (strcmp(type, "r*") == 0));
}

+ (BOOL)WOTest_typeIsCharacterString:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_CHARPTR);
}

+ (BOOL)WOTest_typeIsObject:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_ID);
}

+ (BOOL)WOTest_typeIsClass:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_CLASS);
}

+ (BOOL)WOTest_typeIsSelector:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_SEL);
}

+ (BOOL)WOTest_typeIsPointerToVoid:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 2) && (strcmp(type, "^v") == 0));
}

+ (BOOL)WOTest_typeIsPointer:(NSString *)typeString
{
    NSScanner *scanner = [NSScanner scannerWithString:typeString];
    return [scanner scanPointerIntoString:nil];
}

+ (BOOL)WOTest_typeIsArray:(NSString *)typeString
{
    NSScanner *scanner = [NSScanner scannerWithString:typeString];
    return [scanner WOTest_scanArrayIntoString:nil];
}

+ (BOOL)WOTest_typeIsStruct:(NSString *)typeString
{
    NSScanner *scanner = [NSScanner scannerWithString:typeString];
    return [scanner WOTest_scanStructIntoString:nil];
}

+ (BOOL)WOTest_typeIsUnion:(NSString *)typeString
{
    NSScanner *scanner = [NSScanner scannerWithString:typeString];
    return [scanner WOTest_scanUnionIntoString:nil];
}

+ (BOOL)WOTest_typeIsBitfield:(NSString *)typeString
{
    NSScanner *scanner = [NSScanner scannerWithString:typeString];
    return [scanner WOTest_scanBitfieldIntoString:nil];
}

+ (BOOL)WOTest_typeIsUnknown:(NSString *)typeString
{
    if (!typeString) return NO;
    const char *type = [typeString UTF8String];
    return ((strlen(type) == 1) && *type == _C_UNDEF);
}

#pragma mark -
#pragma mark High-level test methods

- (BOOL)WOTest_testIsEqualToValue:(NSValue *)otherValue
{
    if (!otherValue) return NO;

    if ([self WOTest_isObject])
    {
        if ([otherValue WOTest_isObject])
        {
            // can only compare objects with objects
            id selfObject   = [self nonretainedObjectValue];
            id otherObject  = [otherValue nonretainedObjectValue];

            // avoid the message send if pointers are equal
            // this also allows two nil object pointers to be considered equal, as they should
            if (selfObject == otherObject)
                return YES;

            @try {
                if (selfObject && otherObject && [NSObject WOTest_object:selfObject respondsToSelector:@selector(isEqual:)])
                    return [selfObject isEqual:otherObject];
            }
            @catch (id e) {
                // fall through
            }
        }
        else if ([otherValue WOTest_isNumericScalar])
        {
            // check for special case: comparing an object with nil
            if (strcmp([otherValue objCType], @encode(typeof(nil))) == 0)
            {
                typeof(nil) nilId = nil;
                NSValue *nilValue = [NSValue valueWithBytes:&nilId objCType:@encode(typeof(nil))];
                if ([otherValue WOTest_compare:nilValue] == NSOrderedSame) // comparing other value (nil) with self object
                    return ([self nonretainedObjectValue] == nil);
            }

            // will raise exception (comparing numeric scalar with object)
            return ([self WOTest_compare:otherValue] == NSOrderedSame);
        }
        else if ([otherValue WOTest_isPointerToVoid])
            // encodings changed on Leopard such that comparisons such as WO_TEST_EQ(foo, nil) no longer worked;
            // in this case foo is encoded as type "@" (object) and nil as "^v" (pointer to void)
            // so we end up here and just compare pointers numerically
            return ((void *)[self nonretainedObjectValue] == [otherValue pointerValue]);
    }
    else if ([self WOTest_isNumericScalar])
    {
        // check for special case: comparing with nil
        typeof(nil) nilId = nil;
        NSValue *nilValue = [NSValue valueWithBytes:&nilId objCType:@encode(typeof(nil))];
        if ((strcmp([self objCType], @encode(typeof(nil))) == 0) && ([self WOTest_compare:nilValue] == NSOrderedSame))
        {
            // self is nil (or at least looks like nil)
            if ([otherValue WOTest_isObject])                          // comparing self (nil) with otherObject
                return ([otherValue nonretainedObjectValue] == nil);
            else if ([otherValue WOTest_isPointerToVoid])              // special case can compare to pointer to void if zero
                return ((id)[otherValue pointerValue] == nil);
        }

        // could raise exception (comparing numeric scalar with object)
        return ([self WOTest_compare:otherValue] == NSOrderedSame);
    }
    else if ([self WOTest_isPointerToVoid])
    {
        if ([otherValue WOTest_isObject])
            // special case for pointer-to-void vs object comparisons (necessary on Leopard)
            return ([self pointerValue] == (void *)[otherValue nonretainedObjectValue]);
        else if ([otherValue WOTest_isPointerToVoid])
            // this special case already necessary on Leopard, otherwise nil-to-nil comparison fails
            return ([self pointerValue] == [otherValue pointerValue]);

        // fall through to standard case
        return ([self WOTest_compare:otherValue] == NSOrderedSame);
    }
    else if (([self WOTest_isCharArray] || [self WOTest_isCharacterString] || [self WOTest_isConstantCharacterString]) &&
             ([otherValue WOTest_isCharArray] || [otherValue WOTest_isCharacterString] ||
              [otherValue WOTest_isConstantCharacterString]))
    {
        // another special case
        NSString *selfString    = [self WOTest_stringValue];
        NSString *otherString   = [otherValue WOTest_stringValue];
        if (selfString && otherString)
            return [selfString isEqualToString:otherString];
    }

    // fallback case (Class objects, SEL, structs, unions, pointers etc)
    return [self isEqualToValue:otherValue];
}

- (BOOL)WOTest_testIsGreaterThanValue:(NSValue *)aValue
{
    return ([self WOTest_compare:aValue] == NSOrderedDescending);
}

- (BOOL)WOTest_testIsLessThanValue:(NSValue *)aValue
{
    return ([self WOTest_compare:aValue] == NSOrderedAscending);
}

- (BOOL)WOTest_testIsNotGreaterThanValue:(NSValue *)aValue
{
    return ([self WOTest_compare:aValue] != NSOrderedDescending);
}

- (BOOL)WOTest_testIsNotLessThanValue:(NSValue *)aValue
{
    return ([self WOTest_compare:aValue] != NSOrderedAscending);
}

- (NSComparisonResult)WOTest_compare:(NSValue *)aValue
{
    if (!aValue)
        [NSException raise:NSInvalidArgumentException format:@"cannot compare to nil"];

    // object case
    if ([self WOTest_isObject])
    {
        if (![aValue WOTest_isObject])
            [NSException raise:NSInvalidArgumentException format:@"cannot compare object with non-object"];

        id selfObject   = [self nonretainedObjectValue];
        id otherObject  = [aValue nonretainedObjectValue];

        if ([selfObject isKindOfClass:[otherObject class]] && [selfObject respondsToSelector:@selector(compare:)])
            return ((NSComparisonResult (*)(id, SEL, id))objc_msgSend)(selfObject, @selector(compare:), otherObject);
        else if ([otherObject isKindOfClass:[selfObject class]] && [otherObject respondsToSelector:@selector(compare:)])
            return ((NSComparisonResult (*)(id, SEL, id))objc_msgSend)(otherObject, @selector(compare:), selfObject);

        [NSException raise:NSInvalidArgumentException format:@"compared objects must be of same class and implement compare:"];
    }

    // pointer-to-void case
    if ([self WOTest_isPointerToVoid] && [aValue WOTest_isPointerToVoid])
    {
        // test conservatively here: equal pointers are considered equal;
        // all others fall through and an exception is raised
        if ([self pointerValue] == [aValue pointerValue])
            return NSOrderedSame;
    }

    // numeric scalar case
    if ([self WOTest_isNumericScalar] && [aValue WOTest_isNumericScalar])
    {
        if ([aValue WOTest_isChar])
            return [self WOTest_compareWithChar:[aValue WOTest_charValue]];
        else if ([aValue WOTest_isInt])
            return [self WOTest_compareWithInt:[aValue WOTest_intValue]];
        else if ([aValue WOTest_isShort])
            return [self WOTest_compareWithShort:[aValue WOTest_shortValue]];
        else if ([aValue WOTest_isLong])
            return [self WOTest_compareWithLong:[aValue WOTest_longValue]];
        else if ([aValue WOTest_isLongLong])
            return [self WOTest_compareWithLongLong:[aValue WOTest_longLongValue]];
        else if ([aValue WOTest_isUnsignedChar])
            return [self WOTest_compareWithUnsignedChar:[aValue WOTest_unsignedCharValue]];
        else if ([aValue WOTest_isUnsignedInt])
            return [self WOTest_compareWithUnsignedInt:[aValue WOTest_unsignedIntValue]];
        else if ([aValue WOTest_isUnsignedShort])
            return [self WOTest_compareWithUnsignedShort:[aValue WOTest_unsignedShortValue]];
        else if ([aValue WOTest_isUnsignedLong])
            return [self WOTest_compareWithUnsignedLong:[aValue WOTest_unsignedLongValue]];
        else if ([aValue WOTest_isUnsignedLongLong])
            return [self WOTest_compareWithUnsignedLongLong:
                [aValue WOTest_unsignedLongLongValue]];
        else if ([aValue WOTest_isFloat])
            return [self WOTest_compareWithFloat:[aValue WOTest_floatValue]];
        else if ([aValue WOTest_isDouble])
            return [self WOTest_compareWithDouble:[aValue WOTest_doubleValue]];
        else if ([aValue WOTest_isC99Bool])
            return [self WOTest_compareWithC99Bool:[aValue WOTest_C99BoolValue]];
    }

    [NSException raise:NSInvalidArgumentException format:@"non-numeric value(s) passed"];

    // never reached, but necessary to suppress compiler warning
    return NSOrderedSame;
}

#pragma mark -
#pragma mark Utility methods

- (size_t)WOTest_bufferSize
{
    return [[self class] WOTest_sizeForType:[self WOTest_objCTypeString]];
}

- (void)WOTest_printSignCompareWarning:(NSString *)warning
{
    NSParameterAssert(warning != nil);

    // this conditional in here so that the warnings can be turned off in WOTest self-testing
    if ([[WOTest sharedInstance] warnsAboutSignComparisons])
    {
        [[WOTest sharedInstance] writeWarning:warning];
        [[WOTest sharedInstance] writeLastKnownLocation];
    }
}

#pragma mark -
#pragma mark Convenience methods

/*! Returns the Objective-C type of the receiver as an NSString. */
- (NSString *)WOTest_objCTypeString
{
    return [NSString stringWithUTF8String:[self objCType]];
}

- (NSString *)WOTest_description
{
    // these special handlings exist because NSValue's description is not very human-friendly
    // it gets even worse when running on Intel: for example, an integer like 500,000 (0x0007a120 hex) is displayed as "<20a10700>"
    if ([self WOTest_isObject])
    {
        // look for objects that are either (NSString objects) or objects that respond to "description"
        id valueContents = [self WOTest_objectValue];
        if (valueContents)
        {
            // for NSString objects: just return content
            if ([NSObject WOTest_object:valueContents isKindOfClass:[NSString class]])
                return [[valueContents retain] autorelease];
            else if ([NSObject WOTest_object:valueContents respondsToSelector:@selector(description)] &&
                     [NSObject WOTest_isIdReturnType:[NSObject WOTest_returnTypeForObject:valueContents
                                                                                 selector:@selector(description)]])
            {
                NSString *description = objc_msgSend(valueContents, @selector(description));
                if (description && [NSObject WOTest_object:description isKindOfClass:[NSString class]])
                    return description;
            }
        }
    }
    // TODO: write unit tests to confirm that NSString supports all of these printf format markers and modifiers
    else if ([self WOTest_isChar])
    {
        char character = [self WOTest_charValue];
        if (character == 32)                                                // the space character
            return @"(space)";
        else if ((character >= 33) && (character <= 126))                   // other printable characters printed as an ASCII char
            return [NSString stringWithFormat:@"'%C'", (unichar)character];
        else
            return [NSString stringWithFormat:@"(char)%hhd", character];    // all others printed as signed numbers
    }
    else if ([self WOTest_isInt])
        return [NSString stringWithFormat:@"(int)%d", [self WOTest_intValue]];
    else if ([self WOTest_isShort])
        return [NSString stringWithFormat:@"(short)%hi", [self WOTest_shortValue]];
    else if ([self WOTest_isLong])
        return [NSString stringWithFormat:@"(long)%ld", [self WOTest_longValue]];
    else if ([self WOTest_isLongLong])
        return [NSString stringWithFormat:@"(long long)%lld", [self WOTest_longLongValue]];
    else if ([self WOTest_isUnsignedChar])
    {
        unsigned char character = [self WOTest_unsignedCharValue];
        if (character == 32)                                        // the space character
            return @"(space)";
        else if ((character >= 33) && (character <= 126))           // other printable characters printed as an ASCII char
            return [NSString stringWithFormat:@"%C", (unichar)character];
        else
            // all others printed as unsigned numbers
            return [NSString stringWithFormat:@"(unsigned char)%hhu", [self WOTest_unsignedCharValue]];
    }
    else if ([self WOTest_isUnsignedInt])
        return [NSString stringWithFormat:@"(unsigned int)%u", [self WOTest_unsignedIntValue]];
    else if ([self WOTest_isUnsignedShort])
        return [NSString stringWithFormat:@"(unsigned short)%hu", [self WOTest_unsignedShortValue]];
    else if ([self WOTest_isUnsignedLong])
        return [NSString stringWithFormat:@"(unsigned long)%lu", [self WOTest_unsignedLongValue]];
    else if ([self WOTest_isUnsignedLongLong])
        return [NSString stringWithFormat:@"(unsigned long long)%llu", [self WOTest_unsignedLongLongValue]];
    else if ([self WOTest_isFloat])
        return [NSString stringWithFormat:@"(float)%f", [self WOTest_floatValue]];
    else if ([self WOTest_isDouble])
        return [NSString stringWithFormat:@"(double)%f", [self WOTest_doubleValue]];
    else if ([self WOTest_isC99Bool])
        return [NSString stringWithFormat:@"(_Bool)%@", [self WOTest_C99BoolValue] ? @"true" : @"false"];
    else if ([self WOTest_isVoid])
        return @"(void)";
    else if ([self WOTest_isConstantCharacterString])
        return [NSString stringWithFormat:@"\"%s\"", [self WOTest_constantCharacterStringValue]];
    else if ([self WOTest_isCharacterString])
        return [NSString stringWithFormat:@"\"%s\"", [self WOTest_characterStringValue]];
    else if ([self WOTest_isClass])
        return [NSString stringWithFormat:@"(Class)%@", NSStringFromClass([self WOTest_classValue])];
    else if ([self WOTest_isSelector])
        return [NSString stringWithFormat:@"(SEL)%@", NSStringFromSelector([self WOTest_selectorValue])];
    else if ([self WOTest_isPointerToVoid])
        return [NSString stringWithFormat:@"(void *)%#08x", [self WOTest_pointerToVoidValue]];
    return [self description];  // fallback case
}

#pragma mark -
#pragma mark Identifying generic types

- (BOOL)WOTest_isNumericScalar
{
    return ([self WOTest_isChar]           || [self WOTest_isInt]                 ||
            [self WOTest_isShort]          || [self WOTest_isLong]                ||
            [self WOTest_isLongLong]       || [self WOTest_isUnsignedChar]        ||
            [self WOTest_isUnsignedInt]    || [self WOTest_isUnsignedShort]       ||
            [self WOTest_isUnsignedLong]   || [self WOTest_isUnsignedLongLong]    ||
            [self WOTest_isFloat]          || [self WOTest_isDouble]              ||
            [self WOTest_isC99Bool]);
}

- (BOOL)WOTest_isPointer
{
    return [[self class] WOTest_typeIsPointer:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isArray
{
    return [[self class] WOTest_typeIsArray:[self WOTest_objCTypeString]];
}

- (unsigned)WOTest_arrayCount
{
    NSAssert([self WOTest_isArray],
             @"WOTest_arrayCount sent but receiver does not contain an array");
    NSScanner *scanner = [NSScanner scannerWithString:[self WOTest_objCTypeString]];
    unichar startMarker;
    int count = 0;

    // attempt the scan: it should work
    if (!([scanner WOTest_scanCharacter:&startMarker] && (startMarker == _C_ARY_B) && [scanner scanInt:&count]))
        [NSException raise:NSInternalInconsistencyException format:@"scanner error in WOTest_arrayCount"];

    return (unsigned)count;
}

- (NSString *)WOTest_arrayType
{
    NSAssert([self WOTest_isArray], @"WOTest_arrayType sent but receiver does not contain an array");
    NSScanner *scanner = [NSScanner scannerWithString:[self WOTest_objCTypeString]];
    [scanner setScanLocation:1];
    NSString *typeString;
    if (!([scanner scanInt:nil] && [scanner WOTest_scanTypeIntoString:&typeString]))
        [NSException raise:NSInternalInconsistencyException format:@"scanner error in WOTest_arrayType"];
    return typeString;
}

- (BOOL)WOTest_isStruct
{
    return [[self class] WOTest_typeIsStruct:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isUnion
{
    return [[self class] WOTest_typeIsUnion:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isBitfield
{
    return [[self class] WOTest_typeIsBitfield:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isUnknown
{
    return [[self class] WOTest_typeIsUnknown:[self WOTest_objCTypeString]];
}

#pragma mark -
#pragma mark Identifying and retrieving specific types

- (BOOL)WOTest_isChar
{
    return [[self class] WOTest_typeIsChar:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isInt
{
    return [[self class] WOTest_typeIsInt:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isShort
{
    return [[self class] WOTest_typeIsShort:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isLong
{
    return [[self class] WOTest_typeIsLong:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isLongLong
{
    return [[self class] WOTest_typeIsLongLong:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isUnsignedChar
{
    return [[self class] WOTest_typeIsUnsignedChar:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isUnsignedInt
{
    return [[self class] WOTest_typeIsUnsignedInt:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isUnsignedShort
{
    return [[self class] WOTest_typeIsUnsignedShort:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isUnsignedLong
{
    return [[self class] WOTest_typeIsUnsignedLong:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isUnsignedLongLong
{
    return [[self class] WOTest_typeIsUnsignedLongLong:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isFloat
{
    return [[self class] WOTest_typeIsFloat:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isDouble
{
    return [[self class] WOTest_typeIsDouble:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isC99Bool
{
    return [[self class] WOTest_typeIsC99Bool:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isVoid
{
    return [[self class] WOTest_typeIsVoid:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isConstantCharacterString
{
    return [[self class] WOTest_typeIsConstantCharacterString:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isCharacterString
{
    return [[self class] WOTest_typeIsCharacterString:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isObject
{
    return [[self class] WOTest_typeIsObject:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isClass
{
    return [[self class] WOTest_typeIsClass:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isSelector
{
    return [[self class] WOTest_typeIsSelector:[self WOTest_objCTypeString]];
}

- (BOOL)WOTest_isPointerToVoid
{
    return [[self class] WOTest_typeIsPointerToVoid:[self WOTest_objCTypeString]];
}

- (char)WOTest_charValue
{
    char value;
    [self getValue:&value];
    return value;
}

- (int)WOTest_intValue
{
    int value;
    [self getValue:&value];
    return value;
}

- (short)WOTest_shortValue
{
    short value;
    [self getValue:&value];
    return value;
}

- (long)WOTest_longValue
{
    long value;
    [self getValue:&value];
    return value;
}

- (long long)WOTest_longLongValue
{
    long long value;
    [self getValue:&value];
    return value;
}

- (unsigned char)WOTest_unsignedCharValue
{
    unsigned char value;
    [self getValue:&value];
    return value;
}

- (unsigned int)WOTest_unsignedIntValue
{
    unsigned int value;
    [self getValue:&value];
    return value;
}

- (unsigned short)WOTest_unsignedShortValue
{
    unsigned short value;
    [self getValue:&value];
    return value;
}

- (unsigned long)WOTest_unsignedLongValue
{
    unsigned long value;
    [self getValue:&value];
    return value;
}

- (unsigned long long)WOTest_unsignedLongLongValue
{
    unsigned long long value;
    [self getValue:&value];
    return value;
}

- (float)WOTest_floatValue
{
    float value;
    [self getValue:&value];
    return value;
}

- (double)WOTest_doubleValue
{
    double value;
    [self getValue:&value];
    return value;
}

- (_Bool)WOTest_C99BoolValue
{
    _Bool value;
    [self getValue:&value];
    return value;
}

- (const char *)WOTest_constantCharacterStringValue
{
    const char *value;
    [self getValue:&value];
    return value;
}

- (char *)WOTest_characterStringValue
{
    char *value;
    [self getValue:&value];
    return value;
}

- (id)WOTest_objectValue
{
    id value;
    [self getValue:&value];
    return value;
}

- (Class)WOTest_classValue
{
    Class value;
    [self getValue:&value];
    return value;
}

- (SEL)WOTest_selectorValue
{
    SEL value;
    [self getValue:&value];
    return value;
}

- (void *)WOTest_pointerToVoidValue
{
    void *value;
    [self getValue:&value];
    return value;
}

- (BOOL)WOTest_isCharArray
{
    // look for string of form "[4c]"
    NSScanner *scanner = [NSScanner scannerWithString:[self WOTest_objCTypeString]];
    unichar startMarker, flag, endMarker;
    int count;
    return ([scanner WOTest_scanCharacter:&startMarker] && (startMarker == _C_ARY_B) &&
            [scanner scanInt:&count] &&
            [scanner WOTest_scanCharacter:&flag] && (flag == _C_CHR) &&
            [scanner WOTest_scanCharacter:&endMarker] && (endMarker == _C_ARY_E) &&
            [scanner isAtEnd]);
}

- (NSString *)WOTest_stringValue
{
    @try {
        if ([self WOTest_isCharacterString] || [self WOTest_isConstantCharacterString])
            return [NSString stringWithUTF8String:(const char *)[self pointerValue]];
        else // see if this is a char array
        {
            NSScanner *scanner = [NSScanner scannerWithString:[self WOTest_objCTypeString]];
            unichar startMarker, flag, endMarker;
            int count;
            if ([scanner WOTest_scanCharacter:&startMarker] &&
                (startMarker == _C_ARY_B) && [scanner scanInt:&count] &&
                [scanner WOTest_scanCharacter:&flag] && (flag == _C_CHR) &&
                [scanner WOTest_scanCharacter:&endMarker] && (endMarker == _C_ARY_E) &&
                [scanner isAtEnd])
            {
                // is char array
                if (count > 0)
                {
                    char *buffer = malloc(count * sizeof(char));
                    NSAssert1(buffer != NULL, @"malloc() failed (size %d)",
                              (count * sizeof(char)));
                    [self getValue:buffer];

                    // confirm that this is a null-terminated string
                    for (int i = 0; i < count; i++)
                    {
                        if (buffer[i] == 0)
                            return [NSString stringWithUTF8String:buffer];
                    }
                    free(buffer);
                }
            }
        }
    }
    @catch (id e) {
        // fall through
    }
    return nil;
}

#pragma mark -
#pragma mark Low-level test methods

/* Unfortunately there is a lot of very similar code repeated across these methods but it seems to be a necessary evil (600 lines of necessary evil). Firstly, it's necessary to explicitly declare the type of the right-hand value of the comparison. There are lots of permuations for implicit casts, explicit casts (and warnings), and GCC seems to warn about signed to unsigned comparisons differently depending on the types. */
- (NSComparisonResult)WOTest_compareWithChar:(char)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // no cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        // implicit cast
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other);
    else if ([self WOTest_isUnsignedInt])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedIntValue], (unsigned char)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], (unsigned char)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedLongLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        // explicit cast
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], (unsigned char)other);
    }
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
         return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithInt:(int)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // no cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
                                    // implicit cast
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other);
    else if ([self WOTest_isUnsignedInt])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedIntValue], (unsigned int)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], (unsigned int)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedLongLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], (unsigned int)other);  // explicit cast
    }
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithShort:(short)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // no cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
                                    // implicit cast
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other);
    else if ([self WOTest_isUnsignedInt])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedIntValue], (unsigned short)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], (unsigned short)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedLongLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], (unsigned short)other);  // explicit cast
    }
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithLong:(long)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // no cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
                                    // implicit cast
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other);
    else if ([self WOTest_isUnsignedInt])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedIntValue], (unsigned long)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], (unsigned long)other); // explicit cast
    }
    else if ([self WOTest_isUnsignedLongLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        // explicit cast
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], (unsigned long)other);
    }
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithLongLong:(long long)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // no cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS ([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], (unsigned long long)other);  // explicit cast
    }
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithUnsignedChar:(unsigned char)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // no cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS ([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // implicit cast
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;       // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithUnsignedInt:(unsigned int)other
{
    if ([self WOTest_isChar]) // (also BOOL)
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned char)[self WOTest_charValue], other); // explicit cast
    }
    else if ([self WOTest_isInt])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned int)[self WOTest_intValue], other); // explicit cast
    }
    else if ([self WOTest_isShort])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned short)[self WOTest_shortValue], other); // explicit cast
    }
    else if ([self WOTest_isLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned long)[self WOTest_longValue], other); // explicit cast
    }
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS([self WOTest_unsignedIntValue], other); // no cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // implicit cast
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithUnsignedShort:(unsigned short)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS ([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // no cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // implicit cast
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithUnsignedLong:(unsigned long)other
{
    if ([self WOTest_isChar]) // char (also BOOL)
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned char)[self WOTest_charValue], other); // expicit cast
    }
    else if ([self WOTest_isInt]) // int
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned int)[self WOTest_intValue], other); // explicit cast
    }
    else if ([self WOTest_isShort]) // short
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned short)[self WOTest_shortValue], other); // explicit cast
    }
    else if ([self WOTest_isLong]) // long
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned long)[self WOTest_longValue], other); // explicit cast
    }
    else if ([self WOTest_isLongLong]) // long long
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // unsigned char (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt]) // unsigned int
        return WO_COMPARE_SCALARS([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort]) // unsigned short
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong]) // unsigned long
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // no cast
    else if ([self WOTest_isUnsignedLongLong]) // unsigned long long
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // implicit cast
    else if ([self WOTest_isFloat]) // float
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble]) // double
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool]) // C99 _Bool
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;       // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithUnsignedLongLong:(unsigned long long)other
{
    if ([self WOTest_isChar]) // (also BOOL)
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned char)[self WOTest_charValue], other); // explicit cast
    }
    else if ([self WOTest_isInt])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned int)[self WOTest_intValue], other); // explicit cast
    }
    else if ([self WOTest_isShort])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned short)[self WOTest_shortValue], other); // explicit cast
    }
    else if ([self WOTest_isLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned long)[self WOTest_longValue], other); // explicit cast
    }
    else if ([self WOTest_isLongLong])
    {
        [self WOTest_printSignCompareWarning:@"comparison between signed and unsigned, to avoid this warning use an explicit cast"];
        return WO_COMPARE_SCALARS((unsigned long long)[self WOTest_longLongValue], other); // explicit cast
    }
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // no cast
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithFloat:(float)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS ([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // implicit cast
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // no cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithDouble:(double)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS ([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // implicit cast
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // no cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // implicit cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;   // never reached, but necessary to suppress compiler warning
}

- (NSComparisonResult)WOTest_compareWithC99Bool:(_Bool)other
{
    if ([self WOTest_isChar]) // (also BOOL)
        return WO_COMPARE_SCALARS([self WOTest_charValue], other); // implicit cast
    else if ([self WOTest_isInt])
        return WO_COMPARE_SCALARS([self WOTest_intValue], other); // implicit cast
    else if ([self WOTest_isShort])
        return WO_COMPARE_SCALARS([self WOTest_shortValue], other); // implicit cast
    else if ([self WOTest_isLong])
        return WO_COMPARE_SCALARS([self WOTest_longValue], other); // implicit cast
    else if ([self WOTest_isLongLong])
        return WO_COMPARE_SCALARS([self WOTest_longLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedChar]) // (also Boolean)
        return WO_COMPARE_SCALARS([self WOTest_unsignedCharValue], other); // implicit cast
    else if ([self WOTest_isUnsignedInt])
        return WO_COMPARE_SCALARS ([self WOTest_unsignedIntValue], other); // implicit cast
    else if ([self WOTest_isUnsignedShort])
        return WO_COMPARE_SCALARS([self WOTest_unsignedShortValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongValue], other); // implicit cast
    else if ([self WOTest_isUnsignedLongLong])
        return WO_COMPARE_SCALARS([self WOTest_unsignedLongLongValue], other); // implicit cast
    else if ([self WOTest_isFloat])
        return WO_COMPARE_SCALARS([self WOTest_floatValue], other); // implicit cast
    else if ([self WOTest_isDouble])
        return WO_COMPARE_SCALARS([self WOTest_doubleValue], other); // implicit cast
    else if ([self WOTest_isC99Bool])
        return WO_COMPARE_SCALARS([self WOTest_C99BoolValue], other); // no cast

    // all other cases
    [NSException raise:NSInvalidArgumentException
                format:@"cannot compare type \"%s\" with type \"%s\"", [self objCType], @encode(typeof(other))];

    return NSOrderedSame;       // never reached, but necessary to suppress compiler warning
}

@end
