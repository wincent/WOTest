//
//  WOTest.h
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

//! \file WOTest.h

#pragma mark -
#pragma mark Marker protocol


/*! You can indicate that a class contains unit tests by marking it with the WOTest marker protocol. Although there are no selectors explicitly defined in the protocol you should at the very least ensure that your class responds to the alloc and init selectors (this is because before running each test method the framework instantiates a new copy of your test class by sending the alloc and init messages. In practice this means that any subclass of NSObject is suitable for writing test classes. You can also use classes which do not derive from the NSObject root class but you should be aware that if they do not implement alloc and init then WOTest will issue warnings at runtime. */
@protocol WOTest

@end

#pragma mark -
#pragma mark Macros

#import "WOTestMacros.h"

#pragma mark -
#pragma mark Classes

#import "WOClassMock.h"
#import "WOObjectMock.h"
#import "WOObjectStub.h"
#import "WOProtocolMock.h"
#import "WOProtocolStub.h"
#import "WOTestApplicationTestsController.h"
#import "WOTestBundleInjector.h"
#import "WOTestClass.h"
#import "WOTestLowLevelException.h"

#pragma mark -
#pragma mark Categories

#import "NSException+WOTest.h"
#import "NSInvocation+WOTest.h"
#import "NSMethodSignature+WOTest.h"
#import "NSObject+WOTest.h"
#import "NSProxy+WOTest.h"
#import "NSScanner+WOTest.h"
#import "NSString+WOTest.h"
#import "NSValue+WOTest.h"
