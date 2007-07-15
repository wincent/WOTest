//
//  WOMock.h
//  WOTest
//
//  Created by Wincent Colaiuta on 14 June 2005.
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

/*! 

There are a small number of methods defined in the WOMock class that you can use to create a mock object and then tell it how to behave. The accept, acceptOnce, reject, expect, expectOnce methods tell the mock object which selectors to accept, reject and expect. 

Each of these methods returns an object of type id which allows you to chain selectors together using the standard Objective-C pattern:

\code
[[mock accept] anotherMethod];
\endcode

The mocked class must at least implement the NSObject method, instanceMethodSignatureForSelector:.

*/
@interface WOMock : NSProxy {

    /*! Selectors that should be accepted. */
    NSMutableSet            *accepted;
    
    /*! Selectors that should be accepted once only. */
    NSMutableSet            *acceptedOnce;
    
    /*! Selectors that should be expected. */
    NSMutableSet            *expected;
    
    /*! Selectors that should be expected once only. */
    NSMutableSet            *expectedOnce;
    
    /*! Selectors that should be expected in a specific order. */
    NSMutableArray          *expectedInOrder;

    /*! Selectors that should be rejected. */
    NSMutableSet            *rejected; 
    
    NSMutableDictionary     *methodSignatures;
    
    BOOL                    acceptsByDefault;
}

#pragma mark -
#pragma mark Creation

/*! Convenience initializer that returns the appropriate subclass. This message should only be sent to the WOMock class, never to one of its subclasses; sending it to a subclass raises an exception. */
+ (id)mockForObjectClass:(Class)aClass;

/*! Convenience initializer that returns the appropriate subclass. This message should only be sent to the WOMock class, never to one of its subclasses; sending it to a subclass raises an exception. */
+ (id)mockForClass:(Class)aClass;

/*! Convenience initializer that returns the appropriate subclass. This message should only be sent to the WOMock class, never to one of its subclasses; sending it to a subclass raises an exception. */
+ (id)mockForProtocol:(Protocol *)aProtocol;

/*! Convenience initializer that returns the appropriate subclass. This message should only be sent to the WOMock class, never to one of its subclasses; sending it to a subclass raises an exception. */
- (id)initWithObjectClass:(Class)aClass;

/*! Convenience initializer that returns the appropriate subclass. This message should only be sent to the WOMock class, never to one of its subclasses; sending it to a subclass raises an exception. */
- (id)initWithClass:(Class)aClass;

/*! Convenience initializer that returns the appropriate subclass. This message should only be sent to the WOMock class, never to one of its subclasses; sending it to a subclass raises an exception. */
- (id)initWithProtocol:(Protocol *)aProtocol;

/*! Basic initizialer available for use by subclasses. Do not call directly. */
- (id)init;

#pragma mark -
#pragma mark Recording expectations

/*!
\name Recording

 These are recording methods used for setting up expectations about which selectors should be rejected, accepted, accepted once, expected, expected once, or expected in order.

 When the mock receives a message it checks its internal lists in the following order (in order of decreasing specificity):
 
 -# rejected
 -# expected in order
 -# expected once
 -# expected
 -# accepted once
 -# accepted

 Rejected selectors cause an exception to be raised.
 
 By default, if a selector does not appear in any of the internal lists an exception is raised. This latter behaviour requires you to be explicit about <em>all</em> selectors which a mock object may receive. For example, you may have a mock object that stands in for an NSString instance and expect that it be sent a "lowercaseString" selector. If during your test you also send an "uppercaseString" selector then an exception will be raised (because the selector does not appear in the internal lists, even though it is a valid NSString selector). A small number of methods will be accepted even without being explicitly added the the lists; these include methods like retain and release and other NSObject protocol methods. These are accepted because they are inherited from the parent class of WOMock (NSProxy).
 
 If you wish to override this behaviour you may send the setAcceptsByDefault message passing a flag of YES, but be aware that selectors which fall through to the "accepts by default" cannot return any defined value. For control over return values the selector in question must be explicitly set up with the expectInOrder, expectOnce, expect, acceptOnce or accept methods.
 
 If a selector does appear in the lists but has been set to throw an exception an exception will be raised. It is the responsibility of the caller to avoid ambiguous list membership; for example, it does not make any sense to add a selector to both the "expected once" and the "accepted" lists.
 
 \startgroup
*/

