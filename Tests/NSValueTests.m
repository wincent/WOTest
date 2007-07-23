//
//  NSValueTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 31 January 2006.
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

#import "NSValueTests.h"

#pragma mark -
#pragma mark typedefs for testing size calculations

typedef union WOSimpleStruct {
    long                one;
    short               two;
} WOSimpleStruct;

typedef struct WOSubstruct {
    id                  foo;
    long long           bar;
    SEL                 fee;
    unsigned short      fye;
    NSRect              foe;
    NSPoint             fum;
} WOSubstruct;

typedef union WOSubunion {
    NSPoint             a;
    int                 b;
    long long           c;
    WOSubstruct         d;
    double              e;
} WOSubunion;

typedef struct WOComplicatedStruct {
    unsigned long long  a;
    WOSubstruct         b;
    NSRect              c;
    Class               d;
    char                e[100];
    int                 f;
    WOSubunion          g;
    unsigned int        bitfield_a          : 3;
    signed int          bitfield_b          : 5;
    unsigned int        /* no identifier */ : 7;
    unsigned int        bitfield_d          : 1;
    long                h;
} WOComplicatedStruct;

typedef union WOSimpleUnion {
    long                one;
    short               two;
} WOSimpleUnion;

typedef union WOComplicatedUnion {
    int                 alice;
    id                  bob;
    WOSubunion          eva;
    WOComplicatedStruct mallory;
    signed int          bitfield_a          : 2;
    unsigned int        bitfield_b          : 3;
    unsigned int        /* no identifier */ : 6;
    unsigned int        bitfield_d          : 2;
    float               xavier;
    char                zach;
} WOComplicatedUnion;

// anonymous struct (no identifier)
typedef struct {
    _Bool               a;
    unsigned long long  b;
    id                  c;
} WOAnonymousStruct;

// anonymous union (no identifier)
typedef struct {
    BOOL                a;
    double              b;
    id                  c[20];
} WOAnonymousUnion;

@implementation NSValueTests

- (void)testAssumptions
{
    // numeric scalar types
    _Bool               b;
    char                c;
    unsigned char       uc;
    short               s;
    unsigned short      us;
    int                 i;
    unsigned int        ui;
    long                l;
    unsigned long       ul;
    long long           ll;
    unsigned long long  ull;
    float               f;
    double              d;

    // pointers etc
    id                  object;
    Class               class;
    SEL                 selector;
    void                *pVoid;
    char                *pChar;
    const char          *pConstChar;
    int                 *pInt;

    // compound types
    WOComplicatedStruct aStruct;
    WOComplicatedUnion  aUnion;

    // special case: function pointers
    float               (*pFunction)(float, float, float);

    // test assumption that @encode() returns the same as @encode(typeof())
    WO_TEST_EQ(@encode(_Bool), @encode(typeof(b)));
    WO_TEST_EQ(@encode(char), @encode(typeof(c)));
    WO_TEST_EQ(@encode(unsigned char), @encode(typeof(uc)));
    WO_TEST_EQ(@encode(short), @encode(typeof(s)));
    WO_TEST_EQ(@encode(unsigned short), @encode(typeof(us)));
    WO_TEST_EQ(@encode(int), @encode(typeof(i)));
    WO_TEST_EQ(@encode(unsigned int), @encode(typeof(ui)));
    WO_TEST_EQ(@encode(long), @encode(typeof(l)));
    WO_TEST_EQ(@encode(unsigned long), @encode(typeof(ul)));
    WO_TEST_EQ(@encode(long long), @encode(typeof(ll)));
    WO_TEST_EQ(@encode(unsigned long long), @encode(typeof(ull)));
    WO_TEST_EQ(@encode(float), @encode(typeof(f)));
    WO_TEST_EQ(@encode(double), @encode(typeof(d)));
    WO_TEST_EQ(@encode(id), @encode(typeof(object)));
    WO_TEST_EQ(@encode(Class), @encode(typeof(class)));
    WO_TEST_EQ(@encode(SEL), @encode(typeof(selector)));
    WO_TEST_EQ(@encode(void *), @encode(typeof(pVoid)));
    WO_TEST_EQ(@encode(char *), @encode(typeof(pChar)));
    WO_TEST_EQ(@encode(const char*), @encode(typeof(pConstChar)));
    WO_TEST_EQ(@encode(int *), @encode(typeof(pInt)));
    WO_TEST_EQ(@encode(WOComplicatedStruct), @encode(typeof(aStruct)));
    WO_TEST_EQ(@encode(WOComplicatedUnion), @encode(typeof(aUnion)));
    WO_TEST_EQ(@encode(float (*)(float, float, float)), @encode(typeof(pFunction)));
}

