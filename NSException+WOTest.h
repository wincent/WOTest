//
//  NSException+WOTest.h
//  WOTest
//
//  Created by Wincent Colaiuta on 19 October 2004.
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

#pragma mark -
#pragma mark User info dictionary keys

#define WO_TEST_USERINFO_LINE   @"WOTestLine"
#define WO_TEST_USERINFO_PATH   @"WOTestPath"

@interface NSException (WOTest) 

/*! Cocoa allows any Objective-C object to be thrown in an exception. Although NSException objects are most commonly used for this purpose there is no limitation that prevents other objects from being used. These objects may or may not respond to the name, reason and userInfo methods that are implemented by NSException. This method accepts any object and attempts to produce a textual description, using the name and reason methods if implemented and otherwise resorting to the description method if implented and finally a basic description based on the name of the class if not. */
+ (NSString *)WOTest_descriptionForException:(id)exception;

    /*! Returns the name of the passed exception, trying first to send a "name" selector, but falling back on the "description" selector and finally the class name itself. Returns the string "no exception" if passed nil. */
+ (NSString *)WOTest_nameForException:(id)exception;

/*! Convenience method that invokes exceptionWithName:reason:userInfo:, packing the supplied path and line information into a userInfo dictionary. */
+ (NSException *)WOTest_exceptionWithName:(NSString *)name reason:(NSString *)reason inFile:(char *)path atLine:(int)line;

/*! Convenience method that invokes exceptionWithName:reason:inFile:atLine: to create and raise an exception, packing the supplied path and line information into a userInfo dictionary. */
+ (void)WOTest_raise:(NSString *)name reason:(NSString *)reason inFile:(char *)path atLine:(int)line;

@end
