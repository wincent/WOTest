//
//  WOObjectStubTests.m
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
//  $Id: WOObjectStubTests.m 208 2007-07-07 19:02:28Z wincent $

// class header
#import "WOObjectStubTests.h"

// framework headers
#import "WOLightweightRoot.h"

@implementation WOObjectStubTests

- (void)testReturning
{
    // preliminaries
    id              mock    = nil;
    WOObjectStub    *stub   = nil;
    NSValue         *value  = [NSValue WOTest_valueWithObject:@"foobar"];
    
    // should raise if returning: invoked but return value already recorded
    stub = [WOObjectStub stubForClass:[NSString class] withDelegate:nil];
    WO_TEST_DOES_NOT_THROW([stub returning:value]);
    WO_TEST_THROWS([stub returning:value]);
    
    // should return expected value
    mock = [WOObjectMock mockForClass:[NSString class]];
    [[[mock accept] returning:value] lowercaseString];
    WO_TEST_EQ([mock lowercaseString], @"foobar");
}

- (void)testRaising
{
    // preliminaries
    id mock = nil;
    WOObjectStub *stub = nil;
    NSException *exception = [NSException exceptionWithName:@"WOFooException"
                                                     reason:@"foo exception"
                                                   userInfo:nil];
    
    // should raise if raising: invoked but exception already recorded
    stub = [WOObjectStub stubForClass:[NSString class] withDelegate:nil];
    WO_TEST_DOES_NOT_THROW([stub raising:exception]);
    WO_TEST_THROWS([stub raising:exception]);
    
    // try with different kind of exception object (not NSException)
    stub = [WOObjectStub stubForClass:[NSString class] withDelegate:nil];
    WO_TEST_DOES_NOT_THROW([stub raising:@"foo"]);
    WO_TEST_THROWS([stub raising:@"bar"]);
    
    // should raise if raising: passed an object that does not respond to 
    // retain, release or autorelease
    WOLightweightRoot *root = [WOLightweightRoot newLightweightRoot];
    stub = [WOObjectStub stubForClass:[NSString class] withDelegate:nil];
    WO_TEST_THROWS([stub raising:root]);
    [root dealloc];
    
    // should raise expected exception
    mock = [WOObjectMock mockForClass:[NSString class]];
    [[[mock accept] raising:exception] lowercaseString];
    WO_TEST_THROWS_EXCEPTION_NAMED([mock lowercaseString], @"WOFooException");
}

@end