#pragma mark -
#pragma mark Creation and retrieval convenience methods

- (void)testCharConvenienceMethods
{
    // test valueWithChar
    char aChar = 'a';
    NSValue *value = [NSValue WOTest_valueWithChar:aChar];

    // check type
    WO_TEST_EQ([value objCType], @encode(char));

    // check that the value extracts as expected
    char extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, aChar);

    // also test WOTest_charValue method
    WO_TEST_EQ([value WOTest_charValue], aChar);
}

- (void)testIntConvenienceMethods
{
    // test valueWithInt
    int anInt = 20;
    NSValue *value = [NSValue WOTest_valueWithInt:anInt];

    // check type
    WO_TEST_EQ([value objCType], @encode(int));

    // check that the value extracts as expected
    int extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, anInt);

    // also test WOTest_intValue method
    WO_TEST_EQ([value WOTest_intValue], anInt);
}

- (void)testShortConvenienceMethods
{
    // test valueWithShort
    short aShort = 100;
    NSValue *value = [NSValue WOTest_valueWithShort:aShort];

    // check type
    WO_TEST_EQ([value objCType], @encode(short));

    // check that the value extracts as expected
    short extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, aShort);

    // also test WOTest_shortValue method
    WO_TEST_EQ([value WOTest_shortValue], aShort);
}

- (void)testLongConvenienceMethods
{
    // test valueWithLong
    long aLong = 200;
    NSValue *value = [NSValue WOTest_valueWithLong:aLong];

    // check type
    WO_TEST_EQ([value objCType], @encode(long));

    // check that the value extracts as expected
    long extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, aLong);

    // also test WOTest_longValue method
    WO_TEST_EQ([value WOTest_longValue], aLong);
}

- (void)testLongLongConvenienceMethods
{
    // test valueWithLongLong
    long long aLongLong = 5;
    NSValue *value = [NSValue WOTest_valueWithLongLong:aLongLong];

    // check type
    WO_TEST_EQ([value objCType], @encode(long long));

    // check that the value extracts as expected
    long long extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, aLongLong);

    // also test WOTest_longLongValue method
    WO_TEST_EQ([value WOTest_longLongValue], aLongLong);
}

- (void)testUnsignedCharConvenienceMethods
{
    // test valueWithUnsignedChar
    unsigned char anUnsignedChar = 'a';
    NSValue *value = [NSValue WOTest_valueWithUnsignedChar:anUnsignedChar];

    // check type
    WO_TEST_EQ([value objCType], @encode(unsigned char));

    // check that the value extracts as expected
    unsigned char extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, anUnsignedChar);

    // also test WOTest_unsignedCharValue method
    WO_TEST_EQ([value WOTest_unsignedCharValue], anUnsignedChar);
}

- (void)testUnsignedIntConvenienceMethods
{
    // test valueWithUnsignedInt
    unsigned int anUnsignedInt = 100;
    NSValue *value = [NSValue WOTest_valueWithUnsignedInt:anUnsignedInt];

    // check type
    WO_TEST_EQ([value objCType], @encode(unsigned int));

    // check that the value extracts as expected
    unsigned int extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, anUnsignedInt);

    // also test WOTest_unsignedIntValue method
    WO_TEST_EQ([value WOTest_unsignedIntValue], anUnsignedInt);
}

