//
//  WOObjectMockTests.m
//  WOTest
//
//  Created by Wincent Colaiuta on 29 January 2006.
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

#import "WOObjectMockTests.h"

@implementation WOObjectMockTests

#pragma mark -
#pragma mark High-level tests

- (void)testMockForClass
{
    // should throw if passed NULL
    WO_TEST_THROWS([WOObjectMock mockForClass:NULL]);

    // should throw if passed non-class pointer
    WO_TEST_THROWS([WOObjectMock mockForClass:(Class)self]);

    // otherwise should work
    WO_TEST_DOES_NOT_THROW([WOObjectMock mockForClass:[self class]]);

    // should throw if passed a meta class
    Class class     = [NSString class];
    Class metaclass = object_getClass(class);
    WO_TEST_THROWS([WOObjectMock mockForClass:metaclass]);
}

- (void)testInitWithClass
{
    // preliminaries
    WOObjectMock *mock = nil;

    // should throw if passed NULL
    mock = [WOObjectMock alloc];
    WO_TEST_THROWS([mock initWithClass:NULL]);
    [mock release];

    // should throw if passed non-class pointer
    mock = [WOObjectMock alloc];
    WO_TEST_THROWS([mock initWithClass:(Class)self]);
    [mock release];

    // otherwise should work
    WO_TEST_DOES_NOT_THROW
        ([[[WOObjectMock alloc] initWithClass:[self class]] autorelease]);

    // should throw if passed a meta class
    Class class     = [NSString class];
    Class metaclass = object_getClass(class);
    mock = [WOObjectMock alloc];
    WO_TEST_THROWS([mock initWithClass:metaclass]);
    [mock release];
}

- (void)testMockExpectInOrder
{
    // basic test
    id mock = [WOObjectMock mockForClass:[NSString class]];

    [[mock expectInOrder] lowercaseString];
    [[mock expectInOrder] uppercaseString];
    [[mock expectInOrder] stringByExpandingTildeInPath];
    [[mock expectInOrder] uppercaseString];

    [mock lowercaseString];
    [mock uppercaseString];
    [mock stringByExpandingTildeInPath];
    [mock uppercaseString];

    WO_TEST_DOES_NOT_THROW([mock verify]);

    // repeat test: this time omit one of the expected methods
    [mock clear];
    [[mock expectInOrder] lowercaseString];
    [[mock expectInOrder] uppercaseString];
    [[mock expectInOrder] stringByAbbreviatingWithTildeInPath];
    [[mock expectInOrder] uppercaseString];

    [mock lowercaseString];
    [mock uppercaseString];
    [mock stringByAbbreviatingWithTildeInPath];

    WO_TEST_THROWS([mock verify]);

    // repeat test: this time invoke methods in wrong order
    [mock clear];
    [[mock expectInOrder] lowercaseString];
    [[mock expectInOrder] uppercaseString];
    [[mock expectInOrder] stringByAbbreviatingWithTildeInPath];
    [[mock expectInOrder] uppercaseString];

    [mock lowercaseString];
    WO_TEST_THROWS([mock stringByAbbreviatingWithTildeInPath]);

    // test with arguments
    [mock clear];
    [[mock expectInOrder] stringByAppendingFormat:@"foobar"];
    [[mock expectInOrder] uppercaseString];
    [[mock expectInOrder] stringByAbbreviatingWithTildeInPath];
    [[mock expectInOrder] uppercaseString];

    [mock stringByAppendingFormat:@"foobar"];
    [mock uppercaseString];
    [mock stringByAbbreviatingWithTildeInPath];
    [mock uppercaseString];

    WO_TEST_DOES_NOT_THROW([mock verify]);

    // repeat test: this time pass unexpected argument
    [mock clear];
    [[mock expectInOrder] stringByAppendingFormat:@"foobar"];
    [[mock expectInOrder] uppercaseString];
    [[mock expectInOrder] stringByAbbreviatingWithTildeInPath];
    [[mock expectInOrder] uppercaseString];

    WO_TEST_THROWS([mock stringByAppendingFormat:@"other"]);

    // test with object return value
    NSValue *value = [NSValue WOTest_valueWithObject:@"foobar"];
    [mock clear];
    [[[mock expectInOrder] returning:value] stringByAppendingString:@"bar"];
    WO_TEST_EQ(@"foobar", [mock stringByAppendingString:@"bar"]);
    WO_TEST_DOES_NOT_THROW([mock verify]);

    // test with scalar return value
    value = [NSValue WOTest_valueWithUnsignedInt:6];
    [mock clear];
    [[[mock expectInOrder] returning:value] length];
    WO_TEST_EQ((unsigned int)6, [mock length]);
    WO_TEST_DOES_NOT_THROW([mock verify]);

    // test with raising exception
    [mock clear];
    [[[mock expectInOrder] raising:self] lowercaseString];
    WO_TEST_THROWS([mock lowercaseString]);

    // test raising named exception
    NSException *exception = [NSException exceptionWithName:@"Robert"
                                                     reason:@"Robert exception"
                                                   userInfo:nil];
    [mock clear];
    [[[mock expectInOrder] raising:exception] lowercaseString];
    WO_TEST_THROWS_EXCEPTION_NAMED([mock lowercaseString], @"Robert");
}

