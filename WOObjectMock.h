//
//  WOObjectMock.h
//  WOTest
//
//  Created by Wincent Colaiuta on 10/02/06.
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
#import "WOMock.h"

@interface WOObjectMock : WOMock {

    Class           mockedClass;

}

#pragma mark -
#pragma mark Creation

/*! \p aClass may not be nil. */
+ (id)mockForClass:(Class)aClass;

/*! Designated initializer. \p aClass may not be nil. */
- (id)initWithClass:(Class)aClass;

#pragma mark -
#pragma mark Accessors

    /*!
    \name  Accessor methods 
     \startgroup 
     */

- (Class)mockedClass;
- (void)setMockedClass:(Class)aMockedClass;

/*! \endgroup */

@end
