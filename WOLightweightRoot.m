//
//  WOLightweightRoot.m
//  WOTest
//
//  Created by Wincent Colaiuta on 31 January 2006.
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
#import "WOLightweightRoot.h"

// system headers
#import <Foundation/Foundation.h>

@implementation WOLightweightRoot

+ (void)initialize
{
    // do nothing: this method required by the runtime
}

+ (id)newLightweightRoot
{
    Class class = object_getClass(self);
    return class_createInstance(class, 0);
}

- (void)exampleMethod
{
    // do nothing
}

- forward:(SEL)sel :(marg_list)args
{
    [NSException raise:NSInternalInconsistencyException format:@"Unrecognized selector %@", NSStringFromSelector(sel)];
    return nil; // never executed, but include this to quell compiler warning
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return nil;
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    [NSException raise:NSInternalInconsistencyException
                format:@"Unrecognized selector %@", NSStringFromSelector(aSelector)];
}

@end
