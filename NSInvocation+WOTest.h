//
//  NSInvocation+WOTest.h
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
//  $Id: NSInvocation+WOTest.h 208 2007-07-07 19:02:28Z wincent $

#import <Foundation/Foundation.h>

@interface NSInvocation (WOTest)

//! Need a method for checking invocation equality (NSInvocation isEqual: method always returns NO).
- (BOOL)WOTest_isEqualToInvocation:(NSInvocation *)anInvocation;

//! A method for checking invocation equality which ignores arguments.
- (BOOL)WOTest_isEqualToInvocationIgnoringArguments:(NSInvocation *)anInvocation;

//! Convenience method for extracting arguments from invocations, returning them as NSValues.
//! \throws NSInternalInconsistencyException thrown if \p index is outside the range of arguments in the receiver.
- (NSValue *)WOTest_valueForArgumentAtIndex:(unsigned)index;

//! Convenience method for inserting arguments passed as NSValues into invocations
//! \throws NSInternalInconsistencyException thrown if \p index is outside the range of arguments in the receiver.
- (void)WOTest_setArgumentValue:(NSValue *)aValue atIndex:(unsigned)index;

@end
