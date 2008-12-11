#import "DvdTesting.h"
#import <DVDKit/DVDKit.h>
#import "DVDVirtualMachine.h"

@implementation DvdTesting

- (void) testDecodingAndDescriptions
{
    DVDCommand* command;
    
    //  0000000000000000 | Nop
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x00\x00\x00\x00\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      0000000000000000 | Nop"], @"Instruction not decoded properly.");
    
	
	
		
	// 0001000000000008 | Goto 8
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x01\x00\x00\x00\x00\x00\x08" length:8 freeWhenDone:NO]];
    printf("Testing:  %@\n",[command description]);
	STAssertTrue([[command description] isEqualTo:@"   0001000000000008 | Goto 8"], @"Instruction not decoded properly.");
	
	// 0001000000000009 | Goto 9
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x01\x00\x00\x00\x00\x00\x09" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      000100000000000a | Goto 9"], @"Instruction not decoded properly.");
	
	// 000100000000000a | Goto 10
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\x01\x00\x00\x00\x00\x00\x0a" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      000100000000000a | Goto 10"], @"Instruction not decoded properly.");
	
	
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
    
	
	// 00a1000000140005 | if (g[0] == 0x14) Goto 5
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\xa1\x00\x00\x00\x14\x00\x05" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      00a1000000140005 | if (g[0] == 0x14) Goto 5"], @"Instruction not decoded properly.");    
    
	// 00a1000100010004 | if (g[1] == 0x1) Goto 4
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\xa1\x00\x01\x00\x01\x00\x04" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"     00a1000100010004 | if (g[1] == 0x1) Goto 4"], @"Instruction not decoded properly.");    
    
	
	// 00a1000100010005 | if (g[1] == 0x1) Goto 5
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\xa1\x00\x01\x00\x01\x00\x05" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"     00a1000100010005 | if (g[1] == 0x1) Goto 5"], @"Instruction not decoded properly.");    
    
	// 00b10009001f0044 | if (g[9] != 0x1f) Goto 68
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x00\xb1\x00\x09\x00\x1f\x00\x44" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"     00b10009001f0044 | if (g[9] != 0x1f) Goto 68"], @"Instruction not decoded properly.");    
    
	
	// 200400000000000a | LinkPGCN 10
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x20\x04\x00\x00\x00\x00\x00\x0a" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"     200400000000000a | LinkPGCN 10"], @"Instruction not decoded properly.");    
    
	
	
	// 2006000000000407 | LinkPGN 7 (button 1)
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x20\x06\x00\x00\x00\x00\x04\x07" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"	 2006000000000407 | LinkPGN 7 (button 1)"], @"Instruction not decoded properly.");    
    
	
	// 20f4000900640006 | if (g[9] < 0x64) LinkPGCN 6
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x20\xf4\x00\x09\x00\x64\x00\x06" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"	  20f4000900640006 | if (g[9] < 0x64) LinkPGCN 6"], @"Instruction not decoded properly.");    
    
	
	
	// 3001000000000000 | Exit
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x30\x01\x00\x00\x00\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"	  3001000000000000 | Exit"], @"Instruction not decoded properly.");    
    
	
	// 3025001000010001 | if (g[0] == g[1]) JumpVTS_PTT 1:16
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x30\x25\x00\x10\x00\x01\x00\x01" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"	  3025001000010001 | if (g[0] == g[1]) JumpVTS_PTT 1:16"], @"Instruction not decoded properly.");    
    
	
	// 4100000086000000 | Sub-picture Stream Number (SRPM:2) = g[6]
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x41\x00\x00\x00\x86\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"	  4100000086000000 | Sub-picture Stream Number (SRPM:2) = g[6]"], @"Instruction not decoded properly.");    
    
	
	
	
	// 5600000008000000 | Highlighted Button Number (SRPM:8) = 0x800 (button 2)
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x56\x00\x00\x00\x08\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      5600000008000000 | Highlighted Button Number (SRPM:8) = 0x800 (button 2)"], @"Instruction not decoded properly.");
    
	
	
	
	// 6100000900810000 | g[9] = Audio Stream Number (SRPM:1)
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x61\x00\x00\x09\x00\x81\x00\x00" length:8 freeWhenDone:NO]];
    printf("command:  %@\n",[command description]);
	STAssertTrue([[command description] isEqualTo:@"     6100000900810000 | g[9] = Audio Stream Number (SRPM:1)"], @"Instruction not decoded properly.");
    
	
	
	
	// 7100000100130000 | g[1] = 0x13
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x71\x00\x00\x01\x00\x13\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      7100000100130000 | g[1] = 0x13"], @"Instruction not decoded properly.");
    
	
	
	
	
    //  7100000D43210000 | g[13] = 0x4321
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x71\x00\x00\x0D\x43\x21\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      7100000d43210000 | g[13] = 0x4321 (\"C!\")"], @"Instruction not decoded properly.");
    
    //  7100000000000000 | g[0] = 0x0
	command = [DVDCommand commandWithData:[NSData dataWithBytesNoCopy:"\x71\x00\x00\x00\x00\x00\x00\x00" length:8 freeWhenDone:NO]];
    STAssertTrue([[command description] isEqualTo:@"      7100000000000000 | g[0] = 0x0"], @"Instruction not decoded properly.");
	
	
	
	
}

@end
