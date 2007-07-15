//
//  NSProxy+WOTest.h
//  WOTest
//
//  Created by Wincent Colaiuta on 12 July 2005.
//
//  Copyright 2005-2007 Wincent Colaiuta.
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
#import <objc/objc-class.h>

//! The runtime requires that all root classes implement the forward:: method. To my knowledge this is not officially documented anywhere, but can at least be confirmed by examining the Darwin source code. This header declares the method as part of a category; include the header to silence compiler warnings when trying to call forward:: on NSProxy or a subclass.
//! \sa http://darwinsource.opendarwin.org/10.4.3/objc4-267/runtime/Messengers.subproj/objc-msg-ppc.s
@interface NSProxy (WOTestPrivate)

- forward:(SEL)sel :(marg_list)args;

@end