//
//  WOTestMacros.h
//  WOTest
//
//  Created by Wincent Colaiuta on 12 October 2004.
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

//! \file WOTestMacros.h

#pragma mark -
#pragma mark Special macros

// TODO: A headers only target so that I can build apps that want to include this header without actually building the framework

//! TODO: explain why this method is needed
//! \code
//!   @implemenation ExampleClass
//!   WO_TEST_NO_DEAD_STRIP_CLASS(ExampleClass);
//!   // remainder of class implementation
//! \endcode
//! \param class The class whose name should be protected from dead-code stripping
#define WO_TEST_NO_DEAD_STRIP_CLASS(class) __asm__ (".no_dead_strip .objc_class_name_" #class "\n");

#pragma mark -
#pragma mark Bootstrap macros for unit testing within applications

#define WO_TEST_CLASS_NAME                  @"WOTest"

#define WO_TEST_FRAMEWORK_NAME              @"WOTest.framework"

/*! Path to default install location for WOTest framework. */
#define WO_TEST_FRAMEWORK_INSTALL_PATH      @"/Library/Frameworks/" WO_TEST_FRAMEWORK_NAME

/*! Alternate path to install location for WOTest framework. */
#define WO_TEST_FRAMEWORK_ALT_INSTALL_PATH  @"~/Library/Frameworks/" WO_TEST_FRAMEWORK_NAME

#define WO_MISSING_WO_TEST_FRAMEWORK        "--run-unit-tests commandline option present but WOTest.framework missing\n"

/*! Exception thrown when a test explicitly expects a given class of object (such as NSString, NSArray or NSDictionary) but is passed an object of a different class. Subclasses of the expected class, as well as nil values, are acceptable and do not cause an exception to be thrown. */
#define WO_TEST_CLASS_MISMATCH_EXCEPTION    @"WOTestClassMismatchException"

//! Exception thrown when a nil parameter is passed to a test that disallows nil parameters.
#define WO_TEST_NIL_PARAMETER_EXCEPTION     @"WOTestNilParameterException"

/*! Exception thrown when the scalar expressions passed using one of the scalar test macros are of two different types. No casting is attempted when using the scalar test macros and all assume that the passed scalars will be of matching types. If casting (without exceptions) is the desired behaviour, perform the tests using the integer, unsigned, float or double test macros, which the compiler casts prior calling the underlying test method. (The behaviour of the scalar test macros is markedly different; because the type of the passed expressions cannot be known by the preprocessor, the macros cannot use any underlying test methods because they cannot know which method to call, and all test logic is therefore contained within the macro itself.) */
#define WO_TEST_TYPE_MISMATCH_EXCEPTION     @"WOTestTypeMismatchException"

/*! Exception thrown if there is a fatal error during the self-testing of WOTest itself (specifically, if there is a problem detected with the boolean test methods, which are fundamental because all other tests in the self-test depend on those methods. This exception should only occur if their is a programming error in WOTest. */
#define WO_TEST_SELF_TEST_FAILURE_EXCEPTION @"WOTestSelfTestFailureException"

/*! No memory error. */
#define WO_TEST_MEMORY_ERROR 1

#define WO_TEST_SHARED_INSTANCE     (WOTest *)[NSClassFromString(@"WOTest") sharedInstance]

#define WO_TEST_FRAMEWORK_IS_LOADED (WO_TEST_SHARED_INSTANCE ? YES : NO)

/*! For developers who do not wish to link against the WOTest framework but want to optionally load it at run time. */
#define WO_TEST_LOAD_FRAMEWORK                                                 \
do {                                                                           \
    /* check if framework is already loaded */                                 \
    if (WO_TEST_FRAMEWORK_IS_LOADED) break;                                    \
                                                                               \
    /* check if framework is in the current working directory */               \
    NSString *currentWorkingDirectory =                                        \
        [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0]             \
            stringByDeletingLastPathComponent];                                \
                                                                               \
    NSBundle *WOTestFrameworkBundle = [NSBundle bundleWithPath:                \
        [currentWorkingDirectory stringByAppendingPathComponent:               \
            WO_TEST_FRAMEWORK_NAME]];                                          \
    if (WOTestFrameworkBundle && [WOTestFrameworkBundle load]) break;          \
                                                                               \
    /* check in the default install locations */                               \
    WOTestFrameworkBundle =                                                    \
        [NSBundle bundleWithPath:WO_TEST_FRAMEWORK_INSTALL_PATH];              \
    if (WOTestFrameworkBundle && [WOTestFrameworkBundle load]) break;          \
                                                                               \
    WOTestFrameworkBundle = [NSBundle bundleWithPath:                          \
            [WO_TEST_FRAMEWORK_ALT_INSTALL_PATH stringByStandardizingPath]];   \
    if (WOTestFrameworkBundle && [WOTestFrameworkBundle load]) break;          \
                                                                               \
    /* check parent directory (WOTestRunner may be embedded) */                \
    NSString *frameworkBundlePath =                                            \
        [[[currentWorkingDirectory stringByDeletingLastPathComponent]          \
            stringByDeletingLastPathComponent]                                 \
            stringByDeletingLastPathComponent];                                \
                                                                               \
    if (frameworkBundlePath &&                                                 \
        [[frameworkBundlePath lastPathComponent] isEqualToString:              \
            WO_TEST_FRAMEWORK_NAME])                                           \
    {                                                                          \
        WOTestFrameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath]; \
        if (WOTestFrameworkBundle && [WOTestFrameworkBundle load]) break;      \
    }                                                                          \
                                                                               \
    fprintf(stderr, "error: could not load WOTest.framework bundle\n");        \
} while (0);

