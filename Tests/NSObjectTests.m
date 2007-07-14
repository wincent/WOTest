//
//  NSObjectTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 10 February 2006.
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
//  $Id: NSObjectTests.m 208 2007-07-07 19:02:28Z wincent $

// class header
#import "NSObjectTests.h"

// framework headers
#import "WOLightweightRoot.h"

@implementation NSObjectTests

- (void)testDescriptionForObject
{
    // description for nil should be "(nil)"
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:nil], @"(nil)");
    
    // NSString objects should be returned as-is
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:@"foo"], @"foo");
    
    // NSNumber is a special case:
    // when an NSValue is initialized with an int NSNumber, the NSValue behaves as though it were initialized with an int
    NSNumber *number = [NSNumber numberWithInt:1];
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:number], @"(int)1");
    
    // other objects should return "description"
    NSButton *button = [[NSButton alloc] init];
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:button], [button description]);
    
    // custom classes that do not respond to "description" return class name    
    WOLightweightRoot *root = [WOLightweightRoot newLightweightRoot];
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:root], @"WOLightweightRoot");
    [root dealloc];
    
    // special case: NSValues that contain NSStrings should return the string
    NSValue *value = [NSValue WOTest_valueWithObject:@"foo"];
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:value], @"foo");
    
    // standard case: other NSValues should return "description"
    NSRange range;
    range.location  = 0; // can't use NSMakeRange (Intel release warnings)
    range.length    = 0;
    value = [NSValue valueWithRange:range];
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:value], [value WOTest_description]);
    
    // pointers to void should be formatted as "(void *)<00000000 >", as returned by WOTest_description
    value = [NSValue valueWithNonretainedObject:@"bar"];
    WO_TEST_EQ([NSObject WOTest_descriptionForObject:value], [value WOTest_description]);
}

- (void)testIsRegisteredClass
{
    WO_TEST([NSObject WOTest_isRegisteredClass:[self class]]);
    WO_TEST_FALSE([NSObject WOTest_isRegisteredClass:(Class)self]); // shouldn't raise
}

- (void)testIsMetaClass
{
    WO_TEST([NSObject WOTest_isMetaClass:objc_getMetaClass("NSObjectTests")]);
    WO_TEST_FALSE([NSObject WOTest_isMetaClass:[self class]]);
}

- (void)testObjectIsKindOfClass
{
    // preliminaries
    id object       = @"foo";
    id subobject    = [NSMutableString stringWithString:@"bar"];
    id otherObject  = [WOLightweightRoot newLightweightRoot];
    
    // should raise if passed a non-class pointer
    WO_TEST_THROWS([NSObject WOTest_object:self isKindOfClass:(Class)self]);
    WO_TEST_DOES_NOT_THROW([NSObject WOTest_object:self isKindOfClass:[self class]]);
    
    // nil object or NULL class should always return NO
    WO_TEST_FALSE([NSObject WOTest_object:nil isKindOfClass:NULL]);
    WO_TEST_FALSE([NSObject WOTest_object:self isKindOfClass:NULL]);
    WO_TEST_FALSE([NSObject WOTest_object:nil isKindOfClass:[self class]]);
    
    // basic test cases
    WO_TEST([NSObject WOTest_object:object isKindOfClass:[NSString class]]);
    WO_TEST_FALSE([NSObject WOTest_object:object isKindOfClass:[NSNumber class]]);        
    
    // subclass should be considered of same kind as superclass
    WO_TEST([NSObject WOTest_object:subobject isKindOfClass:[NSString class]]);
    
    // superclass should not be considered as same kind as subclass
    WO_TEST_FALSE([NSObject WOTest_object:[[[NSObject alloc] init] autorelease]
                     isKindOfClass:[self class]]);
    
    // initial attempt at this test failed because the NSString object had a
    // superclass of "%NSCFString", which happened to match NSMutableString!
    //WO_TEST_FALSE([NSObject WOTest_object:object
    //                 isKindOfClass:[NSMutableString class]]);
    // note that the Cocoa isKindOfClass: method also produces this behaviour:
    //WO_TEST_FALSE([@"constant string" isKindOfClass:[NSMutableString class]]);
        
    // should handle custom root classes without problems
    WO_TEST([NSObject WOTest_object:otherObject 
               isKindOfClass:NSClassFromString(@"WOLightweightRoot")]);
    WO_TEST_FALSE([NSObject WOTest_object:otherObject isKindOfClass:[NSString class]]);
    WO_TEST_FALSE([NSObject WOTest_object:self 
                     isKindOfClass:NSClassFromString(@"WOLightweightRoot")]);
    
    // cleanup
    [otherObject dealloc];
}

