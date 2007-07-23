//
//  NSValue+WOTest.h
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

#import <Foundation/Foundation.h>

#import <objc/objc-class.h>

#ifndef _C_LNGLNG

/*! Type macros missing from objc-class.h at the time of writing; definition taken from docs file:///Developer/ADC%20Reference%20Library/documentation/Cocoa/Conceptual/ObjectiveC/index.html */
#define _C_LNGLNG 'q'

#endif

#ifndef _C_ULNGLNG

/*! Type macros missing from objc-class.h at the time of writing; definition taken from docs file:///Developer/ADC%20Reference%20Library/documentation/Cocoa/Conceptual/ObjectiveC/index.html */
#define _C_ULNGLNG 'Q'

#endif

#ifndef _C_99BOOL

/*! Type macros missing from objc-class.h at the time of writing; definition taken from docs file:///Developer/ADC%20Reference%20Library/documentation/Cocoa/Conceptual/ObjectiveC/index.html */
#define _C_99BOOL 'B'

#endif

/*! Macro that compares two scalar values, \p a and \p b, using standard relational operators and returns NSOrderedSame, NSOrderedAscending or NSOrderedDescending. */
#define WO_COMPARE_SCALARS(a, b) \
((a) == (b) ? NSOrderedSame : ((a) < (b) ? NSOrderedAscending : NSOrderedDescending))

/*! This category adds unit testing methods to the NSValue class. It provides methods for comparing NSValue objects for equality/non-equality and ordering.

The base NSValue class adopts a stricter view of equality that makes it hard to compare numeric scalar values (char, int, short, long, long long, unsigned char, unsigned int, unsigned short, unsigned long, unsigned long long, float, double and C99 _Bool) because those values must be of the same type or class. For example, an NSValue that contains an int (10) and another that contains a long (10) would be considered unequal according the default implementation of the isEqualTo: method because they are not of the same type. Likewise an NSValue containing an NSMutableString (@"string") and another containing an NSString (@"string") would also be considered unequal because they are of different classes.

This category adds a number of high-level methods for use in unit testing that implement a more flexible comparison method. Any numeric scalar value can be compared to any other scalar value and the values will be appropriately cast before comparison. In cases where GCC would issue a warning (for example, when comparing a signed and an unsigned type) a warning will be printed to the console (and will appear in the Xcode build results).

Any object can be compared to any other object for equality provided that it implements the isEqualTo: method. If it does not implement the method then the WOTest_testIsEqualToValue: method will return NO. If both ids are nil then the method returns YES.

Objects can be compared to one another for ordering provided that they are of the same class (or at least have a super-subclass relationship) and at least one of the objects implement the compare: method. If neither of these conditions are true then an NSInvalidArgument exception will be raised.

Class objects, method selectors (SEL), void types, character strings (char *), arrays, structs, unions and pointers have no special behaviour implemented in this category. If you try to compare them the standard isEqualTo: NSValue method will be used and testing the ordering will raise an NSInvalidArgument exception. */
@interface NSValue (WOTest)

#pragma mark -
#pragma mark Value creation methods

+ (NSValue *)WOTest_valueWithChar:(char)aChar;

+ (NSValue *)WOTest_valueWithInt:(int)anInt;

+ (NSValue *)WOTest_valueWithShort:(short)aShort;

+ (NSValue *)WOTest_valueWithLong:(long)aLong;

+ (NSValue *)WOTest_valueWithLongLong:(long long)aLongLong;

+ (NSValue *)WOTest_valueWithUnsignedChar:(unsigned char)anUnsignedChar;

+ (NSValue *)WOTest_valueWithUnsignedInt:(unsigned int)anUnsignedInt;

+ (NSValue *)WOTest_valueWithUnsignedShort:(unsigned short)anUnsignedShort;

+ (NSValue *)WOTest_valueWithUnsignedLong:(unsigned long)anUnsignedLong;

+ (NSValue *)WOTest_valueWithUnsignedLongLong:(unsigned long long)anUnsignedLongLong;

+ (NSValue *)WOTest_valueWithFloat:(float)aFloat;

