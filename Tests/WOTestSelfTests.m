//
//  WOTestSelfTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 15 October 2004.
//
//  Copyright 2004-2007 Wincent Colaiuta.
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

#import "WOTestSelfTests.h"

#import <objc/objc-class.h>
#import <objc/objc-runtime.h>
#import <objc/Protocol.h>

// empty class that does not have the WOTest marker protocol at compile time
@interface WOEmpty : NSObject {

}

@end

@implementation WOEmpty

NSMutableArray *WOEmptyClassMethodInvocations;
NSMutableArray *WOEmptyInstanceMethodInvocations;

+ (void)initialize
{
    WOEmptyClassMethodInvocations = [NSMutableArray arrayWithCapacity:3];
    WOEmptyInstanceMethodInvocations = [NSMutableArray arrayWithCapacity:3];
}

+ (void)verify
{
    // were class methods called in order?
    NSArray *expectedClassMethods = [NSArray arrayWithObjects:@"preflight", @"testClassMethod", @"postflight", nil];
    NSAssert([expectedClassMethods isEqualToArray:WOEmptyClassMethodInvocations], @"Class method verification failed");

    // were instance methods called in order?
    NSArray *expectedInstanceMethods = [NSArray arrayWithObjects:@"preflight", @"testInstanceMethod", @"postflight", nil];
    NSAssert([expectedInstanceMethods isEqualToArray:WOEmptyInstanceMethodInvocations], @"Instance method verification failed");
}

+ (void)preflight
{
    [WOEmptyClassMethodInvocations addObject:NSStringFromSelector(_cmd)];
}

+ (void)testClassMethod
{
    [WOEmptyClassMethodInvocations addObject:NSStringFromSelector(_cmd)];
}

+ (void)postflight
{
    [WOEmptyClassMethodInvocations addObject:NSStringFromSelector(_cmd)];
}

- (void)preflight
{
    [WOEmptyInstanceMethodInvocations addObject:NSStringFromSelector(_cmd)];
}

- (void)testInstanceMethod
{
    [WOEmptyInstanceMethodInvocations addObject:NSStringFromSelector(_cmd)];
}

- (void)postflight
{
    [WOEmptyInstanceMethodInvocations addObject:NSStringFromSelector(_cmd)];
}

@end

// root class that does not implement the NSObject protocol
@interface WORootClass {

    Class isa;

}

@end

@implementation WORootClass

+ (id)new
{
    Class class = object_getClass(self);
    return class_createInstance(class, 0);
}

// http://www.geocities.com/chrootstrap/custom_objective_c_root_classes.html
// http://darwinsource.opendarwin.org/10.3/objc4-235/runtime/Messengers.subproj/objc-msg-ppc.s
// Apple's runtime makes the assumption that this method is implemented
- forward:(SEL)sel :(marg_list)args
{
    return self; // although it behaves equally if I return nil here

    /*

     TODO: figure out how to make it crash if you send it a selector it doesn't recognize

     [Object crashes];      // crashes
     [Protocol foobar];     // crashes (inherits behavior from Object)
     [NSObject foobar];     // raises exception, selector not recognized
     [WORootClass foobar];  // continues execution, no warning

    */
}

@end

#pragma mark -
#pragma mark Unit tests

@implementation WOTestSelfTests

+ (void)initialize
{
    // seeding with 1 produces repeatable test results across runs
    [WO_TEST_SHARED_INSTANCE seedRandomNumberGenerator:1];

    // TODO: set up mock object here to expect that +testClassMethods gets run
}

+ (void)testClassMethods
{
    // make sure that class methods run (not just instance methods)
    // TODO: do I need a mock object here to test that the test is run?
    WO_TEST_PASS;
}

+ (void)preflight
{
    [WO_TEST_SHARED_INSTANCE setExpectLowLevelExceptions:NO];
}

+ (void)postflight
{

}

- (void)preflight
{

}

- (void)postflight
{

}

- (void)testTestRunningMethods
{
    NSSet *expectedMethods = [NSSet setWithObjects:
        @"+testClassMethods",
        @"-testTestRunningMethods",
        @"-testTestableMethodsFrom",
        @"-testPreAndPostflightMethods",
        @"-testEmptyTests",
        @"-testBooleanTests",
        @"-testNSValueCategory",
        @"-testNSExceptionCategory",
        @"-testNSStringCategory",
        @"-testNSValueCategory",
        @"-testPointerToVoidTests",
        @"-testIntTests",
        @"-testUnsignedTests",
        @"-testFloatTests",
        @"-testFloatWithErrorMarginTests",
        @"-testDoubleTests",
        @"-testDoubleWithErrorMarginTests",
        @"-testObjectTests",
        @"-testStringTests",
        @"-testArrayTests",
        @"-testDictionaryTests",
        @"-testShorthandMacros",
        @"-testExceptionTests",
        @"-testLowLevelExceptionTests",
        @"-testRandomValueGeneratorMethods", nil];

    NSSet *actualMethods =[NSSet setWithArray:
        [WO_TEST_SHARED_INSTANCE testableMethodsFrom:[self class]]];

    WO_TEST_EQ(expectedMethods, actualMethods);
    //WO_TEST_ARRAYS_EQUAL(expectedMethods, actualMethods);
    // TODO: write WO_TEST_SETS_EQUAL
    // TODO: write shorthand macros for like WO_TEST_ARRAYS_EQ

    WO_TEST_THROWS([WO_TEST_SHARED_INSTANCE runTestsForClassName:nil]);
    WO_TEST_THROWS([WO_TEST_SHARED_INSTANCE runTestsForClass:nil]);
}

- (void)testTestableMethodsFrom
{
    // should throw (but not crash) when passed an "id" instead of a "Class"
    WO_TEST_THROWS([WO_TEST_SHARED_INSTANCE testableMethodsFrom:(Class)self]);

    // should find class and instance methods beginning with "test"
    NSSet *expectedMethods = [NSSet setWithObjects:
        @"+testClassMethod", @"-testInstanceMethod", nil];
    NSSet *actualMethods = [NSSet setWithArray:
        [WO_TEST_SHARED_INSTANCE testableMethodsFrom:[WOEmpty class]]];
    WO_TEST_EQ(expectedMethods, actualMethods);
}

- (void)testPreAndPostflightMethods
{
    /*

     Testing whether methods get called in order requires some tricky runtime
     hackery. First of all we start with the WOEmpty class which is not marked
     with the WOTest protocol. This prevents its test methods from being run
     until we are ready to run them.

     We then add the marker protocol at runtime so that the tests can be run.

     It would be nice to be able to use mock objects to verify that the methods
     on the WOEmpty class are being called but unfortunately it's not possible
     for two reasons: firstly, mock objects are just that (objects) whereas the
     test running methods work on classes (not instances); secondly, because the
     test running methods work at a very low level in the runtime we can't just
     use a WOClassMock -- once again, a class mock is just an object whereas the
     low-level test running methods work directly with classes in the runtime.

     TODO: use objc_allocateClassPair() to create classes on the fly (better class mock implementation)

     So we unfortunately have to upgrade WOEmpty to be a real stub and we can't
     benefit from the shortcuts provided by the WOMock cluster.

     The runtime hackery cannot be avoided by labelling the WOEmpty class with
     the WOTest marker at compile time because we have no way of knowing the
     order in which classes will be tested and so we cannot know when to fire
     the verify method. The hackery is the only way in which we can have total
     control over the timing of the WOEmpty tests.

     */

     // confirm that WOEmpty does not conform to protocol
     NSAssert([WOEmpty conformsToProtocol:@protocol(WOTest)] == NO, @"WOEmpty already conforms to WOTest protocol");

     // build new protocol entry
     Protocol *protocol = @protocol(WOTest);
     struct objc_protocol_list *new;
     new = calloc(1, sizeof(struct objc_protocol_list)); // never free
     NSAssert1(new != NULL, @"calloc() failed (size %d)", sizeof(struct objc_protocol_list));
     new->count = 1;
     new->list[0] = protocol;
     NSAssert(class_addProtocol([WOEmpty class], protocol), @"class_addProtocol failed");
     NSAssert([WOEmpty conformsToProtocol:@protocol(WOTest)], @"WOEmpty class does not conform to WOTest protocol");

     // perform the actual "tests" (even though WOEmpty contains no real tests)
     [WO_TEST_SHARED_INSTANCE runTestsForClass:[WOEmpty class]];
     WO_TEST_DOES_NOT_THROW([WOEmpty verify]);
}

- (void)wouldTestTestWrappers
{
    // can't actually test that the wrappers work, can only demonstrate what they would do if we were to include bad code in a test
    WO_TEST_NOT_NIL([@"short" substringToIndex:10000]);
}

- (void)testEmptyTests
{
    // should pass
    WO_TEST_PASS;

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];
    WO_TEST_FAIL;
    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO];
}

- (void)testBooleanTests
{
    // should pass
    WO_TEST_TRUE(YES);
    WO_TEST_FALSE(NO);

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];

    WO_TEST_TRUE(NO);
    WO_TEST_FALSE(YES);

    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO];
}

