//
//  WOClassMockTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 10 February 2006.
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

#import "WOClassMockTests.h"

@implementation WOClassMockTests

- (void)testInitWithClass
{
    // preliminaries
    WOClassMock *mock = nil;

    // should throw if passed NULL
    mock = [WOClassMock alloc];
    WO_TEST_THROWS([mock initWithClass:NULL]);

    // should throw if passed non-class pointer
    mock = [WOClassMock alloc];
    WO_TEST_THROWS([mock initWithClass:(Class)self]);

    // otherwise should work
    WO_TEST_DOES_NOT_THROW([[WOClassMock alloc] initWithClass:[self class]]);

    // should throw if passed a meta class
    Class class     = [NSString class];
    Class metaclass = object_getClass(class);
    mock = [WOClassMock alloc];
    WO_TEST_THROWS([mock initWithClass:metaclass]);
}

- (void)testAccept
{
    // should work with class methods
    id mock = [WOClassMock mockForClass:[NSString class]];
    WO_TEST_DOES_NOT_THROW([[mock accept] stringWithString:@"foo"]);
    WO_TEST_DOES_NOT_THROW([mock stringWithString:@"foo"]);

    // should throw for instance methods
    WO_TEST_THROWS([[mock accept] lowercaseString]);

    // should throw for unknown methods
    WO_TEST_THROWS(objc_msgSend([mock accept], @selector(foobar)));
}

@end