+ (NSValue *)WOTest_valueWithDouble:(double)aDouble;

+ (NSValue *)WOTest_valueWithC99Bool:(_Bool)aC99Bool;

+ (NSValue *)WOTest_valueWithConstantCharacterString:(const char *)aConstantCharString;

+ (NSValue *)WOTest_valueWithCharacterString:(char *)aCharacterString;

/*! Unlike Cocoa's valueWithNonretainedObject method, which is equivalent to calling:

    \code
    NSValue *theValue = [NSValue value:&anObject withObjCType:@encode(void  *)];
    \endcode

                                               This method is equivalent to invoking:

    \code
    NSValue *theValue = [NSValue value:&anObject withObjCType:@encode(id)];
    \endcode

    The object is not retained.

    */
+ (NSValue *)WOTest_valueWithObject:(id)anObject;

+ (NSValue *)WOTest_valueWithClass:(Class)aClass;

+ (NSValue *)WOTest_valueWithSelector:(SEL)aSelector;

#pragma mark -
#pragma mark Parsing type strings

/*!
\name Parsing type strings
\startgroup
*/

/*! Used to determine the maximum number of bytes needed to store the type represented by \p typeString when it is embedded inside a composite type (a struct, array or union). It is possible that compiler pragmas or flags may lead to data being aligned differently and packed in a more compact form, but this method is guaranteed to return the maximum amount of space that would be required to store the type under the least-compact alignment conditions. The alignments and embedding rules are taken from "The alignments taken from Apple's "Mac OS X ABI Function Call Guide". Throws an exception if \p typeString is nil. */
+ (size_t)WOTest_maximumEmbeddedSizeForType:(NSString *)typeString;

/*! This method returns the minimum buffer size required to safely store an object of the type represented by \p typeString. Because it is impossible to know if any compiler pragmas or flags were used to change the default alignment behaviour of composite  types (structs, arrays, unions), this method bases its calculations on the space that would be required if the least-packed alignment were chosen. As such the values returned by this function may be greater than or equal to those returned by the sizeof compiler directive, but never less than. Throws an exception if \p typeString is nil. */
+ (size_t)WOTest_sizeForType:(NSString *)typeString;

/*! Returns YES if \p typeString contains a numeric scalar value (char, int, short, long, long long, unsigned char, unsigned int, unsigned short, unsigned long, unsigned long long, float, double, C99 _Bool). Returns NO if the receiver contains any other type, object or pointer (id, Class, SEL, void, char *, as well as arrays, structures and pointers). */
+ (BOOL)WOTest_typeIsNumericScalar:(NSString *)typeString;

/*! Returns YES if \p typeString represents a compound type (struct, union or array). */
+ (BOOL)WOTest_typeIsCompound:(NSString *)typeString;

+ (BOOL)WOTest_typeIsChar:(NSString *)typeString;

+ (BOOL)WOTest_typeIsInt:(NSString *)typeString;

+ (BOOL)WOTest_typeIsShort:(NSString *)typeString;

+ (BOOL)WOTest_typeIsLong:(NSString *)typeString;

+ (BOOL)WOTest_typeIsLongLong:(NSString *)typeString;

+ (BOOL)WOTest_typeIsUnsignedChar:(NSString *)typeString;

+ (BOOL)WOTest_typeIsUnsignedInt:(NSString *)typeString;

+ (BOOL)WOTest_typeIsUnsignedShort:(NSString *)typeString;

+ (BOOL)WOTest_typeIsUnsignedLong:(NSString *)typeString;

+ (BOOL)WOTest_typeIsUnsignedLongLong:(NSString *)typeString;

+ (BOOL)WOTest_typeIsFloat:(NSString *)typeString;

+ (BOOL)WOTest_typeIsDouble:(NSString *)typeString;

+ (BOOL)WOTest_typeIsC99Bool:(NSString *)typeString;

+ (BOOL)WOTest_typeIsVoid:(NSString *)typeString;

+ (BOOL)WOTest_typeIsConstantCharacterString:(NSString *)typeString;

+ (BOOL)WOTest_typeIsCharacterString:(NSString *)typeString;