#pragma mark -
#pragma mark Random value generator method macros

/*! \name Random value generator method macros
\startgroup */

#define WO_BIG_TEST_VALUE       1000000000
#define WO_TEST_VALUE           2000000
#define WO_SMALL_TEST_VALUE     70000

#define WO_RANDOMIZATION_RANGE  500

/*! \endgroup */

#pragma mark -
#pragma mark Unit test macros

#define WO_TEST_WRAPPER(test)                                                                   \
do {                                                                                            \
    @try                                                                                        \
    {                                                                                           \
        (test);                                                                                 \
    }                                                                                           \
    @catch (id WOTestWrapperUncaughtException)                                                  \
    {                                                                                           \
        NSString *info = [NSString stringWithFormat:@"%@ (%@)",                                 \
            [NSException WOTest_nameForException:WOTestWrapperUncaughtException],               \
            [NSException WOTest_descriptionForException:WOTestWrapperUncaughtException]];       \
        [WO_TEST_SHARED_INSTANCE writeUncaughtException:info inFile:__FILE__ atLine:__LINE__];  \
    }                                                                                           \
} while (0)

#pragma mark -
#pragma mark Empty (do-nothing) test macros

//! \name Empty (do-nothing) test macros
//! \startgroup

//! This macro is not a test but you can optionally include it at the start of a test method so that WOTest can cache the current file name and line number. This is useful for cases where a test method might cause an uncaught exception. If WOTest has a cached copy of the last known location then the user can quickly go to the site of the exception (or near to the site) by clicking in the build results window.
#define WO_TEST_START               [WO_TEST_SHARED_INSTANCE cacheFile:__FILE__ line:__LINE__]

//! An empty test which always passes.
#define WO_TEST_PASS                [WO_TEST_SHARED_INSTANCE passTestInFile:__FILE__ atLine:__LINE__]

//! An empty test which always fails.
#define WO_TEST_FAIL                [WO_TEST_SHARED_INSTANCE failTestInFile:__FILE__ atLine:__LINE__]

//! \endgroup */

#pragma mark -
#pragma mark Boolean test macros

/*! \name Boolean test macros
\startgroup */

/*! The expression should evalutate to TRUE. */
#define WO_TEST_TRUE(expr)          WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testTrue:(expr) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_TRUE. */
#define WO_TEST(expr)               WO_TEST_TRUE(expr)

/*! The expression should evaluate to FALSE. */
#define WO_TEST_FALSE(expr)         WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFalse:(expr) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_FALSE. */
#define WO_TEST_NOT(expr)           WO_TEST_FALSE(expr)

/*! \endgroup */

#pragma mark -
#pragma mark Generic scalar test macros without error margins

/*! The (scalar) expression should be positive (greater than 0). The comparison is done using the greather-than operator (">"). */
#define WO_TEST_POSITIVE(scalar)    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testPositive:(scalar) inFile:__FILE__ atLine:__LINE__])

/*! The (scalar) expression should be negative (less than 0). The comparison is done using the less-than operator ("<"). */
#define WO_TEST_NEGATIVE(scalar)    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testNegative:(scalar) inFile:__FILE__ atLine:__LINE__])

/*! The (scalar) expression should be zero (0). The comparison is done using the equal-to operator ("=="). */
#define WO_TEST_ZERO(scalar)        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testZero:(scalar) inFile:__FILE__ atLine:__LINE__])

/*! The (scalar) expression should not be zero (0). The comparison is done using the not-equal-to operator ("!="). */
#define WO_TEST_NOT_ZERO(scalar)    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testNotZero:(scalar) inFile:__FILE__ atLine:__LINE__])

