//
//  WOTestBundleInjector.m
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

// class header
#import "WOTestBundleInjector.h"

// system headers
#import <libkern/OSAtomic.h>        /* OSAtomicIncrement32Barrier() */

// other headers
#import "WOEnumerate.h"

@implementation WOTestBundleInjector

+ (void)load
{
    // do this once only
    static int32_t initialized = 0;
    if (OSAtomicIncrement32Barrier(&initialized) != 1)
        return;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    char *inject = getenv("WOTestInjectBundle");
    if (inject)
    {
        NSArray *bundles = [[NSString stringWithUTF8String:inject] componentsSeparatedByString:@":"];
        WO_ENUMERATE(bundles, bundlePath)
        {
            NSString *path = [bundlePath stringByStandardizingPath];
            if (![path isAbsolutePath])
            {
                NSLog(@"WOTestBundleInjector: skipping bundle \"%@\" (absolute path required)", bundlePath);
                continue;
            }
            NSBundle *bundle = [NSBundle bundleWithPath:path];
            if (!bundle)
                NSLog(@"WOTestBundleInjector: unable to get bundle for path \"%@\"", bundlePath);
            else if ([bundle isLoaded])
                NSLog(@"WOTestBundleInjector: skipping bundle \"%@\" (already loaded)", bundlePath);
            else if ([bundle load])
                NSLog(@"WOTestBundleInjector: bundle \"%@\" loaded", bundlePath);
            else
                // Note that you can't "load" application bundles this way, trying will wind up here
                // not even with low-level functions like NSCreateObjectFileImageFromFile() and NSCreateObjectFileImageFromMemory()
                // the docs for those functions say "you must build the Mach-O executable file using the -bundle linker option"
                // dlopen() successfully loads application executables but the symbols aren't visible even with the RTLD_NOW flag
                // CFBundle probably has the same limitations as well, altough haven't tested this
                NSLog(@"WOTestBundleInjector: failed to load bundle \"%@\"", bundlePath);
        }
    }
    [pool release];
}

@end