- (void)testMockExpectOnce
{
    // basic test
    id mock = [WOObjectMock mockForClass:[NSString class]];
    [[mock expectOnce] lowercaseString];
    WO_TEST_THROWS([mock verify]); // was bug
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]);
    WO_TEST_THROWS([mock lowercaseString]);
    WO_TEST_DOES_NOT_THROW([mock verify]);

    // test with arguments
    [mock clear];
    [[mock expectOnce] stringByAppendingFormat:@"foo"];
    WO_TEST_THROWS([mock verify]);
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingFormat:@"foo"]);
    WO_TEST_THROWS([mock stringByAppendingFormat:@"bar"]);
    WO_TEST_DOES_NOT_THROW([mock verify]);

    // repeat test: this time pass unexpected argument
    [mock clear];
    [[mock expectOnce] stringByAppendingFormat:@"foo"];
    WO_TEST_THROWS([mock verify]);
    WO_TEST_THROWS([mock stringByAppendingFormat:@"bar"]);
    WO_TEST_THROWS([mock verify]);

    // test with return value
    NSValue *value = [NSValue WOTest_valueWithObject:@"foobar"];
    [mock clear];
    [[[mock expectOnce] returning:value] stringByAppendingString:@"bar"];
    WO_TEST_THROWS([mock verify]);
    WO_TEST_EQ(@"foobar", [mock stringByAppendingString:@"bar"]);
    WO_TEST_DOES_NOT_THROW([mock verify]);

    // test with raising exception
    [mock clear];
    [[[mock expectOnce] raising:self] lowercaseString];
    WO_TEST_THROWS([mock verify]);
    WO_TEST_THROWS([mock lowercaseString]);
    WO_TEST_DOES_NOT_THROW([mock verify]);

    // test raising named exception
    NSException *exception = [NSException exceptionWithName:@"Robert"
                                                     reason:@"Robert exception"
                                                   userInfo:nil];
    [mock clear];
    [[[mock expectOnce] raising:exception] lowercaseString];
    WO_TEST_THROWS([mock verify]);
    WO_TEST_THROWS_EXCEPTION_NAMED([mock lowercaseString], @"Robert");
    WO_TEST_DOES_NOT_THROW([mock verify]);
}

