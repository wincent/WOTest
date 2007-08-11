#import <Foundation/Foundation.h>

// ********** START TEST CASE (<rdar://problem/5403996>) **********

// "public" interface: where bar is declared readonly, copy
@interface Foo : NSObject {
    NSString *bar;
}
@property(readonly, copy) NSString *bar;
@end

// "private" interface: where bar is redeclared readwrite
@interface Foo ()
@property(readwrite) NSString *bar;
/*

 The preceding property redeclaration generates the following warnings:

 warning: no 'assign', 'retain', or 'copy' attribute is specified - 'assign' is assumed
 warning: 'assign' attribute (default) not appropriate for non-gc object property 'bar'
 warning: property 'bar' attribute in 'Foo' class continuation does not match class 'Foo' property

 In order to make the warnings go away the copy attribute must be explicitly carried over to the redeclaration:

 @property(readwrite, copy) NSString *bar;

 So here we either have a compiler bug or a documentation bug, because the documentation states:

 "You can re-declare properties in a subclass, and you can repeat properties' attributes in whole or in part"
 "The same holds true for properties declared in a category"
 "the property's attributes must only be repeated in whole or part"

 Which would imply that explicitly repeating the "copy" attribute should not be necessary.

 */
@end

// implementation
@implementation Foo
@synthesize bar;
@end

// ********** END TEST CASE **********

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSLog(@"Hello, World!");
    [pool drain];
    return 0;
}