- (void)testUnsignedShortConvenienceMethods
{
    // test valueWithUnsignedShort
    unsigned short anUnsignedShort = 40;
    NSValue *value = [NSValue WOTest_valueWithUnsignedShort:anUnsignedShort];

    // check type
    WO_TEST_EQ([value objCType], @encode(unsigned short));

    // check that the value extracts as expected
    unsigned short extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, anUnsignedShort);

    // also test WOTest_unsignedShortValue method
    WO_TEST_EQ([value WOTest_unsignedShortValue], anUnsignedShort);
}

- (void)testUnsignedLongConvenienceMethods
{
    // test valueWithUnsignedLong
    unsigned long anUnsignedLong = 2000;
    NSValue *value = [NSValue WOTest_valueWithUnsignedLong:anUnsignedLong];

    // check type
    WO_TEST_EQ([value objCType], @encode(unsigned long));

    // check that the value extracts as expected
    unsigned long extracted = 0;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, anUnsignedLong);

    // also test WOTest_unsignedLongValue method
    WO_TEST_EQ([value WOTest_unsignedLongValue], anUnsignedLong);
}

- (void)testUnsignedLongLongConvenienceMethods
{
    // test valueWithUnsignedLongLong
    unsigned long long anUnsignedLongLong = 20, extracted = 0;
    NSValue *value = [NSValue WOTest_valueWithUnsignedLongLong:anUnsignedLongLong];

    // check type
    WO_TEST_EQ([value objCType], @encode(unsigned long long));

    // check that the value extracts as expected
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, anUnsignedLongLong);

    // also test WOTest_unsignedLongLongValue method
    WO_TEST_EQ([value WOTest_unsignedLongLongValue], anUnsignedLongLong);
}

- (void)testFloatConvenienceMethods
{
    // test valueWithFloat
    float aFloat = 10.0, extracted = 0.0;
    NSValue *value = [NSValue WOTest_valueWithFloat:aFloat];

    // check type
    WO_TEST_EQ([value objCType], @encode(float));

    // check that the value extracts as expected
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, aFloat);

    // also test WOTest_floatValue method
    WO_TEST_EQ([value WOTest_floatValue], aFloat);
}

- (void)testDoubleConvenienceMethods
{
    double aDouble = 20.0, extracted = 0.0;
    NSValue *value = [NSValue WOTest_valueWithDouble:aDouble];
    WO_TEST_EQ([value objCType], @encode(double));  // check type
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, aDouble);                 // check extracts
    WO_TEST_EQ([value WOTest_doubleValue], aDouble);       // also test WOTest_doubleValue
}

- (void)testC99BoolConvenienceMethods
{
    _Bool aC99Bool = 1, extracted = 0;
    NSValue *value = [NSValue WOTest_valueWithC99Bool:aC99Bool];
    WO_TEST_EQ([value objCType], @encode(_Bool));   // check type
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, aC99Bool);                // check extracts
    WO_TEST_EQ([value WOTest_C99BoolValue], aC99Bool);     // also test WOTest_C99BoolValue
}

- (void)testConstantCharacterStringConvenienceMethods
{
    // test valueWithObject
    const char *string = "foo";
    NSValue *value = [NSValue WOTest_valueWithConstantCharacterString:string];

    // check type
    WO_TEST_EQ([value objCType], @encode(const char *));

    // check that the value extracts as expected
    const char *extracted;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, string);

    // also test WOTest_constantCharacterStringValue method
    WO_TEST_EQ([value WOTest_constantCharacterStringValue], string);
}

- (void)testCharacterStringConvenienceMethods
{
    // test valueWithObject
    char *string = "foo";
    NSValue *value = [NSValue WOTest_valueWithCharacterString:string];

    // check type
    WO_TEST_EQ([value objCType], @encode(char *));

    // check that the value extracts as expected
    char *extracted = NULL;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, string);

    // also test WOTest_characterStringValue method
    WO_TEST_EQ([value WOTest_characterStringValue], string);
}

