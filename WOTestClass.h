//
//  WOTestClass.h
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

#import <Foundation/Foundation.h>

@interface WOTest : NSObject {

    NSDate      *startDate;

    unsigned    classesWithTests;
    unsigned    classesWithoutTests;
    unsigned    methodsWithTests;
    unsigned    testsRun;
    unsigned    testsPassed;
    unsigned    testsFailed;
    unsigned    uncaughtExceptions;

    //! test sense inversion: should only be used during WOTest self-testing
    unsigned    testsFailedExpected;
    unsigned    testsPassedUnexpected;
    BOOL        expectFailures;

    //! low-level exception handling inversion: should only be used during WOTest self-testing
    unsigned    lowLevelExceptionsExpected;
    unsigned    lowLevelExceptionsUnexpected;
    BOOL        expectLowLevelExceptions;

    //! Optionally refrain from handling low level exceptions
    BOOL        handlesLowLevelExceptions;

    //! Internal use only: used for keeping track of whether low-level exception handlers have been installed or not
    //! Necessary because tested methods may change the low-level-exception-catching status mid-test
    BOOL        lowLevelExceptionHandlerInstalled;

    //! 0 = mostly silent operation; 1 = verbose; 2 = very verbose
    unsigned    verbosity;

    //! Optionally trim leading path components when printing path names to console.
    unsigned    trimInitialPathComponents;

    //! Cache last reported path and last reported line number for use when printing warnings and errors which don't include file and line information
    NSString    *lastReportedFile;
    int         lastReportedLine;

    //! Defaults to YES.
    BOOL        warnsAboutSignComparisons;
}

#pragma mark -
#pragma mark Singleton pattern enforcement methods

/*! \name Singleton pattern enforcement methods
\startgroup */

+ (WOTest *)sharedInstance;

/*! \endgroup */

#pragma mark -
#pragma mark Utility methods

/*! \name Utility methods
    \startgroup */

/*! Returns an NSString based on sending the "description" selector to anObject, compressing whitespace and truncating if necessary at index and appending an ellipsis. Returns nil if anObject is nil. Optionally returns YES or NO indirectyl via /p didTruncate to indicate whether truncation actually occurred. Pass \p index of 0 to return an untruncated, uncompressed description. */
- (NSString *)description:(id)anObject truncatedAt:(unsigned)index didTruncate:(BOOL *)didTruncate;

/*! Seed the random number generator with current system time, in effect causing the random number generator to produce a different sequence of numbers on each run. The random value generator methods will output values that are equal to WO_TEST_VALUE (or WO_BIG_TEST_VALUE or WO_SMALL_TEST_VALUE) plus or minus a random offset up to WO_RANDOMIZATION_RANGE. If you do not explicitly seed the random number generator, the same seed will be used on each run. */
- (void)seedRandomNumberGenerator;

/*! Seed the random number generator with the value passed as seed. Pass 1 to generate a repeatable sequence of numbers on each run (see the random (3) man page for more information. */
- (void)seedRandomNumberGenerator:(unsigned long)seed;

/*! \endgroup */

#pragma mark -
#pragma mark Test-running methods

/*! \name Test-running test methods
    \startgroup */

/*! Runs all tests currently visible in the runtime. Returns YES if all tests pass, NO if any test fails. */
- (BOOL)runAllTests;

/*! Returns YES if all tests pass, NO if any test fails. Raises an exception if className is nil. */
- (BOOL)runTestsForClassName:(NSString *)className;

/*! Returns YES if all tests pass, NO if any test fails. Raises an exception if aClass is nil. */
- (BOOL)runTestsForClass:(Class)aClass;

/*! Returns a list of class names (NSStrings) corresponding to all classes known to the runtime that conform to the WOTest protocol. */
- (NSArray *)testableClasses;

/*! Like the allTestableClasses method, returns a list of class names (NSStrings) corresponding to all classes known to the runtime that conform to the WOTest protocol, with the additional limitation that only classes belonging to the specified bundle are included. */
- (NSArray *)testableClassesFrom:(NSBundle *)aBundle;

/*! Given a class that conforms to the WOTest protocol, returns a list of method names (NSStrings) in that class that correspond to testable methods (in other words, method names that begin with the string "test"). */
- (NSArray *)testableMethodsFrom:(Class)aClass;

- (void)printTestResultsSummary;

//! Returns YES if there were no failures.
- (BOOL)testsWereSuccessful;

/*! \endgroup */

#pragma mark -
#pragma mark Growl support

- (void)growlNotifyTitle:(NSString *)title message:(NSString *)message isWarning:(BOOL)isWarning sticky:(BOOL)sticky;

