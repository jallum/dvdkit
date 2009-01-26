#import "UnitTests.h"
#import <DVDKit/DVDKit.h>
#import "DKFileHandleDataSource.h"
#import <DVDKit/DKTitleTrackSearchPointer.h>
#import "DKDataDataSource.h"

@implementation UnitTests

- (void) testDecodingAndDescriptions
{
    DKCommand* command;
	
    //0000000000000000 | Nop
    command = [DKCommand commandWith64Bits:0x0000000000000000L];
    STAssertTrue([[command description] isEqualTo:@"      0000000000000000 | Nop"], @"Instruction not decoded properly.");
    
    //000100000000000d | Goto 13
    command = [DKCommand commandWith64Bits:0x000100000000000dL];
    STAssertTrue([[command description] isEqualTo:@"      000100000000000d | Goto 13"], @"Instruction not decoded properly.");
    
    //0041000d00050004 | if (g[13] >= g[5]) Goto 4
    command = [DKCommand commandWith64Bits:0x0041000d00050004L];
    STAssertTrue([[command description] isEqualTo:@"      0041000d00050004 | if (g[13] >= g[5]) Goto 4"], @"Instruction not decoded properly.");
    
    //0091000a00040014 | if (g[10] & 0x4) Goto 20
    command = [DKCommand commandWith64Bits:0x0091000a00040014L];
    STAssertTrue([[command description] isEqualTo:@"      0091000a00040014 | if (g[10] & 0x4) Goto 20"], @"Instruction not decoded properly.");
    
    //0091000a0020000c | if (g[10] & 0x20) Goto 12
    command = [DKCommand commandWith64Bits:0x0091000a0020000cL];
    STAssertTrue([[command description] isEqualTo:@"      0091000a0020000c | if (g[10] & 0x20) Goto 12"], @"Instruction not decoded properly.");
    
    //0091000a04000004 | if (g[10] & 0x400) Goto 4
    command = [DKCommand commandWith64Bits:0x0091000a04000004L];
    STAssertTrue([[command description] isEqualTo:@"      0091000a04000004 | if (g[10] & 0x400) Goto 4"], @"Instruction not decoded properly.");
    
    //00a1000100010006 | if (g[1] == 0x1) Goto 6
    command = [DKCommand commandWith64Bits:0x00a1000100010006L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000100010006 | if (g[1] == 0x1) Goto 6"], @"Instruction not decoded properly.");
    
    //00a100083000000b | if (g[8] == 0x3000) Goto 11
    command = [DKCommand commandWith64Bits:0x00a100083000000bL];
    STAssertTrue([[command description] isEqualTo:@"      00a100083000000b | if (g[8] == 0x3000) Goto 11"], @"Instruction not decoded properly.");
    
    //00a1000900020025 | if (g[9] == 0x2) Goto 37
    command = [DKCommand commandWith64Bits:0x00a1000900020025L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000900020025 | if (g[9] == 0x2) Goto 37"], @"Instruction not decoded properly.");
    
    //00a1000900050028 | if (g[9] == 0x5) Goto 40
    command = [DKCommand commandWith64Bits:0x00a1000900050028L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000900050028 | if (g[9] == 0x5) Goto 40"], @"Instruction not decoded properly.");
    
    //00a100090009002c | if (g[9] == 0x9) Goto 44
    command = [DKCommand commandWith64Bits:0x00a100090009002cL];
    STAssertTrue([[command description] isEqualTo:@"      00a100090009002c | if (g[9] == 0x9) Goto 44"], @"Instruction not decoded properly.");
    
    //00a10009000f0003 | if (g[9] == 0xf) Goto 3
    command = [DKCommand commandWith64Bits:0x00a10009000f0003L];
    STAssertTrue([[command description] isEqualTo:@"      00a10009000f0003 | if (g[9] == 0xf) Goto 3"], @"Instruction not decoded properly.");
    
    //00a1000900130003 | if (g[9] == 0x13) Goto 3
    command = [DKCommand commandWith64Bits:0x00a1000900130003L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000900130003 | if (g[9] == 0x13) Goto 3"], @"Instruction not decoded properly.");
    
    //00a1000900170003 | if (g[9] == 0x17) Goto 3
    command = [DKCommand commandWith64Bits:0x00a1000900170003L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000900170003 | if (g[9] == 0x17) Goto 3"], @"Instruction not decoded properly.");
    
    //00a10009001c0003 | if (g[9] == 0x1c) Goto 3
    command = [DKCommand commandWith64Bits:0x00a10009001c0003L];
    STAssertTrue([[command description] isEqualTo:@"      00a10009001c0003 | if (g[9] == 0x1c) Goto 3"], @"Instruction not decoded properly.");
    
    //00a1000900210038 | if (g[9] == 0x21) Goto 56
    command = [DKCommand commandWith64Bits:0x00a1000900210038L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000900210038 | if (g[9] == 0x21) Goto 56"], @"Instruction not decoded properly.");
    
    //00a1000900250003 | if (g[9] == 0x25) Goto 3
    command = [DKCommand commandWith64Bits:0x00a1000900250003L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000900250003 | if (g[9] == 0x25) Goto 3"], @"Instruction not decoded properly.");
    
    //00a100091000000c | if (g[9] == 0x1000) Goto 12
    command = [DKCommand commandWith64Bits:0x00a100091000000cL];
    STAssertTrue([[command description] isEqualTo:@"      00a100091000000c | if (g[9] == 0x1000) Goto 12"], @"Instruction not decoded properly.");
    
    //00a100091200001c | if (g[9] == 0x1200) Goto 28
    command = [DKCommand commandWith64Bits:0x00a100091200001cL];
    STAssertTrue([[command description] isEqualTo:@"      00a100091200001c | if (g[9] == 0x1200) Goto 28"], @"Instruction not decoded properly.");
    
    //00a100093000001d | if (g[9] == 0x3000) Goto 29
    command = [DKCommand commandWith64Bits:0x00a100093000001dL];
    STAssertTrue([[command description] isEqualTo:@"      00a100093000001d | if (g[9] == 0x3000) Goto 29"], @"Instruction not decoded properly.");
    
    //00a1000940000009 | if (g[9] == 0x4000) Goto 9
    command = [DKCommand commandWith64Bits:0x00a1000940000009L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000940000009 | if (g[9] == 0x4000) Goto 9"], @"Instruction not decoded properly.");
    
    //00a1000960000031 | if (g[9] == 0x6000) Goto 49
    command = [DKCommand commandWith64Bits:0x00a1000960000031L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000960000031 | if (g[9] == 0x6000) Goto 49"], @"Instruction not decoded properly.");
    
    //00a1000980000010 | if (g[9] == 0x8000) Goto 16
    command = [DKCommand commandWith64Bits:0x00a1000980000010L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000980000010 | if (g[9] == 0x8000) Goto 16"], @"Instruction not decoded properly.");
    
    //00a10009ce00000a | if (g[9] == 0xce00) Goto 10
    command = [DKCommand commandWith64Bits:0x00a10009ce00000aL];
    STAssertTrue([[command description] isEqualTo:@"      00a10009ce00000a | if (g[9] == 0xce00) Goto 10"], @"Instruction not decoded properly.");
    
    //00a1000e2f010004 | if (g[14] == 0x2f01) Goto 4
    command = [DKCommand commandWith64Bits:0x00a1000e2f010004L];
    STAssertTrue([[command description] isEqualTo:@"      00a1000e2f010004 | if (g[14] == 0x2f01) Goto 4"], @"Instruction not decoded properly.");
    
    //00a2000900100000 | if (g[9] == 0x10) Break
    command = [DKCommand commandWith64Bits:0x00a2000900100000L];
    STAssertTrue([[command description] isEqualTo:@"      00a2000900100000 | if (g[9] == 0x10) Break"], @"Instruction not decoded properly.");
    
    //00a2000900180000 | if (g[9] == 0x18) Break
    command = [DKCommand commandWith64Bits:0x00a2000900180000L];
    STAssertTrue([[command description] isEqualTo:@"      00a2000900180000 | if (g[9] == 0x18) Break"], @"Instruction not decoded properly.");
    
    //00b1000010000009 | if (g[0] != 0x1000) Goto 9
    command = [DKCommand commandWith64Bits:0x00b1000010000009L];
    STAssertTrue([[command description] isEqualTo:@"      00b1000010000009 | if (g[0] != 0x1000) Goto 9"], @"Instruction not decoded properly.");
    
    //00b100040003001c | if (g[4] != 0x3) Goto 28
    command = [DKCommand commandWith64Bits:0x00b100040003001cL];
    STAssertTrue([[command description] isEqualTo:@"      00b100040003001c | if (g[4] != 0x3) Goto 28"], @"Instruction not decoded properly.");
    
    //00b1000900000003 | if (g[9] != 0x0) Goto 3
    command = [DKCommand commandWith64Bits:0x00b1000900000003L];
    STAssertTrue([[command description] isEqualTo:@"      00b1000900000003 | if (g[9] != 0x0) Goto 3"], @"Instruction not decoded properly.");
    
    //00b100090000003f | if (g[9] != 0x0) Goto 63
    command = [DKCommand commandWith64Bits:0x00b100090000003fL];
    STAssertTrue([[command description] isEqualTo:@"      00b100090000003f | if (g[9] != 0x0) Goto 63"], @"Instruction not decoded properly.");
    
    //00b100090004000e | if (g[9] != 0x4) Goto 14
    command = [DKCommand commandWith64Bits:0x00b100090004000eL];
    STAssertTrue([[command description] isEqualTo:@"      00b100090004000e | if (g[9] != 0x4) Goto 14"], @"Instruction not decoded properly.");
    
    //00b1000900090018 | if (g[9] != 0x9) Goto 24
    command = [DKCommand commandWith64Bits:0x00b1000900090018L];
    STAssertTrue([[command description] isEqualTo:@"      00b1000900090018 | if (g[9] != 0x9) Goto 24"], @"Instruction not decoded properly.");
    
    //00b10009000f0024 | if (g[9] != 0xf) Goto 36
    command = [DKCommand commandWith64Bits:0x00b10009000f0024L];
    STAssertTrue([[command description] isEqualTo:@"      00b10009000f0024 | if (g[9] != 0xf) Goto 36"], @"Instruction not decoded properly.");
    
    //00b100090014002e | if (g[9] != 0x14) Goto 46
    command = [DKCommand commandWith64Bits:0x00b100090014002eL];
    STAssertTrue([[command description] isEqualTo:@"      00b100090014002e | if (g[9] != 0x14) Goto 46"], @"Instruction not decoded properly.");
    
    //00b1000900190038 | if (g[9] != 0x19) Goto 56
    command = [DKCommand commandWith64Bits:0x00b1000900190038L];
    STAssertTrue([[command description] isEqualTo:@"      00b1000900190038 | if (g[9] != 0x19) Goto 56"], @"Instruction not decoded properly.");
    
    //00b1000900200046 | if (g[9] != 0x20) Goto 70
    command = [DKCommand commandWith64Bits:0x00b1000900200046L];
    STAssertTrue([[command description] isEqualTo:@"      00b1000900200046 | if (g[9] != 0x20) Goto 70"], @"Instruction not decoded properly.");
    
    //00b1000900250050 | if (g[9] != 0x25) Goto 80
    command = [DKCommand commandWith64Bits:0x00b1000900250050L];
    STAssertTrue([[command description] isEqualTo:@"      00b1000900250050 | if (g[9] != 0x25) Goto 80"], @"Instruction not decoded properly.");
    
    //00b1000f03e7000d | if (g[15] != 0x3e7) Goto 13
    command = [DKCommand commandWith64Bits:0x00b1000f03e7000dL];
    STAssertTrue([[command description] isEqualTo:@"      00b1000f03e7000d | if (g[15] != 0x3e7) Goto 13"], @"Instruction not decoded properly.");
    
    //00d100030002000f | if (g[3] > 0x2) Goto 15
    command = [DKCommand commandWith64Bits:0x00d100030002000fL];
    STAssertTrue([[command description] isEqualTo:@"      00d100030002000f | if (g[3] > 0x2) Goto 15"], @"Instruction not decoded properly.");
    
    //00d1000400020014 | if (g[4] > 0x2) Goto 20
    command = [DKCommand commandWith64Bits:0x00d1000400020014L];
    STAssertTrue([[command description] isEqualTo:@"      00d1000400020014 | if (g[4] > 0x2) Goto 20"], @"Instruction not decoded properly.");
    
    //00d1000900280056 | if (g[9] > 0x28) Goto 86
    command = [DKCommand commandWith64Bits:0x00d1000900280056L];
    STAssertTrue([[command description] isEqualTo:@"      00d1000900280056 | if (g[9] > 0x28) Goto 86"], @"Instruction not decoded properly.");
    
    //00e1000500ff0006 | if (g[5] <= 0xff) Goto 6
    command = [DKCommand commandWith64Bits:0x00e1000500ff0006L];
    STAssertTrue([[command description] isEqualTo:@"      00e1000500ff0006 | if (g[5] <= 0xff) Goto 6"], @"Instruction not decoded properly.");
    
    //2001000000000407 | LinkPrevPG (button 1)
    command = [DKCommand commandWith64Bits:0x2001000000000407L];
    STAssertTrue([[command description] isEqualTo:@"      2001000000000407 | LinkPrevPG (button 1)"], @"Instruction not decoded properly.");
    
    //2001000000001c06 | LinkNextPG (button 7)
    command = [DKCommand commandWith64Bits:0x2001000000001c06L];
    STAssertTrue([[command description] isEqualTo:@"      2001000000001c06 | LinkNextPG (button 7)"], @"Instruction not decoded properly.");
    
    //2004000000000005 | LinkPGCN 5
    command = [DKCommand commandWith64Bits:0x2004000000000005L];
    STAssertTrue([[command description] isEqualTo:@"      2004000000000005 | LinkPGCN 5"], @"Instruction not decoded properly.");
    
    //200400000000000a | LinkPGCN 10
    command = [DKCommand commandWith64Bits:0x200400000000000aL];
    STAssertTrue([[command description] isEqualTo:@"      200400000000000a | LinkPGCN 10"], @"Instruction not decoded properly.");
    
    //2004000000000010 | LinkPGCN 16
    command = [DKCommand commandWith64Bits:0x2004000000000010L];
    STAssertTrue([[command description] isEqualTo:@"      2004000000000010 | LinkPGCN 16"], @"Instruction not decoded properly.");
    
    //200400000000001a | LinkPGCN 26
    command = [DKCommand commandWith64Bits:0x200400000000001aL];
    STAssertTrue([[command description] isEqualTo:@"      200400000000001a | LinkPGCN 26"], @"Instruction not decoded properly.");
    
    //2004000000000022 | LinkPGCN 34
    command = [DKCommand commandWith64Bits:0x2004000000000022L];
    STAssertTrue([[command description] isEqualTo:@"      2004000000000022 | LinkPGCN 34"], @"Instruction not decoded properly.");
    
    //2004000000000027 | LinkPGCN 39
    command = [DKCommand commandWith64Bits:0x2004000000000027L];
    STAssertTrue([[command description] isEqualTo:@"      2004000000000027 | LinkPGCN 39"], @"Instruction not decoded properly.");
    
    //200400000000002d | LinkPGCN 45
    command = [DKCommand commandWith64Bits:0x200400000000002dL];
    STAssertTrue([[command description] isEqualTo:@"      200400000000002d | LinkPGCN 45"], @"Instruction not decoded properly.");
    
    //2004000000000033 | LinkPGCN 51
    command = [DKCommand commandWith64Bits:0x2004000000000033L];
    STAssertTrue([[command description] isEqualTo:@"      2004000000000033 | LinkPGCN 51"], @"Instruction not decoded properly.");
    
    //2006000000000002 | LinkPGN 2
    command = [DKCommand commandWith64Bits:0x2006000000000002L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000000002 | LinkPGN 2"], @"Instruction not decoded properly.");
    
    //2006000000000401 | LinkPGN 1 (button 1)
    command = [DKCommand commandWith64Bits:0x2006000000000401L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000000401 | LinkPGN 1 (button 1)"], @"Instruction not decoded properly.");
    
    //2006000000000406 | LinkPGN 6 (button 1)
    command = [DKCommand commandWith64Bits:0x2006000000000406L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000000406 | LinkPGN 6 (button 1)"], @"Instruction not decoded properly.");
    
    //200600000000040d | LinkPGN 13 (button 1)
    command = [DKCommand commandWith64Bits:0x200600000000040dL];
    STAssertTrue([[command description] isEqualTo:@"      200600000000040d | LinkPGN 13 (button 1)"], @"Instruction not decoded properly.");
    
    //2006000000000420 | LinkPGN 32 (button 1)
    command = [DKCommand commandWith64Bits:0x2006000000000420L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000000420 | LinkPGN 32 (button 1)"], @"Instruction not decoded properly.");
    
    //200600000000043a | LinkPGN 58 (button 1)
    command = [DKCommand commandWith64Bits:0x200600000000043aL];
    STAssertTrue([[command description] isEqualTo:@"      200600000000043a | LinkPGN 58 (button 1)"], @"Instruction not decoded properly.");
    
    //2006000000001002 | LinkPGN 2 (button 4)
    command = [DKCommand commandWith64Bits:0x2006000000001002L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000001002 | LinkPGN 2 (button 4)"], @"Instruction not decoded properly.");
    
    //2006000000001401 | LinkPGN 1 (button 5)
    command = [DKCommand commandWith64Bits:0x2006000000001401L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000001401 | LinkPGN 1 (button 5)"], @"Instruction not decoded properly.");
    
    //200600000000140b | LinkPGN 11 (button 5)
    command = [DKCommand commandWith64Bits:0x200600000000140bL];
    STAssertTrue([[command description] isEqualTo:@"      200600000000140b | LinkPGN 11 (button 5)"], @"Instruction not decoded properly.");
    
    //2006000000001417 | LinkPGN 23 (button 5)
    command = [DKCommand commandWith64Bits:0x2006000000001417L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000001417 | LinkPGN 23 (button 5)"], @"Instruction not decoded properly.");
    
    //2006000000001801 | LinkPGN 1 (button 6)
    command = [DKCommand commandWith64Bits:0x2006000000001801L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000001801 | LinkPGN 1 (button 6)"], @"Instruction not decoded properly.");
    
    //2006000000002001 | LinkPGN 1 (button 8)
    command = [DKCommand commandWith64Bits:0x2006000000002001L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000002001 | LinkPGN 1 (button 8)"], @"Instruction not decoded properly.");
    
    //2006000000002801 | LinkPGN 1 (button 10)
    command = [DKCommand commandWith64Bits:0x2006000000002801L];
    STAssertTrue([[command description] isEqualTo:@"      2006000000002801 | LinkPGN 1 (button 10)"], @"Instruction not decoded properly.");
    
    //2094000a0004000a | if (g[10] & 0x4) LinkPGCN 10
    command = [DKCommand commandWith64Bits:0x2094000a0004000aL];
    STAssertTrue([[command description] isEqualTo:@"      2094000a0004000a | if (g[10] & 0x4) LinkPGCN 10"], @"Instruction not decoded properly.");
    
    //20a400000065000c | if (g[0] == 0x65) LinkPGCN 12
    command = [DKCommand commandWith64Bits:0x20a400000065000cL];
    STAssertTrue([[command description] isEqualTo:@"      20a400000065000c | if (g[0] == 0x65) LinkPGCN 12"], @"Instruction not decoded properly.");
    
    //20a4000000ff0012 | if (g[0] == 0xff) LinkPGCN 18
    command = [DKCommand commandWith64Bits:0x20a4000000ff0012L];
    STAssertTrue([[command description] isEqualTo:@"      20a4000000ff0012 | if (g[0] == 0xff) LinkPGCN 18"], @"Instruction not decoded properly.");
    
    //20a4000100010008 | if (g[1] == 0x1) LinkPGCN 8
    command = [DKCommand commandWith64Bits:0x20a4000100010008L];
    STAssertTrue([[command description] isEqualTo:@"      20a4000100010008 | if (g[1] == 0x1) LinkPGCN 8"], @"Instruction not decoded properly.");
    
    //20a4000830000006 | if (g[8] == 0x3000) LinkPGCN 6
    command = [DKCommand commandWith64Bits:0x20a4000830000006L];
    STAssertTrue([[command description] isEqualTo:@"      20a4000830000006 | if (g[8] == 0x3000) LinkPGCN 6"], @"Instruction not decoded properly.");
    
    //20a4000900120013 | if (g[9] == 0x12) LinkPGCN 19
    command = [DKCommand commandWith64Bits:0x20a4000900120013L];
    STAssertTrue([[command description] isEqualTo:@"      20a4000900120013 | if (g[9] == 0x12) LinkPGCN 19"], @"Instruction not decoded properly.");
    
    //20a400090800000a | if (g[9] == 0x800) LinkPGCN 10
    command = [DKCommand commandWith64Bits:0x20a400090800000aL];
    STAssertTrue([[command description] isEqualTo:@"      20a400090800000a | if (g[9] == 0x800) LinkPGCN 10"], @"Instruction not decoded properly.");
    
    //20a50009cc010001 | if (g[9] == 0xcc01) LinkPTT 1
    command = [DKCommand commandWith64Bits:0x20a50009cc010001L];
    STAssertTrue([[command description] isEqualTo:@"      20a50009cc010001 | if (g[9] == 0xcc01) LinkPTT 1"], @"Instruction not decoded properly.");
    
    //20a50009cc060006 | if (g[9] == 0xcc06) LinkPTT 6
    command = [DKCommand commandWith64Bits:0x20a50009cc060006L];
    STAssertTrue([[command description] isEqualTo:@"      20a50009cc060006 | if (g[9] == 0xcc06) LinkPTT 6"], @"Instruction not decoded properly.");
    
    //20a50009cc0b000b | if (g[9] == 0xcc0b) LinkPTT 11
    command = [DKCommand commandWith64Bits:0x20a50009cc0b000bL];
    STAssertTrue([[command description] isEqualTo:@"      20a50009cc0b000b | if (g[9] == 0xcc0b) LinkPTT 11"], @"Instruction not decoded properly.");
    
    //20a50009cc100010 | if (g[9] == 0xcc10) LinkPTT 16
    command = [DKCommand commandWith64Bits:0x20a50009cc100010L];
    STAssertTrue([[command description] isEqualTo:@"      20a50009cc100010 | if (g[9] == 0xcc10) LinkPTT 16"], @"Instruction not decoded properly.");
    
    //20a50009cc150015 | if (g[9] == 0xcc15) LinkPTT 21
    command = [DKCommand commandWith64Bits:0x20a50009cc150015L];
    STAssertTrue([[command description] isEqualTo:@"      20a50009cc150015 | if (g[9] == 0xcc15) LinkPTT 21"], @"Instruction not decoded properly.");
    
    //20a50009cc1a001a | if (g[9] == 0xcc1a) LinkPTT 26
    command = [DKCommand commandWith64Bits:0x20a50009cc1a001aL];
    STAssertTrue([[command description] isEqualTo:@"      20a50009cc1a001a | if (g[9] == 0xcc1a) LinkPTT 26"], @"Instruction not decoded properly.");
    
    //20a6000000040c04 | if (g[0] == 0x4) LinkPGN 4 (button 3)
    command = [DKCommand commandWith64Bits:0x20a6000000040c04L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000000040c04 | if (g[0] == 0x4) LinkPGN 4 (button 3)"], @"Instruction not decoded properly.");
    
    //20a6000064650801 | if (g[0] == 0x6465 ("de")) LinkPGN 1 (button 2)
    command = [DKCommand commandWith64Bits:0x20a6000064650801L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000064650801 | if (g[0] == 0x6465 (\"de\")) LinkPGN 1 (button 2)"], @"Instruction not decoded properly.");
    
    //20a6000300031401 | if (g[3] == 0x3) LinkPGN 1 (button 5)
    command = [DKCommand commandWith64Bits:0x20a6000300031401L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000300031401 | if (g[3] == 0x3) LinkPGN 1 (button 5)"], @"Instruction not decoded properly.");
    
    //20a6000800010003 | if (g[8] == 0x1) LinkPGN 3
    command = [DKCommand commandWith64Bits:0x20a6000800010003L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000800010003 | if (g[8] == 0x1) LinkPGN 3"], @"Instruction not decoded properly.");
    
    //20a6000900010401 | if (g[9] == 0x1) LinkPGN 1 (button 1)
    command = [DKCommand commandWith64Bits:0x20a6000900010401L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000900010401 | if (g[9] == 0x1) LinkPGN 1 (button 1)"], @"Instruction not decoded properly.");
    
    //20a6000900061405 | if (g[9] == 0x6) LinkPGN 5 (button 5)
    command = [DKCommand commandWith64Bits:0x20a6000900061405L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000900061405 | if (g[9] == 0x6) LinkPGN 5 (button 5)"], @"Instruction not decoded properly.");
    
    //20a60009000d1405 | if (g[9] == 0xd) LinkPGN 5 (button 5)
    command = [DKCommand commandWith64Bits:0x20a60009000d1405L];
    STAssertTrue([[command description] isEqualTo:@"      20a60009000d1405 | if (g[9] == 0xd) LinkPGN 5 (button 5)"], @"Instruction not decoded properly.");
    
    //20a600090013080a | if (g[9] == 0x13) LinkPGN 10 (button 2)
    command = [DKCommand commandWith64Bits:0x20a600090013080aL];
    STAssertTrue([[command description] isEqualTo:@"      20a600090013080a | if (g[9] == 0x13) LinkPGN 10 (button 2)"], @"Instruction not decoded properly.");
    
    //20a6000900151401 | if (g[9] == 0x15) LinkPGN 1 (button 5)
    command = [DKCommand commandWith64Bits:0x20a6000900151401L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000900151401 | if (g[9] == 0x15) LinkPGN 1 (button 5)"], @"Instruction not decoded properly.");
    
    //20a6000900180801 | if (g[9] == 0x18) LinkPGN 1 (button 2)
    command = [DKCommand commandWith64Bits:0x20a6000900180801L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000900180801 | if (g[9] == 0x18) LinkPGN 1 (button 2)"], @"Instruction not decoded properly.");
    
    //20a6000900221c01 | if (g[9] == 0x22) LinkPGN 1 (button 7)
    command = [DKCommand commandWith64Bits:0x20a6000900221c01L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000900221c01 | if (g[9] == 0x22) LinkPGN 1 (button 7)"], @"Instruction not decoded properly.");
    
    //20a6000905130c01 | if (g[9] == 0x513) LinkPGN 1 (button 3)
    command = [DKCommand commandWith64Bits:0x20a6000905130c01L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000905130c01 | if (g[9] == 0x513) LinkPGN 1 (button 3)"], @"Instruction not decoded properly.");
    
    //20a6000908120801 | if (g[9] == 0x812) LinkPGN 1 (button 2)
    command = [DKCommand commandWith64Bits:0x20a6000908120801L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000908120801 | if (g[9] == 0x812) LinkPGN 1 (button 2)"], @"Instruction not decoded properly.");
    
    //20a6000909030003 | if (g[9] == 0x903) LinkPGN 3
    command = [DKCommand commandWith64Bits:0x20a6000909030003L];
    STAssertTrue([[command description] isEqualTo:@"      20a6000909030003 | if (g[9] == 0x903) LinkPGN 3"], @"Instruction not decoded properly.");
    
    //20a600098601043c | if (g[9] == 0x8601) LinkPGN 60 (button 1)
    command = [DKCommand commandWith64Bits:0x20a600098601043cL];
    STAssertTrue([[command description] isEqualTo:@"      20a600098601043c | if (g[9] == 0x8601) LinkPGN 60 (button 1)"], @"Instruction not decoded properly.");
    
    //20a70009cea4000b | if (g[9] == 0xcea4) LinkCN 11
    command = [DKCommand commandWith64Bits:0x20a70009cea4000bL];
    STAssertTrue([[command description] isEqualTo:@"      20a70009cea4000b | if (g[9] == 0xcea4) LinkCN 11"], @"Instruction not decoded properly.");
    
    //20a70009cea90029 | if (g[9] == 0xcea9) LinkCN 41
    command = [DKCommand commandWith64Bits:0x20a70009cea90029L];
    STAssertTrue([[command description] isEqualTo:@"      20a70009cea90029 | if (g[9] == 0xcea9) LinkCN 41"], @"Instruction not decoded properly.");
    
    //20b4000100040002 | if (g[1] != 0x4) LinkPGCN 2
    command = [DKCommand commandWith64Bits:0x20b4000100040002L];
    STAssertTrue([[command description] isEqualTo:@"      20b4000100040002 | if (g[1] != 0x4) LinkPGCN 2"], @"Instruction not decoded properly.");
    
    //20d40003012c0022 | if (g[3] > 0x12c) LinkPGCN 34
    command = [DKCommand commandWith64Bits:0x20d40003012c0022L];
    STAssertTrue([[command description] isEqualTo:@"      20d40003012c0022 | if (g[3] > 0x12c) LinkPGCN 34"], @"Instruction not decoded properly.");
    
    //20f4000900640006 | if (g[9] < 0x64) LinkPGCN 6
    command = [DKCommand commandWith64Bits:0x20f4000900640006L];
    STAssertTrue([[command description] isEqualTo:@"      20f4000900640006 | if (g[9] < 0x64) LinkPGCN 6"], @"Instruction not decoded properly.");
    
    //3002000000030000 | JumpTT 3
    command = [DKCommand commandWith64Bits:0x3002000000030000L];
    STAssertTrue([[command description] isEqualTo:@"      3002000000030000 | JumpTT 3"], @"Instruction not decoded properly.");
    
    //3002000000080000 | JumpTT 8
    command = [DKCommand commandWith64Bits:0x3002000000080000L];
    STAssertTrue([[command description] isEqualTo:@"      3002000000080000 | JumpTT 8"], @"Instruction not decoded properly.");
    
    //30020000000d0000 | JumpTT 13
    command = [DKCommand commandWith64Bits:0x30020000000d0000L];
    STAssertTrue([[command description] isEqualTo:@"      30020000000d0000 | JumpTT 13"], @"Instruction not decoded properly.");
    
    //3002000000120000 | JumpTT 18
    command = [DKCommand commandWith64Bits:0x3002000000120000L];
    STAssertTrue([[command description] isEqualTo:@"      3002000000120000 | JumpTT 18"], @"Instruction not decoded properly.");
    
    //3002000000170000 | JumpTT 23
    command = [DKCommand commandWith64Bits:0x3002000000170000L];
    STAssertTrue([[command description] isEqualTo:@"      3002000000170000 | JumpTT 23"], @"Instruction not decoded properly.");
    
    //30020000001c0000 | JumpTT 28
    command = [DKCommand commandWith64Bits:0x30020000001c0000L];
    STAssertTrue([[command description] isEqualTo:@"      30020000001c0000 | JumpTT 28"], @"Instruction not decoded properly.");
    
    //3002000000210000 | JumpTT 33
    command = [DKCommand commandWith64Bits:0x3002000000210000L];
    STAssertTrue([[command description] isEqualTo:@"      3002000000210000 | JumpTT 33"], @"Instruction not decoded properly.");
    
    //3002000000260000 | JumpTT 38
    command = [DKCommand commandWith64Bits:0x3002000000260000L];
    STAssertTrue([[command description] isEqualTo:@"      3002000000260000 | JumpTT 38"], @"Instruction not decoded properly.");
    
    //3006000102830000 | JumpSS VTSM (vts 2, title 1, menu 3)
    command = [DKCommand commandWith64Bits:0x3006000102830000L];
    STAssertTrue([[command description] isEqualTo:@"      3006000102830000 | JumpSS VTSM (vts 2, title 1, menu 3)"], @"Instruction not decoded properly.");
    
    //3006000105870000 | JumpSS VTSM (vts 5, title 1, menu 7)
    command = [DKCommand commandWith64Bits:0x3006000105870000L];
    STAssertTrue([[command description] isEqualTo:@"      3006000105870000 | JumpSS VTSM (vts 5, title 1, menu 7)"], @"Instruction not decoded properly.");
    
    //3006000200c00000 | JumpSS VMGM (pgc 2)
    command = [DKCommand commandWith64Bits:0x3006000200c00000L];
    STAssertTrue([[command description] isEqualTo:@"      3006000200c00000 | JumpSS VMGM (pgc 2)"], @"Instruction not decoded properly.");
    
    //3006000d00c00000 | JumpSS VMGM (pgc 13)
    command = [DKCommand commandWith64Bits:0x3006000d00c00000L];
    STAssertTrue([[command description] isEqualTo:@"      3006000d00c00000 | JumpSS VMGM (pgc 13)"], @"Instruction not decoded properly.");
    
    //3008000701c00000 | CallSS VMGM (pgc 7, rsm_cell 1)
    command = [DKCommand commandWith64Bits:0x3008000701c00000L];
    STAssertTrue([[command description] isEqualTo:@"      3008000701c00000 | CallSS VMGM (pgc 7, rsm_cell 1)"], @"Instruction not decoded properly.");
    
    //3025000600010001 | if (g[0] == g[1]) JumpVTS_PTT 1:6
    command = [DKCommand commandWith64Bits:0x3025000600010001L];
    STAssertTrue([[command description] isEqualTo:@"      3025000600010001 | if (g[0] == g[1]) JumpVTS_PTT 1:6"], @"Instruction not decoded properly.");
    
    //3025000b00010001 | if (g[0] == g[1]) JumpVTS_PTT 1:11
    command = [DKCommand commandWith64Bits:0x3025000b00010001L];
    STAssertTrue([[command description] isEqualTo:@"      3025000b00010001 | if (g[0] == g[1]) JumpVTS_PTT 1:11"], @"Instruction not decoded properly.");
    
    //3025001000010001 | if (g[0] == g[1]) JumpVTS_PTT 1:16
    command = [DKCommand commandWith64Bits:0x3025001000010001L];
    STAssertTrue([[command description] isEqualTo:@"      3025001000010001 | if (g[0] == g[1]) JumpVTS_PTT 1:16"], @"Instruction not decoded properly.");
    
    //3025001500010001 | if (g[0] == g[1]) JumpVTS_PTT 1:21
    command = [DKCommand commandWith64Bits:0x3025001500010001L];
    STAssertTrue([[command description] isEqualTo:@"      3025001500010001 | if (g[0] == g[1]) JumpVTS_PTT 1:21"], @"Instruction not decoded properly.");
    
    //4100000081000000 | Sub-picture Stream Number (SRPM:2) = g[1]
    command = [DKCommand commandWith64Bits:0x4100000081000000L];
    STAssertTrue([[command description] isEqualTo:@"      4100000081000000 | Sub-picture Stream Number (SRPM:2) = g[1]"], @"Instruction not decoded properly.");
    
    //410000008f000000 | Sub-picture Stream Number (SRPM:2) = g[15]
    command = [DKCommand commandWith64Bits:0x410000008f000000L];
    STAssertTrue([[command description] isEqualTo:@"      410000008f000000 | Sub-picture Stream Number (SRPM:2) = g[15]"], @"Instruction not decoded properly.");
    
    //4100008e00000000 | Audio Stream Number (SRPM:1) = g[14]
    command = [DKCommand commandWith64Bits:0x4100008e00000000L];
    STAssertTrue([[command description] isEqualTo:@"      4100008e00000000 | Audio Stream Number (SRPM:1) = g[14]"], @"Instruction not decoded properly.");
    
    //5600000008000000 | Highlighted Button Number (SRPM:8) = 0x800 (button 2)
    command = [DKCommand commandWith64Bits:0x5600000008000000L];
    STAssertTrue([[command description] isEqualTo:@"      5600000008000000 | Highlighted Button Number (SRPM:8) = 0x800 (button 2)"], @"Instruction not decoded properly.");
    
    //5604000004000002 | Highlighted Button Number (SRPM:8) = 0x400 (button 1), LinkPGCN 2
    command = [DKCommand commandWith64Bits:0x5604000004000002L];
    STAssertTrue([[command description] isEqualTo:@"      5604000004000002 | Highlighted Button Number (SRPM:8) = 0x400 (button 1), LinkPGCN 2"], @"Instruction not decoded properly.");
    
    //6100000000820000 | g[0] = Sub-picture Stream Number (SRPM:2)
    command = [DKCommand commandWith64Bits:0x6100000000820000L];
    STAssertTrue([[command description] isEqualTo:@"      6100000000820000 | g[0] = Sub-picture Stream Number (SRPM:2)"], @"Instruction not decoded properly.");
    
    //6100000100850000 | g[1] = VTS Title Track Number (SRPM:5)
    command = [DKCommand commandWith64Bits:0x6100000100850000L];
    STAssertTrue([[command description] isEqualTo:@"      6100000100850000 | g[1] = VTS Title Track Number (SRPM:5)"], @"Instruction not decoded properly.");
    
    //6100000200820000 | g[2] = Sub-picture Stream Number (SRPM:2)
    command = [DKCommand commandWith64Bits:0x6100000200820000L];
    STAssertTrue([[command description] isEqualTo:@"      6100000200820000 | g[2] = Sub-picture Stream Number (SRPM:2)"], @"Instruction not decoded properly.");
    
    //61000004000a0000 | g[4] = g[10]
    command = [DKCommand commandWith64Bits:0x61000004000a0000L];
    STAssertTrue([[command description] isEqualTo:@"      61000004000a0000 | g[4] = g[10]"], @"Instruction not decoded properly.");
    
    //6100000600870000 | g[6] = PTT Number for One_Sequential_PGC_Title (SRPM:7)
    command = [DKCommand commandWith64Bits:0x6100000600870000L];
    STAssertTrue([[command description] isEqualTo:@"      6100000600870000 | g[6] = PTT Number for One_Sequential_PGC_Title (SRPM:7)"], @"Instruction not decoded properly.");
    
    //6100000900020000 | g[9] = g[2]
    command = [DKCommand commandWith64Bits:0x6100000900020000L];
    STAssertTrue([[command description] isEqualTo:@"      6100000900020000 | g[9] = g[2]"], @"Instruction not decoded properly.");
    
    //61000009000e0000 | g[9] = g[14]
    command = [DKCommand commandWith64Bits:0x61000009000e0000L];
    STAssertTrue([[command description] isEqualTo:@"      61000009000e0000 | g[9] = g[14]"], @"Instruction not decoded properly.");
    
    //6100000b000c0000 | g[11] = g[12]
    command = [DKCommand commandWith64Bits:0x6100000b000c0000L];
    STAssertTrue([[command description] isEqualTo:@"      6100000b000c0000 | g[11] = g[12]"], @"Instruction not decoded properly.");
    
    //6100000e00040000 | g[14] = g[4]
    command = [DKCommand commandWith64Bits:0x6100000e00040000L];
    STAssertTrue([[command description] isEqualTo:@"      6100000e00040000 | g[14] = g[4]"], @"Instruction not decoded properly.");
    
    //6170000d000f0005 | if (g[0] < g[5]) g[13] = g[15]
    command = [DKCommand commandWith64Bits:0x6170000d000f0005L];
    STAssertTrue([[command description] isEqualTo:@"      6170000d000f0005 | if (g[0] < g[5]) g[13] = g[15]"], @"Instruction not decoded properly.");
    
    //61c00d06000d0040 | if (g[13] >= 0x40) g[6] = g[13]
    command = [DKCommand commandWith64Bits:0x61c00d06000d0040L];
    STAssertTrue([[command description] isEqualTo:@"      61c00d06000d0040 | if (g[13] >= 0x40) g[6] = g[13]"], @"Instruction not decoded properly.");
    
    //7100000000010000 | g[0] = 0x1
    command = [DKCommand commandWith64Bits:0x7100000000010000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000000010000 | g[0] = 0x1"], @"Instruction not decoded properly.");
    
    //7100000100030000 | g[1] = 0x3
    command = [DKCommand commandWith64Bits:0x7100000100030000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000100030000 | g[1] = 0x3"], @"Instruction not decoded properly.");
    
    //7100000100080000 | g[1] = 0x8
    command = [DKCommand commandWith64Bits:0x7100000100080000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000100080000 | g[1] = 0x8"], @"Instruction not decoded properly.");
    
    //71000001000d0000 | g[1] = 0xd
    command = [DKCommand commandWith64Bits:0x71000001000d0000L];
    STAssertTrue([[command description] isEqualTo:@"      71000001000d0000 | g[1] = 0xd"], @"Instruction not decoded properly.");
    
    //7100000100120000 | g[1] = 0x12
    command = [DKCommand commandWith64Bits:0x7100000100120000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000100120000 | g[1] = 0x12"], @"Instruction not decoded properly.");
    
    //7100000100170000 | g[1] = 0x17
    command = [DKCommand commandWith64Bits:0x7100000100170000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000100170000 | g[1] = 0x17"], @"Instruction not decoded properly.");
    
    //7100000300430000 | g[3] = 0x43
    command = [DKCommand commandWith64Bits:0x7100000300430000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000300430000 | g[3] = 0x43"], @"Instruction not decoded properly.");
    
    //7100000500440000 | g[5] = 0x44
    command = [DKCommand commandWith64Bits:0x7100000500440000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000500440000 | g[5] = 0x44"], @"Instruction not decoded properly.");
    
    //7100000800000000 | g[8] = 0x0
    command = [DKCommand commandWith64Bits:0x7100000800000000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000800000000 | g[8] = 0x0"], @"Instruction not decoded properly.");
    
    //7100000900050000 | g[9] = 0x5
    command = [DKCommand commandWith64Bits:0x7100000900050000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000900050000 | g[9] = 0x5"], @"Instruction not decoded properly.");
    
    //7100000900160000 | g[9] = 0x16
    command = [DKCommand commandWith64Bits:0x7100000900160000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000900160000 | g[9] = 0x16"], @"Instruction not decoded properly.");
    
    //71000009001f0000 | g[9] = 0x1f
    command = [DKCommand commandWith64Bits:0x71000009001f0000L];
    STAssertTrue([[command description] isEqualTo:@"      71000009001f0000 | g[9] = 0x1f"], @"Instruction not decoded properly.");
    
    //7100000a00000000 | g[10] = 0x0
    command = [DKCommand commandWith64Bits:0x7100000a00000000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000a00000000 | g[10] = 0x0"], @"Instruction not decoded properly.");
    
    //7100000b00050000 | g[11] = 0x5
    command = [DKCommand commandWith64Bits:0x7100000b00050000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000b00050000 | g[11] = 0x5"], @"Instruction not decoded properly.");
    
    //7100000c00040000 | g[12] = 0x4
    command = [DKCommand commandWith64Bits:0x7100000c00040000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000c00040000 | g[12] = 0x4"], @"Instruction not decoded properly.");
    
    //7100000d00010000 | g[13] = 0x1
    command = [DKCommand commandWith64Bits:0x7100000d00010000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000d00010000 | g[13] = 0x1"], @"Instruction not decoded properly.");
    
    //7100000e25040000 | g[14] = 0x2504
    command = [DKCommand commandWith64Bits:0x7100000e25040000L];
    STAssertTrue([[command description] isEqualTo:@"      7100000e25040000 | g[14] = 0x2504"], @"Instruction not decoded properly.");
}

- (void) testExecutionOfSimpleInstructions
{
    /* We shouldn't be testing instructions that need *real* a datasource 
     * in this pass, so we'll just pass in ourselves.
     */
    DKVirtualMachine* vm = [[DKVirtualMachine alloc] initWithDataSource:self];
    for (int i = 0; i < 16; i++) {
        STAssertTrue([vm generalPurposeRegister:i] == 0, @"This register has the wrong initial value.");
    }
    id initialState = [vm state];

    //  0000000000000000 | Nop
    [[DKCommand commandWith64Bits:0x0000000000000000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([[vm state] isEqual:initialState], @"Nop should have no effect."); 


    /*  Test basic arithmetic (Add / Subtract / Multiply / Divide)
     */
    
    //  7100000000010000 | g[0] = 0x1
    [[DKCommand commandWith64Bits:0x7100000000010000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:0] == 1, @"7100000000010000 | g[0] = 0x1");

    //  7100000100020000 | g[1] = 0x2
    [[DKCommand commandWith64Bits:0x7100000100020000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 2, @"7100000100020000 | g[1] = 0x2");

    //  7300000100010000 | g[1] += 0x1
    [[DKCommand commandWith64Bits:0x7300000100010000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 3, @"7300000100010000 | g[1] += 0x1");

    //  7400000100010000 | g[1] -= 0x1
    [[DKCommand commandWith64Bits:0x7400000100010000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 2, @"7400000100010000 | g[1] -= 0x1");

	//  7500000100020000 | g[1] *= 0x2
    [[DKCommand commandWith64Bits:0x7500000100020000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 4, @"7500000100010000 | g[1] *= 0x2");

	//  7600000100020000 | g[1] %= 0x2
    [[DKCommand commandWith64Bits:0x7600000100020000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 2, @"7600000100020000 | g[1] %= 0x2");

	//  TODO: Test basic division.
    //  TODO: Test "uneven" division, e.g. 37/3 = 12

    /*  Test basic bitwise arithmetic (Or / Xor / And / Not)
     */

	//  AND
	//  7900000100020000 | g[1] &= 0x6
    [[DKCommand commandWith64Bits:0x7900000100060000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 2, @"7900000100020000 | g[1] &= 0x6");
	
    //  OR
	//  7a00000100020000 | g[1] |= 0x6
    [[DKCommand commandWith64Bits:0x7a00000100060000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 6, @"7a00000100020000 | g[1] |= 0x6");
	
	//  XOR
	//  7b00000100020000 | g[1] ^= 0x6
    [[DKCommand commandWith64Bits:0x7b00000100060000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 0, @"7b00000100020000 | g[1] ^= 0x6");
	

    /*  Test for proper 16-bit register overflow/underflow.  (0xFFFF + 1, etc.)
     */
	
	// Divide by zero
    //  7600000100020000 | g[1] %= 0x0
    [[DKCommand commandWith64Bits:0x7600000100000000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] != 0, @"7600000100020000 | g[1] %= 0x0");
	
    
    //  TODO: Test for additive overflow, e.g. 0xFFFF + 1 == 0
    //  TODO: Test for subtractive underflow, e.g. 0x0000 - 1 == 0xFFFF
	//  TODO: Test multiplication that causes overflow, e.g. 25600 * 64 == 0x0000, not 0x190000.
	
	//  First, we set up the test for overflow from addition
	
	//  71000001FFFF0000 | g[1] = 0xFFFF
	[[DKCommand commandWith64Bits:0x71000001FFFF0000L] executeAgainstVirtualMachine:vm];
	STAssertTrue([vm generalPurposeRegister:1] == 0xFFFF, @"71000001FFFF0000 | g[1] = 0xFFFF");
	

    // When we try to overflow, we should get back the original result.
    //  7300000100010000 | g[1] += 0x1
	[[DKCommand commandWith64Bits:0x7300000100010000L] executeAgainstVirtualMachine:vm];
	STAssertTrue([vm generalPurposeRegister:1] == 0xFFFF, @"7300000100010000 | g[1] += 0x1");
	
	
    //  Now we set up the test for underflow
    //  7100000100000000 | g[1] = 0x0000
	[[DKCommand commandWith64Bits:0x7100000100000000L] executeAgainstVirtualMachine:vm];
	STAssertTrue([vm generalPurposeRegister:1] == 0x0000, @"7100000100000000 | g[1] = 0x0000");
	
	
    // When we try to underflow, we should get back 0x0000.
    //  7400000100010000 | g[1] -= 0x1
	[[DKCommand commandWith64Bits:0x7400000100010000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 0x0000, @"7400000100010000 | g[1] -= 0x1");
	
		
    //  First, we set up the test for overflow from mutiplication
    //  710000010000 | g[1] = 0x6400
	[[DKCommand commandWith64Bits:0x7100000164000000L] executeAgainstVirtualMachine:vm];
	STAssertTrue([vm generalPurposeRegister:1] == 0x6400, @"7100000164000000 | g[1] = 0x6400");
	
	
    // When we try to overflow, we should get back 0xFFFF.
    //  7500000100640000 | g[1] *= 0x64
	[[DKCommand commandWith64Bits:0x7500000100640000L] executeAgainstVirtualMachine:vm];
	STAssertTrue([vm generalPurposeRegister:1] == 0xFFFF, @"7500000100640000 | g[1] *= 0x64");
    
}

- (void) testLoadAndDecodeOf_VIDEO_TS_IFO_01
{
    
	//Start of MainMenuInformation testing
	
	NSFileHandle* ifoHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"VIDEO_TS.IFO.01" ofType:nil]];
    STAssertTrue(ifoHandle != nil, @"Unable to open a file handle for the resource.");
    
    id<DKDataSource> dataSource = [[[DKFileHandleDataSource alloc] initWithFileHandle:ifoHandle] autorelease];
    STAssertTrue(dataSource != nil, @"Unable to create a data source.");
    
    NSError* error = nil;
    DKMainMenuInformation* mainMenuInformation = [DKMainMenuInformation mainMenuInformationWithDataSource:dataSource error:&error];
    
	STAssertTrue(!error, @"VIDEO_TS.IFO.01 should decode without errors.");
    STAssertTrue(mainMenuInformation != nil, @"mainMenuInformation should not be nil.");

	// Specification version number should be 0.0
	STAssertTrue([mainMenuInformation specificationVersion] == 0, @"Specification version number should be 0.0.");
	
	// Category and Mask
	STAssertTrue([mainMenuInformation categoryAndMask] == 0x00fe0000, @"Category/Mask should be 0x00fe0000.");
	
	
	// Number of volumes should be 1
	STAssertTrue([mainMenuInformation numberOfVolumes] == 1, @"Number of volumes should be 1.");
	
	// This volume should be 1
	STAssertTrue([mainMenuInformation volumeNumber] == 1, @"Volume number should be 1.");
	
	// This side should be 1
	STAssertTrue([mainMenuInformation side] == 1, @"Side should be 1.");
	
	
	
	// Number of title sets should be 8
	STAssertTrue([mainMenuInformation numberOfTitleSets] == 8, @"Number of title sets should be 8.");

	// Point of sale code should be 0x0000000000000000
	STAssertTrue([mainMenuInformation pointOfSaleCode] == 0x0000000000000000, @"Point of sale should be 0x0000000000000000.");

	
	// Video compression should be mpeg-2
	STAssertTrue([[mainMenuInformation menuVideoAttributes] mpeg_version] == kDKMPEGVersion2, @"Video compression should be MPEG-2.");

	// Video format should be NTSC
	STAssertTrue([[mainMenuInformation menuVideoAttributes] video_format] == kDKVideoFormatNTSC, @"Video format should be NTSC.");
	
	// Display aspect ratio should be 16:9
	STAssertTrue([[mainMenuInformation menuVideoAttributes] display_aspect_ratio] ==  kDKAspectRatio16By9, @"Aspect ratio should be 16:9.");
	//Todo:  check on film mode
	
	// Letterboxed should be true
	// Todo:  This looks to be true when dumped out using ifo_dump, but we are returning false.  Need to research this.
	//STAssertTrue([[mainMenuInformation menuVideoAttributes] letterboxed] ==  YES, @"Letterboxed should be true.");
	
	// Picture size should be 720x480
	STAssertTrue([[mainMenuInformation menuVideoAttributes] picture_size] ==  kDKPictureSize720x480, @"Picture size should be 720x480.");
	
	// Bit rate should be variable
	STAssertTrue([[mainMenuInformation menuVideoAttributes] constantBitRate] ==  NO, @"Bit rate should be variable.");
	
	
	//Todo:  line21_cc_2;
    //Todo:   line21_cc_1;
	// I don't see a value for these in the reference ifo, so I'm not sure what to do for testing these.
	// Start of audio testing
	// Since there is only one audio stream in the reference ifo, we will assert on stream count first.
	STAssertTrue([[mainMenuInformation menuAudioAttributes] count] == 1, @"Audio stream count should be 1.");

	DKAudioAttributes* menuAudioAttributes = [[mainMenuInformation menuAudioAttributes] objectAtIndex:0];  
	// Audio format should be AC3
	STAssertTrue([menuAudioAttributes audio_format] == kDKAudioFormatAC3, @"Audio stream format should be AC3.");
	
	// Multichannel extension should be false
	STAssertTrue([menuAudioAttributes has_multichannel_extension] == NO, @"Multichannel extension should be false.");
	
	
	// Application mode should be unspecified
	STAssertTrue([menuAudioAttributes application_mode] ==  kDKAudioApplocationModeUnspecified, @"Application extension should be unspecified.");

	// Quantization should be three
	//Note:  I wasn't able to get the quantization value from ifo_dump, so I'm not sure if this is correct or not
	STAssertTrue([menuAudioAttributes quantization] ==  3, @"Quantization should be 3.");

	// Sampling frequency should be 48kbps
	// The sample frequency value is zero, so this assert is failing
	
	STAssertTrue([menuAudioAttributes sample_frequency] == kDKAudioSamplingRate48KHz, @"Sampling rate should be 48kbps.");

	// Channels should be two
	STAssertTrue([menuAudioAttributes channels] ==  2, @"Number of channels should be 2.");

	// Language code should be zero
	STAssertTrue([menuAudioAttributes lang_code] ==  0, @"Language code should be 0.");

	// Language extension should be zero
	STAssertTrue([menuAudioAttributes lang_extension] ==  0, @"Language extension should be 0.");

	// Code extension should be zero
	STAssertTrue([menuAudioAttributes code_extension] ==  0, @"Code extension should be 0.");

	// Application information should be zero
	STAssertTrue([menuAudioAttributes app_info_value] ==  0, @"Application information should be 0.");

	
	// Start of SubPicture testing
	// Number of subpicture streams should be 1
	STAssertTrue([[mainMenuInformation menuSubpictureAttributes] code_mode] ==  0, @"Subpicture stream count should be 1.");

	// Start of First Play PGC testing
	// Playback time should be 00:00:00.00 @ 29.97 fps
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] playback_time ].frame_u, @"Playback time should be 192.");

	// All prohibited user operations should be equal to 0
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].__zero_1 == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].angle_change == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].angle_menu_call == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].audio_menu_call == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].audio_stream_change == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].backward_scan == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].button_select_or_activate == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].chapter_menu_call == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].chapter_search_or_play == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].forward_scan == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].go_up == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].karaoke_audio_pres_mode_change == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].next_pg_search == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].pause_on == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].prev_or_top_pg_search == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].resume == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].root_menu_call == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].still_off == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].stop == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].subpic_menu_call == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].subpic_stream_change == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].time_or_chapter_search == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].title_menu_call == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].title_or_time_play == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].title_play == 0, @"Prohibited user operations should be 0.");
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] prohibitedUserOperations].video_pres_mode_change == 0, @"Prohibited user operations should be 0.");
	
	
	//Todo:  I'm not sure what these values should be.  Ifo_dump doesn't list these as being in our reference ifo
	//audio_control[8];
    //subp_control[32];
	
	// Next program chain number should be zero
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] nextProgramChainNumber] == 0, @"Next program chain number should be 0.");
	
	// Previous program chain number should be zero
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] previousProgramChainNumber] == 0, @"Previous program chain number should be 0.");
	
	
	// GoUp program chain number should be zero
	STAssertTrue([[mainMenuInformation firstPlayProgramChain] goUpProgramChainNumber] == 0, @"GoUp program chain number should be 0.");
	
	//Todo:  still_time??
	
	//Todo:  pg_playback_mode
	
	//Todo:  palette

	//Todo:  precommands - I'm not sure how to compare the bits from the DKCommand with the ifo_dump
	
	// Post commands count should be zero
	STAssertTrue([[[mainMenuInformation firstPlayProgramChain] postCommands] count] == 0, @"Post commands count should be 0.");
	
	// Cell commands count should be zero
	STAssertTrue([[[mainMenuInformation firstPlayProgramChain] cellCommands] count] == 0, @"Cell commands count should be 0.");
	
	// Program map count should be zero
	STAssertTrue([[[mainMenuInformation firstPlayProgramChain] programMap] count] == 0, @"Program map count should be 0.");
	
	// Cell playback count should be zero
	STAssertTrue([[[mainMenuInformation firstPlayProgramChain] cellPlaybackTable] count] == 0, @"Cell playback count should be 0.");
	
	
	// Cell position count should be zero
	STAssertTrue([[[mainMenuInformation firstPlayProgramChain] cellPositionTable] count] == 0, @"Cell position count should be 0.");
	
	
	// Start of title track search pointer table
	
	// Title track search pointer count should be 13
	STAssertTrue([[mainMenuInformation titleTrackSearchPointerTable] count] == 13, @"Title track search pointer count should be 0.");
	
	// Now we process the title track search pointer array
	for(int count = 0;count < [[mainMenuInformation titleTrackSearchPointerTable] count];count++)
	{
		
		
		switch (count) {
			case 0:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 1
				STAssertTrue([tempPointer title_set_nr] == 1, @"Title set number should be 1.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 13
				STAssertTrue([tempPointer nr_of_ptts] == 13, @"PTT number should be 13.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 000549b0
				STAssertTrue([tempPointer title_set_sector ] == 0x000549b0, @"Title set starting sector should be 000549b0.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 0, @"jlc_exists_in_button_cmd should be 0.");
				//jlc_exists_in_cell_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 0, @"jlc_exists_in_cell_cmd should be 0.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				
				
				break;
			}
			case 1:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 1
				STAssertTrue([tempPointer title_set_nr] == 1, @"Title set number should be 1.");
				
				// VTS_TTN should be 2
				STAssertTrue([tempPointer vts_ttn] == 2, @"VTS_TTN should be 2.");
				
				//PTT number should be 2
				STAssertTrue([tempPointer nr_of_ptts] == 2, @"PTT number should be 2.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 000549b0
				STAssertTrue([tempPointer title_set_sector ] == 0x000549b0, @"Title set starting sector should be 000549b0.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 0, @"jlc_exists_in_button_cmd should be 0.");
				//jlc_exists_in_cell_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 0, @"jlc_exists_in_cell_cmd should be 0.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 2:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 1
				STAssertTrue([tempPointer title_set_nr] == 1, @"Title set number should be 1.");
				
				// VTS_TTN should be 3
				STAssertTrue([tempPointer vts_ttn] == 3, @"VTS_TTN should be 3.");
				
				//PTT number should be 1
				STAssertTrue([tempPointer nr_of_ptts] == 1, @"PTT number should be 1.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 000549b0
				STAssertTrue([tempPointer title_set_sector ] == 0x000549b0, @"Title set starting sector should be 000549b0.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 0, @"jlc_exists_in_button_cmd should be 0.");
				//jlc_exists_in_cell_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 0, @"jlc_exists_in_cell_cmd should be 0.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 3:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 2
				STAssertTrue([tempPointer title_set_nr] == 2, @"Title set number should be 2.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 5
				STAssertTrue([tempPointer nr_of_ptts] == 5, @"PTT number should be 5.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 0030cf29
				STAssertTrue([tempPointer title_set_sector ] == 0x0030cf29, @"Title set starting sector should be 0030cf29.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 0, @"jlc_exists_in_button_cmd should be 0.");
				//jlc_exists_in_cell_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 0, @"jlc_exists_in_cell_cmd should be 0.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 4:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 3
				STAssertTrue([tempPointer title_set_nr] == 3, @"Title set number should be 3.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 1
				STAssertTrue([tempPointer nr_of_ptts] == 1, @"PTT number should be 1.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 003269d3
				STAssertTrue([tempPointer title_set_sector ] == 0x003269d3, @"Title set starting sector should be 003269d3.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 5:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 4
				STAssertTrue([tempPointer title_set_nr] == 4, @"Title set number should be 4.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 1
				STAssertTrue([tempPointer nr_of_ptts] == 1, @"PTT number should be 1.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 00326a28
				STAssertTrue([tempPointer title_set_sector ] == 0x00326a28, @"Title set starting sector should be 00326a28.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 6:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 5
				STAssertTrue([tempPointer title_set_nr] == 5, @"Title set number should be 5.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 1
				STAssertTrue([tempPointer nr_of_ptts] == 1, @"PTT number should be 1.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 0033f8d9
				STAssertTrue([tempPointer title_set_sector ] == 0x0033f8d9, @"Title set starting sector should be 0033f8d9.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 7:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 6
				STAssertTrue([tempPointer title_set_nr] == 6, @"Title set number should be 6.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 73
				STAssertTrue([tempPointer nr_of_ptts] == 73, @"PTT number should be 73.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 0035878a
				STAssertTrue([tempPointer title_set_sector ] == 0x0035878a, @"Title set starting sector should be 0035878a.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 1
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 1, @"multi_or_random_pgc_title should be 1.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 8:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 7
				STAssertTrue([tempPointer title_set_nr] == 7, @"Title set number should be 7.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 1
				STAssertTrue([tempPointer nr_of_ptts] == 1, @"PTT number should be 1.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 0037187b
				STAssertTrue([tempPointer title_set_sector ] == 0x0037187b, @"Title set starting sector should be 0037187b.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 9:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 8
				STAssertTrue([tempPointer title_set_nr] == 8, @"Title set number should be 8.");
				
				// VTS_TTN should be 1
				STAssertTrue([tempPointer vts_ttn] == 1, @"VTS_TTN should be 1.");
				
				//PTT number should be 1
				STAssertTrue([tempPointer nr_of_ptts] == 1, @"PTT number should be 1.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 0037a98c
				STAssertTrue([tempPointer title_set_sector ] == 0x0037a98c, @"Title set starting sector should be 0037a98c.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 10:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 1
				STAssertTrue([tempPointer title_set_nr] == 1, @"Title set number should be 1.");
				
				// VTS_TTN should be 4
				STAssertTrue([tempPointer vts_ttn] == 4, @"VTS_TTN should be 4.");
				
				//PTT number should be 13
				STAssertTrue([tempPointer nr_of_ptts] == 13, @"PTT number should be 13.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 000549b0
				STAssertTrue([tempPointer title_set_sector ] == 0x000549b0, @"Title set starting sector should be 000549b0.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 11:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 1
				STAssertTrue([tempPointer title_set_nr] == 1, @"Title set number should be 1.");
				
				// VTS_TTN should be 5
				STAssertTrue([tempPointer vts_ttn] == 5, @"VTS_TTN should be 5.");
				
				//PTT number should be 13
				STAssertTrue([tempPointer nr_of_ptts] == 13, @"PTT number should be 13.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 000549b0
				STAssertTrue([tempPointer title_set_sector ] == 0x000549b0, @"Title set starting sector should be 000549b0.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			case 12:
			{
				DKTitleTrackSearchPointer* tempPointer = [[mainMenuInformation titleTrackSearchPointerTable] objectAtIndex:count];
				
				// Title set number should be 1
				STAssertTrue([tempPointer title_set_nr] == 1, @"Title set number should be 1.");
				
				// VTS_TTN should be 6
				STAssertTrue([tempPointer vts_ttn] == 6, @"VTS_TTN should be 6.");
				
				//PTT number should be 13
				STAssertTrue([tempPointer nr_of_ptts] == 13, @"PTT number should be 13.");
				
				//Number of angles should be 1
				STAssertTrue([tempPointer nr_of_angles ] == 1, @"Number of angles should be 1.");
				
				//Title set starting sector should be 000549b0
				STAssertTrue([tempPointer title_set_sector ] == 0x000549b0, @"Title set starting sector should be 000549b0.");
				
				//Parental id  should be 0000
				STAssertTrue([tempPointer parental_id ] == 0000, @"Parental id should be 0000.");
				
				//Title playback type checking
				
				//__zero_1 should be 0
				STAssertTrue([tempPointer pb_ty ].__zero_1 == 0, @"__zero_1 should be 0.");
				//chapter_search_or_play should be 0
				STAssertTrue([tempPointer pb_ty ].chapter_search_or_play == 0, @"chapter_search_or_play should be 0.");
				//jlc_exists_in_button_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_button_cmd == 1, @"jlc_exists_in_button_cmd should be 1.");
				//jlc_exists_in_cell_cmd should be 1
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_cell_cmd == 1, @"jlc_exists_in_cell_cmd should be 1.");
				//jlc_exists_in_prepost_cmd should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_prepost_cmd == 1, @"jlc_exists_in_prepost_cmd should be 0.");
				//jlc_exists_in_tt_dom should be 0
				STAssertTrue([tempPointer pb_ty ].jlc_exists_in_tt_dom == 1, @"jlc_exists_in_tt_dom should be 0.");
				//multi_or_random_pgc_title should be 0
				STAssertTrue([tempPointer pb_ty ].multi_or_random_pgc_title == 0, @"multi_or_random_pgc_title should be 0.");
				
				//title_or_time_play should be 0
				STAssertTrue([tempPointer pb_ty ].title_or_time_play == 0, @"title_or_time_play should be 0.");
				break;
			}
			default:
				break;
		}//switch
		// Title 
		STAssertTrue([[mainMenuInformation titleTrackSearchPointerTable] count] == 13, @"Title track search pointer count should be 13.");
		
		
		
		
		
		
	}//for
	
		
	
	// Saving out our data
	NSData* menuObject = [mainMenuInformation saveAsData:&error lengthOfMenuVOB:CFBitVectorGetCount([mainMenuInformation menuVobuAddressMap])];
		
	id<DKDataSource> tempDataSource = [[[DKDataDataSource alloc] initWithNSData:menuObject] autorelease];
    STAssertTrue(tempDataSource != nil, @"Unable to create a data source.");
	error = nil;

    DKMainMenuInformation* mainMenuInformation2ndLoad = [DKMainMenuInformation mainMenuInformationWithDataSource:tempDataSource error:&error];
	STAssertTrue(error == nil, @"Unable to create a MainMenuInformation instance.");
	STAssertTrue([mainMenuInformation isEqual:mainMenuInformation2ndLoad] == YES, @"isEqual should return true.");
	
	
}

- (void) testLoadAndDecodeOf_VIDEO_01_0_IFO
{
	NSFileHandle* ifoHandle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"VTS_01_0.IFO" ofType:nil]];
    STAssertTrue(ifoHandle != nil, @"Unable to open a file handle for the resource.");
    
    id<DKDataSource> dataSource = [[[DKFileHandleDataSource alloc] initWithFileHandle:ifoHandle] autorelease];
    STAssertTrue(dataSource != nil, @"Unable to create a data source.");
    
    NSError* error = nil;

    DKTitleSetInformation* titleSetInformation = [DKTitleSetInformation titleSetInformationWithDataSource:dataSource index:1 error:&error];
    
    // Specification version number should be 0.0
    STAssertTrue([titleSetInformation specificationVersion] == 16, @"Specification version number should be 1.0.");
    
    // Category and Mask
	//	STAssertTrue([mainMenuInformation categoryAndMask] == 0x00000000, @"Category/Mask should be 0x00000000.");
    /*
     Video attributes for Menu
     */
    
    // Video compression should be mpeg-2
    STAssertTrue([[titleSetInformation menuVideoAttributes] mpeg_version] == kDKMPEGVersion2, @"Video compression should be MPEG-2.");
    
    // Video format should be NTSC
    STAssertTrue([[titleSetInformation menuVideoAttributes] video_format] == kDKVideoFormatNTSC, @"Video format should be NTSC.");
    
    // Display aspect ratio should be 16:9
    STAssertTrue([[titleSetInformation menuVideoAttributes] display_aspect_ratio] ==  kDKAspectRatio16By9, @"Aspect ratio should be 16:9.");
    //Todo:  check on film mode
    
    // Letterboxed should be true
    // Todo:  This looks to be true when dumped out using ifo_dump, but we are returning false.  Need to research this.
    //STAssertTrue([[mainMenuInformation menuVideoAttributes] letterboxed] ==  YES, @"Letterboxed should be true.");
    
    // Picture size should be 720x480
    STAssertTrue([[titleSetInformation menuVideoAttributes] picture_size] ==  kDKPictureSize720x480, @"Picture size should be 720x480.");
    
    // Bit rate should be variable
    STAssertTrue([[titleSetInformation menuVideoAttributes] constantBitRate] ==  NO, @"Bit rate should be variable.");
    
    
    /*
     Audio attributes for menu
     
     */
    
    STAssertTrue([[titleSetInformation menuAudioAttributes] count] == 1, @"Audio stream count should be 1.");
    
    DKAudioAttributes* titleAudioAttributes = [[titleSetInformation menuAudioAttributes] objectAtIndex:0];  
    // Audio format should be AC3
    STAssertTrue([titleAudioAttributes audio_format] == kDKAudioFormatAC3, @"Audio stream format should be AC3.");
    
    // Multichannel extension should be false
    STAssertTrue([titleAudioAttributes has_multichannel_extension] == NO, @"Multichannel extension should be false.");
    
    
    // Application mode should be unspecified
    STAssertTrue([titleAudioAttributes application_mode] ==  kDKAudioApplocationModeUnspecified, @"Application extension should be unspecified.");
    
    // Quantization should be three
    //Note:  I wasn't able to get the quantization value from ifo_dump, so I'm not sure if this is correct or not
    STAssertTrue([titleAudioAttributes quantization] ==  3, @"Quantization should be 3.");
    
    // Sampling frequency should be 48kbps
    // The sample frequency value is zero, so this assert is failing
    
    STAssertTrue([titleAudioAttributes sample_frequency] == kDKAudioSamplingRate48KHz, @"Sampling rate should be 48kbps.");
    
    // Channels should be two
    STAssertTrue([titleAudioAttributes channels] ==  2, @"Number of channels should be 2.");
    
    // Language code should be zero
    STAssertTrue([titleAudioAttributes lang_code] ==  0, @"Language code should be 0.");
    
    // Language extension should be zero
    STAssertTrue([titleAudioAttributes lang_extension] ==  0, @"Language extension should be 0.");
    
    // Code extension should be zero
    STAssertTrue([titleAudioAttributes code_extension] ==  0, @"Code extension should be 0.");
    
    // Application information should be zero
    STAssertTrue([titleAudioAttributes app_info_value] ==  0, @"Application information should be 0.");
    
    /*
     Subpicture 
     */
    
    // Number of subpicture streams should be 1
    STAssertTrue([[titleSetInformation menuSubpictureAttributes] code_mode] ==  0, @"Subpicture stream count should be 1.");
    
    /* Video attributes for VTSM
     */
    DKVideoAttributes* vtsmVideoAttributes = [titleSetInformation videoAttributes];
    
    // Video compression should be mpeg-2
    STAssertTrue([vtsmVideoAttributes mpeg_version] == kDKMPEGVersion2, @"Video compression should be MPEG-2.");
    
    // Video format should be NTSC
    STAssertTrue([vtsmVideoAttributes video_format] == kDKVideoFormatNTSC, @"Video format should be NTSC.");
    
    // Display aspect ratio should be 16:9
    STAssertTrue([vtsmVideoAttributes display_aspect_ratio] ==  kDKAspectRatio16By9, @"Aspect ratio should be 16:9.");
    //Todo:  check on film mode
    
    // Letterboxed should be true
    // Todo:  This looks to be true when dumped out using ifo_dump, but we are returning false.  Need to research this.
    //STAssertTrue([[mainMenuInformation menuVideoAttributes] letterboxed] ==  YES, @"Letterboxed should be true.");
    
    // Picture size should be 720x480
    STAssertTrue([vtsmVideoAttributes picture_size] ==  kDKPictureSize720x480, @"Picture size should be 720x480.");
    
    // Bit rate should be variable
    STAssertTrue([vtsmVideoAttributes constantBitRate] ==  NO, @"Bit rate should be variable.");
    
    
    /*
     Audio attributes array processing
     
     */
    
    for(int count = 0;count < [[titleSetInformation audioAttributes] count];count++)
    {
        
        DKAudioAttributes* vtsmAudioAttributes = [[titleSetInformation audioAttributes] objectAtIndex:count];
        
        // Audio format should be AC3
        STAssertTrue([vtsmAudioAttributes audio_format] == kDKAudioFormatAC3, @"Audio stream format should be AC3.");
        
        // Multichannel extension should be false
        STAssertTrue([vtsmAudioAttributes has_multichannel_extension] == NO, @"Multichannel extension should be false.");
        
        
        // Application mode should be unspecified
        STAssertTrue([vtsmAudioAttributes application_mode] ==  kDKAudioApplocationModeUnspecified, @"Application extension should be unspecified.");
        
        // Quantization should be three
        //Note:  I wasn't able to get the quantization value from ifo_dump, so I'm not sure if this is correct or not
        STAssertTrue([vtsmAudioAttributes quantization] ==  3, @"Quantization should be 3.");
        
        // Sampling frequency should be 48kbps
        // The sample frequency value is zero, so this assert is failing
        
        STAssertTrue([vtsmAudioAttributes sample_frequency] == kDKAudioSamplingRate48KHz, @"Sampling rate should be 48kbps.");
        
        // Channels should be 6 on first entry, 2 on all others
        if(count == 0)
			STAssertTrue([vtsmAudioAttributes channels] ==  6, @"Number of channels should be 6.");
        else
            STAssertTrue([vtsmAudioAttributes channels] ==  2, @"Number of channels should be 2.");
        
        // Language code should be en, except for the third entry
        if(count == 2)
            STAssertTrue([vtsmAudioAttributes lang_code] ==  25971, @"Language code should be 25971.");
        else
            STAssertTrue([vtsmAudioAttributes lang_code] ==  25966, @"Language code should be 25966.");
        
        
        
        // Language extension should be zero
        STAssertTrue([vtsmAudioAttributes lang_extension] ==  0, @"Language extension should be 0.");
        
        // Code extension should be zero
        STAssertTrue([vtsmAudioAttributes code_extension] ==  1, @"Code extension should be 1.");
        
        // Application information should be zero
        STAssertTrue([vtsmAudioAttributes app_info_value] ==  0, @"Application information should be 0.");
        
        
    }
    
    
    /*
     Subpicture attributes array processing
     
     */
    
    for(int count = 0;count < [[titleSetInformation subpictureAttributes] count];count++)
    {
        
        DKSubpictureAttributes* vtsmSubPictureAttributes = [[titleSetInformation subpictureAttributes] objectAtIndex:count];
        STAssertTrue([vtsmSubPictureAttributes code_mode ] ==  0, @"Code mode should be 0.");
        if(count == 2)
            STAssertTrue([vtsmSubPictureAttributes lang_code ] ==  25971, @"Lang code should be 25971.");
        else
            STAssertTrue([vtsmSubPictureAttributes lang_code ] ==  25966, @"Lang code should be 0.");
        
        
    }
    
	// part of title testing
	STAssertTrue([[titleSetInformation partOfTitleSearchTable] count] ==  8, @"Srpt count should be 8.");
	
	for(int count = 0;count < [[titleSetInformation partOfTitleSearchTable] count];count++)
	{
		
		NSMutableArray* srptObject = [[ titleSetInformation partOfTitleSearchTable] objectAtIndex:count];
		int iNumberOfParts = [srptObject count];
		switch (count) {
			case 0:
			{
				STAssertTrue(iNumberOfParts == 51, @"Part count should be 51.");
				break;
			}
				
			case 1:
			{
				STAssertTrue(iNumberOfParts == 3, @"Part count should be 3.");
				break;
			}
				
			case 2:
			{
				STAssertTrue(iNumberOfParts == 1, @"Part count should be 1.");
				break;
			}
				
			case 3:
			{
				STAssertTrue(iNumberOfParts == 1, @"Part count should be 1.");
				break;
			}
			case 4:
			{
				STAssertTrue(iNumberOfParts == 1, @"Part count should be 1.");
				break;
			}
			case 5:
			{
				STAssertTrue(iNumberOfParts == 1, @"Part count should be 1.");
				break;
			}
			case 6:
			{
				STAssertTrue(iNumberOfParts == 1, @"Part count should be 1.");
				break;
			}
			case 7:
			{
				STAssertTrue(iNumberOfParts == 1, @"Part count should be 1.");
				break;
			}
				
				break;
			default:
				break;
		}
		
		
		
	}
	
	// Program chain testing
	
	
	
	for(int val = 0;val < [[titleSetInformation programChainInformationTable] count];val++)
	{
		
		DKProgramChainSearchPointer* programChainSearchPointerObj = [[titleSetInformation programChainInformationTable] objectAtIndex:val];
		switch (val) {
			case 0:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  51, @"Number of programs should be 51.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  80, @"Number of cells should be 80.");
				STAssertTrue([[tempProgramChain postCommands] count] ==  4, @"Number of post commands be 4.");
				break;
				
			}
			case 1:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  3, @"Number of programs should be 3.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  3, @"Number of cells should be 3.");
				STAssertTrue([[tempProgramChain postCommands] count] == 2, @"Number of post commands be 2.");
				break;
				
			}
			case 2:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  1, @"Number of programs should be 1.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  1, @"Number of cells should be 1.");
				STAssertTrue([[tempProgramChain postCommands] count] ==  3, @"Number of post commands be 3.");
				break;
				
			}
			case 3:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  1, @"Number of programs should be 1.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  1, @"Number of cells should be 1.");
				STAssertTrue([[tempProgramChain postCommands] count] ==  3, @"Number of post commands be 3.");
				break;
				
			}
			case 4:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  1, @"Number of programs should be 1.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  1, @"Number of cells should be 1.");
				STAssertTrue([[tempProgramChain postCommands] count] ==  3, @"Number of post commands be 3.");
				break;
				
			}
			case 5:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  0, @"Number of programs should be 0.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  0, @"Number of cells should be 0.");
				STAssertTrue([[tempProgramChain postCommands] count] ==  0, @"Number of post commands be 0.");
				break;
				
			}
			case 6:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  0, @"Number of programs should be 0.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  0, @"Number of cells should be 0.");
				STAssertTrue([[tempProgramChain postCommands] count] ==  0, @"Number of post commands be 0.");
				break;
				
			}
			case 7:
			{
				DKProgramChain* tempProgramChain = [programChainSearchPointerObj programChain];
				
				STAssertTrue([[tempProgramChain programMap] count] ==  0, @"Number of programs should be 0.");
				STAssertTrue([[tempProgramChain cellPlaybackTable] count] ==  0, @"Number of cells should be 0.");
				STAssertTrue([[tempProgramChain postCommands] count] ==  0, @"Number of post commands be 0.");
				break;
				
			}	
			default:
				break;
		}	
		
		
	}
	
	
    // Saving out our title set data
    NSData* titleObject = [titleSetInformation saveAsData:&error lengthOfMenuVOB:CFBitVectorGetCount([titleSetInformation menuVobuAddressMap]) lengthOfVideoVOB:CFBitVectorGetCount([titleSetInformation vobuAddressMap])];
      
    
    id<DKDataSource> tempDataSource = [[[DKDataDataSource alloc] initWithNSData:titleObject] autorelease];
    STAssertTrue(tempDataSource != nil, @"Unable to create a data source.");
    error = nil;

    DKTitleSetInformation* titleSetInformation2ndLoad = [DKTitleSetInformation titleSetInformationWithDataSource:tempDataSource index:1 error:&error];
    STAssertTrue(error == nil, @"Unable to create a MainMenuInformation instance.");
    STAssertTrue([titleSetInformation isEqual:titleSetInformation2ndLoad] == YES, @"isEqual should return true.");
    
}


@end