- (void)testObjectConvenienceMethods
{
    // test valueWithObject
    NSValue *value = [NSValue WOTest_valueWithObject:self];

    // check type
    WO_TEST_EQ([value objCType], @encode(id));

    // check that the value extracts as expected
    id extracted = nil;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, self);

    // also test WOTest_objectValue method
    WO_TEST_EQ([value WOTest_objectValue], self);
}

- (void)testClassConvenienceMethods
{
    // test valueWithClass
    NSValue *value = [NSValue WOTest_valueWithClass:[self class]];

    // check type
    WO_TEST_EQ([value objCType], @encode(Class));

    // check that the value extracts as expected
    Class extracted = NULL;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, [self class]);

    // also test WOTest_classValue method
    WO_TEST_EQ([value WOTest_classValue], [self class]);
}

- (void)testSelectorConvenienceMethods
{
    // test valueWithSelector
    NSValue *value = [NSValue WOTest_valueWithSelector:_cmd];

    // check type
    WO_TEST_EQ([value objCType], @encode(SEL));

    // check that the value extracts as expected
    SEL extracted = NULL;
    [value getValue:&extracted];
    WO_TEST_EQ(extracted, _cmd);

    // also test WOTest_selectorValue method
    WO_TEST_EQ([value WOTest_selectorValue], _cmd);
}

- (void)testSizeCalculationsForScalars
{
    // preliminaries
    NSValue *value = nil;

    // test with int
    int i = 0;
    value = [NSValue value:&i withObjCType:@encode(int)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(int));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(int));

    // test with unsigned int
    unsigned int ui = 0;
    value = [NSValue value:&ui withObjCType:@encode(unsigned int)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(unsigned int));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(unsigned int));

    // test with short
    short s = 0;
    value = [NSValue value:&s withObjCType:@encode(short)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(short));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(short));

    // test with unsigned short
    unsigned short us = 0;
    value = [NSValue value:&us withObjCType:@encode(unsigned short)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(unsigned short));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(unsigned short));

    // test with long
    long l = 0;
    value = [NSValue value:&l withObjCType:@encode(int)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(int));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(int));

    // test with unsigned long
    unsigned long ul = 0;
    value = [NSValue value:&ul withObjCType:@encode(unsigned long)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(unsigned long));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(unsigned long));

    // test with long long
    long long ll = 0;
    value = [NSValue value:&ll withObjCType:@encode(long long)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(long long));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(long long));

    // test with unsigned long long
    unsigned long long ull = 0;
    value = [NSValue value:&ull withObjCType:@encode(unsigned long long)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(unsigned long long));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(unsigned long long));

    // test with float
    float f = 0;
    value = [NSValue value:&f withObjCType:@encode(float)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(float));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(float));

    // test with double
    double d = 0;
    value = [NSValue value:&d withObjCType:@encode(double)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(double));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(double));

    // test with char
    char c = 0;
    value = [NSValue value:&c withObjCType:@encode(char)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(char));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(char));

    // test with unsigned char
    unsigned char uc = 0;
    value = [NSValue value:&uc withObjCType:@encode(unsigned char)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(unsigned char));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(unsigned char));

    // test with C99 _Bool
    _Bool b = 0;
    value = [NSValue value:&b withObjCType:@encode(_Bool)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(_Bool));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(_Bool));
}