#pragma mark -
#pragma mark Logging methods

//! \name Logging methods
//! \startgroup

//! Keep track of last known file and line number
- (void)cacheFile:(char *)path line:(int)line;

- (void)writeLastKnownLocation;

- (void)writePassed:(BOOL)passed inFile:(char *)path atLine:(int)line message:(NSString *)message, ...;

- (void)writeErrorInFile:(char *)path atLine:(int)line message:(NSString *)message, ...;

- (void)writeWarningInFile:(char *)path atLine:(int)line message:(NSString *)message, ...;

- (void)writeUncaughtException:(NSString *)info inFile:(char *)path atLine:(int)line;

- (void)writeStatusInFile:(char *)path atLine:(int)line message:(NSString *)message, ...;

- (void)writeStatus:(NSString *)message, ...;

- (void)writeWarning:(NSString *)message, ...;

- (void)writeError:(NSString *)message, ...;

//! \endgroup

#pragma mark -
#pragma mark Empty (do-nothing) test methods

/*! \name Empty (do-nothing) test methods
    \startgroup */

/*! An empty test which always passes. */
- (void)passTestInFile:(char *)path atLine:(int)line;

/*! An empty test which always fails. */
- (void)failTestInFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark Boolean test methods

/*! \name Boolean test methods
    \startgroup */

- (void)testTrue:(BOOL)expr inFile:(char *)path atLine:(int)line;

- (void)testFalse:(BOOL)expr inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark NSValue-based tests

/*! \name NSValue-based tests
    \startgroup */

- (void)testValue:(NSValue *)actual isEqualTo:(NSValue *)expected inFile:(char *)path atLine:(int)line;

- (void)testValue:(NSValue *)actual isNotEqualTo:(NSValue *)expected inFile:(char *)path atLine:(int)line;

- (void)testValue:(NSValue *)actual greaterThan:(NSValue *)expected inFile:(char *)path atLine:(int)line;

- (void)testValue:(NSValue *)actual notGreaterThan:(NSValue *)expected inFile:(char *)path atLine:(int)line;

- (void)testValue:(NSValue *)actual lessThan:(NSValue *)expected inFile:(char *)path atLine:(int)line;

- (void)testValue:(NSValue *)actual notLessThan:(NSValue *)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark Pointer to void test methods

/*! \name Pointer to void test methods
    \startgroup */

- (void)testNil:(void *)pointer inFile:(char *)path atLine:(int)line;

- (void)testNotNil:(void *)pointer inFile:(char *)path atLine:(int)line;

- (void)testPointer:(void *)actual isEqualTo:(void *)expected inFile:(char *)path atLine:(int)line;

- (void)testPointer:(void *)actual isNotEqualTo:(void *)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark int test methods

/*! \name int test methods
    \startgroup */

/*! The WO_TEST_IS_INT macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsInt:(char *)type inFile:(char *)path atLine:(int)line;

/*! The WO_TEST_IS_NOT_INT macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsNotInt:(char *)type inFile:(char *)path atLine:(int)line;

- (void)testIntPositive:(int)aInt inFile:(char *)path atLine:(int)line;

- (void)testIntNegative:(int)aInt inFile:(char *)path atLine:(int)line;

- (void)testIntZero:(int)aInt inFile:(char *)path atLine:(int)line;

- (void)testIntNotZero:(int)aInt inFile:(char *)path atLine:(int)line;

- (void)testInt:(int)actual isEqualTo:(int)expected inFile:(char *)path atLine:(int)line;

- (void)testInt:(int)actual isNotEqualTo:(int)expected inFile:(char *)path atLine:(int)line;

- (void)testInt:(int)actual greaterThan:(int)expected inFile:(char *)path atLine:(int)line;

- (void)testInt:(int)actual notGreaterThan:(int)expected inFile:(char *)path atLine:(int)line;

- (void)testInt:(int)actual lessThan:(int)expected inFile:(char *)path atLine:(int)line;

- (void)testInt:(int)actual notLessThan:(int)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark unsigned test methods

/*! \name unsigned test methods
    \startgroup */