/*! Test if two NSValue-compatible values are equal. Any value that is compatible with the NSValue value:withObjCType: method can be compared using this macro. This means that you can compare any standard C or Objective-C data item (scalar types such as int, float and char, as well as pointers, structures and object ids, SELs or Class objects). A relaxed comparison is performed that is not as strict as the usual NSValue isEqualToValue: method. For example, values such as ints and longs are cast by the compiler before comparison; this is different from the normal case in which the two values would be considered not equal because of their different types even if their actual numeric content was identical. Object equality is tested using the isEqual: method. Any cases not specially handled are passed through to the standard NSValue isEqualToValue: method for comparison.

Implicit casting is performed between numeric types (char, int, short, long, long long, unsigned char, unsigned int, unsigned short, unsigned long, unsigned long long, float, double and _Bool). Casting is not performed between types such as id, Class and SEL.

If you wish to avoid the cast or make a stricter comparison you should use macros such as WO_TEST_IS_INT to confirm the type of the value before comparison. You could also use the WO_TEST_INTS_EQUAL macro (or similar) to force the compiler to cast the values to your chosen type prior to comparison.

In most cases the WO_TEST_EQUAL macro is the best choice because it is equivalent to allowing the compiler to transparently perform a cast as in the following example; this is what most programmers expect when they perform an equality test:

\code
unsigned int    a = 10;
long long       b = 10;
if (a == b) // compiler implicitly casts here
{
    // values are equal
}
else
{
    // values are not equal
}
\endcode

*/
#define WO_TEST_EQUAL(actual, expected)                                                                                         \
do {                                                                                                                            \
    typeof(actual) WOMacroVariable1 = (actual);                                                                                 \
    typeof(expected) WOMacroVariable2 = (expected);                                                                             \
    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testValue:[NSValue value:&WOMacroVariable1 withObjCType:@encode(typeof(actual))]   \
                                             isEqualTo:[NSValue value:&WOMacroVariable2 withObjCType:@encode(typeof(expected))] \
                                                inFile:__FILE__                                                                 \
                                                atLine:__LINE__]);                                                              \
} while (0)

/*! Synonym for WO_TEST_EQUAL. "EQ" stands for "Equal". */
#define WO_TEST_EQ(actual, expected)  WO_TEST_EQUAL(actual, expected)

#define WO_TEST_NOT_EQUAL(actual, expected)                                                                                     \
do {                                                                                                                            \
    typeof(actual) WOMacroVariable1 = (actual);                                                                                 \
    typeof(expected) WOMacroVariable2 = (expected);                                                                             \
    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testValue:[NSValue value:&WOMacroVariable1 withObjCType:@encode(typeof(actual))]   \
                                          isNotEqualTo:[NSValue value:&WOMacroVariable2 withObjCType:@encode(typeof(expected))] \
                                                inFile:__FILE__                                                                 \
                                                atLine:__LINE__]);                                                              \
} while (0)

/*! Synonym for WO_TEST_NE. "NE" stands for "Not Equal". */
#define WO_TEST_NE(actual, expected)  WO_TEST_NOT_EQUAL(actual, expected)

#define WO_TEST_GREATER_THAN(actual, expected)                                                                                  \
do {                                                                                                                            \
    typeof(actual) WOMacroVariable1 = (actual);                                                                                 \
    typeof(expected) WOMacroVariable2 = (expected);                                                                             \
    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testValue:[NSValue value:&WOMacroVariable1 withObjCType:@encode(typeof(actual))]   \
                                           greaterThan:[NSValue value:&WOMacroVariable2 withObjCType:@encode(typeof(expected))] \
                                                inFile:__FILE__                                                                 \
                                                atLine:__LINE__]);                                                              \
} while (0)

/*! Synonym for WO_TEST_GREATER_THAN. "GT" stands for "Greater Than". */
#define WO_TEST_GT(actual, expected)  WO_TEST_GREATER_THAN(actual, expected)

#define WO_TEST_NOT_GREATER_THAN(actual, expected)                                                                              \
do {                                                                                                                            \
    typeof(actual) WOMacroVariable1 = (actual);                                                                                 \
    typeof(expected) WOMacroVariable2 = (expected);                                                                             \
    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testValue:[NSValue value:&WOMacroVariable1 withObjCType:@encode(typeof(actual))]   \
                                        notGreaterThan:[NSValue value:&WOMacroVariable2 withObjCType:@encode(typeof(expected))] \
                                                inFile:__FILE__                                                                 \
                                                atLine:__LINE__]);                                                              \
} while (0)

/*! Synonym for WO_TEST_NOT_GREATER_THAN. "LTE" stands for "Less Than or Equal". */
#define WO_TEST_LTE(actual, expected) WO_TEST_NOT_GREATER_THAN(actual, expected)

/*! Synonym for WO_TEST_NOT_GREATER_THAN. "NGT" stands for "Not Greater Than". */
#define WO_TEST_NGT(actual, expected) WO_TEST_NOT_GREATER_THAN(actual, expected)

#define WO_TEST_LESS_THAN(actual, expected)                                                                                     \
do {                                                                                                                            \
    typeof(actual) WOMacroVariable1 = (actual);                                                                                 \
    typeof(expected) WOMacroVariable2 = (expected);                                                                             \
    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testValue:[NSValue value:&WOMacroVariable1 withObjCType:@encode(typeof(actual))]   \
                                              lessThan:[NSValue value:&WOMacroVariable2 withObjCType:@encode(typeof(expected))] \
                                                inFile:__FILE__                                                                 \
                                                atLine:__LINE__]);                                                              \
} while (0)

