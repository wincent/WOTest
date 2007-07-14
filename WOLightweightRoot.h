//
//  WOLightweightRoot.h
//  WOTest
//
//  Created by Wincent Colaiuta on 31/01/06.
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
//  $Id: WOLightweightRoot.h 208 2007-07-07 19:02:28Z wincent $

#import <objc/objc-runtime.h>

/*! An extremely lightweight root class (that does not inherit from NSObject or any other root class) that implements an absolute minimum of selectors so as to provide a namespace that is as close as practically possible to being "empty". */
@interface WOLightweightRoot {
    Class isa;
}

/*! An empty implementation provided because the runtime tries to send an initialize method before a class is used for the first time. */
+ (void)initialize;

+ (id)newLightweightRoot;

- (void)dealloc;

/*! This method required by the runtime (called by _objc_forward for unrecognized selectors). The default implementation simply raises an NSInternalInconsistencyException. */
- forward:(SEL)sel :(marg_list)args;

@end