- (void)testMockExpect
{
    // basic test
    id mock = [WOObjectMock mockForClass:[NSString class]];
    [[mock expect] lowercaseString];
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]);
    WO_TEST_DOES_NOT_THROW([mock verify]);
    WO_TEST_THROWS([mock uppercaseString]);

    // test with return value (no parameters)
    NSValue *value = [NSValue WOTest_valueWithObject:@".txt"];
    [mock clear];
    [[[mock expect] returning:value] stringByAppendingPathExtension:@"txt"];
    WO_TEST_EQ([mock stringByAppendingPathExtension:@"txt"], @".txt");
    WO_TEST_DOES_NOT_THROW([mock verify]);

    // test with parameters and return value
    [mock clear];
    value = [NSValue WOTest_valueWithObject:@"foo.txt"];
    [[[mock expect] returning:value] stringByAppendingFormat:@".txt"];
    WO_TEST_EQ([mock stringByAppendingFormat:@".txt"], @"foo.txt");
    WO_TEST_THROWS([mock stringByAppendingFormat:@".m"]); // wrong argument

    // test with parameters but without return value
    [mock clear];
    [[mock expect] stringByAppendingFormat:@".mov"];
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingFormat:@".mov"]);
    WO_TEST_THROWS([mock stringByAppendingFormat:@".mpeg"]);
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingFormat:@".mov"]);
}

- (void)testMockAcceptOnce
{
    // basic test
    id mock = [WOObjectMock mockForClass:[NSString class]];
    [[mock acceptOnce] lowercaseString];
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]);
    WO_TEST_THROWS([mock lowercaseString]);

    // test with arguments
    [mock clear];
    [[mock acceptOnce] stringByAppendingFormat:@"foo"];
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingFormat:@"foo"]);
    WO_TEST_THROWS([mock stringByAppendingFormat:@"foo"]);

    // repeat test: this time pass unexpected argument
    [mock clear];
    [[mock acceptOnce] stringByAppendingFormat:@"foo"];
    WO_TEST_THROWS([mock stringByAppendingFormat:@"bar"]);
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingFormat:@"foo"]);
    WO_TEST_THROWS([mock stringByAppendingFormat:@"foo"]);

    // test with return value
    NSValue *value = [NSValue WOTest_valueWithObject:@"foobar"];
    [mock clear];
    [[[mock acceptOnce] returning:value] stringByAppendingFormat:@"bar"];
    WO_TEST_EQ([mock stringByAppendingFormat:@"bar"], @"foobar");
    WO_TEST_THROWS([mock stringByAppendingFormat:@"bar"]);

    // test raising exception
    [mock clear];
    [[[mock acceptOnce] raising:@"foo"] lowercaseString];
    WO_TEST_THROWS([mock lowercaseString]);

    // test raising named exception
    NSException *exception = [NSException exceptionWithName:@"Robert"
                                                     reason:@"Robert exception"
                                                   userInfo:nil];
    [mock clear];
    [[[mock acceptOnce] raising:exception] lowercaseString];
    WO_TEST_THROWS_EXCEPTION_NAMED([mock lowercaseString], @"Robert");
}

- (void)testMockAccept
{
    // preliminaries
    id mock = nil;

    // should throw (NSString instances do not respond to -stringWithString)
    // they do respond to the +stringWithString class method
    mock = [WOObjectMock mockForClass:[NSString class]];
    WO_TEST_THROWS([[mock accept] stringWithString:@"Hello"]);
    WO_TEST_THROWS([mock stringWithString:@"Hello"]);

    // should throw even for valid selectors if you haven't set them up first
    mock = [WOObjectMock mockForClass:[NSString class]];
    [[mock expect] lowercaseString];        // a valid NSString selector
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]);
    WO_TEST_DOES_NOT_THROW([mock verify]);
    WO_TEST_DOES_NOT_THROW([mock retain]);  // ok (inherited from NSProxy)
    WO_TEST_DOES_NOT_THROW([mock release]); // ok (inherited from NSProxy)
    WO_TEST_THROWS([mock uppercaseString]); // fail (not explicitly expected)

    // should throw for class methods
    mock = [WOObjectMock mockForClass:[NSString class]];
    WO_TEST_THROWS([[mock expect] stringWithString:@"foo"]);
    WO_TEST_THROWS([mock stringWithString:@"foo"]);
}