/*! Synonym for WO_TEST_LESS_THAN. "LT" stands for "Less Than". */
#define WO_TEST_LT(actual, expected)  WO_TEST_LESS_THAN(actual, expected)

#define WO_TEST_NOT_LESS_THAN(actual, expected)                                                                                 \
do {                                                                                                                            \
    typeof(actual) WOMacroVariable1 = (actual);                                                                                 \
    typeof(expected) WOMacroVariable2 = (expected);                                                                             \
    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testValue:[NSValue value:&WOMacroVariable1 withObjCType:@encode(typeof(actual))]   \
                                           notLessThan:[NSValue value:&WOMacroVariable2 withObjCType:@encode(typeof(expected))] \
                                                inFile:__FILE__                                                                 \
                                                atLine:__LINE__]);                                                              \
} while (0)

/*! Synonym for WO_TEST_NOT_LESS_THAN. "GTE" stands for "Greater Than or Equal". */
#define WO_TEST_GTE(actual, expected) WO_TEST_NOT_LESS_THAN(actual, expected)

/*! Synonym for WO_TEST_NOT_LESS_THAN. "NLT" stands for "Not Less Than". */
#define WO_TEST_NLT(actual, expected) WO_TEST_NOT_LESS_THAN(actual, expected)

#pragma mark -
#pragma mark Generic scalar test macros with error margins

#define WO_TEST_POSITIVE_WITHIN_ERROR
#define WO_TEST_NEGATIVE_WITHIN_ERROR
#define WO_TEST_ZERO_WITHIN_ERROR
#define WO_TEST_NOT_ZERO_WITHIN_ERROR
#define WO_TEST_EQUAL_WITHIN_ERROR
#define WO_TEST_NOT_EQUAL_WITHIN_ERROR
#define WO_TEST_GREATER_THAN_WITHIN_ERROR
#define WO_TEST_NOT_GREATER_THAN_WITHIN_ERROR
#define WO_TEST_LESS_THAN_WITHIN_ERROR
#define WO_TEST_NOT_LESS_THAN_WITHIN_ERROR

#pragma mark -
#pragma mark Pointer to void test macros

/*! \name Pointer to void test macros
\startgroup */

/*! The pointer should be nil (0). Given that the pointer is passed as a pointer to void, this test should work with pointers to Objective-C objects as well as other pointers to other objects. The comparison is done using the equal-to operator ("=="). */
#define WO_TEST_NIL(pointer)        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testNil:(pointer) inFile:__FILE__ atLine:__LINE__])

/*! The pointer should not be nil (0). Given that the pointer is passed as a pointer to void, this test should work with pointers to Objective-C objects as well as pointers to other objects. The comparison is done using the not-equal-to operator ("!="). */
#define WO_TEST_NOT_NIL(pointer)    WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testNotNil:(pointer) inFile:__FILE__ atLine:__LINE__])

/*! The two pointers should be equal. Given that the pointers are passed as pointers to void, this test should work with pointers to Objective-C objects as well as pointers to other objects. The comparison is done using the equal-to operator ("=="). */
#define WO_TEST_POINTERS_EQUAL(actual, expected)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testPointer:(actual) isEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! The two pointers should not be equal. Given that the pointers are passed as pointers to void, this test should work with pointers to Objective-C objects as well as pointers to other objects. The comparison is done using the not-equal-to operator ("!="). */
#define WO_TEST_POINTERS_NOT_EQUAL(actual, expected)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testPointer:(actual) isNotEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark int test macros

/*! \name int test macros
\startgroup */

#define WO_TEST_IS_INT(aScalar)                                 \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsInt:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_IS_NOT_INT(aScalar)                                 \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsNotInt:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])


/*! The integer expression should be positive (greater than 0). */
#define WO_TEST_INT_POSITIVE(aInt) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIntPositive:(aInt) inFile:__FILE__ atLine:__LINE__])

/*! The integer expression should be negative (less than 0). */
#define WO_TEST_INT_NEGATIVE(aInt) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIntNegative:(aInt) inFile:__FILE__ atLine:__LINE__])

/*! The integer expression should be zero (0). */
#define WO_TEST_INT_ZERO(aInt) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIntZero:(aInt) inFile:__FILE__ atLine:__LINE__])

/*! The integer expression should not be zero (0). */
#define WO_TEST_INT_NOT_ZERO(aInt) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIntNotZero:(aInt) inFile:__FILE__ atLine:__LINE__])

/*! The two integer expressions should be equal. */
#define WO_TEST_INTS_EQUAL(actual, expected)      \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testInt:(actual) isEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! The two integer expressions should not be equal. */
#define WO_TEST_INTS_NOT_EQUAL(actual, expected)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testInt:(actual) isNotEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_INT_GREATER_THAN(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testInt:(actual) greaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_INT_NOT_GREATER_THAN(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testInt:(actual) notGreaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_INT_LESS_THAN(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testInt:(actual) lessThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_INT_NOT_LESS_THAN(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testInt:(actual) notLessThan:(expected) inFile:__FILE__ atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark unsigned test macros