// arguably the most important code in the framework, so *lots* of tests
- (void)testNSValueCategory
{
    // should pass

    // objects
    NSString    *string1    = @"flippant";
    NSString    *string2    = [NSString stringWithString:@"flippant"];
    NSString    *string3    = @"bonanza";
    NSString    *string4    = @"";
    NSString    *string5    = nil;
    NSString    *string6    = nil;
    NSArray     *array1     = [NSArray arrayWithObjects:@"1", @"2", nil];
    NSArray     *array2     = [NSArray arrayWithObjects:@"1", @"2", nil];
    NSArray     *array3     = [NSArray arrayWithObject:@"dirt"];
    NSArray     *array4     = [NSArray array];
    NSArray     *array5     = nil;
    NSArray     *array6     = nil;

    WO_TEST_EQUAL(string1, string2);
    WO_TEST_EQUAL(string2, string1);        // order shouldn't matter
    WO_TEST_EQUAL(string5, string6);        // nil equals nil
    WO_TEST_EQUAL(nil, nil);
    WO_TEST_EQUAL(nil, string5);
    WO_TEST_EQUAL(string5, nil);
    WO_TEST_NOT_EQUAL(nil, string1);
    WO_TEST_NOT_EQUAL(string1, nil);
    WO_TEST_NOT_EQUAL(string2, string3);
    WO_TEST_NOT_EQUAL(string3, string2);
    WO_TEST_NOT_EQUAL(string2, string4);
    WO_TEST_NOT_EQUAL(string4, string2);
    WO_TEST_NOT_EQUAL(string2, string5);
    WO_TEST_NOT_EQUAL(string5, string2);
    WO_TEST_NOT_EQUAL(string4, string5);    // @"" does not equal nil
    WO_TEST_NOT_EQUAL(string5, string4);
    WO_TEST_NOT_EQUAL(string5, string3);
    WO_TEST_NOT_EQUAL(string3, string5);

    WO_TEST_EQUAL(array1, array2);
    WO_TEST_EQUAL(array2, array1);
    WO_TEST_EQUAL(array5, array6);
    WO_TEST_NOT_EQUAL(array2, array3);
    WO_TEST_NOT_EQUAL(array3, array2);
    WO_TEST_NOT_EQUAL(array2, array4);
    WO_TEST_NOT_EQUAL(array4, array2);
    WO_TEST_NOT_EQUAL(array2, array5);
    WO_TEST_NOT_EQUAL(array5, array2);
    WO_TEST_NOT_EQUAL(array4, array5);
    WO_TEST_NOT_EQUAL(array5, array4);
    WO_TEST_NOT_EQUAL(array5, array3);
    WO_TEST_NOT_EQUAL(array3, array5);

    WO_TEST_EQUAL(string5, array5);         // (id)nil == (id)nil
    WO_TEST_EQUAL(array5, string5);
    WO_TEST_NOT_EQUAL(string4, array4);
    WO_TEST_NOT_EQUAL(array4, string4);
    WO_TEST_NOT_EQUAL(string2, array2);
    WO_TEST_NOT_EQUAL(array2, string2);
    WO_TEST_NOT_EQUAL(string1, array1);
    WO_TEST_NOT_EQUAL(array1, string1);

    // class objects
    Class class1 = [NSString class];
    Class class2 = [NSString class];
    Class class3 = [NSMutableDictionary class];
    Class class4 = [NSDictionary class];
    Class class5 = nil;
    Class class6 = nil;

    WO_TEST_EQUAL(class1, class2);
    WO_TEST_EQUAL(class2, class1);      // order shouldn't matter
    WO_TEST_EQUAL(class5, class6);      // nil equals nil
    WO_TEST_EQUAL(class6, class5);
    WO_TEST_NOT_EQUAL(class1, class3);
    WO_TEST_NOT_EQUAL(class3, class1);
    WO_TEST_NOT_EQUAL(class3, class4);
    WO_TEST_NOT_EQUAL(class4, class3);
    WO_TEST_NOT_EQUAL(class4, class5);
    WO_TEST_NOT_EQUAL(class5, class4);

    WO_TEST_NOT_EQUAL(string5, class5); // different types (even if both nil)
    WO_TEST_NOT_EQUAL(class5, string5);
    WO_TEST_NOT_EQUAL(string1, class1); // class obj is not an instance obj
    WO_TEST_NOT_EQUAL(class1, string1);
    WO_TEST_NOT_EQUAL(string4, class1); // even if instance obj is empty
    WO_TEST_NOT_EQUAL(class1, string4);

    // selectors
    SEL selector1   = @selector(stringWithString:);
    SEL selector2   = @selector(stringWithString:);
    SEL selector3   = @selector(init);
    SEL selector4   = NULL;
    SEL selector5   = NULL;

    WO_TEST_EQUAL(selector1, selector2);
    WO_TEST_EQUAL(selector2, selector1);
    WO_TEST_NOT_EQUAL(selector2, selector3);
    WO_TEST_NOT_EQUAL(selector3, selector2);
    WO_TEST_NOT_EQUAL(selector3, selector4);
    WO_TEST_NOT_EQUAL(selector4, selector3);
    WO_TEST_EQUAL(selector4, selector5);
    WO_TEST_EQUAL(selector5, selector4);

    WO_TEST_NOT_EQUAL(selector1, class1);   // different types
    WO_TEST_NOT_EQUAL(class1, selector1);
    WO_TEST_NOT_EQUAL(selector1, string1);
    WO_TEST_NOT_EQUAL(string1, selector1);
    WO_TEST_NOT_EQUAL(selector5, class5);   // even if both nil/NULL
    WO_TEST_NOT_EQUAL(class5, selector5);
    WO_TEST_NOT_EQUAL(selector5, string6);
    WO_TEST_NOT_EQUAL(string6, selector5);

    // values of matching types
    char char1 = 'a';
    char char2 = 'a';
    char char3 = 'b';
    char char4 = 0;
    char char5 = 0;
    WO_TEST_EQUAL(char1, char2);
    WO_TEST_EQUAL(char2, char1);        // order shouldn't matter
    WO_TEST_NOT_EQUAL(char2, char3);
    WO_TEST_NOT_EQUAL(char3, char2);
    WO_TEST_NOT_EQUAL(char3, char4);
    WO_TEST_NOT_EQUAL(char4, char3);
    WO_TEST_EQUAL(char4, char5);
    WO_TEST_EQUAL(char5, char4);

    int int1 = 10;
    int int2 = 10;
    int int3 = 50;
    WO_TEST_EQUAL(int1, int2);
    WO_TEST_EQUAL(int2, int1);
    WO_TEST_NOT_EQUAL(int2, int3);
    WO_TEST_NOT_EQUAL(int3, int2);

    // need to test all of the different kinds of casts


    // char, char
    // char, int
    // char, short
    // char, long
    // char, long long
    // char, unsigned char
    // char, unsigned int
    // char, unsigned short
    // char, unsigned long
    // char, unsigned long long
    // char, float
    // char, double
    // char, C99 _Bool
    // char, void *
    // char, char *


    // int, char
    // int, int
    // int, short
    // int, long
    // int, long long
    // int, unsigned char
    // int, unsigned int
    // int, unsigned short
    // int, unsigned long
    // int, unsigned long long
    // int, float
    // int, double
    // int, C99 _Bool
    // int, void *
    // int, char *

    // short, char
    // short, int
    // short, short
    // short, long
    // short, long long
    // short, unsigned char
    // short, unsigned int
    // short, unsigned short
    // short, unsigned long
    // short, unsigned long long
    // short, float
    // short, double
    // short, C99 _Bool
    // short, void *
    // short, char *

    // long, char
    // long, int
    // long, short
    // long, long
    // long, long long
    // long, unsigned char
    // long, unsigned int
    // long, unsigned short
    // long, unsigned long
    // long, unsigned long long
    // long, float
    // long, double
    // long, C99 _Bool
    // long, void *
    // long, char *

    // long long, char
    // long long, int
    // long long, short
    // long long, long
    // long long, long long
    // long long, unsigned char
    // long long, unsigned int
    // long long, unsigned short
    // long long, unsigned long
    // long long, unsigned long long
    // long long, float
    // long long, double
    // long long, C99 _Bool
    // long long, void *
    // long long, char *

    // unsigned char, char
    // unsigned char, int
    // unsigned char, short
    // unsigned char, long
    // unsigned char, long long
    // unsigned char, unsigned char
    // unsigned char, unsigned int
    // unsigned char, unsigned short
    // unsigned char, unsigned long
    // unsigned char, unsigned long long
    // unsigned char, float
    // unsigned char, double
    // unsigned char, C99 _Bool
    // unsigned char, void *
    // unsigned char, char *

    // unsigned int, char
    // unsigned int, int
    // unsigned int, short
    // unsigned int, long
    // unsigned int, long long
    // unsigned int, unsigned char
    // unsigned int, unsigned int
    // unsigned int, unsigned short
    // unsigned int, unsigned long
    // unsigned int, unsigned long long
    // unsigned int, float
    // unsigned int, double
    // unsigned int, C99 _Bool
    // unsigned int, void *
    // unsigned int, char *

    // unsigned short, char
    // unsigned short, int
    // unsigned short, short
    // unsigned short, long
    // unsigned short, long long
    // unsigned short, unsigned char
    // unsigned short, unsigned int
    // unsigned short, unsigned short
    // unsigned short, unsigned long
    // unsigned short, unsigned long long
    // unsigned short, float
    // unsigned short, double
    // unsigned short, C99 _Bool
    // unsigned short, void *
    // unsigned short, char *

    // unsigned long, char
    // unsigned long, int
    // unsigned long, short
    // unsigned long, long
    // unsigned long, long long
    // unsigned long, unsigned char
    // unsigned long, unsigned int
    // unsigned long, unsigned short
    // unsigned long, unsigned long
    // unsigned long, unsigned long long
    // unsigned long, float
    // unsigned long, double
    // unsigned long, C99 _Bool
    // unsigned long, void *
    // unsigned long, char *

    // unsigned long long, char
    // unsigned long long, int
    // unsigned long long, short
    // unsigned long long, long
    // unsigned long long, long long
    // unsigned long long, unsigned char
    // unsigned long long, unsigned int
    // unsigned long long, unsigned short
    // unsigned long long, unsigned long
    // unsigned long long, unsigned long long
    // unsigned long long, float
    // unsigned long long, double
    // unsigned long long, C99 _Bool
    // unsigned long long, void *
    // unsigned long long, char *

    // float, char
    // float, int
    // float, short
    // float, long
    // float, long long
    // float, unsigned char
    // float, unsigned int
    // float, unsigned short
    // float, unsigned long
    // float, unsigned long long
    // float, float
    // float, double
    // float, C99 _Bool
    // float, void *
    // float, char *

    // double, char
    // double, int
    // double, short
    // double, long
    // double, long long
    // double, unsigned char
    // double, unsigned int
    // double, unsigned short
    // double, unsigned long
    // double, unsigned long long
    // double, float
    // double, double
    // double, C99 _Bool
    // double, void *
    // double, char *

    // C99 _Bool, char
    // C99 _Bool, int
    // C99 _Bool, short
    // C99 _Bool, long
    // C99 _Bool, long long
    // C99 _Bool, unsigned char
    // C99 _Bool, unsigned int
    // C99 _Bool, unsigned short
    // C99 _Bool, unsigned long
    // C99 _Bool, unsigned long long
    // C99 _Bool, float
    // C99 _Bool, double
    // C99 _Bool, C99 _Bool
    // C99 _Bool, void *
    // C99 _Bool, char *

    // void *, char
    // void *, int
    // void *, short
    // void *, long
    // void *, long long
    // void *, unsigned char
    // void *, unsigned int
    // void *, unsigned short
    // void *, unsigned long
    // void *, unsigned long long
    // void *, float
    // void *, double
    // void *, C99 _Bool
    // void *, void *
    // void *, char *

    // char *, char
    // char *, int
    // char *, short
    // char *, long
    // char *, long long
    // char *, unsigned char
    // char *, unsigned int
    // char *, unsigned short
    // char *, unsigned long
    // char *, unsigned long long
    // char *, float
    // char *, double
    // char *, C99 _Bool
    // char *, void *
    // char *, char *



    // literal values
    WO_TEST_EQUAL(1000, 1000);
    WO_TEST_NOT_EQUAL(2000, 4000);

    // literal values with casts
    WO_TEST_EQUAL((float)10.0, (float)10.0);
    WO_TEST_NOT_EQUAL((float)10.0, (float)200.0);

    // literal values with mismatched casts
    WO_TEST_EQUAL((int)100, (long)100);
    WO_TEST_NOT_EQUAL((int)100, (long)1000);

    // compound values (variables)



    // compound values (literals)



    // compound values (variables + literals)



    // arrays


    // structures
    NSPoint point1  = {10.0f, 300.0f};
    NSPoint point2  = {10.0f, 300.0f};
    NSPoint point3  = NSZeroPoint;
    NSRange range1  = {10U, 30U};
    NSRange range2  = {10U, 30U};
    NSRange range3  = {0U, 199U};
    NSRect  rect1   = NSMakeRect(10.0, 20.0, 30.0, 40.0);
    NSRect  rect2   = NSMakeRect(10.0, 20.0, 30.0, 40.0);
    NSRect  rect3   = NSMakeRect(90.0, 80.0, 10.0, 100.0);
    NSSize  size1   = {1000.0f, 2000.0f};
    NSSize  size2   = {1000.0f, 2000.0f};
    NSSize  size3   = {20.0f, 4000.0f};
    WO_TEST_EQUAL(point1, point2);
    WO_TEST_NOT_EQUAL(point2, point3);  // different values
    WO_TEST_EQUAL(range1, range2);
    WO_TEST_NOT_EQUAL(range2, range3);  // different values
    WO_TEST_EQUAL(rect1, rect2);
    WO_TEST_NOT_EQUAL(rect2, rect3);    // different values
    WO_TEST_EQUAL(size1, size2);
    WO_TEST_NOT_EQUAL(size2, size3);    // different values
    WO_TEST_NOT_EQUAL(point1, rect1);   // incompatible types
    WO_TEST_NOT_EQUAL(rect2, point2);   // incompatible types
    WO_TEST_NOT_EQUAL(point1, range1);  // incompatible types
    WO_TEST_NOT_EQUAL(range2, point2);  // incompatible types
    WO_TEST_NOT_EQUAL(range1, rect1);   // incompatible types
    WO_TEST_NOT_EQUAL(rect2, range2);   // incompatible types
    WO_TEST_NOT_EQUAL(point1, size1);   // incompatible types
    WO_TEST_NOT_EQUAL(range1, size1);   // incompatible types
    WO_TEST_NOT_EQUAL(rect1, size1);    // incompatible types
    WO_TEST_NOT_EQUAL(size2, point2);   // incompatible types
    WO_TEST_NOT_EQUAL(size2, range2);   // incompatible types
    WO_TEST_NOT_EQUAL(size2, rect2);    // incompatible types

    // pointers









    // >, <, >=, <=
    char small  = 'd';
    char big    = 'z';
    char other  = 'd';

    WO_TEST_GREATER_THAN(big, small);
    WO_TEST_NOT_GREATER_THAN(small, big);
    WO_TEST_NOT_GREATER_THAN(small, other);

    WO_TEST_LESS_THAN(small, big);
    WO_TEST_NOT_LESS_THAN(big, small);
    WO_TEST_NOT_LESS_THAN(small, other);

    int negative    = -100;
    int middle      = 50;
    int positive    = 75;
    int otherMiddle = 50;

    WO_TEST_GREATER_THAN(middle, negative);
    WO_TEST_GREATER_THAN(positive, negative);
    WO_TEST_GREATER_THAN(positive, middle);

    WO_TEST_NOT_GREATER_THAN(middle, positive);
    WO_TEST_NOT_GREATER_THAN(negative, middle);
    WO_TEST_NOT_GREATER_THAN(negative, positive);
    WO_TEST_NOT_GREATER_THAN(middle, otherMiddle);

    WO_TEST_LESS_THAN(negative, middle);
    WO_TEST_LESS_THAN(negative, positive);
    WO_TEST_LESS_THAN(middle, positive);

    WO_TEST_NOT_LESS_THAN(middle, negative);
    WO_TEST_NOT_LESS_THAN(positive, middle);
    WO_TEST_NOT_LESS_THAN(positive, negative);
    WO_TEST_NOT_LESS_THAN(middle, otherMiddle);

    // casts to signed types
    WO_TEST_GREATER_THAN((short)big, (short)small);
    WO_TEST_NOT_GREATER_THAN((short)small, (short)big);
    WO_TEST_NOT_GREATER_THAN((short)small, (short)other);
    WO_TEST_LESS_THAN((short)small, (short)big);
    WO_TEST_NOT_LESS_THAN((short)big, (short)small);
    WO_TEST_NOT_LESS_THAN((short)small, (short)other);
    WO_TEST_GREATER_THAN((short)middle, (short)negative);
    WO_TEST_GREATER_THAN((short)positive, (short)negative);
    WO_TEST_GREATER_THAN((short)positive, (short)middle);
    WO_TEST_NOT_GREATER_THAN((short)middle, (short)positive);
    WO_TEST_NOT_GREATER_THAN((short)negative, (short)middle);
    WO_TEST_NOT_GREATER_THAN((short)negative, (short)positive);
    WO_TEST_NOT_GREATER_THAN((short)middle, (short)otherMiddle);
    WO_TEST_LESS_THAN((short)negative, (short)middle);
    WO_TEST_LESS_THAN((short)negative, (short)positive);
    WO_TEST_LESS_THAN((short)middle, (short)positive);
    WO_TEST_NOT_LESS_THAN((short)middle, (short)negative);
    WO_TEST_NOT_LESS_THAN((short)positive, (short)middle);
    WO_TEST_NOT_LESS_THAN((short)positive, (short)negative);
    WO_TEST_NOT_LESS_THAN((short)middle, (short)otherMiddle);

    WO_TEST_GREATER_THAN((long)big, (long)small);
    WO_TEST_NOT_GREATER_THAN((long)small, (long)big);
    WO_TEST_NOT_GREATER_THAN((long)small, (long)other);
    WO_TEST_LESS_THAN((long)small, (long)big);
    WO_TEST_NOT_LESS_THAN((long)big, (long)small);
    WO_TEST_NOT_LESS_THAN((long)small, (long)other);
    WO_TEST_GREATER_THAN((long)middle, (long)negative);
    WO_TEST_GREATER_THAN((long)positive, (long)negative);
    WO_TEST_GREATER_THAN((long)positive, (long)middle);
    WO_TEST_NOT_GREATER_THAN((long)middle, (long)positive);
    WO_TEST_NOT_GREATER_THAN((long)negative, (long)middle);
    WO_TEST_NOT_GREATER_THAN((long)negative, (long)positive);
    WO_TEST_NOT_GREATER_THAN((long)middle, (long)otherMiddle);
    WO_TEST_LESS_THAN((long)negative, (long)middle);
    WO_TEST_LESS_THAN((long)negative, (long)positive);
    WO_TEST_LESS_THAN((long)middle, (long)positive);
    WO_TEST_NOT_LESS_THAN((long)middle, (long)negative);
    WO_TEST_NOT_LESS_THAN((long)positive, (long)middle);
    WO_TEST_NOT_LESS_THAN((long)positive, (long)negative);
    WO_TEST_NOT_LESS_THAN((long)middle, (long)otherMiddle);

    WO_TEST_GREATER_THAN((long long)big, (long long)small);
    WO_TEST_NOT_GREATER_THAN((long long)small, (long long)big);
    WO_TEST_NOT_GREATER_THAN((long long)small, (long long)other);
    WO_TEST_LESS_THAN((long long)small, (long long)big);
    WO_TEST_NOT_LESS_THAN((long long)big, (long long)small);
    WO_TEST_NOT_LESS_THAN((long long)small, (long long)other);
    WO_TEST_GREATER_THAN((long long)middle, (long long)negative);
    WO_TEST_GREATER_THAN((long long)positive, (long long)negative);
    WO_TEST_GREATER_THAN((long long)positive, (long long)middle);
    WO_TEST_NOT_GREATER_THAN((long long)middle, (long long)positive);
    WO_TEST_NOT_GREATER_THAN((long long)negative, (long long)middle);
    WO_TEST_NOT_GREATER_THAN((long long)negative, (long long)positive);
    WO_TEST_NOT_GREATER_THAN((long long)middle, (long long)otherMiddle);
    WO_TEST_LESS_THAN((long long)negative, (long long)middle);
    WO_TEST_LESS_THAN((long long)negative, (long long)positive);
    WO_TEST_LESS_THAN((long long)middle, (long long)positive);
    WO_TEST_NOT_LESS_THAN((long long)middle, (long long)negative);
    WO_TEST_NOT_LESS_THAN((long long)positive, (long long)middle);
    WO_TEST_NOT_LESS_THAN((long long)positive, (long long)negative);
    WO_TEST_NOT_LESS_THAN((long long)middle, (long long)otherMiddle);

    WO_TEST_GREATER_THAN((float)big, (float)small);
    WO_TEST_NOT_GREATER_THAN((float)small, (float)big);
    WO_TEST_NOT_GREATER_THAN((float)small, (float)other);
    WO_TEST_LESS_THAN((float)small, (float)big);
    WO_TEST_NOT_LESS_THAN((float)big, (float)small);
    WO_TEST_NOT_LESS_THAN((float)small, (float)other);
    WO_TEST_GREATER_THAN((float)middle, (float)negative);
    WO_TEST_GREATER_THAN((float)positive, (float)negative);
    WO_TEST_GREATER_THAN((float)positive, (float)middle);
    WO_TEST_NOT_GREATER_THAN((float)middle, (float)positive);
    WO_TEST_NOT_GREATER_THAN((float)negative, (float)middle);
    WO_TEST_NOT_GREATER_THAN((float)negative, (float)positive);
    WO_TEST_NOT_GREATER_THAN((float)middle, (float)otherMiddle);
    WO_TEST_LESS_THAN((float)negative, (float)middle);
    WO_TEST_LESS_THAN((float)negative, (float)positive);
    WO_TEST_LESS_THAN((float)middle, (float)positive);
    WO_TEST_NOT_LESS_THAN((float)middle, (float)negative);
    WO_TEST_NOT_LESS_THAN((float)positive, (float)middle);
    WO_TEST_NOT_LESS_THAN((float)positive, (float)negative);
    WO_TEST_NOT_LESS_THAN((float)middle, (float)otherMiddle);

    WO_TEST_GREATER_THAN((double)big, (double)small);
    WO_TEST_NOT_GREATER_THAN((double)small, (double)big);
    WO_TEST_NOT_GREATER_THAN((double)small, (double)other);
    WO_TEST_LESS_THAN((double)small, (double)big);
    WO_TEST_NOT_LESS_THAN((double)big, (double)small);
    WO_TEST_NOT_LESS_THAN((double)small, (double)other);
    WO_TEST_GREATER_THAN((double)middle, (double)negative);
    WO_TEST_GREATER_THAN((double)positive, (double)negative);
    WO_TEST_GREATER_THAN((double)positive, (double)middle);
    WO_TEST_NOT_GREATER_THAN((double)middle, (double)positive);
    WO_TEST_NOT_GREATER_THAN((double)negative, (double)middle);
    WO_TEST_NOT_GREATER_THAN((double)negative, (double)positive);
    WO_TEST_NOT_GREATER_THAN((double)middle, (double)otherMiddle);
    WO_TEST_LESS_THAN((double)negative, (double)middle);
    WO_TEST_LESS_THAN((double)negative, (double)positive);
    WO_TEST_LESS_THAN((double)middle, (double)positive);
    WO_TEST_NOT_LESS_THAN((double)middle, (double)negative);
    WO_TEST_NOT_LESS_THAN((double)positive, (double)middle);
    WO_TEST_NOT_LESS_THAN((double)positive, (double)negative);
    WO_TEST_NOT_LESS_THAN((double)middle, (double)otherMiddle);

    // casts to unsigned types
    WO_TEST_GREATER_THAN((unsigned char)big, (unsigned char)small);
    WO_TEST_NOT_GREATER_THAN((unsigned char)small, (unsigned char)big);
    WO_TEST_NOT_GREATER_THAN((unsigned char)small, (unsigned char)other);
    WO_TEST_LESS_THAN((unsigned char)small, (unsigned char)big);
    WO_TEST_NOT_LESS_THAN((unsigned char)big, (unsigned char)small);
    WO_TEST_NOT_LESS_THAN((unsigned char)small, (unsigned char)other);
    WO_TEST_GREATER_THAN((unsigned char)positive, (unsigned char)middle);
    WO_TEST_NOT_GREATER_THAN((unsigned char)middle, (unsigned char)positive);
    WO_TEST_NOT_GREATER_THAN((unsigned char)middle, (unsigned char)otherMiddle);
    WO_TEST_LESS_THAN((unsigned char)middle, (unsigned char)positive);
    WO_TEST_NOT_LESS_THAN((unsigned char)positive, (unsigned char)middle);
    WO_TEST_NOT_LESS_THAN((unsigned char)middle, (unsigned char)otherMiddle);

    WO_TEST_GREATER_THAN((unsigned int)big, (unsigned int)small);
    WO_TEST_NOT_GREATER_THAN((unsigned int)small, (unsigned int)big);
    WO_TEST_NOT_GREATER_THAN((unsigned int)small, (unsigned int)other);
    WO_TEST_LESS_THAN((unsigned int)small, (unsigned int)big);
    WO_TEST_NOT_LESS_THAN((unsigned int)big, (unsigned int)small);
    WO_TEST_NOT_LESS_THAN((unsigned int)small, (unsigned int)other);
    WO_TEST_GREATER_THAN((unsigned int)positive, (unsigned int)middle);
    WO_TEST_NOT_GREATER_THAN((unsigned int)middle, (unsigned int)positive);
    WO_TEST_NOT_GREATER_THAN((unsigned int)middle, (unsigned int)otherMiddle);
    WO_TEST_LESS_THAN((unsigned int)middle, (unsigned int)positive);
    WO_TEST_NOT_LESS_THAN((unsigned int)positive, (unsigned int)middle);
    WO_TEST_NOT_LESS_THAN((unsigned int)middle, (unsigned int)otherMiddle);

    WO_TEST_GREATER_THAN((unsigned long)big, (unsigned long)small);
    WO_TEST_NOT_GREATER_THAN((unsigned long)small, (unsigned long)big);
    WO_TEST_NOT_GREATER_THAN((unsigned long)small, (unsigned long)other);
    WO_TEST_LESS_THAN((unsigned long)small, (unsigned long)big);
    WO_TEST_NOT_LESS_THAN((unsigned long)big, (unsigned long)small);
    WO_TEST_NOT_LESS_THAN((unsigned long)small, (unsigned long)other);
    WO_TEST_GREATER_THAN((unsigned long)positive, (unsigned long)middle);
    WO_TEST_NOT_GREATER_THAN((unsigned long)middle, (unsigned long)positive);
    WO_TEST_NOT_GREATER_THAN((unsigned long)middle, (unsigned long)otherMiddle);
    WO_TEST_LESS_THAN((unsigned long)middle, (unsigned long)positive);
    WO_TEST_NOT_LESS_THAN((unsigned long)positive, (unsigned long)middle);
    WO_TEST_NOT_LESS_THAN((unsigned long)middle, (unsigned long)otherMiddle);

    WO_TEST_GREATER_THAN((unsigned short)big, (unsigned short)small);
    WO_TEST_NOT_GREATER_THAN((unsigned short)small, (unsigned short)big);
    WO_TEST_NOT_GREATER_THAN((unsigned short)small, (unsigned short)other);
    WO_TEST_LESS_THAN((unsigned short)small, (unsigned short)big);
    WO_TEST_NOT_LESS_THAN((unsigned short)big, (unsigned short)small);
    WO_TEST_NOT_LESS_THAN((unsigned short)small, (unsigned short)other);
    WO_TEST_GREATER_THAN((unsigned short)positive, (unsigned short)middle);
    WO_TEST_NOT_GREATER_THAN((unsigned short)middle, (unsigned short)positive);
    WO_TEST_NOT_GREATER_THAN ((unsigned short)middle, (unsigned short)otherMiddle);
    WO_TEST_LESS_THAN((unsigned short)middle, (unsigned short)positive);
    WO_TEST_NOT_LESS_THAN((unsigned short)positive, (unsigned short)middle);
    WO_TEST_NOT_LESS_THAN((unsigned short)middle, (unsigned short)otherMiddle);
    WO_TEST_GREATER_THAN((unsigned long long)big, (unsigned long long)small);
    WO_TEST_NOT_GREATER_THAN ((unsigned long long)small, (unsigned long long)big);
    WO_TEST_NOT_GREATER_THAN ((unsigned long long)small, (unsigned long long)other);
    WO_TEST_LESS_THAN((unsigned long long)small, (unsigned long long)big);
    WO_TEST_NOT_LESS_THAN((unsigned long long)big, (unsigned long long)small);
    WO_TEST_NOT_LESS_THAN((unsigned long long)small, (unsigned long long)other);
    WO_TEST_GREATER_THAN ((unsigned long long)positive, (unsigned long long)middle);
    WO_TEST_NOT_GREATER_THAN ((unsigned long long)middle, (unsigned long long)positive);
    WO_TEST_NOT_GREATER_THAN ((unsigned long long)middle, (unsigned long long)otherMiddle);
    WO_TEST_LESS_THAN((unsigned long long)middle, (unsigned long long)positive);
    WO_TEST_NOT_LESS_THAN ((unsigned long long)positive, (unsigned long long)middle);
    WO_TEST_NOT_LESS_THAN((unsigned long long)middle, (unsigned long long)otherMiddle);







    // casts to non-matching types






    // objects: strings
    WO_TEST_GREATER_THAN(@"foo", @"bar");
    WO_TEST_GREATER_THAN(@"food", @"foo");
    WO_TEST_LESS_THAN(@"bar", @"foo");
    WO_TEST_LESS_THAN(@"foo", @"food");
    WO_TEST_NOT_GREATER_THAN(@"bar", @"foo");
    WO_TEST_NOT_GREATER_THAN(@"foo", @"food");
    WO_TEST_NOT_GREATER_THAN(@"bar", @"bar");
    WO_TEST_NOT_LESS_THAN(@"foo", @"bar");
    WO_TEST_NOT_LESS_THAN(@"foo", @"foo");
    WO_TEST_NOT_LESS_THAN(@"food", @"foo");

    // objects: numbers
    NSNumber *smallNumber   = [NSNumber numberWithInt:3];
    NSNumber *bigNumber     = [NSNumber numberWithFloat:10.0];
    NSNumber *otherNumber   = [NSNumber numberWithLongLong:10];

    WO_TEST_GREATER_THAN(bigNumber, smallNumber);
    WO_TEST_NOT_GREATER_THAN(smallNumber, bigNumber);
    WO_TEST_NOT_GREATER_THAN(bigNumber, otherNumber);

    WO_TEST_LESS_THAN(smallNumber, bigNumber);
    WO_TEST_NOT_LESS_THAN(bigNumber, smallNumber);
    WO_TEST_NOT_LESS_THAN(bigNumber, otherNumber);

    // objects that don't implement compare: should raise exception
    NSFileManager *manager = [NSFileManager defaultManager];
    NSValue *managerValue = [NSValue valueWithNonretainedObject:manager];
    NSString *compareString = @"hello";
    NSValue *stringValue = [NSValue valueWithNonretainedObject:compareString];
    WO_TEST_THROWS([managerValue WOTest_compare:stringValue]);

    // can't compare objects and non-objects
    int         scalar      = 1234;
    const void  *scalarPtr  = &scalar;
    WO_TEST_THROWS([stringValue WOTest_compare:[NSValue value:scalarPtr withObjCType:@encode(typeof(scalar))]]);
    WO_TEST_THROWS([stringValue WOTest_compare:[NSValue valueWithPoint:NSZeroPoint]]);


    typeof(int) dastardlyScalar = 10000;
    WO_TEST_THROWS
        ([[NSValue valueWithBytes:&dastardlyScalar
                         objCType:@encode(int)] WOTest_testIsEqualToValue:[NSValue valueWithNonretainedObject:@"foo"]]);

    typeof(nil) nilVar = nil;
    NSValue *nilValue = [NSValue valueWithBytes:&nilVar objCType:@encode(typeof(nil))];
    NSString *objectString = @"foo";
    NSValue *nonVoidValue = [NSValue valueWithBytes:&objectString objCType:@encode(typeof(objectString))];
    WO_TEST_TRUE([nonVoidValue WOTest_isObject]);
    WO_TEST_DOES_NOT_THROW([nonVoidValue WOTest_testIsEqualToValue:nilValue]);
    WO_TEST_DOES_NOT_THROW([nilValue WOTest_testIsEqualToValue:nonVoidValue]);

    // can also compare pointers to void to nil
    NSValue *objectValue = [NSValue valueWithNonretainedObject:[NSString stringWithFormat:@"bar"]];
    WO_TEST_FALSE([objectValue WOTest_isObject]); // due to valueWithNonretainedObject
    WO_TEST_TRUE([objectValue WOTest_isPointerToVoid]);
    WO_TEST_DOES_NOT_THROW([objectValue WOTest_testIsEqualToValue:nilValue]);
    WO_TEST_DOES_NOT_THROW([nilValue WOTest_testIsEqualToValue:objectValue]);

    NSValue *realObjectValue = [NSValue valueWithNonretainedObject:[[NSObject alloc] init]];
    WO_TEST_FALSE([realObjectValue WOTest_isObject]);
    WO_TEST_TRUE([realObjectValue WOTest_isPointerToVoid]);
    WO_TEST_DOES_NOT_THROW([realObjectValue WOTest_testIsEqualToValue:nilValue]);
    WO_TEST_DOES_NOT_THROW([nilValue WOTest_testIsEqualToValue:realObjectValue]);

    NSValue *otherValue = [NSValue valueWithNonretainedObject:@"bar"];
    WO_TEST_FALSE([otherValue WOTest_isObject]);
    WO_TEST_TRUE([otherValue WOTest_isPointerToVoid]);

    typeof("^v") myCoolVar = ("^v");
    NSValue *charArray = [NSValue valueWithBytes:&myCoolVar objCType:@encode(typeof("^v"))];
    WO_TEST_TRUE([charArray WOTest_isCharArray]);
    WO_TEST_EQUAL([charArray WOTest_stringValue], @"^v");

    char *constChar = "^v";
    NSValue *constCharValue = [NSValue valueWithBytes:&constChar objCType:@encode(char*)];
    WO_TEST_TRUE([constCharValue WOTest_isCharacterString]);
    WO_TEST_EQUAL([constCharValue WOTest_stringValue], @"^v");
    WO_TEST_EQUAL([charArray WOTest_stringValue], [constCharValue WOTest_stringValue]);

    WO_TEST_EQUAL([otherValue objCType], "^v");

    WO_TEST_EQUAL(strcmp([nilValue objCType], @encode(typeof(nil))), 0);
    typeof(nil) otherNilVar = nil;
    NSValue *otherNilValue = [NSValue valueWithBytes:&otherNilVar objCType:@encode(typeof(nil))];
    WO_TEST_EQUAL([nilValue WOTest_compare:otherNilValue], NSOrderedSame);
    WO_TEST_NOT_EQUAL([otherValue nonretainedObjectValue], nil);
    WO_TEST_DOES_NOT_THROW([nilValue WOTest_testIsEqualToValue:otherValue]);

    const char *constCharArray = "my char array";
    char *nonConstCharArray = "my char array";

    WO_TEST_EQUAL("my char array", "my char array");
    WO_TEST_EQUAL(constCharArray, nonConstCharArray);
    WO_TEST_EQUAL(nonConstCharArray, constCharArray);
    WO_TEST_EQUAL("my char array", nonConstCharArray);
    WO_TEST_EQUAL("my char array", constCharArray);
    WO_TEST_EQUAL(nonConstCharArray, "my char array");
    WO_TEST_EQUAL(constCharArray, "my char array");
    WO_TEST_NOT_EQUAL("my char array", "my other char array");
    WO_TEST_NOT_EQUAL("hello", 0);

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testNSStringCategory
{
    // should pass
    NSString *string1 = @"Fun\n  \nFun ";
    NSString *string2 = @"Fun Fun ";
    NSString *string3 = [string1 WOTest_stringByCollapsingWhitespace];

    WO_TEST_EQUAL(string2, string3);
    WO_TEST_EQUAL(string3, string2);

    NSString *string4 = @"\n\r Not fun at all...";
    NSString *string5 = @" Not fun at all...";
    NSString *string6 = [string4 WOTest_stringByCollapsingWhitespace];

    WO_TEST_EQUAL(string5, string6);
    WO_TEST_EQUAL(string6, string5);

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];

    WO_TEST_NOT_EQUAL(string2, string3);
    WO_TEST_NOT_EQUAL(string3, string2);
    WO_TEST_NOT_EQUAL(string5, string6);
    WO_TEST_NOT_EQUAL(string6, string5);

    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testNSExceptionCategory
{
    NSException *exception1 =
    [NSException exceptionWithName:@"foo" reason:@"bar" userInfo:nil];
    WO_TEST_EQUAL([NSException WOTest_descriptionForException:exception1], @"foo: bar");

    // NSImage responds to name but not reason
    NSImage *exception2 = [[NSImage alloc] initWithSize:NSZeroSize];
    [exception2 setName:@"Roger Smith"];
    WO_TEST_EQUAL([NSException WOTest_descriptionForException:exception2],
                  ([NSString stringWithFormat:@"%@ (%x)", [exception2 name], exception2]));

    // NSObject responds to description but not to name or reason
    NSObject *exception3 = [[NSObject alloc] init];
    WO_TEST_EQUAL([NSException WOTest_descriptionForException:exception3], [exception3 description]);

    WO_TEST_EQUAL([NSException WOTest_nameForException:nil], @"no exception");
    WO_TEST_EQUAL([NSException WOTest_nameForException:@"hello"], @"hello");

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];

    WO_TEST_EQUAL([NSException WOTest_descriptionForException:exception1], @"welcome");
    WO_TEST_NOT_EQUAL([NSException WOTest_descriptionForException:exception1], @"foo: bar");

    WO_TEST_NOT_EQUAL([NSException WOTest_nameForException:nil], @"no exception");
    WO_TEST_NOT_EQUAL([NSException WOTest_nameForException:@"hello"], @"hello");

    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testPointerToVoidTests
{
    // should pass

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testIntTests
{
    // should pass

    WO_TEST_IS_INT((int)-2000);
    WO_TEST_IS_INT((int)-1000);
    WO_TEST_IS_INT((int)-10);
    WO_TEST_IS_INT((int)-1);
    WO_TEST_IS_INT((int)0);
    WO_TEST_IS_INT((int)200);
    WO_TEST_IS_INT((int)1000);
    WO_TEST_IS_INT((int)50000);
    WO_TEST_IS_INT((int)1350000);

    WO_TEST_IS_NOT_INT((double)-2000.0);
    WO_TEST_IS_NOT_INT((double)-1000.0);
    WO_TEST_IS_NOT_INT((float)-10.0);
    WO_TEST_IS_NOT_INT((float)-1.0);
    WO_TEST_IS_NOT_INT((unsigned)0);
    WO_TEST_IS_NOT_INT((unsigned)200);
    WO_TEST_IS_NOT_INT((unsigned)1000);
    WO_TEST_IS_NOT_INT((float)50000.0);
    WO_TEST_IS_NOT_INT((double)1350000.0);

    WO_TEST_INT_POSITIVE((int)1);
    WO_TEST_INT_POSITIVE((int)2);
    WO_TEST_INT_POSITIVE((int)5);
    WO_TEST_INT_POSITIVE((int)10);
    WO_TEST_INT_POSITIVE((int)200);
    WO_TEST_INT_POSITIVE((int)1000);
    WO_TEST_INT_POSITIVE((int)50000);
    WO_TEST_INT_POSITIVE((int)1350000);

    WO_TEST_INT_NEGATIVE((int)-1);
    WO_TEST_INT_NEGATIVE((int)-2);
    WO_TEST_INT_NEGATIVE((int)-5);
    WO_TEST_INT_NEGATIVE((int)-10);
    WO_TEST_INT_NEGATIVE((int)-200);
    WO_TEST_INT_NEGATIVE((int)-1000);
    WO_TEST_INT_NEGATIVE((int)-50000);
    WO_TEST_INT_NEGATIVE((int)-1350000);

    WO_TEST_INT_ZERO((int)0);

    WO_TEST_INT_NOT_ZERO((int)1);
    WO_TEST_INT_NOT_ZERO((int)2);
    WO_TEST_INT_NOT_ZERO((int)200);
    WO_TEST_INT_NOT_ZERO((int)50000);
    WO_TEST_INT_NOT_ZERO((int)-1);
    WO_TEST_INT_NOT_ZERO((int)-2);
    WO_TEST_INT_NOT_ZERO((int)-200);
    WO_TEST_INT_NOT_ZERO((int)-50000);

    WO_TEST_INTS_EQUAL((int)0, (int)0);
    WO_TEST_INTS_EQUAL((int)2, (int)2);
    WO_TEST_INTS_EQUAL((int)20, (int)20);
    WO_TEST_INTS_EQUAL((int)1000, (int)1000);
    WO_TEST_INTS_EQUAL((int)-10, (int)-10);
    WO_TEST_INTS_EQUAL((int)-100, (int)-100);
    WO_TEST_INTS_EQUAL((int)-200, (int)-200);
    WO_TEST_INTS_EQUAL((int)-1350000, (int)-1350000);

    WO_TEST_INTS_NOT_EQUAL((int)1, (int)2);
    WO_TEST_INTS_NOT_EQUAL((int)2, (int)1);
    WO_TEST_INTS_NOT_EQUAL((int)10, (int)20);
    WO_TEST_INTS_NOT_EQUAL((int)200, (int)100);
    WO_TEST_INTS_NOT_EQUAL((int)-1, (int)0);
    WO_TEST_INTS_NOT_EQUAL((int)0, (int)-1);
    WO_TEST_INTS_NOT_EQUAL((int)-10, (int)10);
    WO_TEST_INTS_NOT_EQUAL((int)-100, (int)-200);

    WO_TEST_INT_GREATER_THAN((int)1, (int)0);
    WO_TEST_INT_GREATER_THAN((int)10, (int)5);
    WO_TEST_INT_GREATER_THAN((int)0, (int)-5);
    WO_TEST_INT_GREATER_THAN((int)20, (int)-40);
    WO_TEST_INT_GREATER_THAN((int)1000, (int)1);
    WO_TEST_INT_GREATER_THAN((int)1000, (int)999);
    WO_TEST_INT_GREATER_THAN((int)1350000, (int)5000);
    WO_TEST_INT_GREATER_THAN((int)5000000, (int)-5000000);

    WO_TEST_INT_NOT_GREATER_THAN((int)1, (int)1);
    WO_TEST_INT_NOT_GREATER_THAN((int)1, (int)2);
    WO_TEST_INT_NOT_GREATER_THAN((int)0, (int)1);
    WO_TEST_INT_NOT_GREATER_THAN((int)-1, (int)1);
    WO_TEST_INT_NOT_GREATER_THAN((int)1500, (int)120000);
    WO_TEST_INT_NOT_GREATER_THAN((int)-500, (int)-400);
    WO_TEST_INT_NOT_GREATER_THAN((int)-1600, (int)-1599);
    WO_TEST_INT_NOT_GREATER_THAN((int)400, (int)400);

    WO_TEST_INT_LESS_THAN((int)0, (int)1);
    WO_TEST_INT_LESS_THAN((int)1, (int)2);
    WO_TEST_INT_LESS_THAN((int)-1, (int)0);
    WO_TEST_INT_LESS_THAN((int)-1, (int)1);
    WO_TEST_INT_LESS_THAN((int)-1, (int)2);
    WO_TEST_INT_LESS_THAN((int)1000, (int)1001);
    WO_TEST_INT_LESS_THAN((int)1350, (int)1000000);
    WO_TEST_INT_LESS_THAN((int)-5000000, (int)1);

    WO_TEST_INT_NOT_LESS_THAN((int)0, (int)0);
    WO_TEST_INT_NOT_LESS_THAN((int)1, (int)0);
    WO_TEST_INT_NOT_LESS_THAN((int)2, (int)1);
    WO_TEST_INT_NOT_LESS_THAN((int)-1, (int)-1);
    WO_TEST_INT_NOT_LESS_THAN((int)-1, (int)-2);
    WO_TEST_INT_NOT_LESS_THAN((int)2000, (int)1000);
    WO_TEST_INT_NOT_LESS_THAN((int)5000, (int)5000);
    WO_TEST_INT_NOT_LESS_THAN((int)-10000, (int)-12000);

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];

    WO_TEST_IS_INT((float)0.0);
    WO_TEST_IS_INT((float)-1.0);
    WO_TEST_IS_INT((double)2.0);
    WO_TEST_IS_INT((double)-5.0);
    WO_TEST_IS_INT((unsigned)10);
    WO_TEST_IS_INT((unsigned)200);
    WO_TEST_IS_INT((unsigned)1000);
    WO_TEST_IS_INT((unsigned)50000);
    WO_TEST_IS_INT((unsigned)1350000);

    WO_TEST_IS_NOT_INT((int)-2000);
    WO_TEST_IS_NOT_INT((int)-1000);
    WO_TEST_IS_NOT_INT((int)-10);
    WO_TEST_IS_NOT_INT((int)-1);
    WO_TEST_IS_NOT_INT((int)0);
    WO_TEST_IS_NOT_INT((int)200);
    WO_TEST_IS_NOT_INT((int)1000);
    WO_TEST_IS_NOT_INT((int)50000);
    WO_TEST_IS_NOT_INT((int)1350000);

    WO_TEST_INT_POSITIVE((int)0);
    WO_TEST_INT_POSITIVE((int)-2);
    WO_TEST_INT_POSITIVE((int)-5);
    WO_TEST_INT_POSITIVE((int)-10);
    WO_TEST_INT_POSITIVE((int)-200);
    WO_TEST_INT_POSITIVE((int)-1000);
    WO_TEST_INT_POSITIVE((int)-50000);
    WO_TEST_INT_POSITIVE((int)-1350000);

    WO_TEST_INT_NEGATIVE((int)0);
    WO_TEST_INT_NEGATIVE((int)2);
    WO_TEST_INT_NEGATIVE((int)5);
    WO_TEST_INT_NEGATIVE((int)10);
    WO_TEST_INT_NEGATIVE((int)200);
    WO_TEST_INT_NEGATIVE((int)1000);
    WO_TEST_INT_NEGATIVE((int)50000);
    WO_TEST_INT_NEGATIVE((int)1350000);

    WO_TEST_INT_ZERO((int)1);
    WO_TEST_INT_ZERO((int)2);
    WO_TEST_INT_ZERO((int)200);
    WO_TEST_INT_ZERO((int)50000);
    WO_TEST_INT_ZERO((int)-1);
    WO_TEST_INT_ZERO((int)-2);
    WO_TEST_INT_ZERO((int)-200);
    WO_TEST_INT_ZERO((int)-50000);

    WO_TEST_INT_NOT_ZERO((int)0);

    WO_TEST_INTS_EQUAL((int)0, (int)10);
    WO_TEST_INTS_EQUAL((int)2, (int)1);
    WO_TEST_INTS_EQUAL((int)20, (int)-20);
    WO_TEST_INTS_EQUAL((int)1000, (int)2000);
    WO_TEST_INTS_EQUAL((int)-10, (int)0);
    WO_TEST_INTS_EQUAL((int)-100, (int)200);
    WO_TEST_INTS_EQUAL((int)-200, (int)-400);
    WO_TEST_INTS_EQUAL((int)-1350000, (int)1350000);

    WO_TEST_INTS_NOT_EQUAL((int)1, (int)1);
    WO_TEST_INTS_NOT_EQUAL((int)-2, (int)-2);
    WO_TEST_INTS_NOT_EQUAL((int)4, (int)4);
    WO_TEST_INTS_NOT_EQUAL((int)-8, (int)-8);
    WO_TEST_INTS_NOT_EQUAL((int)10, (int)10);
    WO_TEST_INTS_NOT_EQUAL((int)-100, (int)-100);
    WO_TEST_INTS_NOT_EQUAL((int)1350000, (int)1350000);
    WO_TEST_INTS_NOT_EQUAL((int)2000000, (int)2000000);

    WO_TEST_INT_GREATER_THAN((int)1, (int)1);
    WO_TEST_INT_GREATER_THAN((int)10, (int)12);
    WO_TEST_INT_GREATER_THAN((int)0, (int)4);
    WO_TEST_INT_GREATER_THAN((int)-20, (int)40);
    WO_TEST_INT_GREATER_THAN((int)1000, (int)1200);
    WO_TEST_INT_GREATER_THAN((int)999, (int)1000);
    WO_TEST_INT_GREATER_THAN((int)1350000, (int)5000000);
    WO_TEST_INT_GREATER_THAN((int)-5000000, (int)5000000);

    WO_TEST_INT_NOT_GREATER_THAN((int)1, (int)0);
    WO_TEST_INT_NOT_GREATER_THAN((int)2, (int)1);
    WO_TEST_INT_NOT_GREATER_THAN((int)1, (int)-10);
    WO_TEST_INT_NOT_GREATER_THAN((int)1, (int)-1);
    WO_TEST_INT_NOT_GREATER_THAN((int)1500000, (int)1200);
    WO_TEST_INT_NOT_GREATER_THAN((int)-400, (int)-500);
    WO_TEST_INT_NOT_GREATER_THAN((int)-1599, (int)-1600);
    WO_TEST_INT_NOT_GREATER_THAN((int)400, (int)1);

    WO_TEST_INT_LESS_THAN((int)1, (int)0);
    WO_TEST_INT_LESS_THAN((int)2, (int)1);
    WO_TEST_INT_LESS_THAN((int)0, (int)-1);
    WO_TEST_INT_LESS_THAN((int)1, (int)-1);
    WO_TEST_INT_LESS_THAN((int)2, (int)-1);
    WO_TEST_INT_LESS_THAN((int)1001, (int)1000);
    WO_TEST_INT_LESS_THAN((int)1000000, (int)1350);
    WO_TEST_INT_LESS_THAN((int)1, (int)-5000000);

    WO_TEST_INT_NOT_LESS_THAN((int)0, (int)1);
    WO_TEST_INT_NOT_LESS_THAN((int)1, (int)2);
    WO_TEST_INT_NOT_LESS_THAN((int)2, (int)3);
    WO_TEST_INT_NOT_LESS_THAN((int)-2, (int)-1);
    WO_TEST_INT_NOT_LESS_THAN((int)-1, (int)12);
    WO_TEST_INT_NOT_LESS_THAN((int)1000, (int)2000);
    WO_TEST_INT_NOT_LESS_THAN((int)2000, (int)5000);
    WO_TEST_INT_NOT_LESS_THAN((int)-16000, (int)-12000);

    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testUnsignedTests
{
    // should pass

    WO_TEST_UNSIGNED_ZERO((unsigned)0);

    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)1);
    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)2);
    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)200);
    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)50000);
    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)60000);
    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)65200);
    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)100000);
    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)5000000);

    WO_TEST_UNSIGNEDS_EQUAL((unsigned)0, (unsigned)0);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)2, (unsigned)2);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)20, (unsigned)20);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)1000, (unsigned)1000);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)10000, (unsigned)10000);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)23000, (unsigned)23000);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)165200, (unsigned)165200);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)1350000, (unsigned)1350000);

    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)1, (unsigned)2);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)2, (unsigned)1);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)10, (unsigned)20);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)200, (unsigned)100);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)1, (unsigned)0);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)0, (unsigned)1);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)10, (unsigned)1230);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)100, (unsigned)200);

    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)1, (unsigned)0);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)10, (unsigned)5);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)6, (unsigned)5);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)20, (unsigned)4);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)1000, (unsigned)1);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)1000, (unsigned)999);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)1350000, (unsigned)5000);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)5000000, (unsigned)50);

    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1, (unsigned)1);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1, (unsigned)2);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)0, (unsigned)1);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1, (unsigned)3);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1500, (unsigned)120000);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)500, (unsigned)4500);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1599, (unsigned)1600);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)400, (unsigned)400);

    WO_TEST_UNSIGNED_LESS_THAN((unsigned)0, (unsigned)1);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1, (unsigned)2);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1, (unsigned)1200);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1, (unsigned)4);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1, (unsigned)2);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1000, (unsigned)1001);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1350, (unsigned)1000000);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)5000000, (unsigned)10000000);

    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)0, (unsigned)0);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)1, (unsigned)0);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)2, (unsigned)1);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)1, (unsigned)1);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)2, (unsigned)2);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)2000, (unsigned)1000);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)5000, (unsigned)5000);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)12000, (unsigned)10000);

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];

    WO_TEST_UNSIGNED_ZERO((unsigned)1);
    WO_TEST_UNSIGNED_ZERO((unsigned)2);
    WO_TEST_UNSIGNED_ZERO((unsigned)200);
    WO_TEST_UNSIGNED_ZERO((unsigned)50000);
    WO_TEST_UNSIGNED_ZERO((unsigned)10);
    WO_TEST_UNSIGNED_ZERO((unsigned)20);
    WO_TEST_UNSIGNED_ZERO((unsigned)2000);
    WO_TEST_UNSIGNED_ZERO((unsigned)500000);

    WO_TEST_UNSIGNED_NOT_ZERO((unsigned)0);

    WO_TEST_UNSIGNEDS_EQUAL((unsigned)0, (unsigned)10);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)2, (unsigned)1);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)20, (unsigned)21);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)1000, (unsigned)2000);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)10, (unsigned)0);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)100, (unsigned)200);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)200, (unsigned)400);
    WO_TEST_UNSIGNEDS_EQUAL((unsigned)1350001, (unsigned)1350000);

    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)1, (unsigned)1);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)2, (unsigned)2);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)4, (unsigned)4);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)8, (unsigned)8);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)10, (unsigned)10);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)100, (unsigned)100);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)1350000, (unsigned)1350000);
    WO_TEST_UNSIGNEDS_NOT_EQUAL((unsigned)2000000, (unsigned)2000000);

    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)1, (unsigned)1);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)10, (unsigned)12);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)0, (unsigned)4);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)20, (unsigned)40);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)1000, (unsigned)1200);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)999, (unsigned)1000);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)1350000, (unsigned)5000000);
    WO_TEST_UNSIGNED_GREATER_THAN((unsigned)5000000, (unsigned)5000000);

    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1, (unsigned)0);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)2, (unsigned)1);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)11, (unsigned)10);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)2, (unsigned)0);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1500000, (unsigned)1200);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)600, (unsigned)599);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)1600, (unsigned)1599);
    WO_TEST_UNSIGNED_NOT_GREATER_THAN((unsigned)400, (unsigned)1);

    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1, (unsigned)0);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)2, (unsigned)1);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)0, (unsigned)0);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1, (unsigned)0);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)12, (unsigned)0);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1001, (unsigned)1000);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)1000000, (unsigned)1350);
    WO_TEST_UNSIGNED_LESS_THAN((unsigned)12, (unsigned)4);

    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)0, (unsigned)1);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)1, (unsigned)2);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)2, (unsigned)3);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)2, (unsigned)5);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)1, (unsigned)12);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)1000, (unsigned)2000);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)2000, (unsigned)5000);
    WO_TEST_UNSIGNED_NOT_LESS_THAN((unsigned)16000, (unsigned)18000);

    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testFloatTests
{
    // should pass

    WO_TEST_FLOAT_POSITIVE((float)1);
    WO_TEST_FLOAT_POSITIVE((float)2);
    WO_TEST_FLOAT_POSITIVE((float)5);
    WO_TEST_FLOAT_POSITIVE((float)10);
    WO_TEST_FLOAT_POSITIVE((float)200);
    WO_TEST_FLOAT_POSITIVE((float)1000);
    WO_TEST_FLOAT_POSITIVE((float)50000);
    WO_TEST_FLOAT_POSITIVE((float)1350000);

    WO_TEST_FLOAT_NEGATIVE((float)-1);
    WO_TEST_FLOAT_NEGATIVE((float)-2);
    WO_TEST_FLOAT_NEGATIVE((float)-5);
    WO_TEST_FLOAT_NEGATIVE((float)-10);
    WO_TEST_FLOAT_NEGATIVE((float)-200);
    WO_TEST_FLOAT_NEGATIVE((float)-1000);
    WO_TEST_FLOAT_NEGATIVE((float)-50000);
    WO_TEST_FLOAT_NEGATIVE((float)-1350000);

    WO_TEST_FLOAT_ZERO((float)0);

    WO_TEST_FLOAT_NOT_ZERO((float)1);
    WO_TEST_FLOAT_NOT_ZERO((float)2);
    WO_TEST_FLOAT_NOT_ZERO((float)200);
    WO_TEST_FLOAT_NOT_ZERO((float)50000);
    WO_TEST_FLOAT_NOT_ZERO((float)-1);
    WO_TEST_FLOAT_NOT_ZERO((float)-2);
    WO_TEST_FLOAT_NOT_ZERO((float)-200);
    WO_TEST_FLOAT_NOT_ZERO((float)-50000);

    WO_TEST_FLOATS_EQUAL((float)0, 0);
    WO_TEST_FLOATS_EQUAL((float)2, 2);
    WO_TEST_FLOATS_EQUAL((float)20, 20);
    WO_TEST_FLOATS_EQUAL((float)1000, 1000);
    WO_TEST_FLOATS_EQUAL((float)-10, -10);
    WO_TEST_FLOATS_EQUAL((float)-100, -100);
    WO_TEST_FLOATS_EQUAL((float)-200, -200);
    WO_TEST_FLOATS_EQUAL((float)-1350000, -1350000);

    WO_TEST_FLOATS_NOT_EQUAL((float)1, 2);
    WO_TEST_FLOATS_NOT_EQUAL((float)2, 1);
    WO_TEST_FLOATS_NOT_EQUAL((float)10, 20);
    WO_TEST_FLOATS_NOT_EQUAL((float)200, 100);
    WO_TEST_FLOATS_NOT_EQUAL((float)-1, 0);
    WO_TEST_FLOATS_NOT_EQUAL((float)0, -1);
    WO_TEST_FLOATS_NOT_EQUAL((float)-10, 10);
    WO_TEST_FLOATS_NOT_EQUAL((float)-100, -200);

    WO_TEST_FLOAT_GREATER_THAN((float)1, 0);
    WO_TEST_FLOAT_GREATER_THAN((float)10, 5);
    WO_TEST_FLOAT_GREATER_THAN((float)0, -5);
    WO_TEST_FLOAT_GREATER_THAN((float)20, -40);
    WO_TEST_FLOAT_GREATER_THAN((float)1000, 1);
    WO_TEST_FLOAT_GREATER_THAN((float)1000, 999);
    WO_TEST_FLOAT_GREATER_THAN((float)1350000, 5000);
    WO_TEST_FLOAT_GREATER_THAN((float)5000000, -5000000);

    WO_TEST_FLOAT_NOT_GREATER_THAN((float)1, 1);
    WO_TEST_FLOAT_NOT_GREATER_THAN((float)1, 2);
    WO_TEST_FLOAT_NOT_GREATER_THAN((float)0, 1);
    WO_TEST_FLOAT_NOT_GREATER_THAN((float)-1, 1);
    WO_TEST_FLOAT_NOT_GREATER_THAN((float)1500, 120000);
    WO_TEST_FLOAT_NOT_GREATER_THAN((float)-500, -400);
    WO_TEST_FLOAT_NOT_GREATER_THAN((float)-1600, -1599);
    WO_TEST_FLOAT_NOT_GREATER_THAN((float)400, 400);

    WO_TEST_FLOAT_LESS_THAN((float)0, 1);
    WO_TEST_FLOAT_LESS_THAN((float)1, 2);
    WO_TEST_FLOAT_LESS_THAN((float)-1, 0);
    WO_TEST_FLOAT_LESS_THAN((float)-1, 1);
    WO_TEST_FLOAT_LESS_THAN((float)-1, 2);
    WO_TEST_FLOAT_LESS_THAN((float)1000, 1001);
    WO_TEST_FLOAT_LESS_THAN((float)1350, 1000000);
    WO_TEST_FLOAT_LESS_THAN((float)-5000000, 1);

    WO_TEST_FLOAT_NOT_LESS_THAN((float)0, 0);
    WO_TEST_FLOAT_NOT_LESS_THAN((float)1, 0);
    WO_TEST_FLOAT_NOT_LESS_THAN((float)2, 1);
    WO_TEST_FLOAT_NOT_LESS_THAN((float)-1, -1);
    WO_TEST_FLOAT_NOT_LESS_THAN((float)-1, -2);
    WO_TEST_FLOAT_NOT_LESS_THAN((float)2000, 1000);
    WO_TEST_FLOAT_NOT_LESS_THAN((float)5000, 5000);
    WO_TEST_FLOAT_NOT_LESS_THAN((float)-10000, -12000);

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testFloatWithErrorMarginTests
{
    // should pass

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testDoubleTests
{
    // should pass

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testDoubleWithErrorMarginTests
{
    // should pass

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testObjectTests
{
    // should pass


    // should freak out if object does not conform to NSObject protocol



    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testStringTests
{
    // should pass


    // should freak out if object does not conform to NSObject protocol

    // should throw an exception when passed an object that is not a subclass of NSString

    // specifically should throw an WO_TEST_CLASS_MISMATCH_EXCEPTION

    // should handle nil string1

    // should handle nil string2

    // should handle nil string1 and nil string2

    // should handle empty string1

    // should handle empty string2

    // should handle empty string1 and empty string2

    // shorthand macros should work


    // in the case of prefix, suffix and contains tests should die if passed nil "expected" parameter

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testArrayTests
{
    // should pass

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testDictionaryTests
{
    // should pass

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];



    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testShorthandMacros
{
    // make sure that the shorthand and longhand test macros are equivalent

    // should pass
    WO_TEST_TRUE(YES);
    WO_TEST(YES);

    WO_TEST_EQUAL(100, 100);
    WO_TEST_EQ(100, 100);

    WO_TEST_NOT_EQUAL(100, 101);
    WO_TEST_NE(100, 101);

    WO_TEST_GREATER_THAN(200, 100);
    WO_TEST_GT(200, 100);

    WO_TEST_NOT_GREATER_THAN(100, 200);
    WO_TEST_LTE(100, 200);
    WO_TEST_NGT(100, 200);

    WO_TEST_NOT_GREATER_THAN(100, 100);
    WO_TEST_LTE(100, 100);
    WO_TEST_NGT(100, 100);

    WO_TEST_LESS_THAN(100, 200);
    WO_TEST_LT(100, 200);

    WO_TEST_NOT_LESS_THAN(200, 100);
    WO_TEST_GTE(200, 100);
    WO_TEST_NLT(200, 100);

    WO_TEST_NOT_LESS_THAN(100, 100);
    WO_TEST_GTE(100, 100);
    WO_TEST_NLT(100, 100);

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];

    WO_TEST_TRUE(NO);
    WO_TEST(NO);

    WO_TEST_EQUAL(100, 200);
    WO_TEST_EQ(100, 200);

    WO_TEST_NOT_EQUAL(100, 100);
    WO_TEST_NE(100, 100);

    WO_TEST_GREATER_THAN(100, 200);
    WO_TEST_GT(100, 200);

    WO_TEST_NOT_GREATER_THAN(200, 100);
    WO_TEST_LTE(200, 100);
    WO_TEST_NGT(200, 100);

    WO_TEST_LESS_THAN(200, 100);
    WO_TEST_LT(200, 100);

    WO_TEST_NOT_LESS_THAN(100, 200);
    WO_TEST_GTE(100, 200);
    WO_TEST_NLT(100, 200);

    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testExceptionTests
{
    // should pass
    WO_TEST_THROWS([self throwException]);
    WO_TEST_THROWS([self raiseException]);
    WO_TEST_THROWS([self throwWOEnigmaException]);
    WO_TEST_THROWS([self throwString]);

    // BUG: busted on Leopard
    //WO_TEST_THROWS([self throwWORootClassObject]);
    WO_TEST_THROWS([self throwObject]);
    WO_TEST_THROWS([self makeCocoaThrowException]);
    WO_TEST_THROWS([self makeCocoaThrowNSRangeException]);

    WO_TEST_DOES_NOT_THROW([self doNotThrowException]);

    WO_TEST_THROWS_EXCEPTION_NAMED
        ([self throwWOEnigmaException], @"WOEnigmaException");
    WO_TEST_THROWS_EXCEPTION_NAMED([self throwString], @"party");

    WO_TEST_DOES_NOT_THROW_EXCEPTION_NAMED([self doNotThrowException], @"Roy");
    WO_TEST_DOES_NOT_THROW_EXCEPTION_NAMED([self throwException], @"Other");

    // BUG: busted on Leopard
    //WO_TEST_DOES_NOT_THROW_EXCEPTION_NAMED([self throwWORootClassObject], @"x");
    //WO_TEST_THROWS_EXCEPTION_NAMED([self throwWORootClassObject], @"WORootClass");

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];

    WO_TEST_DOES_NOT_THROW([self throwException]);
    WO_TEST_DOES_NOT_THROW([self raiseException]);
    WO_TEST_DOES_NOT_THROW([self throwWOEnigmaException]);
    WO_TEST_DOES_NOT_THROW([self throwString]);

    // BUG: Busted on Leopard
    //WO_TEST_DOES_NOT_THROW([self throwWORootClassObject]);
    WO_TEST_DOES_NOT_THROW([self throwObject]);
    WO_TEST_DOES_NOT_THROW([self makeCocoaThrowException]);
    WO_TEST_DOES_NOT_THROW([self makeCocoaThrowNSRangeException]);

    WO_TEST_THROWS([self doNotThrowException]);

    WO_TEST_DOES_NOT_THROW_EXCEPTION_NAMED
        ([self throwWOEnigmaException], @"WOEnigmaException");
    WO_TEST_DOES_NOT_THROW_EXCEPTION_NAMED([self throwString], @"party");

    WO_TEST_THROWS_EXCEPTION_NAMED([self doNotThrowException], @"Roy");
    WO_TEST_THROWS_EXCEPTION_NAMED([self throwException], @"Other");

    // BUG: busted on Leopard
    //WO_TEST_THROWS_EXCEPTION_NAMED([self throwWORootClassObject], @"x");
    //WO_TEST_DOES_NOT_THROW_EXCEPTION_NAMED([self throwWORootClassObject], @"WORootClass");

    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO]; // restore to default
}

- (void)testLowLevelExceptionTests
{
    // BUG: this stuff busted on Leopard
    return;

    [WO_TEST_SHARED_INSTANCE setExpectLowLevelExceptions:YES];  // will be reset to NO in preflight prior to next method
    WO_TEST_PASS;                                               // force update of "lastKnownLocation"
    id *object = NULL;                                          // cause a crash, but WOTest should keep running
    *object = @"foo";                                           // SIGBUS here
    WO_TEST_FAIL;                                               // this line never reached
}

- (void)throwException
{
    @throw [NSException exceptionWithName:@"WOBettySmithException" reason:@"None" userInfo:nil];
}

- (void)raiseException
{
    [NSException raise:@"Bob" format:@"Unexpected Bob Exception"];
}

- (void)throwWOEnigmaException
{
    [NSException raise:@"WOEnigmaException" format:@"Reason"];
}

- (void)throwString
{
    NSString *party = @"party";
    @throw party;
}

- (void)throwWORootClassObject
{
    @throw [WORootClass new];
}

- (void)throwObject
{
    @throw [[Object alloc] init];
}

- (void)doNotThrowException
{
    [NSDate date];
}

- (void)makeCocoaThrowException
{
    // should throw NSInvalidArgumentException
    (void)[[NSString alloc] initWithFormat:nil];
}

- (void)makeCocoaThrowNSRangeException
{
    [@"short string" characterAtIndex:2000];
}

- (void)testRandomValueGeneratorMethods
{
    // should pass
    WO_TEST_PASS;

    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE anInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aPositiveInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aNegativeInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aZeroInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aBigInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aBigPositiveInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aBigNegativeInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aSmallInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aSmallPositiveInt]);
    WO_TEST_IS_INT([WO_TEST_SHARED_INSTANCE aSmallNegativeInt]);

    WO_TEST_IS_UNSIGNED([WO_TEST_SHARED_INSTANCE anUnsigned]);
    WO_TEST_IS_UNSIGNED([WO_TEST_SHARED_INSTANCE aZeroUnsigned]);
    WO_TEST_IS_UNSIGNED([WO_TEST_SHARED_INSTANCE aBigUnsigned]);
    WO_TEST_IS_UNSIGNED([WO_TEST_SHARED_INSTANCE aSmallUnsigned]);

    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aPositiveFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aNegativeFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aZeroFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aBigFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aBigPositiveFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aBigNegativeFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aSmallFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aSmallPositiveFloat]);
    WO_TEST_IS_FLOAT([WO_TEST_SHARED_INSTANCE aSmallNegativeFloat]);

    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aPositiveDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aNegativeDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aZeroDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aBigDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aBigPositiveDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aBigNegativeDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aSmallDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aSmallPositiveDouble]);
    WO_TEST_IS_DOUBLE([WO_TEST_SHARED_INSTANCE aSmallNegativeDouble]);

    WO_TEST_INT_POSITIVE([WO_TEST_SHARED_INSTANCE aPositiveInt]);
    WO_TEST_INT_NEGATIVE([WO_TEST_SHARED_INSTANCE aNegativeInt]);
    WO_TEST_INT_ZERO([WO_TEST_SHARED_INSTANCE aZeroInt]);

    WO_TEST_INT_NOT_LESS_THAN(abs([WO_TEST_SHARED_INSTANCE aBigInt]),
                              (WO_BIG_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_INT_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aBigPositiveInt],
                              (WO_BIG_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_INT_NOT_GREATER_THAN([WO_TEST_SHARED_INSTANCE aBigNegativeInt],
                                 (-WO_BIG_TEST_VALUE + WO_RANDOMIZATION_RANGE));

    WO_TEST_INT_NOT_LESS_THAN(abs([WO_TEST_SHARED_INSTANCE aSmallInt]),
                              (WO_SMALL_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_INT_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aSmallPositiveInt],
                              (WO_SMALL_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_INT_NOT_GREATER_THAN([WO_TEST_SHARED_INSTANCE aSmallNegativeInt],
                                 (-WO_SMALL_TEST_VALUE + WO_RANDOMIZATION_RANGE));

    WO_TEST_UNSIGNED_ZERO([WO_TEST_SHARED_INSTANCE aZeroUnsigned]);

    WO_TEST_UNSIGNED_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aBigUnsigned],
                                   (WO_BIG_TEST_VALUE - WO_RANDOMIZATION_RANGE));

    WO_TEST_UNSIGNED_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aSmallUnsigned],
                                   (WO_SMALL_TEST_VALUE - WO_RANDOMIZATION_RANGE));

    WO_TEST_FLOAT_POSITIVE([WO_TEST_SHARED_INSTANCE aPositiveFloat]);
    WO_TEST_FLOAT_NEGATIVE([WO_TEST_SHARED_INSTANCE aNegativeFloat]);
    WO_TEST_FLOAT_ZERO([WO_TEST_SHARED_INSTANCE aZeroFloat]);

    WO_TEST_FLOAT_NOT_LESS_THAN(fabsf([WO_TEST_SHARED_INSTANCE aBigFloat]),
                                (WO_BIG_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_FLOAT_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aBigPositiveFloat],
                                (WO_BIG_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_FLOAT_NOT_GREATER_THAN([WO_TEST_SHARED_INSTANCE aBigNegativeFloat],
                                   (-WO_BIG_TEST_VALUE + WO_RANDOMIZATION_RANGE));

    WO_TEST_FLOAT_NOT_LESS_THAN(fabsf([WO_TEST_SHARED_INSTANCE aSmallFloat]),
                                (WO_SMALL_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_FLOAT_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aSmallPositiveFloat],
                                (WO_SMALL_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_FLOAT_NOT_GREATER_THAN([WO_TEST_SHARED_INSTANCE aSmallNegativeFloat],
                                   (-WO_SMALL_TEST_VALUE + WO_RANDOMIZATION_RANGE));

    WO_TEST_DOUBLE_POSITIVE([WO_TEST_SHARED_INSTANCE aPositiveDouble]);
    WO_TEST_DOUBLE_NEGATIVE([WO_TEST_SHARED_INSTANCE aNegativeDouble]);
    WO_TEST_DOUBLE_ZERO([WO_TEST_SHARED_INSTANCE aZeroDouble]);

    WO_TEST_DOUBLE_NOT_LESS_THAN(fabs([WO_TEST_SHARED_INSTANCE aBigDouble]),
                                 (WO_BIG_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_DOUBLE_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aBigPositiveDouble],
                                 (WO_BIG_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_DOUBLE_NOT_GREATER_THAN([WO_TEST_SHARED_INSTANCE aBigNegativeDouble],
                                    (-WO_BIG_TEST_VALUE + WO_RANDOMIZATION_RANGE));

    WO_TEST_DOUBLE_NOT_LESS_THAN(fabs([WO_TEST_SHARED_INSTANCE aSmallDouble]),
                                 (WO_SMALL_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_DOUBLE_NOT_LESS_THAN([WO_TEST_SHARED_INSTANCE aSmallPositiveDouble],
                                 (WO_SMALL_TEST_VALUE - WO_RANDOMIZATION_RANGE));
    WO_TEST_DOUBLE_NOT_GREATER_THAN([WO_TEST_SHARED_INSTANCE aSmallNegativeDouble],
                                    (-WO_SMALL_TEST_VALUE + WO_RANDOMIZATION_RANGE));

    // should fail
    [WO_TEST_SHARED_INSTANCE setExpectFailures:YES];











    [WO_TEST_SHARED_INSTANCE setExpectFailures:NO];
}

@end
