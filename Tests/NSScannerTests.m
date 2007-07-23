//
//  NSScannerTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 01 February 2006.
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

#import "NSScannerTests.h"

@implementation NSScannerTests

- (void)testPeekCharacter
{
    // preliminaries
    NSString    *string     = @"foobar";
    NSScanner   *scanner    = [NSScanner scannerWithString:string];
    unichar     character;

    WO_TEST_THROWS([scanner WOTest_peekCharacter:NULL]);        // test response to NULL
    [scanner setScanLocation:0];                                // move to start
    WO_TEST([scanner WOTest_peekCharacter:&character]);         // scans
    WO_TEST_EQ(character, 'f');                                 // gets correct result
    WO_TEST_EQ([scanner scanLocation], 0U);                     // doesn't move location
    [scanner setScanLocation:[string length]];                  // move to end
    WO_TEST_FALSE([scanner WOTest_peekCharacter:&character]);   // doesn't scan past end
}

- (void)testScanCharacter
{
    // preliminaries
    NSString    *string     = @"foobar";
    NSScanner   *scanner    = [NSScanner scannerWithString:string];
    unichar     character   = 0;

    WO_TEST_DOES_NOT_THROW([scanner WOTest_scanCharacter:NULL]);    // test with NULL
    [scanner setScanLocation:0];                                    // move to start
    WO_TEST_TRUE([scanner WOTest_scanCharacter:&character]);        // scans
    WO_TEST_EQ(character, 'f');                                     // gets correct result
    WO_TEST_EQ([scanner scanLocation], 1U);                         // does move location
    [scanner setScanLocation:[string length]];                      // move to end
    WO_TEST_FALSE([scanner WOTest_scanCharacter:&character]);       // doesn't scan past end
}

- (void)testScanCharacterFromSetIntoChar
{
    // handles NULL correctly
}

- (void)testScanReturnTypeIntoString
{
    // handles nil correctly

    // return types must be at beginning of string
}

- (void)testScanTypeIntoString
{
    // handles nil correctly



}

- (void)testScanQualifiersIntoString
{
    // handles nil correctly

}

- (void)testScanNonCompoundTypeIntoString
{
    // test handles nil correctly

}

- (void)testScanBitfieldIntoString
{
    // test handles nil correctly

}

- (void)testScanArrayIntoString
{
    // test handles nil correctly

}

- (void)testScanIdentifierIntoString
{
    // test handles nil correctly

}

- (void)testScanStructIntoString
{
    // test handles nil correctly

}

- (void)testScanUnionIntoString
{
    // test handles nil correctly

}

- (void)testScanPointerIntoString
{
    // preliminaries
    NSString    *string     = @"^i";
    NSScanner   *scanner    = [NSScanner scannerWithString:string];
    NSString    *result     = nil;

    // test handles nil correctly
    WO_TEST_TRUE([scanner scanPointerIntoString:nil]);

    // test scanning a pointer to something
    [scanner setScanLocation:0];
    WO_TEST_TRUE([scanner scanPointerIntoString:&result]);
    WO_TEST_EQUAL(string, result);

    // test scanning a pointer to a pointer to something
    string  = @"^^{WOStruct=fi@}";
    scanner = [NSScanner scannerWithString:string];
    result  = nil;
    WO_TEST_TRUE([scanner scanPointerIntoString:&result]);
    WO_TEST_EQUAL(string, result);

    // test against a non-pointer
    string  = @"{WOStruct=^fi@}";
    scanner = [NSScanner scannerWithString:string];
    result  = nil;
    WO_TEST_FALSE([scanner scanPointerIntoString:&result]);
}