+ (BOOL)WOTest_typeIsObject:(NSString *)typeString;

+ (BOOL)WOTest_typeIsClass:(NSString *)typeString;

+ (BOOL)WOTest_typeIsSelector:(NSString *)typeString;

+ (BOOL)WOTest_typeIsPointerToVoid:(NSString *)typeString;

+ (BOOL)WOTest_typeIsPointer:(NSString *)typeString;

+ (BOOL)WOTest_typeIsArray:(NSString *)typeString;

+ (BOOL)WOTest_typeIsStruct:(NSString *)typeString;

+ (BOOL)WOTest_typeIsUnion:(NSString *)typeString;

+ (BOOL)WOTest_typeIsBitfield:(NSString *)typeString;

+ (BOOL)WOTest_typeIsUnknown:(NSString *)typeString;

/*! \endgroup */

#pragma mark -
#pragma mark High-level test methods

/*!
\name High-level test methods
\startgroup
*/

/*! Compares the receiver with \p aValue for equality and returns YES if equal, NO otherwise. When both the receiver and \p aValue are objects tries to send an isEqualTo: message to the receiver; if the receiver does not implement that selector then the default NSValue isEqualToValue: method is invoked. When both the receiver and \p aValue represent numeric scalars casting is performed as already described. There is one special case where an object to numeric scalar comparison is permitted and that is when the numeric value is both the same size and value as a nil pointer (in other words an int with value 0), such as the relatively common case in which the caller might try to compare an object to nil (in this case the C preprocessor will have substituted "0" for "nil" which means that the NSValue object will record it as an representing an integer rather than an id). This special case is necessary so that test macros such as the following work as expected:

\code
WO_TEST_EQUAL(nil, theObject);          // looks like comparing an id with an id
WO_TEST_NOT_EQUAL(otherObject, nil);    // looks like comparing an id with an id

// which are equivalent to:
WO_TEST_EQUAL(0, theObject);            // actually comparing an int with an id
WO_TEST_NOT_EQUAL(otherObject, 0);      // actually comparing an id with an int
\endcode

Note that the following example would work even without this special handling because in this case there is enough information present at compile time to prevent the nil value from being interpreted as an int:

\code
NSString *aString = nil;
WO_TEST_EQUAL(aString, otherString);    // comparing an id with and id
\endcode

Special case handling notwithstanding, attempting to compare a non-zero int with an object will raise an exception:

\code
WO_TEST_EQUAL(25, aString);             // raises
\endcode

In all other cases the default NSValue isEqualToValue: method is used as a fallback.

<table>
<tr>
<td>Compare value:</td>
<td>With value:</td>
<td>Result:</td>
</tr>
<tr>
<td>numeric scalar</td>
<td>numeric scalar</td>
<td>automated casting takes place prior to comparison, warning printed to console at runtime if risky casts are required (for example signed and unsigned) </td>
</tr>
<tr>
<td>id</td>
<td>id</td>
<td>compared using isEqual: if right-handle value implements that method, otherwise default NSValue isEqualToValue: behaviour used </td>
</tr>
<tr>
<td>id</td>
<td>numeric scalar</td>
<td>comparison allowed if and only if the numeric scalar value is equivalent to "nil", otherwise throws exception </td>
</tr>
<tr>
<td>numeric scalar</td>
<td>id</td>
<td>comparison allowed if and only if the numeric scalar value is equivalent to "nil", otherwise throws exception </td>
</tr>
<tr>
<td>void * </td>
<td>numeric scalar </td>
<td>comparison allowed if and only if the numeric scalar value is equivalent to "nil", otherwise throws exception </td>
</tr>
<tr>
<td>numeric scalar </td>
<td>void * </td>
<td>comparison allowed if any only if the numeric scalar value is equivalent to "nil", otherwise throws exception </td>
</tr>
<tr>
<td>char*</td>
<td>char[]</td>
<td>if possible creates NSString representations of the two values and compares them; if comparison not possible falls back to default NSValue isEqualToValue: behaviour</td>
</tr>
<tr>
<td>char[]</td>
<td>char * </td>
<td>if possible creates NSString representations of the two values and compares them; if comparison not possible falls back to default NSValue isEqualToValue: behaviour</td>
</tr>
<tr>
<td>const char* </td>
<td>char[]</td>
<td>if possible creates NSString representations of the two values and compares them; if comparison not possible falls back to default NSValue isEqualToValue: behaviour</td>
</tr>
<tr>
<td>char[]</td>
<td>const char* </td>
<td>if possible creates NSString representations of the two values and compares them; if comparison not possible falls back to default NSValue isEqualToValue: behaviour</td>
</tr>
</table>

*/
- (BOOL)WOTest_testIsEqualToValue:(NSValue *)aValue;