- (void)testClear
{
    // test that clear actually clears
    id mock = [WOObjectMock mockForClass:[NSString class]];
    [[mock accept] lowercaseString];
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]); // send as many times as
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]); // you like... should work
    [mock clear];
    WO_TEST_THROWS([mock lowercaseString]);         // but fail on clear

    // should be able to clear and re-set the same selector (was a bug)
    [[mock accept] lowercaseString];
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]);
    [mock clear];
    [[mock accept] lowercaseString];
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]);
    [mock clear];

    // same for acceptOnce
    [[mock acceptOnce] lowercaseString];
    [mock clear];
    WO_TEST_THROWS([mock lowercaseString]);

    // expect
    [[mock expect] lowercaseString];
    [mock clear];
    WO_TEST_THROWS([mock lowercaseString]);

    // expectOnce
    [[mock expectOnce] lowercaseString];
    [mock clear];
    WO_TEST_THROWS([mock lowercaseString]);

    // expectInOrder
    [[mock expectInOrder] lowercaseString];
    [mock clear];
    WO_TEST_THROWS([mock lowercaseString]);
}

- (void)testAnyArguments
{
    // by default should require exactly matching arguments
    id mock = [WOObjectMock mockForClass:[NSString class]];
    [[mock accept] stringByAppendingString:@"foo"];
    WO_TEST_THROWS([mock stringByAppendingString:@"bar"]);
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingString:@"foo"]);
    WO_TEST_THROWS([mock stringByAppendingString:nil]);

    // but should also be able to accept any argument
    [mock clear];
    [[[mock accept] anyArguments] stringByAppendingString:@"irrelevant"];
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingString:@"irrelevant"]);
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingString:@"bar"]);
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingString:@"foo"]);
    WO_TEST_DOES_NOT_THROW([mock stringByAppendingString:nil]);
}

- (void)testAcceptsByDefault
{
    id mock = [WOObjectMock mockForClass:[NSString class]];
    [mock setAcceptsByDefault:YES];
    WO_TEST_DOES_NOT_THROW([mock lowercaseString]);

    // unrecognised selector should always throw
    WO_TEST_THROWS(objc_msgSend(mock, @selector(foobar)));

    [mock setAcceptsByDefault:NO];
    WO_TEST_THROWS([mock lowercaseString]);
}

- (void)testReturning
{
    // should work for scalars too
    id mock = [WOObjectMock mockForClass:[NSString class]];
    unsigned int length = 20;
    NSValue *value = [NSValue value:&length withObjCType:@encode(unsigned int)];
    [[[mock accept] returning:value] length];
    WO_TEST_EQ([mock length], length);
    WO_TEST_EQ([mock length], (unsigned int)20);
}

#pragma mark -
#pragma mark Low-level tests

- (void)testMock
{
    // preliminaries
    Class aClass = [self class];

    // should raise if passed nil class
    WO_TEST_THROWS([WOObjectMock mockForClass:nil]);
    WO_TEST_THROWS([[[WOObjectMock alloc] initWithClass:nil] release]);
    WO_TEST_DOES_NOT_THROW([WOObjectMock mockForClass:aClass]);
    WO_TEST_DOES_NOT_THROW([[[WOObjectMock alloc] initWithClass:aClass] release]);

    // test if passed a non-class object (ie. an instance)

    //
}

- (void)testObjectStub
{
    // preliminaries
    id      stub    = nil;
    Class   aClass  = [self class];

    // raise if initialized with nil class pointer
    WO_TEST_DOES_NOT_THROW([WOObjectStub stubForClass:aClass withDelegate:nil]);
    WO_TEST_THROWS([WOObjectStub stubForClass:nil withDelegate:nil]);
    WO_TEST_DOES_NOT_THROW([[[WOObjectStub alloc] initWithClass:aClass delegate:nil] release]);
    WO_TEST_THROWS([[[WOObjectStub alloc] initWithClass:nil delegate:nil] release]);

    // test if passed a non-class object (ie. an instance)



    // shouldn't crash even if passed non-NSObject descendant


    // test hashes

    // make sure methodSignatureForSelector: doesn't go into an infinite loop
    stub = [WOObjectStub stubForClass:[WOObjectStub class] withDelegate:nil];
    SEL selector = @selector(methodSignatureForSelector:);
    WO_TEST_EQUAL([stub methodSignatureForSelector:selector], nil);

    // not with subclasses either


    // raise if returning: is invoked twice
    stub = [WOObjectStub stubForClass:[NSString class] withDelegate:nil];
    [stub lowercaseString];
    WO_TEST_DOES_NOT_THROW([stub returning:@"foo"]);
    WO_TEST_THROWS([stub returning:@"bar"]);

    // raise if sent new message when message previously recorded
    stub = [WOObjectStub stubForClass:[NSString class] withDelegate:nil];
    WO_TEST_DOES_NOT_THROW([stub lowercaseString]);
    WO_TEST_THROWS([stub lowercaseString]);

    // raise if recordedInvocation called but no message previously recorded
    WO_TEST_DOES_NOT_THROW(stub = [WOObjectStub stubForClass:aClass withDelegate:nil]);
    WO_TEST_THROWS([stub recordedInvocation]);

    // test automatic verify on dealloc
}

