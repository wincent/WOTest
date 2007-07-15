//
//  WOProtocolMockTests.m
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

#import "WOProtocolMockTests.h"

@implementation WOProtocolMockTests

- (void)testMockForProtocol
{
    // should throw for NULL protocol
    WO_TEST_THROWS([WOProtocolMock mockForProtocol:NULL]);

}

- (void)testInitWithProtocol
{
    // should throw for NULL protocol
    WOProtocolMock *mock = [WOProtocolMock alloc];
    WO_TEST_THROWS([mock initWithProtocol:NULL]);
    [mock release];
}

- (void)testMethodSignatureForSelector
{
    // should return nil when necessary to avoid recursion
    WOProtocolMock *mock = [WOProtocolMock mockForProtocol:@protocol(NSObject)];
    WO_TEST_NIL([mock methodSignatureForSelector:
        @selector(methodSignatureForSelector:)]);
}

- (void)testAccepts
{
    id mock = [WOProtocolMock mockForProtocol:@protocol(NSTextInput)];
    WO_TEST_DOES_NOT_THROW([[mock accept] hasMarkedText]);

    // order here matters: swap them if you want to see the breakage
    WO_TEST_DOES_NOT_THROW([mock hasMarkedText]);
    WO_TEST_THROWS(objc_msgSend([mock accept], @selector(foobar)));
}

@end