// TODO: write tests that make use of these methods? so far only use the isEqual variant
- (BOOL)WOTest_testIsGreaterThanValue:(NSValue *)aValue;

- (BOOL)WOTest_testIsLessThanValue:(NSValue *)aValue;

- (BOOL)WOTest_testIsNotGreaterThanValue:(NSValue *)aValue;

- (BOOL)WOTest_testIsNotLessThanValue:(NSValue *)aValue;

/*! The table below indicates the warnings that GCC issues when trying to compare numeric scalars of different types. "-" indicates that no warning is issued and the compiler performs an implicit cast. "W" indicates that the compiler issues a warning about signed/unsigned comparison; in this case WOTest performs an explicit cast and prints a warning to the console (visible in the Xcode build results window) at runtime.

<table>
  <tr>
    <td>type</td>
    <td>char</td>
    <td>int</td>
    <td>short</td>
    <td>long</td>
    <td>long long </td>
    <td>unsigned char </td>
    <td>unsigned int</td>
    <td>unsigned short </td>
    <td>unsigned long </td>
    <td>unsigned long long </td>
    <td>float</td>
    <td>double</td>
    <td>C99 _Bool </td>
  </tr>
  <tr>
    <td>char</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>W</td>
    <td>-</td>
    <td>W</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>int</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>W</td>
    <td>-</td>
    <td>W</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>short</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>W</td>
    <td>-</td>
    <td>W</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>long</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>W</td>
    <td>-</td>
    <td>W</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>long long </td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>unsigned char </td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>unsigned int </td>
    <td>W</td>
    <td>W</td>
    <td>W</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>unsigned short </td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>unsigned long </td>
    <td>W</td>
    <td>W</td>
    <td>W</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>unsigned long long </td>
    <td>W</td>
    <td>W</td>
    <td>W</td>
    <td>W</td>
    <td>W</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>float</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>double</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
  <tr>
    <td>C99 _Bool</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
    <td>-</td>
  </tr>
</table>

Table corresponds to the warnings produced by the version of GCC 4.0 that ships with Apple's Xcode 2.1, "powerpc-apple-darwin8-gcc-4.0.0 (GCC) 4.0.0 (Apple Computer, Inc. build 5026)". */
- (NSComparisonResult)WOTest_compare:(NSValue *)aValue;

/*! \endgroup */

#pragma mark -
#pragma mark Utility methods

//! \name Utility methods
//! \startgroup

//! Returns the buffer size necessary to hold the contents of the receiver. For use in conjunction with the getValue method.
- (size_t)WOTest_bufferSize;

//! Prints a warning to the console about a signed-to-unsigned comparison together with information about the last known location (file and line).
- (void)WOTest_printSignCompareWarning:(NSString *)warning;

//! \endgroup

#pragma mark -
#pragma mark Convenience methods

/*!
\name Convenience methods
\startgroup
*/

/*! Returns the Objective-C type of the receiver as an NSString. */
- (NSString *)WOTest_objCTypeString;

/*! Returns a human-readable description of the receiver. */
- (NSString *)WOTest_description;

/*! \endgroup */

#pragma mark -
#pragma mark Identifying generic types

/*!
\name Identifying generic types
\startgroup
*/

/*! Returns YES if the receiver contains a numeric scalar value (char, int, short, long, long long, unsigned char, unsigned int, unsigned short, unsigned long, unsigned long long, float, double, C99 _Bool). Returns NO if the receiver contains any other type, object or pointer (id, Class, SEL, void, char *, as well as arrays, structures and pointers). */
- (BOOL)WOTest_isNumericScalar;

