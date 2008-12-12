#import "DvdTesting.h"
#import <DVDKit/DVDKit.h>

@implementation DvdTesting

- (void) testDecodingAndDescriptions
{
    DVDCommand* command;

    //0000000000000000 | Nop
command = [DVDCommand commandWith64Bits:0x0000000000000000L];
STAssertTrue([[command description] isEqualTo:@"      0000000000000000 | Nop"], @"Instruction not decoded properly.");

//0041000d00050004 | if (g[13] >= g[5]) Goto 4
command = [DVDCommand commandWith64Bits:0x0041000d00050004L];
STAssertTrue([[command description] isEqualTo:@"      0041000d00050004 | if (g[13] >= g[5]) Goto 4"], @"Instruction not decoded properly.");

//0091000a0020000c | if (g[10] & 0x20) Goto 12
command = [DVDCommand commandWith64Bits:0x0091000a0020000cL];
STAssertTrue([[command description] isEqualTo:@"      0091000a0020000c | if (g[10] & 0x20) Goto 12"], @"Instruction not decoded properly.");

//00a1000100010006 | if (g[1] == 0x1) Goto 6
command = [DVDCommand commandWith64Bits:0x00a1000100010006L];
STAssertTrue([[command description] isEqualTo:@"      00a1000100010006 | if (g[1] == 0x1) Goto 6"], @"Instruction not decoded properly.");

//00a1000900020025 | if (g[9] == 0x2) Goto 37
command = [DVDCommand commandWith64Bits:0x00a1000900020025L];
STAssertTrue([[command description] isEqualTo:@"      00a1000900020025 | if (g[9] == 0x2) Goto 37"], @"Instruction not decoded properly.");

//00a100090009002c | if (g[9] == 0x9) Goto 44
command = [DVDCommand commandWith64Bits:0x00a100090009002cL];
STAssertTrue([[command description] isEqualTo:@"      00a100090009002c | if (g[9] == 0x9) Goto 44"], @"Instruction not decoded properly.");

//00a1000900130003 | if (g[9] == 0x13) Goto 3
command = [DVDCommand commandWith64Bits:0x00a1000900130003L];
STAssertTrue([[command description] isEqualTo:@"      00a1000900130003 | if (g[9] == 0x13) Goto 3"], @"Instruction not decoded properly.");

//00a10009001c0003 | if (g[9] == 0x1c) Goto 3
command = [DVDCommand commandWith64Bits:0x00a10009001c0003L];
STAssertTrue([[command description] isEqualTo:@"      00a10009001c0003 | if (g[9] == 0x1c) Goto 3"], @"Instruction not decoded properly.");

//00a1000900250003 | if (g[9] == 0x25) Goto 3
command = [DVDCommand commandWith64Bits:0x00a1000900250003L];
STAssertTrue([[command description] isEqualTo:@"      00a1000900250003 | if (g[9] == 0x25) Goto 3"], @"Instruction not decoded properly.");

//00a100091200001c | if (g[9] == 0x1200) Goto 28
command = [DVDCommand commandWith64Bits:0x00a100091200001cL];
STAssertTrue([[command description] isEqualTo:@"      00a100091200001c | if (g[9] == 0x1200) Goto 28"], @"Instruction not decoded properly.");

//00a1000940000009 | if (g[9] == 0x4000) Goto 9
command = [DVDCommand commandWith64Bits:0x00a1000940000009L];
STAssertTrue([[command description] isEqualTo:@"      00a1000940000009 | if (g[9] == 0x4000) Goto 9"], @"Instruction not decoded properly.");

//00a1000980000010 | if (g[9] == 0x8000) Goto 16
command = [DVDCommand commandWith64Bits:0x00a1000980000010L];
STAssertTrue([[command description] isEqualTo:@"      00a1000980000010 | if (g[9] == 0x8000) Goto 16"], @"Instruction not decoded properly.");

//00a1000e2f010004 | if (g[14] == 0x2f01) Goto 4
command = [DVDCommand commandWith64Bits:0x00a1000e2f010004L];
STAssertTrue([[command description] isEqualTo:@"      00a1000e2f010004 | if (g[14] == 0x2f01) Goto 4"], @"Instruction not decoded properly.");

//00a2000900180000 | if (g[9] == 0x18) Break
command = [DVDCommand commandWith64Bits:0x00a2000900180000L];
STAssertTrue([[command description] isEqualTo:@"      00a2000900180000 | if (g[9] == 0x18) Break"], @"Instruction not decoded properly.");

//00b100040003001c | if (g[4] != 0x3) Goto 28
command = [DVDCommand commandWith64Bits:0x00b100040003001cL];
STAssertTrue([[command description] isEqualTo:@"      00b100040003001c | if (g[4] != 0x3) Goto 28"], @"Instruction not decoded properly.");

//00b100090000003f | if (g[9] != 0x0) Goto 63
command = [DVDCommand commandWith64Bits:0x00b100090000003fL];
STAssertTrue([[command description] isEqualTo:@"      00b100090000003f | if (g[9] != 0x0) Goto 63"], @"Instruction not decoded properly.");

//00b1000900090018 | if (g[9] != 0x9) Goto 24
command = [DVDCommand commandWith64Bits:0x00b1000900090018L];
STAssertTrue([[command description] isEqualTo:@"      00b1000900090018 | if (g[9] != 0x9) Goto 24"], @"Instruction not decoded properly.");

//00b100090014002e | if (g[9] != 0x14) Goto 46
command = [DVDCommand commandWith64Bits:0x00b100090014002eL];
STAssertTrue([[command description] isEqualTo:@"      00b100090014002e | if (g[9] != 0x14) Goto 46"], @"Instruction not decoded properly.");

//00b1000900200046 | if (g[9] != 0x20) Goto 70
command = [DVDCommand commandWith64Bits:0x00b1000900200046L];
STAssertTrue([[command description] isEqualTo:@"      00b1000900200046 | if (g[9] != 0x20) Goto 70"], @"Instruction not decoded properly.");

//00b1000f03e7000d | if (g[15] != 0x3e7) Goto 13
command = [DVDCommand commandWith64Bits:0x00b1000f03e7000dL];
STAssertTrue([[command description] isEqualTo:@"      00b1000f03e7000d | if (g[15] != 0x3e7) Goto 13"], @"Instruction not decoded properly.");

//00d1000400020014 | if (g[4] > 0x2) Goto 20
command = [DVDCommand commandWith64Bits:0x00d1000400020014L];
STAssertTrue([[command description] isEqualTo:@"      00d1000400020014 | if (g[4] > 0x2) Goto 20"], @"Instruction not decoded properly.");

//00e1000500ff0006 | if (g[5] <= 0xff) Goto 6
command = [DVDCommand commandWith64Bits:0x00e1000500ff0006L];
STAssertTrue([[command description] isEqualTo:@"      00e1000500ff0006 | if (g[5] <= 0xff) Goto 6"], @"Instruction not decoded properly.");

//2001000000001c06 | LinkNextPG (button 7)
command = [DVDCommand commandWith64Bits:0x2001000000001c06L];
STAssertTrue([[command description] isEqualTo:@"      2001000000001c06 | LinkNextPG (button 7)"], @"Instruction not decoded properly.");

//200400000000000a | LinkPGCN 10
command = [DVDCommand commandWith64Bits:0x200400000000000aL];
STAssertTrue([[command description] isEqualTo:@"      200400000000000a | LinkPGCN 10"], @"Instruction not decoded properly.");

//200400000000001a | LinkPGCN 26
command = [DVDCommand commandWith64Bits:0x200400000000001aL];
STAssertTrue([[command description] isEqualTo:@"      200400000000001a | LinkPGCN 26"], @"Instruction not decoded properly.");

//2004000000000027 | LinkPGCN 39
command = [DVDCommand commandWith64Bits:0x2004000000000027L];
STAssertTrue([[command description] isEqualTo:@"      2004000000000027 | LinkPGCN 39"], @"Instruction not decoded properly.");

//2004000000000033 | LinkPGCN 51
command = [DVDCommand commandWith64Bits:0x2004000000000033L];
STAssertTrue([[command description] isEqualTo:@"      2004000000000033 | LinkPGCN 51"], @"Instruction not decoded properly.");

//2006000000000401 | LinkPGN 1 (button 1)
command = [DVDCommand commandWith64Bits:0x2006000000000401L];
STAssertTrue([[command description] isEqualTo:@"      2006000000000401 | LinkPGN 1 (button 1)"], @"Instruction not decoded properly.");

//200600000000040d | LinkPGN 13 (button 1)
command = [DVDCommand commandWith64Bits:0x200600000000040dL];
STAssertTrue([[command description] isEqualTo:@"      200600000000040d | LinkPGN 13 (button 1)"], @"Instruction not decoded properly.");

//200600000000043a | LinkPGN 58 (button 1)
command = [DVDCommand commandWith64Bits:0x200600000000043aL];
STAssertTrue([[command description] isEqualTo:@"      200600000000043a | LinkPGN 58 (button 1)"], @"Instruction not decoded properly.");

//2006000000001401 | LinkPGN 1 (button 5)
command = [DVDCommand commandWith64Bits:0x2006000000001401L];
STAssertTrue([[command description] isEqualTo:@"      2006000000001401 | LinkPGN 1 (button 5)"], @"Instruction not decoded properly.");

//2006000000001417 | LinkPGN 23 (button 5)
command = [DVDCommand commandWith64Bits:0x2006000000001417L];
STAssertTrue([[command description] isEqualTo:@"      2006000000001417 | LinkPGN 23 (button 5)"], @"Instruction not decoded properly.");

//2006000000002001 | LinkPGN 1 (button 8)
command = [DVDCommand commandWith64Bits:0x2006000000002001L];
STAssertTrue([[command description] isEqualTo:@"      2006000000002001 | LinkPGN 1 (button 8)"], @"Instruction not decoded properly.");

//2094000a0004000a | if (g[10] & 0x4) LinkPGCN 10
command = [DVDCommand commandWith64Bits:0x2094000a0004000aL];
STAssertTrue([[command description] isEqualTo:@"      2094000a0004000a | if (g[10] & 0x4) LinkPGCN 10"], @"Instruction not decoded properly.");

//20a4000000ff0012 | if (g[0] == 0xff) LinkPGCN 18
command = [DVDCommand commandWith64Bits:0x20a4000000ff0012L];
STAssertTrue([[command description] isEqualTo:@"      20a4000000ff0012 | if (g[0] == 0xff) LinkPGCN 18"], @"Instruction not decoded properly.");

//20a4000830000006 | if (g[8] == 0x3000) LinkPGCN 6
command = [DVDCommand commandWith64Bits:0x20a4000830000006L];
STAssertTrue([[command description] isEqualTo:@"      20a4000830000006 | if (g[8] == 0x3000) LinkPGCN 6"], @"Instruction not decoded properly.");

//20a400090800000a | if (g[9] == 0x800) LinkPGCN 10
command = [DVDCommand commandWith64Bits:0x20a400090800000aL];
STAssertTrue([[command description] isEqualTo:@"      20a400090800000a | if (g[9] == 0x800) LinkPGCN 10"], @"Instruction not decoded properly.");

//20a50009cc060006 | if (g[9] == 0xcc06) LinkPTT 6
command = [DVDCommand commandWith64Bits:0x20a50009cc060006L];
STAssertTrue([[command description] isEqualTo:@"      20a50009cc060006 | if (g[9] == 0xcc06) LinkPTT 6"], @"Instruction not decoded properly.");

//20a50009cc100010 | if (g[9] == 0xcc10) LinkPTT 16
command = [DVDCommand commandWith64Bits:0x20a50009cc100010L];
STAssertTrue([[command description] isEqualTo:@"      20a50009cc100010 | if (g[9] == 0xcc10) LinkPTT 16"], @"Instruction not decoded properly.");

//20a50009cc1a001a | if (g[9] == 0xcc1a) LinkPTT 26
command = [DVDCommand commandWith64Bits:0x20a50009cc1a001aL];
STAssertTrue([[command description] isEqualTo:@"      20a50009cc1a001a | if (g[9] == 0xcc1a) LinkPTT 26"], @"Instruction not decoded properly.");

//20a6000064650801 | if (g[0] == 0x6465 ("de")) LinkPGN 1 (button 2)
command = [DVDCommand commandWith64Bits:0x20a6000064650801L];
STAssertTrue([[command description] isEqualTo:@"      20a6000064650801 | if (g[0] == 0x6465 (\"de\")) LinkPGN 1 (button 2)"], @"Instruction not decoded properly.");

//20a6000800010003 | if (g[8] == 0x1) LinkPGN 3
command = [DVDCommand commandWith64Bits:0x20a6000800010003L];
STAssertTrue([[command description] isEqualTo:@"      20a6000800010003 | if (g[8] == 0x1) LinkPGN 3"], @"Instruction not decoded properly.");

//20a6000900061405 | if (g[9] == 0x6) LinkPGN 5 (button 5)
command = [DVDCommand commandWith64Bits:0x20a6000900061405L];
STAssertTrue([[command description] isEqualTo:@"      20a6000900061405 | if (g[9] == 0x6) LinkPGN 5 (button 5)"], @"Instruction not decoded properly.");

//20a600090013080a | if (g[9] == 0x13) LinkPGN 10 (button 2)
command = [DVDCommand commandWith64Bits:0x20a600090013080aL];
STAssertTrue([[command description] isEqualTo:@"      20a600090013080a | if (g[9] == 0x13) LinkPGN 10 (button 2)"], @"Instruction not decoded properly.");

//20a6000900180801 | if (g[9] == 0x18) LinkPGN 1 (button 2)
command = [DVDCommand commandWith64Bits:0x20a6000900180801L];
STAssertTrue([[command description] isEqualTo:@"      20a6000900180801 | if (g[9] == 0x18) LinkPGN 1 (button 2)"], @"Instruction not decoded properly.");

//20a6000905130c01 | if (g[9] == 0x513) LinkPGN 1 (button 3)
command = [DVDCommand commandWith64Bits:0x20a6000905130c01L];
STAssertTrue([[command description] isEqualTo:@"      20a6000905130c01 | if (g[9] == 0x513) LinkPGN 1 (button 3)"], @"Instruction not decoded properly.");

//20a6000909030003 | if (g[9] == 0x903) LinkPGN 3
command = [DVDCommand commandWith64Bits:0x20a6000909030003L];
STAssertTrue([[command description] isEqualTo:@"      20a6000909030003 | if (g[9] == 0x903) LinkPGN 3"], @"Instruction not decoded properly.");

//20a70009cea4000b | if (g[9] == 0xcea4) LinkCN 11
command = [DVDCommand commandWith64Bits:0x20a70009cea4000bL];
STAssertTrue([[command description] isEqualTo:@"      20a70009cea4000b | if (g[9] == 0xcea4) LinkCN 11"], @"Instruction not decoded properly.");

//20b4000100040002 | if (g[1] != 0x4) LinkPGCN 2
command = [DVDCommand commandWith64Bits:0x20b4000100040002L];
STAssertTrue([[command description] isEqualTo:@"      20b4000100040002 | if (g[1] != 0x4) LinkPGCN 2"], @"Instruction not decoded properly.");

//20f4000900640006 | if (g[9] < 0x64) LinkPGCN 6
command = [DVDCommand commandWith64Bits:0x20f4000900640006L];
STAssertTrue([[command description] isEqualTo:@"      20f4000900640006 | if (g[9] < 0x64) LinkPGCN 6"], @"Instruction not decoded properly.");

//3002000000080000 | JumpTT 8
command = [DVDCommand commandWith64Bits:0x3002000000080000L];
STAssertTrue([[command description] isEqualTo:@"      3002000000080000 | JumpTT 8"], @"Instruction not decoded properly.");

//3002000000120000 | JumpTT 18
command = [DVDCommand commandWith64Bits:0x3002000000120000L];
STAssertTrue([[command description] isEqualTo:@"      3002000000120000 | JumpTT 18"], @"Instruction not decoded properly.");

//30020000001c0000 | JumpTT 28
command = [DVDCommand commandWith64Bits:0x30020000001c0000L];
STAssertTrue([[command description] isEqualTo:@"      30020000001c0000 | JumpTT 28"], @"Instruction not decoded properly.");

//3002000000260000 | JumpTT 38
command = [DVDCommand commandWith64Bits:0x3002000000260000L];
STAssertTrue([[command description] isEqualTo:@"      3002000000260000 | JumpTT 38"], @"Instruction not decoded properly.");

//3006000105870000 | JumpSS VTSM (vts 5, title 1, menu 7)
command = [DVDCommand commandWith64Bits:0x3006000105870000L];
STAssertTrue([[command description] isEqualTo:@"      3006000105870000 | JumpSS VTSM (vts 5, title 1, menu 7)"], @"Instruction not decoded properly.");

//3006000d00c00000 | JumpSS VMGM (pgc 13)
command = [DVDCommand commandWith64Bits:0x3006000d00c00000L];
STAssertTrue([[command description] isEqualTo:@"      3006000d00c00000 | JumpSS VMGM (pgc 13)"], @"Instruction not decoded properly.");

//3025000600010001 | if (g[0] == g[1]) JumpVTS_PTT 1:6
command = [DVDCommand commandWith64Bits:0x3025000600010001L];
STAssertTrue([[command description] isEqualTo:@"      3025000600010001 | if (g[0] == g[1]) JumpVTS_PTT 1:6"], @"Instruction not decoded properly.");

//3025001000010001 | if (g[0] == g[1]) JumpVTS_PTT 1:16
command = [DVDCommand commandWith64Bits:0x3025001000010001L];
STAssertTrue([[command description] isEqualTo:@"      3025001000010001 | if (g[0] == g[1]) JumpVTS_PTT 1:16"], @"Instruction not decoded properly.");

//4100000081000000 | Sub-picture Stream Number (SRPM:2) = g[1]
command = [DVDCommand commandWith64Bits:0x4100000081000000L];
STAssertTrue([[command description] isEqualTo:@"      4100000081000000 | Sub-picture Stream Number (SRPM:2) = g[1]"], @"Instruction not decoded properly.");

//4100008e00000000 | Audio Stream Number (SRPM:1) = g[14]
command = [DVDCommand commandWith64Bits:0x4100008e00000000L];
STAssertTrue([[command description] isEqualTo:@"      4100008e00000000 | Audio Stream Number (SRPM:1) = g[14]"], @"Instruction not decoded properly.");

//5604000004000002 | Highlighted Button Number (SRPM:8) = 0x400 (button 1), LinkPGCN 2
command = [DVDCommand commandWith64Bits:0x5604000004000002L];
STAssertTrue([[command description] isEqualTo:@"      5604000004000002 | Highlighted Button Number (SRPM:8) = 0x400 (button 1), LinkPGCN 2"], @"Instruction not decoded properly.");

//6100000100850000 | g[1] = VTS Title Track Number (SRPM:5)
command = [DVDCommand commandWith64Bits:0x6100000100850000L];
STAssertTrue([[command description] isEqualTo:@"      6100000100850000 | g[1] = VTS Title Track Number (SRPM:5)"], @"Instruction not decoded properly.");

//61000004000a0000 | g[4] = g[10]
command = [DVDCommand commandWith64Bits:0x61000004000a0000L];
STAssertTrue([[command description] isEqualTo:@"      61000004000a0000 | g[4] = g[10]"], @"Instruction not decoded properly.");

//6100000900020000 | g[9] = g[2]
command = [DVDCommand commandWith64Bits:0x6100000900020000L];
STAssertTrue([[command description] isEqualTo:@"      6100000900020000 | g[9] = g[2]"], @"Instruction not decoded properly.");

//6100000b000c0000 | g[11] = g[12]
command = [DVDCommand commandWith64Bits:0x6100000b000c0000L];
STAssertTrue([[command description] isEqualTo:@"      6100000b000c0000 | g[11] = g[12]"], @"Instruction not decoded properly.");

//6170000d000f0005 | if (g[0] < g[5]) g[13] = g[15]
command = [DVDCommand commandWith64Bits:0x6170000d000f0005L];
STAssertTrue([[command description] isEqualTo:@"      6170000d000f0005 | if (g[0] < g[5]) g[13] = g[15]"], @"Instruction not decoded properly.");

//7100000000010000 | g[0] = 0x1
command = [DVDCommand commandWith64Bits:0x7100000000010000L];
STAssertTrue([[command description] isEqualTo:@"      7100000000010000 | g[0] = 0x1"], @"Instruction not decoded properly.");

//7100000100080000 | g[1] = 0x8
command = [DVDCommand commandWith64Bits:0x7100000100080000L];
STAssertTrue([[command description] isEqualTo:@"      7100000100080000 | g[1] = 0x8"], @"Instruction not decoded properly.");

//7100000100120000 | g[1] = 0x12
command = [DVDCommand commandWith64Bits:0x7100000100120000L];
STAssertTrue([[command description] isEqualTo:@"      7100000100120000 | g[1] = 0x12"], @"Instruction not decoded properly.");

//7100000300430000 | g[3] = 0x43
command = [DVDCommand commandWith64Bits:0x7100000300430000L];
STAssertTrue([[command description] isEqualTo:@"      7100000300430000 | g[3] = 0x43"], @"Instruction not decoded properly.");

//7100000800000000 | g[8] = 0x0
command = [DVDCommand commandWith64Bits:0x7100000800000000L];
STAssertTrue([[command description] isEqualTo:@"      7100000800000000 | g[8] = 0x0"], @"Instruction not decoded properly.");

//7100000900160000 | g[9] = 0x16
command = [DVDCommand commandWith64Bits:0x7100000900160000L];
STAssertTrue([[command description] isEqualTo:@"      7100000900160000 | g[9] = 0x16"], @"Instruction not decoded properly.");

//7100000a00000000 | g[10] = 0x0
command = [DVDCommand commandWith64Bits:0x7100000a00000000L];
STAssertTrue([[command description] isEqualTo:@"      7100000a00000000 | g[10] = 0x0"], @"Instruction not decoded properly.");

//7100000c00040000 | g[12] = 0x4
command = [DVDCommand commandWith64Bits:0x7100000c00040000L];
STAssertTrue([[command description] isEqualTo:@"      7100000c00040000 | g[12] = 0x4"], @"Instruction not decoded properly.");

//7100000e25040000 | g[14] = 0x2504
command = [DVDCommand commandWith64Bits:0x7100000e25040000L];
STAssertTrue([[command description] isEqualTo:@"      7100000e25040000 | g[14] = 0x2504"], @"Instruction not decoded properly.");

//7100000e2f010000 | g[14] = 0x2f01
command = [DVDCommand commandWith64Bits:0x7100000e2f010000L];
STAssertTrue([[command description] isEqualTo:@"      7100000e2f010000 | g[14] = 0x2f01"], @"Instruction not decoded properly.");

//710100043001000d | g[4] = 0x3001, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x710100043001000dL];
STAssertTrue([[command description] isEqualTo:@"      710100043001000d | g[4] = 0x3001, LinkTailPGC"], @"Instruction not decoded properly.");

//7101000e1008000d | g[14] = 0x1008, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x7101000e1008000dL];
STAssertTrue([[command description] isEqualTo:@"      7101000e1008000d | g[14] = 0x1008, LinkTailPGC"], @"Instruction not decoded properly.");

//7101000e1018000d | g[14] = 0x1018, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x7101000e1018000dL];
STAssertTrue([[command description] isEqualTo:@"      7101000e1018000d | g[14] = 0x1018, LinkTailPGC"], @"Instruction not decoded properly.");

//7101000e4800000d | g[14] = 0x4800, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x7101000e4800000dL];
STAssertTrue([[command description] isEqualTo:@"      7101000e4800000d | g[14] = 0x4800, LinkTailPGC"], @"Instruction not decoded properly.");

//7101000e9501000d | g[14] = 0x9501, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x7101000e9501000dL];
STAssertTrue([[command description] isEqualTo:@"      7101000e9501000d | g[14] = 0x9501, LinkTailPGC"], @"Instruction not decoded properly.");

//7101000ecc05000d | g[14] = 0xcc05, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x7101000ecc05000dL];
STAssertTrue([[command description] isEqualTo:@"      7101000ecc05000d | g[14] = 0xcc05, LinkTailPGC"], @"Instruction not decoded properly.");

//7101000ecc0f000d | g[14] = 0xcc0f, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x7101000ecc0f000dL];
STAssertTrue([[command description] isEqualTo:@"      7101000ecc0f000d | g[14] = 0xcc0f, LinkTailPGC"], @"Instruction not decoded properly.");

//7101000ecea7000d | g[14] = 0xcea7, LinkTailPGC
command = [DVDCommand commandWith64Bits:0x7101000ecea7000dL];
STAssertTrue([[command description] isEqualTo:@"      7101000ecea7000d | g[14] = 0xcea7, LinkTailPGC"], @"Instruction not decoded properly.");

//7104000000040015 | g[0] = 0x4, LinkPGCN 21
command = [DVDCommand commandWith64Bits:0x7104000000040015L];
STAssertTrue([[command description] isEqualTo:@"      7104000000040015 | g[0] = 0x4, LinkPGCN 21"], @"Instruction not decoded properly.");

//71040000000e0015 | g[0] = 0xe, LinkPGCN 21
command = [DVDCommand commandWith64Bits:0x71040000000e0015L];
STAssertTrue([[command description] isEqualTo:@"      71040000000e0015 | g[0] = 0xe, LinkPGCN 21"], @"Instruction not decoded properly.");

//7104000000650005 | g[0] = 0x65, LinkPGCN 5
command = [DVDCommand commandWith64Bits:0x7104000000650005L];
STAssertTrue([[command description] isEqualTo:@"      7104000000650005 | g[0] = 0x65, LinkPGCN 5"], @"Instruction not decoded properly.");

//7104000300cc0016 | g[3] = 0xcc, LinkPGCN 22
command = [DVDCommand commandWith64Bits:0x7104000300cc0016L];
STAssertTrue([[command description] isEqualTo:@"      7104000300cc0016 | g[3] = 0xcc, LinkPGCN 22"], @"Instruction not decoded properly.");

//7104000300d80016 | g[3] = 0xd8, LinkPGCN 22
command = [DVDCommand commandWith64Bits:0x7104000300d80016L];
STAssertTrue([[command description] isEqualTo:@"      7104000300d80016 | g[3] = 0xd8, LinkPGCN 22"], @"Instruction not decoded properly.");

//7104000805540005 | g[8] = 0x554, LinkPGCN 5
command = [DVDCommand commandWith64Bits:0x7104000805540005L];
STAssertTrue([[command description] isEqualTo:@"      7104000805540005 | g[8] = 0x554, LinkPGCN 5"], @"Instruction not decoded properly.");

//7104000b00010026 | g[11] = 0x1, LinkPGCN 38
command = [DVDCommand commandWith64Bits:0x7104000b00010026L];
STAssertTrue([[command description] isEqualTo:@"      7104000b00010026 | g[11] = 0x1, LinkPGCN 38"], @"Instruction not decoded properly.");

//7104000c0001000c | g[12] = 0x1, LinkPGCN 12
command = [DVDCommand commandWith64Bits:0x7104000c0001000cL];
STAssertTrue([[command description] isEqualTo:@"      7104000c0001000c | g[12] = 0x1, LinkPGCN 12"], @"Instruction not decoded properly.");

//71900a0000000002 | if (g[10] & 0x2) g[0] = 0x0
command = [DVDCommand commandWith64Bits:0x71900a0000000002L];
STAssertTrue([[command description] isEqualTo:@"      71900a0000000002 | if (g[10] & 0x2) g[0] = 0x0"], @"Instruction not decoded properly.");

//71a00309000d0192 | if (g[3] == 0x192) g[9] = 0xd
command = [DVDCommand commandWith64Bits:0x71a00309000d0192L];
STAssertTrue([[command description] isEqualTo:@"      71a00309000d0192 | if (g[3] == 0x192) g[9] = 0xd"], @"Instruction not decoded properly.");

//71a00309001900cb | if (g[3] == 0xcb) g[9] = 0x19
command = [DVDCommand commandWith64Bits:0x71a00309001900cbL];
STAssertTrue([[command description] isEqualTo:@"      71a00309001900cb | if (g[3] == 0xcb) g[9] = 0x19"], @"Instruction not decoded properly.");

//71a00c0100000002 | if (g[12] == 0x2) g[1] = 0x0
command = [DVDCommand commandWith64Bits:0x71a00c0100000002L];
STAssertTrue([[command description] isEqualTo:@"      71a00c0100000002 | if (g[12] == 0x2) g[1] = 0x0"], @"Instruction not decoded properly.");

//71c00309001300d1 | if (g[3] >= 0xd1) g[9] = 0x13
command = [DVDCommand commandWith64Bits:0x71c00309001300d1L];
STAssertTrue([[command description] isEqualTo:@"      71c00309001300d1 | if (g[3] >= 0xd1) g[9] = 0x13"], @"Instruction not decoded properly.");

//7300000b00010000 | g[11] += 0x1
command = [DVDCommand commandWith64Bits:0x7300000b00010000L];
STAssertTrue([[command description] isEqualTo:@"      7300000b00010000 | g[11] += 0x1"], @"Instruction not decoded properly.");

//7500000004000000 | g[0] *= 0x400
command = [DVDCommand commandWith64Bits:0x7500000004000000L];
STAssertTrue([[command description] isEqualTo:@"      7500000004000000 | g[0] *= 0x400"], @"Instruction not decoded properly.");

//7700000000640000 | g[0] %= 0x64
command = [DVDCommand commandWith64Bits:0x7700000000640000L];
STAssertTrue([[command description] isEqualTo:@"      7700000000640000 | g[0] %= 0x64"], @"Instruction not decoded properly.");

//7900000300ff0000 | g[3] &= 0xff
command = [DVDCommand commandWith64Bits:0x7900000300ff0000L];
STAssertTrue([[command description] isEqualTo:@"      7900000300ff0000 | g[3] &= 0xff"], @"Instruction not decoded properly.");

//790000090f000000 | g[9] &= 0xf00
command = [DVDCommand commandWith64Bits:0x790000090f000000L];
STAssertTrue([[command description] isEqualTo:@"      790000090f000000 | g[9] &= 0xf00"], @"Instruction not decoded properly.");

//7900000affef0000 | g[10] &= 0xffef
command = [DVDCommand commandWith64Bits:0x7900000affef0000L];
STAssertTrue([[command description] isEqualTo:@"      7900000affef0000 | g[10] &= 0xffef"], @"Instruction not decoded properly.");

//7a00000a00020000 | g[10] |= 0x2
command = [DVDCommand commandWith64Bits:0x7a00000a00020000L];
STAssertTrue([[command description] isEqualTo:@"      7a00000a00020000 | g[10] |= 0x2"], @"Instruction not decoded properly.");

//7b00000400010000 | g[4] ^= 0x1
command = [DVDCommand commandWith64Bits:0x7b00000400010000L];
STAssertTrue([[command description] isEqualTo:@"      7b00000400010000 | g[4] ^= 0x1"], @"Instruction not decoded properly.");

	    
	
}

