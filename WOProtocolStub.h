//
//  WOProtocolStub.h
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

#import <Foundation/Foundation.h>
#import "WOStub.h"

@interface WOProtocolStub : WOStub {

    Protocol    *mockedProtocol;
    
}

#pragma mark -
#pragma mark Creation

/*! Factory method. */
+ (id)stubForProtocol:(Protocol *)aProtocol withDelegate:(id)aDelegate;

/*! Designated initializer. */
- (id)initWithProtocol:(Protocol *)aProtocol delegate:(id)aDelegate;

#pragma mark -
#pragma mark Accessors

- (Protocol *)mockedProtocol;

@end