- (void)testSizeCalculationsForStructs
{
    // preliminaries
    NSValue *value = nil;

    // test with NSRange
    NSRange range = NSMakeRange(100, 100);
    value = [NSValue valueWithRange:range];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(NSRange));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(NSRange));

    // test with NSPoint
    NSPoint point;
    point.x = 100.0f; // can't use NSMakePoint (warnings on Intel release builds)
    point.y = 100.0f;
    value = [NSValue valueWithPoint:point];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(NSPoint));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(NSPoint));

    // test with NSRect
    NSRect rect = NSMakeRect(100.0, 100.0, 100.0, 100.0);
    value = [NSValue valueWithRect:rect];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(NSRect));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(NSRect));

    // test with simple custom struct
    WOSimpleStruct simple;
    value = [NSValue valueWithBytes:&simple objCType:@encode(WOSimpleStruct)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOSimpleStruct));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOSimpleStruct));

    // test with complicated custom structs
    WOSubstruct substruct;
    value = [NSValue valueWithBytes:&substruct objCType:@encode(WOSubstruct)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOSubstruct));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOSubstruct));

    WOComplicatedStruct complicated;
    value = [NSValue valueWithBytes:&complicated objCType:@encode(WOComplicatedStruct)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOComplicatedStruct));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOComplicatedStruct));

    // test with anonymous struct
    WOAnonymousStruct anonymous;
    value = [NSValue valueWithBytes:&anonymous objCType:@encode(WOAnonymousStruct)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOAnonymousStruct));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOAnonymousStruct));
}

- (void)testSizeCalculationsForUnions
{
    // preliminaries
    NSValue *value = nil;

    // test with WOSimpleUnion
    WOSimpleUnion simple;
    value = [NSValue valueWithBytes:&simple objCType:@encode(WOSimpleUnion)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOSimpleUnion));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOSimpleUnion));

    // test with WOSubunion
    WOSubunion subunion;
    value = [NSValue valueWithBytes:&subunion objCType:@encode(WOSubunion)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOSubunion));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOSubunion));

    // test with WOComplicatedUnion
    WOComplicatedUnion complicated;
    value = [NSValue valueWithBytes:&complicated objCType:@encode(WOComplicatedUnion)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOComplicatedUnion));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOComplicatedUnion));

    // test with anonymous union
    WOAnonymousUnion anonymous;
    value = [NSValue valueWithBytes:&anonymous objCType:@encode(WOAnonymousUnion)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(WOAnonymousUnion));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(WOAnonymousUnion));
}

// tests fo id, Class, SEL (really just pointers)
- (void)testSizeCalculationsForObjects
{
    // preliminaries
    NSValue *value = nil;

    // test with id
    id i = self;
    value = [NSValue valueWithBytes:&i objCType:@encode(id)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(id));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(id));

    // test with Class
    Class c = [self class];
    value = [NSValue valueWithBytes:&c objCType:@encode(Class)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(Class));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(Class));

    // test with SEL
    SEL s = _cmd;
    value = [NSValue valueWithBytes:&s objCType:@encode(SEL)];
    WO_TEST_GTE([NSValue WOTest_sizeForType:[value WOTest_objCTypeString]], sizeof(SEL));
    WO_TEST_GTE([value WOTest_bufferSize], sizeof(SEL));
}

- (void)testSizeCalculationsForPointers
{
    // preliminaries
    NSValue *value = nil;

    // test with function pointers



}

- (void)testSizeCalculationsForArrays
{
    // preliminaries
    NSValue *value = nil;

}