- (void) testExecutionOfSimpleInstructions
{
    /* We shouldn't be testing instructions that need *real* a datasource 
     * in this pass, so we'll just pass in ourselves.
     */
    DVDVirtualMachine* vm = [[DVDVirtualMachine alloc] initWithDataSource:self];
    for (int i = 0; i < 16; i++) {
        STAssertTrue([vm generalPurposeRegister:i] == 0, @"This register has the wrong initial value.");
    }
    id initialState = [vm state];

    //  0000000000000000 | Nop
    [[DVDCommand commandWith64Bits:0x0000000000000000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([[vm state] isEqual:initialState], @"Nop should have no effect."); 


    /*  Test basic arithmetic (Add / Subtract / Multiply / Divide)
     */
    
    //  7100000000010000 | g[0] = 0x1
    [[DVDCommand commandWith64Bits:0x7100000000010000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:0] == 1, @"7100000000010000 | g[0] = 0x1");

    //  7100000100020000 | g[1] = 0x2
    [[DVDCommand commandWith64Bits:0x7100000100020000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 2, @"7100000100020000 | g[1] = 0x2");

    //  7300000100010000 | g[1] += 0x1
    [[DVDCommand commandWith64Bits:0x7300000100010000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 3, @"7300000100010000 | g[1] += 0x1");

    //  7400000100010000 | g[1] -= 0x1
    [[DVDCommand commandWith64Bits:0x7100000100020000L] executeAgainstVirtualMachine:vm];
    STAssertTrue([vm generalPurposeRegister:1] == 2, @"7400000100010000 | g[1] -= 0x1");

    // TODO: Implement more instructions.


    /*  Test basic bitwise arithmetic (Or / Xor / And / Not)
     */

    // TODO: Implement me.

    
    /*  Test for proper 16-bit register overflow/underflow.  (0xFFFF + 1, etc.)
     */

    // TODO: Implement me.
    
    
}

@end