- (BOOL)WOTest_isPointer;

- (BOOL)WOTest_isArray;

/*! Returns the count of items in the array stored by the receiver. Raises an exception if the receiver does not store an array. */
- (unsigned)WOTest_arrayCount;

/*! Returns the type string of the elements in the array stored by the receiver. Raises an exception if the receiver does not store an array. */
- (NSString *)WOTest_arrayType;

- (BOOL)WOTest_isStruct;

- (BOOL)WOTest_isUnion;

- (BOOL)WOTest_isBitfield;

/*! True if the receiver contains a value of type "unknown" (indicated by "?"). Function pointers, for example, are encoded with this type by the \@encode() compiler directive. */
- (BOOL)WOTest_isUnknown;

/*! \endgroup */

#pragma mark -
#pragma mark Identifying and retrieving specific types

/*!
\name Identifying and retrieving specific types
\startgroup
*/

/*! Returns YES if the receiver contains a char. */
- (BOOL)WOTest_isChar;

/*! Returns YES if the receiver contains an int. */
- (BOOL)WOTest_isInt;

/*! Returns YES if the receiver contains a short. */
- (BOOL)WOTest_isShort;

/*! Returns YES if the receiver contains a long. */
- (BOOL)WOTest_isLong;

/*! Returns YES if the receiver contains a long long. */
- (BOOL)WOTest_isLongLong;

/*! Returns YES if the receiver contains an unsigned char. */
- (BOOL)WOTest_isUnsignedChar;

/*! Returns YES if the receiver contains an unsigned int. */
- (BOOL)WOTest_isUnsignedInt;

/*! Returns YES if the receiver contains an unsigned short. */
- (BOOL)WOTest_isUnsignedShort;

/*! Returns YES if the receiver contains an unsigned long. */
- (BOOL)WOTest_isUnsignedLong;

/*! Returns YES if the receiver contains an unsigned long long. */
- (BOOL)WOTest_isUnsignedLongLong;

/*! Returns YES if the receiver contains a float. */
- (BOOL)WOTest_isFloat;

/*! Returns YES if the receiver contains a double. */
- (BOOL)WOTest_isDouble;

/*! Returns YES if the receiver contains a C99 _Bool. */
- (BOOL)WOTest_isC99Bool;

/*! Returns YES if the receiver contains a void. */
- (BOOL)WOTest_isVoid;

/*! Returns YES if the receiver contains a constant character string (const char *). */
- (BOOL)WOTest_isConstantCharacterString;

/*! Returns YES if the receiver contains a character string (char *). */
- (BOOL)WOTest_isCharacterString;

/*! Returns YES if the receiver contains an (id or statically typed) object. */
- (BOOL)WOTest_isObject;

/*! Returns YES if the receiver contains a Class object. */
- (BOOL)WOTest_isClass;

/*! Returns YES if the receiver contains a method selector (SEL). */
- (BOOL)WOTest_isSelector;

/*! Returns YES if the receiver contains a pointer to void. */
- (BOOL)WOTest_isPointerToVoid;

/*! If the receiver was created to hold a char-sized data item, returns that item as a char. Otherwise, the result is undefined. */
- (char)WOTest_charValue;

/*! If the receiver was created to hold an int-sized data item, returns that item as an int. Otherwise, the result is undefined. */
- (int)WOTest_intValue;

/*! If the receiver was created to hold a short-sized data item, returns that item as a short. Otherwise, the result is undefined. */
- (short)WOTest_shortValue;

/*! If the receiver was created to hold a long-sized data item, returns that item as a long. Otherwise, the result is undefined. */
- (long)WOTest_longValue;

/*! If the receiver was created to hold a long long-sized data item, returns that item as a long long. Otherwise, the result is undefined. */
- (long long)WOTest_longLongValue;

/*! If the receiver was created to hold an unsigned char-sized data item, returns that item as an unsigned char. Otherwise, the result is undefined. */
- (unsigned char)WOTest_unsignedCharValue;

