//
//  WOTestRunner.m
//  WOTest
//
//  Created by Wincent Colaiuta on 12/03/05.
//
//  Copyright 2004-2007 Wincent Colaiuta.
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

// main header
#import "WOTestRunner.h"

// system headers
#import <Foundation/Foundation.h>
#import <objc/objc-runtime.h>
#import <getopt.h>

// framework headers
#import "WOTest.h"

// make what(1) produce meaningful output
#import "WOTestRunner_Version.h"

#pragma mark -
#pragma mark Implementation

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int exitCode = EXIT_SUCCESS;
    
    // an example of using the framework without linking to it
    WO_TEST_LOAD_FRAMEWORK;
    if (!WO_TEST_FRAMEWORK_IS_LOADED)
    {
        exitCode = EXIT_FAILURE;
        fprintf(stderr, "error: unable to load WOTest framework\n");
        goto cleanup;
    }
    
    // parse commandline arguments
    int verbose = 0;
    NSMutableArray *testClasses     = [NSMutableArray array];
    NSMutableArray *excludeClasses  = [NSMutableArray array];
    NSMutableArray *testBundles     = [NSMutableArray array];
    NSMutableArray *excludeBundles  = [NSMutableArray array];
    
    extern char *optarg;
    extern int  optind;
    int         ch;    
    static struct option longopts[] = {
        { "help",           no_argument,        NULL,   'h' },
        { "verbose",        no_argument,        NULL,   'v' },
        { "version",        no_argument,        NULL,   'V' },
        { "test-class",     required_argument,  NULL,   't' },
        { "exclude-class",  required_argument,  NULL,   'e' },
        { "test-bundle",    required_argument,  NULL,   'b' },
        { "exclude-bundle", required_argument,  NULL,   'x' }
    };
    while ((ch = getopt_long(argc, (char * const *)argv, "hvVt:e:b:", longopts, NULL)) != -1)
    {
        switch (ch)
        {
            case 'h':   // show help
                showUsage(argv[0]);
                goto cleanup;
                break;
            case 'v':   // be verbose
                verbose++;
                break;
            case 'V':   // show version information
                showVersion();
                goto cleanup;
                break;
            case 't': // test this class
                [testClasses addObject:[NSString stringWithUTF8String:optarg]];   
                break;    
            case 'e': // exclude this class
                [excludeClasses addObject:[NSString stringWithUTF8String:optarg]];
                break;
            case 'b': // test this bundle (loading into memory if necessary)
                [testBundles addObject:[NSString stringWithUTF8String:optarg]];
                break;
            case 'x': // exclude this bundle
                [excludeBundles addObject:[NSString stringWithUTF8String:optarg]];   
                break;
            default:
                showUsage(argv[0]);
                exitCode = EXIT_FAILURE;
                goto cleanup;
        }
    }
     
    // TODO: automatically modify DYLD_FRAMEWORK_PATH based on passed-in bundles, restore to previous setting on exit
    // basic algorithm: 
    // - save DYLD_FRAMEWORK_PATH
    // - for each absolute bundle path, is bundle path already in DYLD_FRAMEWORK_PATH? if not add it
    // - at end, restore DYLD_FRAMEWORK_PATH
    // more sophisticated algorithm:
    // - inspect mach-o headers to see which libraries it wants to load; if they're non-standard locations, add them
    
    /*
     
     Example error when trying to run WOCommon tests without first setting DYLD_FRAMEWORK_PATH
     
     2006-10-23 01:19:51.727 WOTestRunner[892] *** -[NSBundle load]: Error loading code /Users/wincent/trabajo/build/Debug/WOCommon.bundle/Contents/MacOS/WOCommon for bundle /Users/wincent/trabajo/build/Debug/WOCommon.bundle, error code 4 (link edit error code 4, error number 0 (Library not loaded: @executable_path/../Frameworks/WOTest.framework/Versions/A/WOTest
     warning: could not load bundle /Users/wincent/trabajo/build/Debug/WOCommon.bundle
     
    of course, may be more complicated than all that. would be nice to handle case where WOTestRunner, WOTest.framework and the bundle being tested were all in completely unrelated locations
                                                                                                                                                                                                                                                                                        
    */
    
    if ([testBundles count] > 0) // test only these bundles
    {
        WO_ENUMERATE(testBundles, bundlePath)
        {
            bundlePath = [bundlePath WOTest_stringByConvertingToAbsolutePath];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            if (bundle && [bundle load])
            {
                if ([testClasses count] > 0) // test only these classes
                {
                    WO_ENUMERATE(testClasses, class)
                        [WO_TEST_SHARED_INSTANCE runTestsForClassName:class];
                }
                else // test all classes
                {
                    NSArray *classes = [WO_TEST_SHARED_INSTANCE testableClassesFrom:bundle];
                    WO_ENUMERATE(classes, class)
                    {
                        if ([excludeClasses containsObject:class]) continue;
                        [WO_TEST_SHARED_INSTANCE runTestsForClassName:class];
                    }
                }
            }
            else
                fprintf(stderr, "warning: could not load bundle %s\n", [bundlePath UTF8String]);
        }
    }
    else // test all bundles
    {
        if ([testClasses count] > 0) // test only these classes
        {
            WO_ENUMERATE(testClasses, class)
                [WO_TEST_SHARED_INSTANCE runTestsForClassName:class];
        }
        else // test all classes
        {   
            NSArray *classes = [WO_TEST_SHARED_INSTANCE testableClasses];
            WO_ENUMERATE(classes, class)
            {
                if ([excludeClasses containsObject:class]) continue;
                [WO_TEST_SHARED_INSTANCE runTestsForClassName:class];
            }
        }
    }
    
    [WO_TEST_SHARED_INSTANCE printTestResultsSummary];
    if (![WO_TEST_SHARED_INSTANCE testsWereSuccessful])
        exitCode = EXIT_FAILURE;
            