/*! The WO_TEST_IS_UNSIGNED macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsUnsigned:(char *)type inFile:(char *)path atLine:(int)line;

/*! The WO_TEST_IS_NOT_UNSIGNED macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsNotUnsigned:(char *)type inFile:(char *)path atLine:(int)line;

- (void)testUnsignedZero:(unsigned)aUnsigned inFile:(char *)path atLine:(int)line;

- (void)testUnsignedNotZero:(unsigned)aUnsigned inFile:(char *)path atLine:(int)line;

- (void)testUnsigned:(unsigned)actual isEqualTo:(unsigned)expected inFile:(char *)path atLine:(int)line;

- (void)testUnsigned:(unsigned)actual isNotEqualTo:(unsigned)expected inFile:(char *)path atLine:(int)line;

- (void)testUnsigned:(unsigned)actual greaterThan:(unsigned)expected inFile:(char *)path atLine:(int)line;

- (void)testUnsigned:(unsigned)actual notGreaterThan:(unsigned)expected inFile:(char *)path atLine:(int)line;

- (void)testUnsigned:(unsigned)actual lessThan:(unsigned)expected inFile:(char *)path atLine:(int)line;

- (void)testUnsigned:(unsigned)actual notLessThan:(unsigned)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark float test methods without error margins

/*! \name float test methods without error margins
    \startgroup */

/*! The WO_TEST_IS_FLOAT macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsFloat:(char *)type inFile:(char *)path atLine:(int)line;

/*! The WO_TEST_IS_NOT_FLOAT macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsNotFloat:(char *)type inFile:(char *)path atLine:(int)line;

- (void)testFloatPositive:(float)aFloat inFile:(char *)path atLine:(int)line;

- (void)testFloatNegative:(float)aFloat inFile:(char *)path atLine:(int)line;

- (void)testFloatZero:(float)aFloat inFile:(char *)path atLine:(int)line;

- (void)testFloatNotZero:(float)aFloat inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual isEqualTo:(float)expected inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual isNotEqualTo:(float)expected inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual greaterThan:(float)expected inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual notGreaterThan:(float)expected inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual lessThan:(float)expected inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual notLessThan:(float)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark float test methods with error margins

/*! \name float test methods with error margins
    \startgroup */

- (void)testFloatPositive:(float)aFloat withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloatNegative:(float)aFloat withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloatZero:(float)aFloat withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloatNotZero:(float)aFloat withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual isEqualTo:(float)expected withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual isNotEqualTo:(float)expected withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual greaterThan:(float)expected withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual notGreaterThan:(float)expected withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual lessThan:(float)expected withinError:(float)error inFile:(char *)path atLine:(int)line;

- (void)testFloat:(float)actual notLessThan:(float)expected withinError:(float)error inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark double test methods without error margins

/*! \name double test methods without error margins
    \startgroup */

/*! The WO_TEST_IS_DOUBLE macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsDouble:(char *)type inFile:(char *)path atLine:(int)line;

/*! The WO_TEST_IS_NOT_DOUBLE macro uses \@encode(typeof()) to pass a string encoding of the type. */
- (void)testIsNotDouble:(char *)type inFile:(char *)path atLine:(int)line;

- (void)testDoublePositive:(double)aDouble inFile:(char *)path atLine:(int)line;

- (void)testDoubleNegative:(double)aDouble inFile:(char *)path atLine:(int)line;

- (void)testDoubleZero:(double)aDouble inFile:(char *)path atLine:(int)line;

- (void)testDoubleNotZero:(double)aDouble inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual isEqualTo:(double)expected inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual isNotEqualTo:(double)expected inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual greaterThan:(double)expected inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual notGreaterThan:(double)expected inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual lessThan:(double)expected inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual notLessThan:(double)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark double test methods with error margins

/*! \name double test methods with error margins
    \startgroup */

- (void)testDoublePositive:(double)aDouble withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDoubleNegative:(double)aDouble withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDoubleZero:(double)aDouble withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDoubleNotZero:(double)aDouble withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual isEqualTo:(double)expected withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual isNotEqualTo:(double)expected withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual greaterThan:(double)expected withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual notGreaterThan:(double)expected withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual lessThan:(double)expected withinError:(double)error inFile:(char *)path atLine:(int)line;

- (void)testDouble:(double)actual notLessThan:(double)expected withinError:(float)error inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark Object test methods

/*! \name Object test methods
    \startgroup */

- (void)testObject:(id)actual isEqualTo:(id)expected inFile:(char *)path atLine:(int)line;

- (void)testObject:(id)actual isNotEqualTo:(id)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark NSString test methods

/*! \name NSString test methods
    \startgroup */

- (void)testString:(NSString *)actual isEqualTo:(NSString *)expected inFile:(char *)path atLine:(int)line;

- (void)testString:(NSString *)actual isNotEqualTo:(NSString *)expected inFile:(char *)path atLine:(int)line;

- (void)testString:(NSString *)actual hasPrefix:(NSString *)expected inFile:(char *)path atLine:(int)line;

