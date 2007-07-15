//
//  WOClassMock.m
//  WOTest
//
//  Created by Wincent Colaiuta on 28 January 2006.
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

// class header
#import "WOClassMock.h"

// system headers
#import <objc/objc-class.h>

// framework headers
#import "NSObject+WOTest.h"
#import "WOMock.h"

@implementation WOClassMock

- (id)initWithClass:(Class)aClass
{
    NSParameterAssert(aClass != NULL);
    NSParameterAssert([NSObject WOTest_isRegisteredClass:aClass]);	// only registered classes pass (do not pass meta classes)
    if ((self = [super initWithClass:aClass]))
        [self setMockedClass:object_getClass(aClass)];				// look up the meta class and use that
    return self;
}

@end