- (void)testInstancesOfClassAreKindOfClass
{
    Class class         = [NSString class];
    Class subclass      = [NSMutableString class];
    Class otherClass    = NSClassFromString(@"WOLightweightRoot");
    
    // should raise if passed non-class pointers
    WO_TEST_THROWS([NSObject WOTest_instancesOfClass:(Class)self areKindOfClass:(Class)self]);
    WO_TEST_THROWS([NSObject WOTest_instancesOfClass:(Class)self areKindOfClass:[NSString class]]);
    WO_TEST_THROWS([NSObject WOTest_instancesOfClass:[NSString class] areKindOfClass:(Class)self]);
    WO_TEST_DOES_NOT_THROW([NSObject WOTest_instancesOfClass:[self class] areKindOfClass:[NSString class]]);
    
    // if either class is NULL should always return NO
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:NULL areKindOfClass:NULL]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[self class] areKindOfClass:NULL]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:NULL areKindOfClass:[self class]]);
    
    // basic tests
    WO_TEST([NSObject WOTest_instancesOfClass:[NSString class] areKindOfClass:[NSString class]]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[NSString class] areKindOfClass:[NSNumber class]]);
        
    // a subclass should be considered of same kind as superclass
    WO_TEST([NSObject WOTest_instancesOfClass:subclass areKindOfClass:class]);
    
    // a superclass should not be considered as same kind as subclass
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:class areKindOfClass:subclass]);
    
    // should handle custom root classes without problems
    WO_TEST([NSObject WOTest_instancesOfClass:otherClass areKindOfClass:otherClass]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:class areKindOfClass:otherClass]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:otherClass areKindOfClass:class]);
}

- (void)testObjectRespondsToSelector
{
    // preliminaries
    id object       = @"foobar";
    id subobject    = [NSMutableString stringWithString:object];
    id root         = [WOLightweightRoot newLightweightRoot];
    
    // test returns NO for nil object or NULL selector
    WO_TEST_FALSE([NSObject WOTest_object:nil respondsToSelector:NULL]);
    WO_TEST_FALSE([NSObject WOTest_object:nil respondsToSelector:@selector(length)]);
    WO_TEST_FALSE([NSObject WOTest_object:self respondsToSelector:NULL]);
    
    // basic tests
    WO_TEST([NSObject WOTest_object:self 
          respondsToSelector:@selector(testObjectRespondsToSelector)]);
    WO_TEST_FALSE([NSObject WOTest_object:self respondsToSelector:@selector(foo)]);
    
    // should work for subclasses
    WO_TEST([NSObject WOTest_object:object respondsToSelector:@selector(length)]);
    WO_TEST([NSObject WOTest_object:subobject respondsToSelector:@selector(length)]);
    WO_TEST_FALSE([NSObject WOTest_object:object respondsToSelector:@selector(bar)]);
    WO_TEST_FALSE([NSObject WOTest_object:subobject 
                respondsToSelector:@selector(bar)]);
    
    // should handle custom root classes without problems
    WO_TEST([NSObject WOTest_object:root respondsToSelector:@selector(dealloc)]);
    WO_TEST_FALSE([NSObject WOTest_object:root respondsToSelector:@selector(foobar)]);
    
    // cleanup
    [root dealloc];
}

- (void)testClassRespondsToSelector
{
    // should raise if passed non-class pointer
    WO_TEST_THROWS([NSObject WOTest_class:(Class)self respondsToSelector:@selector(init)]);
    WO_TEST_DOES_NOT_THROW([NSObject WOTest_class:[self class] respondsToSelector:@selector(init)]);
    
    // test that NULL class or NULL selector return NO
    WO_TEST_FALSE([NSObject WOTest_class:NULL respondsToSelector:NULL]);
    WO_TEST_FALSE([NSObject WOTest_class:NULL respondsToSelector:@selector(init)]);
    WO_TEST_FALSE([NSObject WOTest_class:[self class] respondsToSelector:NULL]);
    
    // basic tests
    WO_TEST([NSObject WOTest_class:[self class] respondsToSelector:@selector(initialize)]);
    WO_TEST_FALSE([NSObject WOTest_class:[self class] respondsToSelector:@selector(unimplimentedClassMethod)]);
}