/*! \name unsigned test macros
\startgroup */

#define WO_TEST_IS_UNSIGNED(aScalar)                                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsUnsigned:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_IS_NOT_UNSIGNED(aScalar)                                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsNotUnsigned:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])

/*! The unsigned expression should be zero (0). */
#define WO_TEST_UNSIGNED_ZERO(aUnsigned)                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsignedZero:(aUnsigned) inFile:__FILE__ atLine:__LINE__])

/*! The unsigned expression should not be zero (0). */
#define WO_TEST_UNSIGNED_NOT_ZERO(aUnsigned)                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsignedNotZero:(aUnsigned) inFile:__FILE__ atLine:__LINE__])

/*! The two unsigned expressions should be equal. */
#define WO_TEST_UNSIGNEDS_EQUAL(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsigned:(actual) isEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! The two unsigned expressions should not be equal. */
#define WO_TEST_UNSIGNEDS_NOT_EQUAL(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsigned:(actual) isNotEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_UNSIGNED_GREATER_THAN(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsigned:(actual) greaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_UNSIGNED_NOT_GREATER_THAN(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsigned:(actual) notGreaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_UNSIGNED_LESS_THAN(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsigned:(actual) lessThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_UNSIGNED_NOT_LESS_THAN(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testUnsigned:(actual) notLessThan:(expected) inFile:__FILE__ atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark float test macros without error margins

/*! \name float test macros without error margins
\startgroup */

#define WO_TEST_IS_FLOAT(aScalar)                               \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsFloat:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_IS_NOT_FLOAT(aScalar)                               \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsNotFloat:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])

/*! The float expression should be positive (greater than 0). */
#define WO_TEST_FLOAT_POSITIVE(aFloat)              \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatPositive:(aFloat) inFile:__FILE__ atLine:__LINE__])

/*! The float expression should be negative (less than 0). */
#define WO_TEST_FLOAT_NEGATIVE(aFloat)              \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatNegative:(aFloat) inFile:__FILE__ atLine:__LINE__])

/*! The float expression should be zero (0). */
#define WO_TEST_FLOAT_ZERO(aFloat)                  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatZero:(aFloat) inFile:__FILE__ atLine:__LINE__])

/*! The float expression should not be zero (0). */
#define WO_TEST_FLOAT_NOT_ZERO(aFloat)              \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatNotZero:(aFloat) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOATS_EQUAL(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual) isEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOATS_NOT_EQUAL(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual) isNotEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOAT_GREATER_THAN(actual, expected)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual) greaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOAT_NOT_GREATER_THAN(actual, expected)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual) notGreaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOAT_LESS_THAN(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual) lessThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOAT_NOT_LESS_THAN(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual) notLessThan:(expected) inFile:__FILE__ atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark float test macros with error margins

/*! \name float test macros with error margins
\startgroup */

#define WO_TEST_FLOAT_POSITIVE_WITHIN_ERROR(aFloat, error)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatPositive:(aFloat) withinError:(error) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOAT_NEGATIVE_WITHIN_ERROR(aFloat, error)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatNegative:(aFloat) withinError:(error) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOAT_ZERO_WITHIN_ERROR(aFloat, error)      \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatZero:(aFloat) withinError:(error) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_FLOAT_NOT_ZERO_WITHIN_ERROR(aFloat, error)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloatNotZero:(aFloat) withinError:(error) inFile:__FILE__ atLine:__LINE__])

/*! The two float expressions should be equal, within the specified margin of error. As the allowed margin of error becomes larger in the positive direction, the more likely that the test will pass; specifying a negative margin of error causes the test to be meaningless because it means that the test will never pass. Zero (0) is a legal error margin; it causes the test to occur exactly. */
#define WO_TEST_FLOATS_EQUAL_WITHIN_ERROR(actual, expected, error)      \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual)     \
                                                 isEqualTo:(expected)   \
                                               withinError:(error)      \
                                                    inFile:__FILE__     \
                                                    atLine:__LINE__])

/*! The two float expressions should not be equal, within the specified margin of error. As the allowed margin of error becomes larger in the positive direction, the more likely that the test will pass; the larger the margin becomes in the negative direction, the less likely that the test will pass. Zero (0) is a legal error margin; it causes the test to occur exactly. */
#define WO_TEST_FLOATS_NOT_EQUAL_WITHIN_ERROR(actual, expected, error)      \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual)         \
                                              isNotEqualTo:(expected)       \
                                               withinError:(error)          \
                                                    inFile:__FILE__         \
                                                    atLine:__LINE__])

