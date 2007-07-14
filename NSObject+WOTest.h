//
//  NSObject+WOTest.h
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
//  $Id: NSObject+WOTest.h 208 2007-07-07 19:02:28Z wincent $

#import <Foundation/Foundation.h>

/*! WOTest is designed to work with any Objective-C class or object. You are not limited to working only with classes that derive from the Apple root classes (NSObject and NSProxy) or the other root classes (such as Object and NSZombie) that are implemented in libobjc (libobjc is part of Darwin and open source but the headers do not ship with Mac OS X). In most Objective-C programming you can assume that the objects with which you are working descend from NSObject and implement the NSObject protocol. This means that you can avoid exceptions by testing objects to see whether they implement selectors before sending messages; NSObject methods such as conformsToProtocol:, respondsToSelector: and performSelector: are frequently used for this purpose. 

If you try sending these messages to objects which do not implement them then you could cause a non-catchable exception (generated in _objc_error and _objc_trap) which will terminate the testing process. One of the goals of WOTest is to be extremely robust; exceptions should be caught and reported and they should not crash the program. It is true that custom root classes are extremely uncommon but WOTest nevertheless has been designed to cope with them. WOTest interacts with the Objective-C runtime at a low level and implements a number of convenience wrapper routines that enable the framework to work with any Objective-C object without fear of provoking uncatchable exceptions. The wrapper methods are described in this section. In simple cases (for example when invoking the objc_msgSend function) the framework calls the function directly without a wrapper. */

@interface NSObject (WOTest) 

/*! Substitute for NSObject description method. Returns "(nil)" if \p anObject is nil. */
+ (NSString *)WOTest_descriptionForObject:(id)anObject;

/*! Returns YES if \p aClass is a class definition registered with the runtime. Returns NO otherwise. Does not raise an exception if passed a non-class pointer (in fact, the purpose of this method is to provide a way for checking for valid class pointers). */
+ (BOOL)WOTest_isRegisteredClass:(Class)aClass;

/*! Returns YES if aClass is the metaclass of a class that is registered with the runtime. */
+ (BOOL)WOTest_isMetaClass:(Class)aClass;

/*! Substitute for NSObject isKindOfClass: method. */
+ (BOOL)WOTest_object:(id)anObject isKindOfClass:(Class)aClass;

/*! Substitute for NSObject isKindOfClass: method. */
+ (BOOL)WOTest_instancesOfClass:(Class)aClass areKindOfClass:(Class)otherClass;

+ (BOOL)WOTest_class:(Class)aClass respondsToSelector:(SEL)aSelector;

/*! WOTest can work with objects that do not derive from any of the Apple root classes (NSObject, NSProxy) or implement the standard protocols (such as NSObject). This means that it is possible that the objects could be passed that do not even implement the respondsToSelector: method. If such objects are sent the selector then the program running the tests could crash. The WOTest_object:respondsToSelector: method avoids these crashes by providing a wrapper for the low level class_getInstanceMethod function. */
+ (BOOL)WOTest_object:(id)anObject respondsToSelector:(SEL)aSelector;

/*! Similar to WOTest_object:respondsToSelector:. */
+ (BOOL)WOTest_instancesOfClass:(Class)aClass respondToSelector:(SEL)aSelector;

/*! Similar to WOTest_instancesOfClass:respondToSelector:. */
+ (BOOL)WOTest_instancesOfClass:(Class)aClass conformToProtocol:(Protocol *)aProtocol;

+ (NSString *)WOTest_returnTypeForClass:(Class)aClass selector:(SEL)aSelector;

+ (NSString *)WOTest_returnTypeForObject:(id)anObject selector:(SEL)aSelector;

+ (BOOL)WOTest_isIdReturnType:(NSString *)returnType;

+ (BOOL)WOTest_isCharacterStringReturnType:(NSString *)returnType;

+ (BOOL)WOTest_isConstantCharacterStringReturnType:(NSString *)returnType;

/*! Raises if \p anObject is nil or \p aSelector is NULL. Returns no if \p aSelector is not implemented by \p anObject. */
+ (BOOL)WOTest_objectReturnsId:(id)anObject forSelector:(SEL)aSelector;

/*! Raises if \p anObject is nil or \p aSelector is NULL. Returns no if \p aSelector is not implemented by \p anObject. */
+ (BOOL)WOTest_objectReturnsCharacterString:(id)anObject forSelector:(SEL)aSelector;

/*! Raises if \p anObject is nil or \p aSelector is NULL. Returns no if \p aSelector is not implemented by \p anObject. */
+ (BOOL)WOTest_objectReturnsConstantCharacterString:(id)anObject forSelector:(SEL)aSelector;

@end
