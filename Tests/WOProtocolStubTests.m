//
//  WOProtocolStubTests.m
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

#import "WOProtocolStubTests.h"

@implementation WOProtocolStubTests

- (void)testStubForProtocol
{
    // throws if passed NULL, otherwise works
    WO_TEST_THROWS([WOProtocolStub stubForProtocol:NULL withDelegate:nil]);
    WO_TEST_DOES_NOT_THROW([WOProtocolStub stubForProtocol:@protocol(WOTest) withDelegate:nil]);
}

- (void)testInitWithProtocol
{
    // throws if passed NULL
    WOProtocolStub *stub = [WOProtocolStub alloc];
    WO_TEST_THROWS([stub initWithProtocol:NULL delegate:nil]);

    // otherwise works
    stub = [WOProtocolStub alloc];
    WO_TEST_DOES_NOT_THROW([stub initWithProtocol:@protocol(WOTest) delegate:nil]);
}

- (void)testMethodSignatureForSelector
{
    // throws if selector not present in protocol, otherwise works
    WOProtocolStub *stub =
        [WOProtocolStub stubForProtocol:@protocol(NSCopying) withDelegate:nil];
    WO_TEST_THROWS([stub methodSignatureForSelector:@selector(retain)]);
    WO_TEST_DOES_NOT_THROW
        ([stub methodSignatureForSelector:@selector(copyWithZone:)]);
}

@end