- (void)testInstancesOfClassRespondToSelector
{
    // should raise if passed non-class pointer
    WO_TEST_THROWS([NSObject WOTest_instancesOfClass:(Class)self respondToSelector:@selector(init)]);
    WO_TEST_DOES_NOT_THROW([NSObject WOTest_instancesOfClass:[self class] respondToSelector:@selector(init)]);               
    
    // test that NULL class or NULL selector return NO
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:NULL respondToSelector:NULL]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:NULL respondToSelector:@selector(length)]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[self class] respondToSelector:NULL]);
    
    // basic tests
    WO_TEST([NSObject WOTest_instancesOfClass:[NSString class] respondToSelector:@selector(length)]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[NSString class] respondToSelector:@selector(longitude)]);
    
    // subclasses should work as well
    WO_TEST([NSObject WOTest_instancesOfClass:[NSMutableString class] respondToSelector:@selector(length)]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[NSMutableString class] respondToSelector:@selector(longitude)]);
    
    // should work with custom root classes
    WO_TEST([NSObject WOTest_instancesOfClass:NSClassFromString(@"WOLightweightRoot") respondToSelector:@selector(forward::)]);
    WO_TEST([NSObject WOTest_instancesOfClass:NSClassFromString(@"WOLightweightRoot") respondToSelector:@selector(dealloc)]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:NSClassFromString(@"WOLightweightRoot")
                                  respondToSelector:@selector(conformsToProtocol:)]);
}

- (void)testInstancesOfClassConformToProtocol
{
    // should throw if passed non-class pointer
    WO_TEST_THROWS([NSObject WOTest_instancesOfClass:(Class)self conformToProtocol:@protocol(NSLocking)]);
    WO_TEST_DOES_NOT_THROW([NSObject WOTest_instancesOfClass:[self class] conformToProtocol:@protocol(NSObject)]);
    
    // test that NULL class or NULL protocol return NO
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:NULL conformToProtocol:NULL]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[self class] conformToProtocol:NULL]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:NULL conformToProtocol:@protocol(WOTest)]);
    
    // basic tests
    WO_TEST([NSObject WOTest_instancesOfClass:[NSLock class] conformToProtocol:@protocol(NSLocking)]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[NSString class] conformToProtocol:@protocol(NSLocking)]);
    WO_TEST([NSObject WOTest_instancesOfClass:[self class] conformToProtocol:@protocol(WOTest)]);
    WO_TEST_FALSE([NSObject WOTest_instancesOfClass:[self class] conformToProtocol:@protocol(NSTextAttachmentCell)]);
    
    // test with subclasses (subclasses should inherit protocol conformance)
    WO_TEST([NSObject WOTest_instancesOfClass:[NSMutableString class] conformToProtocol:@protocol(NSCopying)]);
    
    // should handle custom root classes
    WO_TEST_FALSE
        ([NSObject WOTest_instancesOfClass:NSClassFromString(@"WOLightweightRoot") conformToProtocol:@protocol(NSLocking)]);
}

- (void)testReturnTypeForClassSelector
{
    // raises if passed NULL class or NULL selector
    WO_TEST_THROWS([NSObject WOTest_returnTypeForClass:NULL selector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_returnTypeForClass:NULL selector:@selector(init)]);
    WO_TEST_THROWS([NSObject WOTest_returnTypeForClass:[self class] selector:NULL]);
    
    // raises if passed non-class pointer
    WO_TEST_THROWS([NSObject WOTest_returnTypeForClass:(Class)self selector:@selector(init)]);
    
    // basic test
    WO_TEST_EQ([NSObject WOTest_returnTypeForClass:[self class] selector:@selector(initialize)], @"v");
    
    // returns nil for unrecognized selector
    WO_TEST_EQ([NSObject WOTest_returnTypeForClass:[self class] selector:@selector(poodle)], nil);
}

