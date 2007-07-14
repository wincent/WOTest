//
//  WOMockTests.m
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
//  $Id: WOMockTests.m 208 2007-07-07 19:02:28Z wincent $

#import "WOMockTests.h"

@implementation WOMockTests

// no real tests in this method: examples of how to use mocks without warnings
- (void)testExample
{
    // using mocks in the following way will cause a compiler warning:
    //WOObjectMock *mock = [WOMock mockForObjectClass:[NSString class]];
    //[[mock expect] lowercaseString];
    //[mock lowercaseString]; // "warning: 'WOObjectMock' may not respond to '-lowercaseString'"
    //[mock verify];        
    
    // one way of avoiding compiler warnings when using mocks: cast to id
    WOObjectMock *mock1 = [WOMock mockForObjectClass:[NSString class]];
    [[mock1 expect] lowercaseString];
    [(id)mock1 lowercaseString];
    [mock1 verify];
    
    // another way of avoiding compiler warnings: use id type from beginning
    id mock2 = [WOMock mockForObjectClass:[NSString class]];
    [[mock2 expect] lowercaseString];
    [mock2 lowercaseString];
    [mock2 verify];
    
    // another way: cast to mocked class
    NSString *mock3 = [WOMock mockForObjectClass:[NSString class]];
    [[(WOMock *)mock3 expect] lowercaseString];
    [mock3 lowercaseString];
    [(WOMock *)mock3 verify];
    
    // another way: alternative way of casting to mocked class
    WOObjectMock *mock4 = [WOMock mockForObjectClass:[NSString class]];
    [[mock4 expect] lowercaseString];
    [(NSString *)mock4 lowercaseString];
    [mock4 verify];
    
    // yet another way: use objc_msgSend
    WOObjectMock *mock5 = [WOMock mockForObjectClass:[NSString class]];
    [[mock5 expect] lowercaseString];
    objc_msgSend(mock5, @selector(lowercaseString));
    [mock5 verify];
}

- (void)testMockForObjectClass
{
    WOObjectMock *mock = [WOMock mockForObjectClass:[self class]];
    
    // make sure WOObjectMock class is returned
    WO_TEST_EQ([mock class], [WOObjectMock class]);
    
    // make sure mocked class is correctly set
    WO_TEST_EQ([mock mockedClass], [self class]);
    
    // should throw exception instead of entering infinite loop
    WO_TEST_THROWS([WOObjectMock mockForObjectClass:[self class]]);
}

- (void)testMockForClass
{
    WOClassMock *mock = [WOMock mockForClass:[self class]];
    
    // make sure WOClassMock class is returned
    WO_TEST_EQ([mock class], [WOClassMock class]);
    
    // make sure mocked class is correctly set
    Class class     = [self class];
    Class metaclass = object_getClass(class);
    WO_TEST_EQ([mock mockedClass], metaclass);
    
    // should throw exception instead of entering infinite loop
    // cannot test this because subclass implements that method directly
    //WO_TEST_THROWS([WOClassMock mockForClass:[self class]]);
}

- (void)testMockForProtocol
{
    WOProtocolMock *mock = [WOMock mockForProtocol:@protocol(WOTest)];
    
    // make sure WOProtocolMock class is returned
    WO_TEST_EQ([mock class], [WOProtocolMock class]);
    
    // make sure mocked protocol is correctly set
    WO_TEST_EQ([mock mockedProtocol], @protocol(WOTest));
    
    // should throw exception instead of entering infinite loop
    // cannot test this because subclass implements that method directly
    //WO_TEST_THROWS([WOProtocolMock mockForProtocol:@protocol(WOTest)]);
}

- (void)testInitWithObjectClass
{
    WOObjectMock *mock = 
        [[[WOMock alloc] initWithObjectClass:[self class]] autorelease];
    
    // make sure WOObjectMock class is returned
    WO_TEST_EQ([mock class], [WOObjectMock class]);
    
    // make sure mocked class is correctly set
    WO_TEST_EQ([mock mockedClass], [self class]);
    
    // should throw exception instead of entering infinite loop
    mock = [WOObjectMock alloc];
    WO_TEST_THROWS([mock initWithObjectClass:[self class]]);
    [mock release];
}

- (void)testInitWithClass
{
    WOClassMock *mock = 
        [[[WOMock alloc] initWithClass:[self class]] autorelease];
    
    // make sure WOClassMock class is returned
    WO_TEST_EQ([mock class], [WOClassMock class]);
    
    // make sure mocked class is correctly set
    Class class     = [self class];
    Class metaclass = object_getClass(class);
    WO_TEST_EQ([mock mockedClass], metaclass);
    
    // should throw exception instead of entering infinite loop
    // cannot test this because subclass implements that method directly
    //mock = [WOClassMock alloc];
    //WO_TEST_THROWS([mock initWithClass:[self class]]);
    //[mock release];
}

- (void)testInitWithProtocol
{
    WOProtocolMock *mock = 
        [[[WOMock alloc] initWithProtocol:@protocol(WOTest)] autorelease];
    
    // make sure WOProtocolMock class is returned
    WO_TEST_EQ([mock class], [WOProtocolMock class]);
    
    // make sure mocked protocol is correctly set
    WO_TEST_EQ([mock mockedProtocol], @protocol(WOTest));
    
    // should throw exception instead of entering infinite loop
    // cannot test this because subclass implements that method directly
    //mock = [WOProtocolMock alloc];
    //WO_TEST_THROWS([mock initWithProtocol:@protocol(WOTest)]);
    //[mock release];
}

- (void)testRecordingMethods
{
    // all recording methods should throw an exception (use subclasses instead)
    WOMock *mock = [[[WOMock alloc] init] autorelease];
    WO_TEST_THROWS([mock reject]);
    WO_TEST_THROWS([mock expectInOrder]);
    WO_TEST_THROWS([mock expectOnce]);
    WO_TEST_THROWS([mock expect]);
    WO_TEST_THROWS([mock acceptOnce]);
    WO_TEST_THROWS([mock accept]);
}

@end