/*! The first float expression should be greater than the second float expression, after adjustment according to the specified margin of error. As the allowed margin of error becomes larger in the positive direction, the more likely that the test will pass; the larger the margin becomes in the negative direction, the less likely that the test will pass. Zero (0) is a legal error margin; it causes the test to occur exactly. */
#define WO_TEST_FLOAT_GREATER_THAN_WITHIN_ERROR(actual, expected, error)    \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual)         \
                                               greaterThan:(expected)       \
                                               withinError:(error)          \
                                                    inFile:__FILE__         \
                                                    atLine:__LINE__])

/*! The first float expression should not be greater than (that is, it should be less than or equal to) the second float expression, after adjustment according to the specified margin of error. As the allowed margin of error becomes larger in the positive direction, the more likely that the test will pass; the larger the margin becomes in the negative direction, the less likely that the test will pass. Zero (0) is a legal error margin; it causes the test to occur exactly. */
#define WO_TEST_FLOAT_NOT_GREATER_THAN_WITHIN_ERROR(actual, expected, error)    \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual)             \
                                            notGreaterThan:(expected)           \
                                               withinError:(error)              \
                                                    inFile:__FILE__             \
                                                    atLine:__LINE__])

/*! The first float expression should be less than the second float expression, after adjustment according to the specified margin of error. As the allowed margin of error becomes larger in the positive direction, the more likely that the test will pass; the larger the margin becomes in the negative direction, the less likely that the test will pass. Zero (0) is a legal error margin; it causes the test to occur exactly. */
#define WO_TEST_FLOAT_LESS_THAN_WITHIN_ERROR(actual, expected, error)   \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual)     \
                                                  lessThan:(expected)   \
                                               withinError:(error)      \
                                                    inFile:__FILE__     \
                                                    atLine:__LINE__])

/*! The first float expression should not be less than (that is, it should be greater than or equal to) the second float expression, after adjustment according to the specified margin of error. As the allowed margin of error becomes larger in the positive direction, the more likely that the test will pass; the larger the margin becomes in the negative direction, the less likely that the test will pass. Zero (0) is a legal error margin; it causes the test to occur exactly. */
#define WO_TEST_FLOAT_NOT_LESS_THAN_WITHIN_ERROR(actual, expected, error)   \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testFloat:(actual)         \
                                               notLessThan:(expected)       \
                                               withinError:(error)          \
                                                    inFile:__FILE__         \
                                                    atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark double test macros without error margins

/*! \name double test macros without error margins
\startgroup */

#define WO_TEST_IS_DOUBLE(aScalar)                                  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsDouble:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_IS_NOT_DOUBLE(aScalar)                              \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testIsNotDouble:(@encode(typeof(aScalar))) inFile:__FILE__ atLine:__LINE__])

/*! The double expression should be positive (greater than 0). */
#define WO_TEST_DOUBLE_POSITIVE(aDouble)                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoublePositive:(aDouble) inFile:__FILE__ atLine:__LINE__])

/*! The double expression should be negative (less than 0). */
#define WO_TEST_DOUBLE_NEGATIVE(aDouble)                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoubleNegative:(aDouble) inFile:__FILE__ atLine:__LINE__])

/*! The double expression should be zero (0). */
#define WO_TEST_DOUBLE_ZERO(aDouble)                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoubleZero:(aDouble) inFile:__FILE__ atLine:__LINE__])

/*! The double expression should not be zero (0). */
#define WO_TEST_DOUBLE_NOT_ZERO(aDouble)                \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoubleNotZero:(aDouble) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLES_EQUAL(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual) isEqualTo:(actual) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLES_NOT_EQUAL(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual) isNotEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLE_GREATER_THAN(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual) greaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLE_NOT_GREATER_THAN(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual) notGreaterThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLE_LESS_THAN(actual, expected)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual) lessThan:(expected) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLE_NOT_LESS_THAN(actual, expected)  \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual) notLessThan:(expected) inFile:__FILE__ atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark double test macros with error margins

/*! \name double test macros with error margins
\startgroup */

#define WO_TEST_DOUBLE_POSITIVE_WITHIN_ERROR(aDouble, error)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoublePositive:(aDouble) withinError:(error) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLE_NEGATIVE_WITHIN_ERROR(aDouble, error)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoubleNegative:(aDouble) withinError:(error) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLE_ZERO_WITHIN_ERROR(aDouble, error)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoubleZero:(aDouble) withinError:(error) inFile:__FILE__ atLine:__LINE__])

#define WO_TEST_DOUBLE_NOT_ZERO_WITHIN_ERROR(aDouble, error)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDoubleNotZero:(aDouble) withinError:(error) inFile:__FILE__ atLine:__LINE__])

/*! The two double expressions should be equal, within the specified margin of error. */
#define WO_TEST_DOUBLES_EQUAL_WITHIN_ERROR(actual, expected, error)     \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual)    \
                                                  isEqualTo:(expected)  \
                                                withinError:(error)     \
                                                     inFile:__FILE__    \
                                                     atLine:__LINE__])

