//
//  WOMultithreadedCrashTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 26 November 2006.
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
#import "WOMultithreadedCrashTests.h"

@implementation WOMultithreadedCrashTests

- (void)preflight
{
    [WO_TEST_SHARED_INSTANCE setExpectLowLevelExceptions:YES];
}

- (void)postflight
{
    [WO_TEST_SHARED_INSTANCE setExpectLowLevelExceptions:YES];
}

#pragma mark -
#pragma mark Helper methods

- (void)secondaryThreadCrasher:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Apple's InstallExceptionHandler doesn't catch crashes on secondary threads
    // - in the case of Carbon threads a separate handler is automatically installed for each thread
    // - pthreads and Cocoa threads don't get extra handlers automatically installed
    // - these are per-thread handlers because the per-process handler port is used by the crash reporter

    // TODO: write a Mach per-process exception handler
    return;                                                     // don't continue (would crash WOTestRunner)

    WO_TEST_PASS;                                               // force update of "lastKnownLocation"
    id *object = NULL;                                          // cause a crash, but WOTest should keep running
    *object = @"foo";                                           // SIGBUS here
    WO_TEST_FAIL;                                               // this line never reached
    [pool drain];                                               // nor this one, but pools are in a stack no problem
}

#pragma mark -
#pragma mark Test methods

- (void)testCrashOnSecondaryThread
{
    [WO_TEST_SHARED_INSTANCE setExpectLowLevelExceptions:YES];  // will be reset to NO in preflight prior to next method
    [NSThread detachNewThreadSelector:@selector(secondaryThreadCrasher:) toTarget:self withObject:self];
}

@end