- (void)testTypeStringMethods
{
    // preliminaries
    NSString            *typeString;

    // numeric scalar types
    _Bool               b;
    char                c;
    unsigned char       uc;
    short               s;
    unsigned short      us;
    int                 i;
    unsigned int        ui;
    long                l;
    unsigned long       ul;
    long long           ll;
    unsigned long long  ull;
    float               f;
    double              d;

    // pointers etc
    id                  object;
    Class               class;
    SEL                 selector;
    void                *pVoid;
    char                *pChar;
    const char          *pConstChar;
    int                 *pInt;

    // compound types
    WOComplicatedStruct aStruct;
    WOComplicatedUnion  aUnion;
    char                anArray[100];

    // special case: function pointers
    float               (*pFunction)(float, float, float);

    // test type is _Bool
    typeString = [NSString stringWithUTF8String:@encode(typeof(b))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is char
    typeString = [NSString stringWithUTF8String:@encode(typeof(c))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is unsigned char
    typeString = [NSString stringWithUTF8String:@encode(typeof(uc))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is short
    typeString = [NSString stringWithUTF8String:@encode(typeof(s))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is unsigned short
    typeString = [NSString stringWithUTF8String:@encode(typeof(us))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is int
    typeString = [NSString stringWithUTF8String:@encode(typeof(i))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is unsigned int
    typeString = [NSString stringWithUTF8String:@encode(typeof(ui))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is long
    typeString = [NSString stringWithUTF8String:@encode(typeof(l))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is unsigned long
    typeString = [NSString stringWithUTF8String:@encode(typeof(ul))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is long long
    typeString = [NSString stringWithUTF8String:@encode(typeof(ll))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is unsigned long long
    typeString = [NSString stringWithUTF8String:@encode(typeof(ull))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is float
    typeString = [NSString stringWithUTF8String:@encode(typeof(f))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is double
    typeString = [NSString stringWithUTF8String:@encode(typeof(d))];
    WO_TEST([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is id
    typeString = [NSString stringWithUTF8String:@encode(typeof(object))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is Class
    typeString = [NSString stringWithUTF8String:@encode(typeof(class))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is SEL
    typeString = [NSString stringWithUTF8String:@encode(typeof(selector))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is pointer to void
    typeString = [NSString stringWithUTF8String:@encode(typeof(pVoid))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is character string
    typeString = [NSString stringWithUTF8String:@encode(typeof(pChar))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is constant character string
    typeString = [NSString stringWithUTF8String:@encode(typeof(pConstChar))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is pointer to int
    typeString = [NSString stringWithUTF8String:@encode(typeof(pInt))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is struct
    typeString = [NSString stringWithUTF8String:@encode(typeof(aStruct))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is union
    typeString = [NSString stringWithUTF8String:@encode(typeof(aUnion))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is array
    typeString = [NSString stringWithUTF8String:@encode(typeof(anArray))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);

    // test type is a function pointer ("^?")
    typeString = [NSString stringWithUTF8String:@encode(typeof(pFunction))];
    WO_TEST_FALSE([NSValue WOTest_typeIsNumericScalar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCompound:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedChar:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedInt:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedShort:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnsignedLongLong:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsFloat:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsDouble:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsC99Bool:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsVoid:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsConstantCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsCharacterString:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsObject:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsClass:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsSelector:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsPointerToVoid:typeString]);
    WO_TEST([NSValue WOTest_typeIsPointer:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsArray:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsStruct:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnion:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsBitfield:typeString]);
    WO_TEST_FALSE([NSValue WOTest_typeIsUnknown:typeString]);
}

- (void)testBugBadCastsToUnsignedChar
{
    // preliminaries
    BOOL warns = [WO_TEST_SHARED_INSTANCE warnsAboutSignComparisons];
    [WO_TEST_SHARED_INSTANCE setWarnsAboutSignComparisons:NO];

    // due to some bad casts, comparing values too large to fit in an unsigned char was failing in specific cases
    // the signed value was being cast to unsigned char in these cases, thus getting truncated
    // this meant that tests would fail with messages like "expected (int)1000, got (unsigned int)1000"

    WO_TEST_EQ(1000U, 1000);            // this is the unsigned int versus int case
    WO_TEST_EQ(1000UL, 1000);           // same bug for unsigned long compared with int

    unsigned long long ullValue = 1000;
    WO_TEST_EQ(ullValue, 1000);         // same bug for unsigned long long compared with int

    short shortValue = 1000;
    WO_TEST_EQ(1000U, shortValue);      // same bug for unsigned compared with short
    WO_TEST_EQ(1000UL, shortValue);     // and unsigned long compared with short
    WO_TEST_EQ(ullValue, shortValue);   // and unsigned long long compared with short

    WO_TEST_EQ(1000U, 1000L);           // and unsigned int versus long
    WO_TEST_EQ(1000UL, 1000L);          // and unsigned long compared with long
    WO_TEST_EQ(ullValue, 1000L);        // and unsigned long long compared with long

    long long llValue = 1000;
    WO_TEST_EQ(ullValue, llValue);      // and unsigned long long compared with long long

    // cleanup
    [WO_TEST_SHARED_INSTANCE setWarnsAboutSignComparisons:warns];
}

@end
