//
//  NSScanner+WOTest.h
//  WOTest
//
//  Created by Wincent Colaiuta on 12 June 2005.
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
//  $Id: NSScanner+WOTest.h 208 2007-07-07 19:02:28Z wincent $

#import <Foundation/Foundation.h>

/*! 
 Example method signatures and types:
 
 The documentation notes the following: "The compiler generates the method type encodings in a format that includes information on the size of the stack and the size occupied by the arguments. These numbers appear after each encoding in the method_types string. However, because the compiler historically generates them incorrectly, and because they differ depending on the CPU type, the runtime ignores them if they are present. These numbers are not required by the Objective-C runtime in Mac OS X v10.0 or later."
 
 The first entry indicates the type of the return value.
 This is followed by the first argument which is always \@0 or \@8 (self).
 The second argument is always :4 or :12 (_cmd).
 Any subsequent arguments follow.
 
 + new  : \@8\@0:4
 
 + (const char *) name  : r*8\@0:4
 - (const char *) name : r*8\@0:4
 - (void *)zone :  ^v8\@0:4
 - (BOOL) conformsTo: (Protocol *)aProtocolObject : c12\@0:4\@8
 
 + (id)allocWithZone:(NSZone *)zone : \@12\@0:4^{_NSZone=}8
 
 + (Class)class : #8\@0:4
 
 + (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget 
 selector:(SEL)aSelector object:(id)anArgument
 v20\@0:4\@8:12\@16
 
 + (NSRect)contentRectForFrameRect:(NSRect)frameRect styleMask:(unsigned int)aStyle
 {_NSRect={_NSPoint=ff}{_NSSize=ff}}28\@0:4{_NSRect={_NSPoint=ff}{_NSSize=ff}}8I24    
 
 + (id)stringWithString:(NSString *)aString : \@12\@0:4\@8
 
 + (NSString *)localizedNameOfStringEncoding:(NSStringEncoding)encoding
 \@12\@0:4\@8
 
 See objc/objc-class.h for macros 
 
 
Additional codes used by runtime as described here: file:///Developer/ADC%20Reference%20Library/documentation/Cocoa/Conceptual/ObjectiveC/RuntimeOverview/chapter_4_section_6.html */

#define WO_ENCODING_QUALIFIER_CONST     'r'
#define WO_ENCODING_QUALIFIER_IN        'n'
#define WO_ENCODING_QUALIFIER_INOUT     'N'
#define WO_ENCODING_QUALIFIER_OUT       'o'
#define WO_ENCODING_QUALIFIER_BYCOPY    'O'
#define WO_ENCODING_QUALIFIER_BYREF     'R'
#define WO_ENCODING_QUALIFIER_ONEWAY    'V'

@interface NSScanner (WOTest) 

/*! Raises an NSInternalInconsistencyException if value is NULL. */
- (BOOL)WOTest_peekCharacter:(unichar *)value;

/*! Pass NULL if you merely wish to scan past a character. */
- (BOOL)WOTest_scanCharacter:(unichar *)value;

/*! Pass NULL if you merely wish to scan past a character from the set. */
- (BOOL)WOTest_scanCharacterFromSet:(NSCharacterSet *)scanSet intoChar:(unichar *)value;

/*! Scans a return type into a string. Return types must appear at the beginning of the string. Pass nil if you simply wish to scan past a return type. */
- (BOOL)WOTest_scanReturnTypeIntoString:(NSString **)stringValue;

/*! Scans a type (simple or compound). Pass nil if you simply wish to scan past a type. */
- (BOOL)WOTest_scanTypeIntoString:(NSString **)stringValue;

/*! Scans one or more qualifieres into a string. Pass nil if you simply wish to scan past the qualifiers. */
- (BOOL)WOTest_scanQualifiersIntoString:(NSString **)stringValue;

/*! Scans a simple (non-compound) type into a string. Pass nil if you simply wish to scan past a type. */
- (BOOL)WOTest_scanNonCompoundTypeIntoString:(NSString **)stringValue;

/*! Scans a bitfield into a string. Pass nil if you simply wish to scan past a bitfield. */
- (BOOL)WOTest_scanBitfieldIntoString:(NSString **)stringValue;

/*! Scans an array into a string. Pass nil if you simply wish to scan past an array. */
- (BOOL)WOTest_scanArrayIntoString:(NSString **)stringValue;

/*! Scans an identifier into a string. Pass nil if you simply wish to scan past an identifier. */
- (BOOL)WOTest_scanIdentifierIntoString:(NSString **)stringValue;

/*! Scans a struct into a string. Pass nil if you simply wish to scan past a struct. */
- (BOOL)WOTest_scanStructIntoString:(NSString **)stringValue;

/*! Scans a union into a string. Pass nil if you simply wish to scan past a union. */
- (BOOL)WOTest_scanUnionIntoString:(NSString **)stringValue;

/*! Scans a pointer into a string. Pass nil if you simply wish to scan past a pointer. */
- (BOOL)scanPointerIntoString:(NSString **)stringValue;

@end
