#import "DvdTesting.h"
#import <DVDKit/DVDKit.h>

@implementation DvdTesting

- (void) testDecodingAndDescriptions
{
    DVDCommand* command;
    
    //  0000000000000000 | Nop
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x00\x00\x00\x00\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      0000000000000000 | Nop"], @"Instruction not decoded properly.");
    
    //  000100000000000a | Goto 10
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x01\x00\x00\x00\x00\x00\x0a" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      000100000000000a | Goto 10"], @"Instruction not decoded properly.");

    //  0002000000000000 | Break
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x02\x00\x00\x00\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      0002000000000000 | Break"], @"Instruction not decoded properly.");

    //  0021000600020007 | if (g[6] == g[2]) Goto 7
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x21\x00\x06\x00\x02\x00\x07" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      0021000600020007 | if (g[6] == g[2]) Goto 7"], @"Instruction not decoded properly.");    
    
    //  0041000200050006 | if (g[2] >= g[5]) Goto 6
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x41\x00\x02\x00\x05\x00\x06" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      0041000200050006 | if (g[2] >= g[5]) Goto 6"], @"Instruction not decoded properly.");    
    
    //  0091000a00020008 | if (g[10] & 0x2) Goto 8
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x91\x00\x0a\x00\x02\x00\x08" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      0091000a00020008 | if (g[10] & 0x2) Goto 8"], @"Instruction not decoded properly.");    
    
    //  7100000D43210000 | g[13] = 0x4321
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x71\x00\x00\x0D\x43\x21\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      7100000d43210000 | g[13] = 0x4321 (\"C!\")"], @"Instruction not decoded properly.");
    
    //  7100000000000000 | g[0] = 0x0
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x71\x00\x00\x00\x00\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      7100000000000000 | g[0] = 0x0"], @"Instruction not decoded properly.");
}

@end
