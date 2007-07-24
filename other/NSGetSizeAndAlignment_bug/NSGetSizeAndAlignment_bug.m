// Testcase for: rdar://problem/5357040

#import <Foundation/Foundation.h>

typedef struct StructWithBitfield {
    int bitfield_a : 3;
    int bitfield_b : 5;
} StructWithBitfield;

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // here we die with an uncaught exception:
    // *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'NSGetSizeAndAlignment(): unsupported type encoding spec 'b' at 'b3b5}' in '{StructWithBitfield=b3b5}''
    StructWithBitfield myStruct;
    [NSValue valueWithBytes:&myStruct objCType:@encode(StructWithBitfield)];

    [pool drain];
    return 0;
}