/*! The two double expressions should not be equal, within the specified margin of error. */
#define WO_TEST_DOUBLES_NOT_EQUAL_WITHIN_ERROR(actual, expected, error) \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual)    \
                                               isNotEqualTo:(expected)  \
                                                withinError:(error)     \
                                                     inFile:__FILE__    \
                                                     atLine:__LINE__])

#define WO_TEST_DOUBLE_GREATER_THAN_WITHIN_ERROR(actual, expected, error)   \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual)        \
                                                greaterThan:(expected)      \
                                                withinError:(error)         \
                                                     inFile:__FILE__        \
                                                     atLine:__LINE__])

#define WO_TEST_DOUBLE_NOT_GREATER_THAN_WITHIN_ERROR(actual, expected, error)   \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual)            \
                                             notGreaterThan:(expected)          \
                                                withinError:(error)             \
                                                     inFile:__FILE__            \
                                                     atLine:__LINE__])

#define WO_TEST_DOUBLE_LESS_THAN_WITHIN_ERROR(actual, expected, error)  \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual)    \
                                                   lessThan:(expected)  \
                                                withinError:(error)     \
                                                     inFile:__FILE__    \
                                                     atLine:__LINE__])

#define WO_TEST_DOUBLE_NOT_LESS_THAN_WITHIN_ERROR(actual, expected, error)  \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDouble:(actual)        \
                                                notLessThan:(expected)      \
                                                withinError:(error)         \
                                                     inFile:__FILE__        \
                                                     atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark Object test macros

/*!
\name Object test macros
\startgroup
*/

/*! \note If both objects are nil they are considered to be equal. */
#define WO_TEST_OBJECTS_EQUAL(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testObject:actual isNotEqualTo:expected inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_OBJECTS_EQUAL. "EQ" stands for "Equal". */
#define WO_TEST_OBJECTS_EQ(actual, expected) WO_TEST_OBJECTS_EQUAL(actual, expected)

/*! \note If both objects are nil they are considered to be equal. */
#define WO_TEST_OBJECTS_NOT_EQUAL(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testObject:actual isNotEqualTo:expected inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_OBJECTS_NOT_EQUAL. "NE" stands for "Not Equal". */
#define WO_TEST_OBJECTS_NE(actual, expected) WO_TEST_OBJECTS_NOT_EQUAL(actual, expected)

/*! \endgroup */

#pragma mark -
#pragma mark NSString test macros

/*!
\name NSString test macros
\startgroup
 */

/*! \note If both objects are nil they are considered to be equal. */
#define WO_TEST_STRINGS_EQUAL(actual, expected) \
        WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) isEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_STRINGS_EQUAL. "EQ" stands for "Equal". */
#define WO_TEST_STRINGS_EQ(actual, expected) WO_TEST_STRINGS_EQUAL(actual, expected)

/*! \note If both objects are nil they are considered to be equal. */
#define WO_TEST_STRINGS_NOT_EQUAL(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) isNotEqualToString:(expected) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_STRINGS_NOT_EQUAL. "NE" stands for "Not Equal". */
#define WO_TEST_STRINGS_NE(actual, expected) WO_TEST_STRINGS_NOT_EQUAL(actual, expected)

//! \note The test is performed using the NSString hasPrefix: method and has the same semantics.
//! \warning An exception will be thrown if \p expected is nil
#define WO_TEST_STRING_HAS_PREFIX(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) hasPrefix:(expected) inFile:__FILE__ atLine:__LINE__])

//! \note The test is performed using the NSString hasPrefix: method and has the same semantics.
//! \warning An exception will be thrown if \p expected is nil
#define WO_TEST_STRING_DOES_NOT_HAVE_PREFIX(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) doesNotHavePrefix:(expected) inFile:__FILE__ atLine:__LINE__])

//! \note The test is performed using the NSString hasSuffix: method and has the same semantics.
//! \warning An exception will be thrown if \p expected is nil
#define WO_TEST_STRING_HAS_SUFFIX(actual, expected) \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) hasSuffix:(expected) inFile:__FILE__ atLine:__LINE__])

//! \note The test is performed using the NSString hasSuffix: method and has the same semantics.
//! \warning An exception will be thrown if \p expected is nil
#define WO_TEST_STRING_DOES_NOT_HAVE_SUFFIX(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) doesNotHaveSuffix:(expected) inFile:__FILE__ atLine:__LINE__])

//! \note The test is performed using the NSString rangeOfString: method and has the same semantics.
//! \warning An exception will be thrown if \p expected is nil
#define WO_TEST_STRING_CONTAINS(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) contains:(expected) inFile:__FILE__ atLine:__LINE__])

//! \note The test is performed using the NSString rangeOfString: method and has the same semantics.
//! \warning An exception will be thrown if \p expected is nil
#define WO_TEST_STRING_DOES_NOT_CONTAIN(actual, expected)   \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testString:(actual) doesNotContain:(expected) inFile:__FILE__ atLine:__LINE__])

/*! \endgroup */

#pragma mark -
#pragma mark NSArray test macros

/*! \name NSArray test macros
\startgroup */