- (void)testStubEquality
{
    WOObjectStub *stub        = nil;
    WOObjectStub *otherStub   = nil;
    Class   aClass      = [self class];

    // pointer equality
    stub = [WOObjectStub stubForClass:aClass withDelegate:nil];
    WO_TEST_EQUAL(stub, stub);
    WO_TEST_TRUE([stub isEqual:stub]); // another way to write the same test

    // compare against non-stub class
    stub = [WOObjectStub stubForClass:aClass withDelegate:nil];
    otherStub = (WOObjectStub *)@"foobar";
    WO_TEST_NOT_EQUAL(stub, otherStub);
    WO_TEST_FALSE([stub isEqual:otherStub]);

    // comparison with nil
    stub = [WOObjectStub stubForClass:aClass withDelegate:nil];
    WO_TEST_NOT_EQUAL(stub, nil);
    WO_TEST_NOT_EQUAL(nil, stub);
    WO_TEST_FALSE([stub isEqual:nil]);

    // same class, different instance
    stub = [WOObjectStub stubForClass:aClass withDelegate:nil];
    otherStub = [WOObjectStub stubForClass:aClass withDelegate:nil];
    WO_TEST_EQUAL(stub, otherStub);
    WO_TEST_TRUE([stub isEqual:otherStub]);

    // stubs with mismatching classes
    stub = [WOObjectStub stubForClass:aClass withDelegate:nil];
    otherStub = [WOObjectStub stubForClass:[NSString class] withDelegate:nil];
    WO_TEST_NOT_EQUAL(stub, otherStub);
    WO_TEST_FALSE([stub isEqual:otherStub]);

    // mismatching invocations

    // mismatching return values


}

- (void)testNonExistentSelector
{
    WO_TEST_START;

    id mock = [WOObjectMock mockForClass:[NSString class]];
    [mock setObjCTypes:@"@@:@" forSelector:@selector(totallyRandom:)];

    // this causes a compiler warning
    //[[[mock expect] returning:[NSValue WOTest_valueWithObject:@"bar"]] totallyRandom:@"foo"];

#ifdef PENDING_MOCK_REWRITE_FOR_LEOPARD
    // so do it this way instead
    id stub = [[mock expect] returning:[NSValue WOTest_valueWithObject:@"bar"]];

    // Here we die with:
    //   NSInvalidArgumentException: *** -[NSProxy doesNotRecognizeSelector:totallyRandom:] called!
    // Setting breakpoints reveals that the -forward:: method of WOMock is not called anymore.
    // So will have to change the way WOMock/WOObjectMock works on Leopard.
    objc_msgSend(stub, @selector(totallyRandom:), @"foo");

    // likewise, this causes a warning
    //WO_TEST_EQ([mock totallyRandom:@"foo"], @"bar");

    // so do it like this:
    WO_TEST_EQ(objc_msgSend(mock, @selector(totallyRandom:), @"foo"), @"bar");
#endif /* PENDING_MOCK_REWRITE_FOR_LEOPARD */
}

// methods for finding out what's going on in margs_list
- (void)testStructReturn
{

}

- (void)testStructParameter
{

}

- (void)testFloatParameter
{

}

@end