/*! If the receiver was created to hold an unsigned int-sized data item, returns that item as an unsigned int. Otherwise, the result is undefined. */
- (unsigned int)WOTest_unsignedIntValue;

/*! If the receiver was created to hold an unsigned short-sized data item, returns that item as an unsigned short. Otherwise, the result is undefined. */
- (unsigned short)WOTest_unsignedShortValue;

/*! If the receiver was created to hold an unsigned long-sized data item, returns that item as an unsigned long. Otherwise, the result is undefined. */
- (unsigned long)WOTest_unsignedLongValue;

/*! If the receiver was created to hold an unsigned long long-sized data item, returns that item as an unsigned long long. Otherwise, the result is undefined. */
- (unsigned long long)WOTest_unsignedLongLongValue;

/*! If the receiver was created to hold a float-sized data item, returns that item as a float. Otherwise, the result is undefined. */
- (float)WOTest_floatValue;

/*! If the receiver was created to hold a double-sized data item, returns that item as a double. Otherwise, the result is undefined. */
- (double)WOTest_doubleValue;

/*! If the receiver was created to hold a C99 _Bool-sized data item, returns that item as a C99 _Bool. Otherwise, the result is undefined. */
- (_Bool)WOTest_C99BoolValue;

/*! If the receiver was created to hold a constant character string-sized data item, returns that item as a constant character string. Otherwise, the result is undefined. */
- (const char *)WOTest_constantCharacterStringValue;

/*! If the receiver was created to hold a character string-sized data item, returns that item as a character string. Otherwise, the result is undefined. */
- (char *)WOTest_characterStringValue;

/*! If the receiver was created to hold an id-sized data item, returns that item as an id. Otherwise, the result is undefined. */
- (id)WOTest_objectValue;

/*! If the receiver was created to hold a Class-sized data item, returns that item as a Class. Otherwise, the result is undefined. */
- (Class)WOTest_classValue;

/*! If the receiver was created to hold a SEL-sized data item, returns that item as a SEL. Otherwise, the result is undefined. */
- (SEL)WOTest_selectorValue;

- (void *)WOTest_pointerToVoidValue;

/*! Returns YES if the receiver is an array of characters (of type char). This method looks for encoding strings of the form "[1c]", "[2c]", "[3c]" and so forth. There are no guarantees that such arrays are null-terminated. Such encodings are produced when passing constant strings to the WOTest macros as illustrated below:

\code
WO_TEST_NOT_EQUAL("foo", "bar");
\endcode

When encoded as NSValues the two constant strings in the example above would be encoded as having type "[4c]" (3 chars plus a terminating byte). */
- (BOOL)WOTest_isCharArray;

/*! If WOTest_isCharacterString returns YES then this method attempts to return an NSString representation of the content of the receiver; returns nil if no representation could be produced. If WOTest_isCharArray returns YES then attempts to do the same, returning nil if not possible. */
- (NSString *)WOTest_stringValue;

/*! \endgroup */

#pragma mark -
#pragma mark Low-level test methods

/*!
\name Low-level test methods
\startgroup
*/

- (NSComparisonResult)WOTest_compareWithChar:(char)other;

- (NSComparisonResult)WOTest_compareWithInt:(int)other;

- (NSComparisonResult)WOTest_compareWithShort:(short)other;

- (NSComparisonResult)WOTest_compareWithLong:(long)other;

- (NSComparisonResult)WOTest_compareWithLongLong:(long long)other;

- (NSComparisonResult)WOTest_compareWithUnsignedChar:(unsigned char)other;

- (NSComparisonResult)WOTest_compareWithUnsignedInt:(unsigned int)other;

- (NSComparisonResult)WOTest_compareWithUnsignedShort:(unsigned short)other;

- (NSComparisonResult)WOTest_compareWithUnsignedLong:(unsigned long)other;

- (NSComparisonResult)WOTest_compareWithUnsignedLongLong:(unsigned long long)other;

- (NSComparisonResult)WOTest_compareWithFloat:(float)other;

- (NSComparisonResult)WOTest_compareWithDouble:(double)other;

- (NSComparisonResult)WOTest_compareWithC99Bool:(_Bool)other;

/*! \endgroup */

@end