/*!  */
#define WO_TEST_ARRAYS_EQUAL(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testArray:(actual) isEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_ARRAYS_EQUAL. "EQ" stands for "Equal". */
#define WO_TEST_ARRAYS_EQ(actual, expected)  WO_TEST_ARRAYS_EQUAL(actual, expected)

/*!  */
#define WO_TEST_ARRAYS_NOT_EQUAL(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testArray:(actual) isNotEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_ARRAYS_NOT_EQUAL. "NE" stands for "Not Equal". */
#define WO_TEST_ARRAYS_NE(actual, expected)  WO_TEST_ARRAYS_NOT_EQUAL(actual, expected)

/*! \endgroup */

#pragma mark -
#pragma mark NSDictionary test macros

/*! \name NSDictionary test macros
\startgroup */

/*!  */
#define WO_TEST_DICTIONARIES_EQUAL(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDictionary:(actual) isEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_DICTIONARIES_EQUAL. "EQ" stands for "Equal". */
#define WO_TEST_DICTIONARIES_EQ(actual, expected) WO_TEST_DICTIONARIES_EQUAL(actual, expected)

/*!  */
#define WO_TEST_DICTIONARIES_NOT_EQUAL(actual, expected)    \
WO_TEST_WRAPPER([WO_TEST_SHARED_INSTANCE testDictionary:(actual) isNotEqualTo:(expected) inFile:__FILE__ atLine:__LINE__])

/*! Synonym for WO_TEST_DICTIONARIES_NOT_EQUAL. "NE" stands for "Not Equal". */
#define WO_TEST_DICTIONARIES_NE(actual, expected) WO_TEST_DICTIONARIES_NOT_EQUAL(actual, expected)

/*! \endgroup */

#pragma mark -
#pragma mark Exception test macros

//! \name Exception test macros
//! The lengthy local variable names (WOTestMacroException and WOTestMacroCaughtException) are contrived so as to minimize the likelihood of namespace clashes.
//! \startgroup

/*! Passes only if an exception is thrown during the evaluation of the expression, expr. */
#define WO_TEST_THROWS(expr)                                                    \
do {                                                                            \
    id WOTestMacroException  = nil;                                             \
    @try {                                                                      \
        expr;                                                                   \
    }                                                                           \
    @catch (id WOTestMacroCaughtException) {                                    \
        WOTestMacroException = WOTestMacroCaughtException;                      \
    }                                                                           \
    [WO_TEST_SHARED_INSTANCE testThrowsException:(WOTestMacroException)         \
                                          inFile:__FILE__                       \
                                          atLine:__LINE__];                     \
} while (0)

/*! Passes only if no exception is thrown during the evaluation of the expression, expr. */
#define WO_TEST_DOES_NOT_THROW(expr)                                            \
do {                                                                            \
    id WOTestMacroException = nil;                                              \
    @try {                                                                      \
        expr;                                                                   \
    }                                                                           \
    @catch (id WOTestMacroCaughtException) {                                    \
        WOTestMacroException = WOTestMacroCaughtException;                      \
    }                                                                           \
    [WO_TEST_SHARED_INSTANCE testDoesNotThrowException:(WOTestMacroException)   \
                                                inFile:__FILE__                 \
                                                atLine:__LINE__];               \
} while (0)

/*! Passes only if an exception with name name is thrown during the evaluation of the expression, expr. The test itself throws an exception if the name parameter is nil, or not a string object (NSString or one of its subclasses). */
#define WO_TEST_THROWS_EXCEPTION_NAMED(expr, name)                      \
do {                                                                    \
    id WOTestMacroException = nil;                                      \
    @try {                                                              \
        expr;                                                           \
    }                                                                   \
    @catch (id WOTestMacroCaughtException) {                            \
        WOTestMacroException = WOTestMacroCaughtException;              \
    }                                                                   \
    [WO_TEST_SHARED_INSTANCE testThrowsException:(WOTestMacroException) \
                                           named:(name)                 \
                                          inFile:__FILE__               \
                                          atLine:__LINE__];             \
} while (0)

/*! Passes only if an exception with name name is not thrown during the evaluation of the expression, expr (exceptions with names other than name do not influence the outcome of the test). The test itself throws an exception if the name parameter is nil, or not a string object (NSString or one of its subclasses). */
#define WO_TEST_DOES_NOT_THROW_EXCEPTION_NAMED(expr, name)                      \
do {                                                                            \
    id WOTestMacroException = nil;                                              \
    @try {                                                                      \
        expr;                                                                   \
    }                                                                           \
    @catch (id WOTestMacroCaughtException) {                                    \
        WOTestMacroException = WOTestMacroCaughtException;                      \
    }                                                                           \
    [WO_TEST_SHARED_INSTANCE testDoesNotThrowException:(WOTestMacroException)   \
                                                 named:(name)                   \
                                                inFile:__FILE__                 \
                                                atLine:__LINE__];               \
} while (0)

//! \endgroup
