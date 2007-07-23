//
//  WOStubTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 09 February 2006.
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

#import "WOStubTests.h"

@implementation WOStubTests

- (void)testMatchesInvocation
{
    WOStub *stub = [[[WOStub alloc] init] autorelease];

    // raises if sent nil
    WO_TEST_THROWS([stub matchesInvocation:nil]);

    // raises if no recorded invocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
        [self methodSignatureForSelector:@selector(testMatchesInvocation)]];
    WO_TEST_THROWS([stub matchesInvocation:invocation]);
    [stub setInvocation:invocation];
    WO_TEST_DOES_NOT_THROW([stub matchesInvocation:invocation]);

    // test strict matching


    // test loose matching (arguments not checked)


}

@end