- (void)testReturnTypeForObjectSelector
{
    // raises if passed nil object or NULL selector
    WO_TEST_THROWS([NSObject WOTest_returnTypeForObject:nil selector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_returnTypeForObject:self selector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_returnTypeForObject:nil selector:@selector(init)]);
    
    // basic test
    WO_TEST_EQ([NSObject WOTest_returnTypeForObject:self selector:@selector(init)], @"@");
    
    // returns nil for unrecognized selector
    WO_TEST_EQ([NSObject WOTest_returnTypeForObject:self selector:@selector(beagle:dog:)], nil);
}

- (void)testIsIdReturnType
{
    WO_TEST([NSObject WOTest_isIdReturnType:@"@"]);
    WO_TEST_FALSE([NSObject WOTest_isIdReturnType:@"v"]);

    // passing nil should return NO, not raise an exception
    WO_TEST_FALSE([NSObject WOTest_isIdReturnType:nil]);
}

- (void)testIsCharacterStringReturnType
{
    WO_TEST([NSObject WOTest_isCharacterStringReturnType:@"*"]);
    WO_TEST_FALSE([NSObject WOTest_isCharacterStringReturnType:@"r*"]);

    // passing nil should return NO, not raise an exception
    WO_TEST_FALSE([NSObject WOTest_isCharacterStringReturnType:nil]);
}

- (void)testIsConstantCharacterStringReturnType
{
    WO_TEST([NSObject WOTest_isConstantCharacterStringReturnType:@"r*"]);
    WO_TEST_FALSE([NSObject WOTest_isConstantCharacterStringReturnType:@"^v"]);
    
    // passing nil should return NO, not raise an exception
    WO_TEST_FALSE([NSObject WOTest_isConstantCharacterStringReturnType:nil]);
}

- (void)testObjectReturnsIdForSelector
{
    // should raise for nil object or NULL selector
    WO_TEST_THROWS([NSObject WOTest_objectReturnsId:nil forSelector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_objectReturnsId:self forSelector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_objectReturnsId:nil forSelector:@selector(init)]);
    
    // basic tests
    WO_TEST([NSObject WOTest_objectReturnsId:self forSelector:@selector(init)]);
    WO_TEST_FALSE([NSObject WOTest_objectReturnsId:self forSelector:@selector(dealloc)]);
    
    // passing unrecognized selector should return NO, not raise an exception
    WO_TEST_FALSE([NSObject WOTest_objectReturnsId:self forSelector:@selector(initWithChicken:)]);
}

- (void)testObjectReturnsCharacterStringForSelector
{
    // should raise for nil object or NULL selector
    WO_TEST_THROWS([NSObject WOTest_objectReturnsCharacterString:nil forSelector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_objectReturnsCharacterString:self forSelector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_objectReturnsCharacterString:nil forSelector:@selector(init)]);
    
    // basic tests
    char *string = "foo";    
    NSValue *value = [NSValue WOTest_valueWithCharacterString:string];
    WO_TEST([NSObject WOTest_objectReturnsCharacterString:value forSelector:@selector(WOTest_characterStringValue)]);
    WO_TEST_FALSE([NSObject WOTest_objectReturnsCharacterString:self forSelector:@selector(init)]);
    
    // passing unrecognized selector should return NO, not raise an exception
    WO_TEST_FALSE([NSObject WOTest_objectReturnsCharacterString:self forSelector:@selector(initWithChicken:)]);
}

- (void)testObjectReturnsConstantCharacterString
{
    // should raise for nil object or NULL selector
    WO_TEST_THROWS([NSObject WOTest_objectReturnsConstantCharacterString:nil forSelector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_objectReturnsConstantCharacterString:self forSelector:NULL]);
    WO_TEST_THROWS([NSObject WOTest_objectReturnsConstantCharacterString:nil forSelector:@selector(init)]);
    
    // basic tests
    NSValue *value      = [NSValue WOTest_valueWithConstantCharacterString:"foobar"];
    SEL     selector    = @selector(WOTest_constantCharacterStringValue);
    WO_TEST([NSObject WOTest_objectReturnsConstantCharacterString:value forSelector:selector]);
    WO_TEST_FALSE([NSObject WOTest_objectReturnsConstantCharacterString:self forSelector:@selector(init)]);
    
    // passing unrecognized selector should return NO, not raise an exception
    WO_TEST_FALSE([NSObject WOTest_objectReturnsConstantCharacterString:self forSelector:@selector(getTurkey)]);
}

@end