- (void)testMethodSignatureParsing
{
    // these type strings taken from the runtime
    NSScanner *scanner1 = [NSScanner scannerWithString:@"@8@0:4"];
    NSScanner *scanner2 = [NSScanner scannerWithString:@"r*8@0:4"];
    NSScanner *scanner3 = [NSScanner scannerWithString:@"^v8@0:4"];
    NSScanner *scanner4 = [NSScanner scannerWithString:@"c12@0:4@8"];
    NSScanner *scanner5 = [NSScanner scannerWithString:@"@12@0:4^{_NSZone=}8"];
    NSScanner *scanner6 = [NSScanner scannerWithString:@"#8@0:4"];
    NSScanner *scanner7 = [NSScanner scannerWithString:@"v20@0:4@8:12@16"];
    NSScanner *scanner8 = [NSScanner scannerWithString:
        (@"{_NSRect={_NSPoint=ff}{_NSSize=ff}}"
         @"28@0:4{_NSRect={_NSPoint=ff}{_NSSize=ff}}8I24")];
    NSScanner *scanner9 = [NSScanner scannerWithString:@"@12@0:4@8"];

    // WOTest_peekCharacter: and WOTest_scanCharacter:
    unichar character;
    [scanner1 WOTest_scanCharacter:&character];
    WO_TEST_EQUAL(character, '@');
    WO_TEST_EQUAL([scanner1 scanLocation], (unsigned)1);        // should advance
    [scanner1 WOTest_peekCharacter:&character];
    WO_TEST_EQUAL(character, '8');
    WO_TEST_EQUAL([scanner1 scanLocation], (unsigned)1);        // should not
    [scanner1 WOTest_scanCharacter:&character];
    WO_TEST_EQUAL(character, '8');
    [scanner1 setScanLocation:5];
    [scanner1 WOTest_scanCharacter:&character];
    WO_TEST_EQUAL(character, '4');
    WO_TEST_FALSE([scanner1 WOTest_peekCharacter:&character]);  // atEnd
    WO_TEST_FALSE([scanner1 WOTest_scanCharacter:&character]);  // atEnd
    [scanner1 setScanLocation:0];                               // reset

    // using higher level scanning methods to parse: @8@0:4
    NSString *type;
    WO_TEST_TRUE([scanner1 WOTest_scanNonCompoundTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"@");
    [scanner1 setScanLocation:0];                           // reset
    type = nil;
    WO_TEST_TRUE([scanner1 WOTest_scanTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"@");
    [scanner1 setScanLocation:0];                           // reset
    type = nil;
    WO_TEST_TRUE([scanner1 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"@");
    WO_TEST_FALSE([scanner1 WOTest_scanReturnTypeIntoString:&type]);
    [scanner1 setScanLocation:0];                           // reset
    type = nil;
    WO_TEST_FALSE([scanner1 WOTest_scanQualifiersIntoString:&type]);
    WO_TEST_FALSE([scanner1 WOTest_scanBitfieldIntoString:&type]);
    WO_TEST_FALSE([scanner1 WOTest_scanArrayIntoString:&type]);
    WO_TEST_FALSE([scanner1 WOTest_scanIdentifierIntoString:&type]);
    WO_TEST_FALSE([scanner1 WOTest_scanStructIntoString:&type]);
    WO_TEST_FALSE([scanner1 WOTest_scanUnionIntoString:&type]);
    WO_TEST_FALSE([scanner1 scanPointerIntoString:&type]);
    WO_TEST_EQUAL([scanner1 scanLocation], (unsigned)0);    // still at start

    // parsing: r*8@0:4
    WO_TEST_FALSE([scanner2 WOTest_scanNonCompoundTypeIntoString:&type]);
    WO_TEST_TRUE([scanner2 WOTest_scanTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"r*");
    [scanner2 setScanLocation:0];                           // reset
    type = nil;
    WO_TEST_TRUE([scanner2 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"r*");
    WO_TEST_FALSE([scanner2 WOTest_scanReturnTypeIntoString:&type]);
    [scanner2 setScanLocation:0];                           // reset
    type = nil;
    WO_TEST_TRUE([scanner2 WOTest_scanQualifiersIntoString:&type]);
    [scanner2 setScanLocation:0];                           // reset
    type = nil;
    WO_TEST_FALSE([scanner2 WOTest_scanBitfieldIntoString:&type]);
    WO_TEST_FALSE([scanner2 WOTest_scanArrayIntoString:&type]);
    WO_TEST_FALSE([scanner2 WOTest_scanIdentifierIntoString:&type]);
    [scanner2 setScanLocation:0];                           // reset
    type = nil;
    WO_TEST_FALSE([scanner2 WOTest_scanStructIntoString:&type]);
    WO_TEST_FALSE([scanner2 WOTest_scanUnionIntoString:&type]);
    WO_TEST_FALSE([scanner2 scanPointerIntoString:&type]);
    WO_TEST_EQUAL([scanner2 scanLocation], (unsigned)0);    // still at start

    // parse: ^v8@0:4
    type = nil;
    WO_TEST_TRUE([scanner3 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"^v");

    // parse: c12@0:4@8
    type = nil;
    WO_TEST_TRUE([scanner4 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"c");

    // parse: @12@0:4^{_NSZone=}8
    type = nil;
    WO_TEST_TRUE([scanner5 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"@");

    // parse: #8@0:4
    type = nil;
    WO_TEST_TRUE([scanner6 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"#");

    // parse: v20@0:4@8:12@16
    type = nil;
    WO_TEST_TRUE([scanner7 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"v");

    // parse: {_NSRect={_NSPoint=ff}{_NSSize=ff}}28@0:4{_NSRect={_NSPoint=f...
    type = nil;
    WO_TEST_TRUE([scanner8 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"{_NSRect={_NSPoint=ff}{_NSSize=ff}}");

    // parse: @12@0:4@8
    type = nil;
    WO_TEST_TRUE([scanner9 WOTest_scanReturnTypeIntoString:&type]);
    WO_TEST_EQUAL(type, @"@");
}

@end
