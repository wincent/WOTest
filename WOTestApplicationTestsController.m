//
//  WOTestApplicationTestsController.m
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

// class header
#import "WOTestApplicationTestsController.h"

// other headers
#import "WOTest.h"

#ifdef WO_EXAMPLE_LOAD_METHOD_FOR_SUBCLASSES_TO_IMPLEMENT

#import <libkern/OSAtomic.h>        /* OSAtomicIncrement32Barrier() */

@implementation WOTestApplicationTestsController (WOExampleOnly)

+ (void)load
{
    static int32_t initialized = 0;
    if (OSAtomicIncrement32Barrier(&initialized) != 1) return;  // do this once only

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    (void)[[self alloc] initWithPath:__FILE__ keepComponents:3];
    [pool drain];
}

@end

#endif /* WO_EXAMPLE_LOAD_METHOD_FOR_SUBCLASSES_TO_IMPLEMENT */

@implementation WOTestApplicationTestsController

// we weak import the AppKit framework to make actually linking to it optional
extern NSString *NSApplicationDidFinishLaunchingNotification;

- (id)initWithPath:(const char *)sourcePath keepComponents:(unsigned)count
{
    NSParameterAssert(sourcePath != NULL);
    if ((self = [super init]))
    {
        NSString *path = [NSString stringWithUTF8String:sourcePath];
        NSAssert([path isAbsolutePath], @"sourcePath must be an absolute path");
        NSArray *components = [path pathComponents];
        unsigned componentCount = [components count];
        NSAssert(componentCount > count, @"componentCount must be greater than count");
        _trimPathComponents = componentCount - count;

        // wait until the app has finish launching before running the tests; means we can test stuff in nibs etc
        NSAssert((NSApplicationDidFinishLaunchingNotification != NULL), @"NSApplicationDidFinishLaunchingNotification not defined");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(runTests:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];

        [self performSelector:@selector(applicationFailedToFinishLaunching:) withObject:nil afterDelay:10.0];
    }
    return self;
}

- (void)runTests:(NSNotification *)aNotification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(applicationFailedToFinishLaunching:) object:nil];

    WOTest *tester                      = [WOTest sharedInstance];
    tester.trimInitialPathComponents    = _trimPathComponents;
    [tester runAllTests];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationFailedToFinishLaunching:(id)ignored
{
    NSLog(@"warning: NSApplicationDidFinishLaunchingNotification still not received after 10 seconds");
}

@end
