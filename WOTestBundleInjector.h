//
//  WOTestBundleInjector.h
//  WOTest
//
//  Created by Wincent Colaiuta on 06 August 2006.
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

#import <Cocoa/Cocoa.h>

/*! As soon as the framework is loaded into memory injects any bundles specified by the WOTestInjectBundle environment variable. Bundles should specified as absolute paths, and multiple paths may be specified using a colon separator. */
@interface WOTestBundleInjector : NSObject {

}

@end