cleanup:
    [pool release];    
    return exitCode;
}

void showUsage(const char *name)
{
    fprintf
    (stdout,
     //------------------------------- 80 columns ----------------------------------->|
     "WOTestRunner, part of the WOTest framework <http://test.wincent.com/>.\n"
     "\n"
     "%s.\n"
     "This program is free software: you can redistribute it and/or modify\n"
     "it under the terms of the GNU General Public License as published by\n"
     "the Free Software Foundation, either version 3 of the License, or\n"
     "(at your option) any later version.\n"
     "\n"
     "This program is distributed in the hope that it will be useful,\n"
     "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
     "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
     "GNU General Public License for more details.\n"
     "\n"
     "You should have received a copy of the GNU General Public License\n"
     "along with this program.  If not, see <http://www.gnu.org/licenses/>.\n"
     "\n"
     "Usage: %s [option]...\n"
     "-t, --test-class=CLASS         test only CLASS\n"
     "-e, --exclude-class=CLASS      test all but CLASS\n"
     "-b, --test-bundle=BUNDLE       test only BUNDLE, loading if necessary\n"
     "-x, --exclude-bundle=BUNDLE    test all but BUNDLE\n"
     "-v, --verbose                  verbose output (repeat for more verbosity)\n"
     "-V, --version                  show version information\n"
     "-h, --help                     show this usage information\n", 
     WO_RCSID_STRING(copyright), name);
}

void showVersion(void)
{
    fprintf
    (stdout, 
     //------------------------------- 80 columns ----------------------------------->|
     "WOTestRunner, part of the WOTest framework <http://test.wincent.com/>.\n"
     "\n"
     "%s.\n"
     "This program is free software: you can redistribute it and/or modify\n"
     "it under the terms of the GNU General Public License as published by\n"
     "the Free Software Foundation, either version 3 of the License, or\n"
     "(at your option) any later version.\n"
     "\n"
     "This program is distributed in the hope that it will be useful,\n"
     "but WITHOUT ANY WARRANTY; without even the implied warranty of\n"
     "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n"
     "GNU General Public License for more details.\n"
     "\n"
     "You should have received a copy of the GNU General Public License\n"
     "along with this program.  If not, see <http://www.gnu.org/licenses/>.\n"
     "\n"
     "%s\n", WO_RCSID_STRING(copyright), WO_RCSID_STRING(version));
}
