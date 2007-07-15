//
//  NSString+WOTest.h
//  WOTest
//
//  Created by Wincent Colaiuta on 07 June 2005.
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

/*! This function is an alternative to NSLog that accepts the same kinds of format specifiers (including the "%@" format specifier to print object descriptions) but which omits the prelimary information that is prepended by NSLog (date, time, process name, process number). Named with a preceding underscore to avoid namespace clash with the WOLog global variable defined in the WOLogManager class of the WODebug framework. */
void _WOLog(NSString *format, ...);

/*! This function is an alternative to NSLogv that accepts the same kinds of format specifiers (including the "%@" format specifier to print object descriptions) but which omits the prelimary information that is prepended by NSLogv (date, time, process name, process number). Named with a preceding underscore for consistency with the _WOLog function. */
void _WOLogv(NSString *format, va_list args);

@interface NSString (WOTest) 

+ (NSString *)WOTest_stringWithFormat:(NSString *)format arguments:(va_list)argList;

/*! Convenience method that returns an NSString based on a single character of type unichar. */
+ (NSString *)WOTest_stringWithCharacter:(unichar)character;

- (NSString *)WOTest_stringByConvertingToAbsolutePath;

/*! Returns an immutable, autoreleased string created by "collapsing" all of the whitespace in the receiver into single spaces. All newlines are converted into spaces and consecutive spaces are "collapsed" into a single space. */
- (NSString *)WOTest_stringByCollapsingWhitespace;


/*! Returns an immutable, autoreleased string created by appending a single character of type unichar to the receiver. */
- (NSString *)WOTest_stringByAppendingCharacter:(unichar)character;

@end
