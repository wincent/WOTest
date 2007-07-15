//
//  WOTestSelfTests.h
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

// link against Cocoa rather than Foundation so that we can use NSImage in tests
#import <Cocoa/Cocoa.h>
#import "WOTest/WOTest.h"

@interface WOTestSelfTests : NSObject <WOTest> {

}

/*! Throws an exception using the Objective-C @throw keyword. */
- (void)throwException;

/*! Raises an exception using the NSException raise:format: method. */
- (void)raiseException;

/*! Throws an exception with name "WOEnigmaException". */
- (void)throwWOEnigmaException;

/*! Throws an object that is not an NSException object. */
- (void)throwString;

/*! Throws a WORootClass object (one which does not inherit from NSObject and does not implement any of the standard protocols). */
- (void)throwWORootClassObject;

/*! Throws an object of class Object (as implemented in libobjc). This is another example of a root class that does not inherit from NSObject or conform to the NSObject protocol. */
- (void)throwObject;

- (void)doNotThrowException;

- (void)makeCocoaThrowException;

- (void)makeCocoaThrowNSRangeException;

@end