- (void)testString:(NSString *)actual doesNotHavePrefix:(NSString *)expected inFile:(char *)path atLine:(int)line;

- (void)testString:(NSString *)actual hasSuffix:(NSString *)expected inFile:(char *)path atLine:(int)line;

- (void)testString:(NSString *)actual doesNotHaveSuffix:(NSString *)expected inFile:(char *)path atLine:(int)line;

- (void)testString:(NSString *)actual contains:(NSString *)expected inFile:(char *)path atLine:(int)line;

- (void)testString:(NSString *)actual doesNotContain:(NSString *)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark NSArray test methods

/*! \name NSArray test methods
    \startgroup */

- (void)testArray:(NSArray *)actual isEqualTo:(NSArray *)expected inFile:(char *)path atLine:(int)line;

- (void)testArray:(NSArray *)actual isNotEqualTo:(NSArray *)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark NSDictionary test methods

/*! \name NSDictionary test methods
    \startgroup */

- (void)testDictionary:(NSDictionary *)actual isEqualTo:(NSDictionary *)expected inFile:(char *)path atLine:(int)line;

- (void)testDictionary:(NSDictionary *)actual isNotEqualTo:(NSDictionary *)expected inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark Exception test methods

/*! \name Exception test methods
    \startgroup */

- (void)testThrowsException:(id)exception inFile:(char *)path atLine:(int)line;

- (void)testDoesNotThrowException:(id)exception inFile:(char *)path atLine:(int)line;

- (void)testThrowsException:(id)exception named:(NSString *)name inFile:(char *)path atLine:(int)line;

- (void)testDoesNotThrowException:(id)exception named:(NSString *)name inFile:(char *)path atLine:(int)line;

/*! \endgroup */

#pragma mark -
#pragma mark Random value generator methods

/*! \name Random value generator methods
    \startgroup */


- (int)anInt;
- (int)aPositiveInt;
- (int)aNegativeInt;
- (int)aZeroInt;
- (int)aBigInt;
- (int)aBigPositiveInt;
- (int)aBigNegativeInt;
- (int)aSmallInt;
- (int)aSmallPositiveInt;
- (int)aSmallNegativeInt;

- (unsigned)anUnsigned;
- (unsigned)aZeroUnsigned;
- (unsigned)aBigUnsigned;
- (unsigned)aSmallUnsigned;

- (float)aFloat;
- (float)aPositiveFloat;
- (float)aNegativeFloat;
- (float)aZeroFloat;
- (float)aBigFloat;
- (float)aBigPositiveFloat;
- (float)aBigNegativeFloat;
- (float)aSmallFloat;
- (float)aSmallPositiveFloat;
- (float)aSmallNegativeFloat;

- (double)aDouble;
- (double)aPositiveDouble;
- (double)aNegativeDouble;
- (double)aZeroDouble;
- (double)aBigDouble;
- (double)aBigPositiveDouble;
- (double)aBigNegativeDouble;
- (double)aSmallDouble;
- (double)aSmallPositiveDouble;
- (double)aSmallNegativeDouble;

/*! \endgroup */

#pragma mark -
#pragma mark Accessors

//! \name Accessors
//! \startgroup

- (NSDate *)startDate;
- (unsigned)classesWithTests;
- (unsigned)classesWithoutTests;
- (unsigned)methodsWithTests;
- (unsigned)testsRun;
- (unsigned)testsPassed;
- (unsigned)testsFailed;

// TODO: need sense inversion here as well (for uncaught exceptions) for self-testing purposes
- (unsigned)uncaughtExceptions;

- (unsigned)testsFailedExpected;
- (unsigned)testsPassedUnexpected;
- (BOOL)expectFailures;
- (void)setExpectFailures:(BOOL)aValue;

- (unsigned)lowLevelExceptionsExpected;
- (unsigned)lowLevelExceptionsUnexpected;
- (BOOL)expectLowLevelExceptions;
- (void)setExpectLowLevelExceptions:(BOOL)aValue;

- (BOOL)handlesLowLevelExceptions;
- (void)setHandlesLowLevelExceptions:(BOOL)aValue;

- (unsigned)verbosity;
- (void)setVerbosity:(unsigned)aVerbosity;

- (unsigned)trimInitialPathComponents;
- (void)setTrimInitialPathComponents:(unsigned)aTrimInitialPathComponents;

- (NSString *)lastReportedFile;
- (void)setLastReportedFile:(NSString *)aLastReportedFile;

- (BOOL)warnsAboutSignComparisons;
- (void)setWarnsAboutSignComparisons:(BOOL)aWarnsAboutSignComparisons;

//! \endgroup

@end