/*! Instructs the receiver to accept a selector. The following example shows how to instruct the WOMock instance mock to accept the connect selector:
    
\code
[[mock accept] connect];
\endcode

If the selector takes arguments then the arguments passed to the mock must match those used when registering the selector with the accept method, otherwise an exception is raised. To override this behaviour and force the mock object to accept any arguments you can send an anyArguments selector as shown in the following example:

\code
[[mock accept] connectTo:server] anyArguments];
\endcode
    
You can explicitly instruct a mock to reject selectors by using the reject method. Selectors added with the accept method will be accepted by the receiver at any time, in any order, until removed with the reject method.

See the WOMockTests class in WOTestSelfTests for usage examples.
    
\see WOStub::anyArguments */
- (id)accept;

/*! Instructs the receiver to accept the selector once and only once. If the selector is performed twice then the second invocation will cause an exception to be raised.

\see accept */
- (id)acceptOnce;

/*! Instructs the receiver to reject a selector that may or may not have been previously added using the accept, acceptOnce, expect or expectOnce methods. Subsequent attempts to send the rejected selector will cause an exception to be raised. The following example shows how to instruct the WOMock instance mock to reject the connect selector:

\code
[[mock reject] connect];
\endcode

 */
- (id)reject;

/*! Instructs the receiver to expect a selector; the receiver not only accepts the selector but it actually requires that it be sent. If the expected selector has not been received when the verify method is called (or at dealloc time) then an exception will be raised. The following example shows how to instruct the WOMock instance mock to expect the disconnect selector:

\code
[[mock expect] disconnect];
\endcode

If the selector takes arguments then the arguments passed to the mock must match those used when registering the selector with the expect method, otherwise an exception is raised. */
- (id)expect;

/*! Instructs the receiver to expect the selector once and only once. If the selector is performed twice then the second invocation will cause an exception to be raised. 

\see accept */
- (id)expectOnce;

/*! Instructs the receiver to expect the selector as part of an ordered sequence. You can build a list of expected selectors by repeatedly calling expectInOrder with the selectors that should appear in the sequence as illustrated in this example:
    
\code
[[mock expectInOrder] connect];
[[mock expectInOrder] logStats];
[[mock expectInOrder] refreshServerList];
[[mock expectInOrder] logStats];
[[mock expectInOrder] disconnect];
\endcode

 */
- (id)expectInOrder;

/*! Instructs the receive to immediately remove all selectors previously registered with expect, expectOnce, expectInOrder, acceptOnce, accept or reject. */
- (void)clear;

/*! \endgroup */

/*! Verifies that all selectors registered with the expect method have been performed. If any have not then an exception is raised. The verify method is automatically called at dealloc time, although you may still wish to invoke it manually. */
- (void)verify;

#pragma mark -
#pragma mark Utility methods

- (void)storeReturnValue:(NSValue *)aValue forInvocation:(NSInvocation *)invocation;

//! Example type strings:
//! - NSMethodSignature: types=@@:@ nargs=3 sizeOfParams=12 returnValueLength=4; (NSString -initWithString)
//! - NSMethodSignature: types=@@::@@ nargs=5 sizeOfParams=20 returnValueLength=4; (NSObject -performSelector:withObject:withObject:)
//! - NSMethodSignature: types=d@: nargs=2 sizeOfParams=8 returnValueLength=8;  (NSNumber -doubleValue)
//! - NSMethodSignature: types=@@:@ nargs=3 sizeOfParams=12 returnValueLength=4; (NSString -initWIthFormat)
//! - NSMethodSignature: types=@@:@@@ nargs=5 sizeOfParams=20 returnValueLength=4; (NSException -initWithName:reason:userInfo:)
- (void)setObjCTypes:(NSString *)types forSelector:(SEL)aSelector;

#pragma mark -
#pragma mark Accessors

//! \name  Accessor methods 
//! Note that the majority of instance variables in this class do not have accessors so as to avoid namespace pollution.
//! \startgroup 

- (BOOL)acceptsByDefault;
- (void)setAcceptsByDefault:(BOOL)flag;

//! Provided so that stubs can query their delegates (mocks) for information about unimplemented selectors.
- (NSMutableDictionary *)methodSignatures;

//! \endgroup

@end
