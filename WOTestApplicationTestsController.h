//
//  WOTestApplicationTestsController.h
//  WOTest
//
//  Created by Wincent Colaiuta on 15 December 2006.
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

#import <Cocoa/Cocoa.h>

//! Abstract example class that demonstrates how to automate the running of application tests without having to link against the WOTest framework.
//!
//! In itself this class does nothing but if you write a subclass or category that implements an appropriate +load method (or a constructor) then you can use this class as a means of automatically running the application unit tests once the program has finished launching.
//!
//! A more advanced subclass could also be used to manage more complicated test configurations, such as checking for and loading plug-ins and the corresponding tests in an application with a plug-in based architecture.
//!
//! The test bundle itself can be automatically injected using the WOTestInjectBundle environment variable, and the WOTest framework can be inserted dynamically using the DYLD_INSERT_LIBRARIES environment variable without any modifications to the application code under testing.
//!
//! See the implementation file for an example +load method that a subclass or category would have to implement in order to take advantage of this class.
//!
@interface WOTestApplicationTestsController : NSObject {

    unsigned    _trimPathComponents;

}

//! For example, if your test controller was implemented in a source file at:
//!
//!     /Users/yourusername/work/project_name/source/tests/MyTestsController.m
//!
//! That path has 8 components (the root directory, "/", 6 other directories, and the source file); you could pass the inbuilt GCC __FILE__ macro as \p sourcePath, and pass 4 for \p count, and WOTest would omit the first 4 path components (8 take 4 equals 4) when printing paths in test results; as such the above path would be printed as:
//!
//!     tests/MyTestsController.m
//!
//! If you want to retain clickable test results in the Xcode build results window you should either use absolute paths or paths relative to the project source root.
//!
- (id)initWithPath:(const char *)sourcePath keepComponents:(unsigned)count;

- (void)runTests:(NSNotification *)aNotification;

@end
