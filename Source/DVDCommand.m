/*
 * Copyright (C) 2008 Jason Allum
 *               2008 RipItApp.com
 * 
 * This file is part of DVDKit, an Objective-C DVD player emulation toolkit. 
 * 
 * DVDKit is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * libdvdnav is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
 *
 */
#import "DVDKit.h"
#import "DVDCommand+Private.h"

@implementation DVDCommand

+ (id) commandWithData:(NSData*)data
{
    return [DVDCommand commandWithData:data row:-1];
}

+ (id) commandWithData:(NSData*)data row:(int)row
{
    return [[[DVDCommand alloc] initWithData:data row:row] autorelease];
}

- (id) initWithData:(NSData*)data row:(int)_row;
{
    NSAssert(data, @"Shouldn't be nil");
    NSAssert([data length] == 8, @"Must be 8 bytes");
    if (self = [super init]) {
        bits = OSReadBigInt64([data bytes], 0x00);
        mask = 0;
        row = _row;
    }
    return self;
}

- (void) executeAgainstVirtualMachine:(DVDVirtualMachine*)virtualMachine
{
    uint8_t type = [self bitsInRange:NSMakeRange(63, 3)];
    if (type >= 7) {
        [NSException raise:@"DVDCommand" format:@"Unexpected type (%d)", type];
    } else switch (type) {
        case 0: {
            uint8_t command = [self bitsInRange:NSMakeRange(51, 4)];
            uint8_t comparison = [self bitsInRange:NSMakeRange(54, 3)];
            if (command && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:[self bitsInRange:NSMakeRange(39, 8)]] value2:[self bitsInRange:NSMakeRange(55, 1)] ? [self bitsInRange:NSMakeRange(31, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(23, 8)]]])) switch (command) {
                case 1: {
                    [virtualMachine executeGoto:[self bitsInRange:NSMakeRange(7, 8)]];
                    break;
                }
                case 2: {
                    [virtualMachine executeBreak];
                    break;
                }
                case 3: {
                    [virtualMachine setTmpPML:[self bitsInRange:NSMakeRange(11, 4)] line:[self bitsInRange:NSMakeRange(7, 8)]];
                    break;
                }
            }
            break;
        }
        
        case 1: {
            uint8_t command = [self bitsInRange:NSMakeRange(51, 4)];
            uint8_t comparison = [self bitsInRange:NSMakeRange(54, 3)];
            if ([self bitsInRange:NSMakeRange(60, 1)]) {
                if (command && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:[self bitsInRange:NSMakeRange(15, 8)]] value2:[virtualMachine registerForCode:[self bitsInRange:NSMakeRange(7, 8)]]])) switch (command) {
                    case 1: {        
                        [virtualMachine stop];
                        break;
                    }
                    case 2: {
                        [virtualMachine executeJumpTT:[self bitsInRange:NSMakeRange(23, 8)]];
                        break;
                    }
                    case 3: {
                        [virtualMachine executeJumpVTS_TT:[self bitsInRange:NSMakeRange(23, 8)]];
                        break;
                    }
                    case 5: {
                        [virtualMachine executeJumpVTS_PTT:[self bitsInRange:NSMakeRange(23, 8)] pttn:[self bitsInRange:NSMakeRange(43, 12)]];
                        break;
                    }
                    case 6: {
                        switch ([self bitsInRange:NSMakeRange(23, 2)]) {
                            case 0: {
                                [virtualMachine executeJumpSS_FP];
                                break;
                            }
                            case 1: {
                                [virtualMachine executeJumpSS_VMGM_menu:[self bitsInRange:NSMakeRange(20, 5)]];
                                break;
                            }
                            case 2: {
                                [virtualMachine executeJumpSS_VTSM_menu:[self bitsInRange:NSMakeRange(20, 5)] vts:[self bitsInRange:NSMakeRange(31, 8)] ttn:[self bitsInRange:NSMakeRange(39, 8)]];
                                break;
                            }
                            case 3: {
                                [virtualMachine executeJumpSS_VMGM_pgcn:[self bitsInRange:NSMakeRange(47, 16)]];
                                break;
                            }
                        }
                        break;
                    }
                    case 8: {
                        switch ([self bitsInRange:NSMakeRange(23, 2)]) {
                            case 0: {
                                [virtualMachine executeCallSS_FP];
                                break;
                            }
                            case 1: {
                                [virtualMachine executeCallSS_VMGM_menu:[self bitsInRange:NSMakeRange(20, 5)] resumeCell:[self bitsInRange:NSMakeRange(31, 8)]];
                                break;
                            }
                            case 2: {
                                [virtualMachine executeCallSS_VTSM_menu:[self bitsInRange:NSMakeRange(20, 5)] resumeCell:[self bitsInRange:NSMakeRange(31, 8)]];
                                break;
                            }
                            case 3: {
                                [virtualMachine executeCallSS_VMGM_pgcn:[self bitsInRange:NSMakeRange(47, 16)] resumeCell:[self bitsInRange:NSMakeRange(31, 8)]];
                                break;
                            }
                        }
                        break;
                    }
                }
            } else {
                if (command && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:[self bitsInRange:NSMakeRange(39,8)]] value2:[self bitsInRange:NSMakeRange(55, 1)] ? [self bitsInRange:NSMakeRange(31, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(23, 8)]]])) switch (command) {
                    case 1: {
                        [virtualMachine executeLinkSubset:[self bitsInRange:NSMakeRange(4, 5)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                    case 4: {
                        [virtualMachine executeLinkPGCN:[self bitsInRange:NSMakeRange(15, 16)]];
                        break;
                    }
                    case 5: {
                        [virtualMachine executeLinkPTTN:[self bitsInRange:NSMakeRange(9, 10)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                    case 6: {
                        [virtualMachine executeLinkPGN:[self bitsInRange:NSMakeRange(7, 8)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                    case 7: {
                        [virtualMachine executeLinkCell:[self bitsInRange:NSMakeRange(7, 8)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                }
            }
            break;
        }

        case 2: {
            uint8_t direct = [self bitsInRange:NSMakeRange(60, 1)];
            uint8_t set = [self bitsInRange:NSMakeRange(59, 4)];
            uint8_t comparison = [self bitsInRange:NSMakeRange(54, 3)];
            if (set && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:[self bitsInRange:NSMakeRange(15, 8)]] value2:[virtualMachine registerForCode:[self bitsInRange:NSMakeRange(7, 8)]]])) {
                switch (set) {
                    case 1: {
                        if ([self bitsInRange:NSMakeRange(39, 1)]) {
                            [virtualMachine setValue:(direct) ? [self bitsInRange:NSMakeRange(38, 7)] : [virtualMachine generalPurposeRegister:[self bitsInRange:NSMakeRange(35, 4)]] forSystemParameterRegister:1];
                        }
                        if ([self bitsInRange:NSMakeRange(31, 1)]) {
                            [virtualMachine setValue:(direct) ? [self bitsInRange:NSMakeRange(30, 7)] : [virtualMachine generalPurposeRegister:[self bitsInRange:NSMakeRange(27, 4)]] forSystemParameterRegister:2];
                        }
                        if ([self bitsInRange:NSMakeRange(23, 1)]) {
                            [virtualMachine setValue:(direct) ? [self bitsInRange:NSMakeRange(22, 7)] : [virtualMachine generalPurposeRegister:[self bitsInRange:NSMakeRange(19, 4)]] forSystemParameterRegister:3];
                        }
                        break;
                    }
                    case 2: {
                        [virtualMachine setValue:(direct) ? [self bitsInRange:NSMakeRange(47, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(39, 8)]] forSystemParameterRegister:9];
                        [virtualMachine setValue:[self bitsInRange:NSMakeRange(31, 16)] forSystemParameterRegister:10];
                        break;
                    }
                    case 3: {
                        uint8_t index = [self bitsInRange:NSMakeRange(19, 4)];
                        [virtualMachine setMode:[self bitsInRange:NSMakeRange(23, 1)] forGeneralPurposeRegister:index];
                        [virtualMachine setValue:(direct) ? [self bitsInRange:NSMakeRange(47, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(39, 8)]] forGeneralPurposeRegister:index];
                        break;
                    }
                    case 6: {
                        [virtualMachine setValue:(direct) ? [self bitsInRange:NSMakeRange(31, 16)] : [virtualMachine generalPurposeRegister:[self bitsInRange:NSMakeRange(19, 4)]] forSystemParameterRegister:8];
                        break;
                    }
                }
                if (!comparison) switch ([self bitsInRange:NSMakeRange(51, 4)]) {
                    case 1: {
                        [virtualMachine executeLinkSubset:[self bitsInRange:NSMakeRange(4, 5)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                    case 4: {
                        [virtualMachine executeLinkPGCN:[self bitsInRange:NSMakeRange(15, 16)]];
                        break;
                    }
                    case 5: {
                        [virtualMachine executeLinkPTTN:[self bitsInRange:NSMakeRange(9, 10)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                    case 6: {
                        [virtualMachine executeLinkPGN:[self bitsInRange:NSMakeRange(7, 8)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                    case 7: {
                        [virtualMachine executeLinkCell:[self bitsInRange:NSMakeRange(7, 8)]];
                        [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                        break;
                    }
                }
            }
            break;
        }
        
        case 3: {
            uint8_t direct = [self bitsInRange:NSMakeRange(60, 1)];
            uint8_t setop = [self bitsInRange:NSMakeRange(59, 4)];
            uint8_t comparison = [self bitsInRange:NSMakeRange(54, 3)];
            if (setop && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:[self bitsInRange:NSMakeRange(47, 8)]] value2:[self bitsInRange:NSMakeRange(55, 1)] ? [self bitsInRange:NSMakeRange(15, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(7, 8)]]])) {
                uint8_t srd = [self bitsInRange:NSMakeRange(35, 4)];
                if (2 == setop && !direct) /* swap */ {
                    uint8_t srs = [self bitsInRange:NSMakeRange(23, 8)];
                    uint16_t x = [virtualMachine registerForCode:srs];
                    [virtualMachine setValue:[virtualMachine generalPurposeRegister:srd] forRegisterForCode:srs];
                    [virtualMachine setValue:x forGeneralPurposeRegister:srd];
                } else {
                    [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:srd] value2:(direct) ? [self bitsInRange:NSMakeRange(31, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(23, 8)]]] forGeneralPurposeRegister:srd];
                }
                if (!comparison) {
                    switch ([self bitsInRange:NSMakeRange(51, 4)]) {
                        case 1: {
                            [virtualMachine executeLinkSubset:[self bitsInRange:NSMakeRange(4, 5)]];
                            [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                            break;
                        }
                        case 4: {
                            [virtualMachine executeLinkPGCN:[self bitsInRange:NSMakeRange(15, 16)]];
                            break;
                        }
                        case 5: {
                            [virtualMachine executeLinkPTTN:[self bitsInRange:NSMakeRange(9, 10)]];
                            [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                            break;
                        }
                        case 6: {
                            [virtualMachine executeLinkPGN:[self bitsInRange:NSMakeRange(7, 8)]];
                            [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                            break;
                        }
                        case 7: {
                            [virtualMachine executeLinkCell:[self bitsInRange:NSMakeRange(7, 8)]];
                            [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
                            break;
                        }
                    }
                }
            }
            break;
        }
        
        case 4: {
            uint8_t direct = [self bitsInRange:NSMakeRange(60, 1)];
            uint8_t setop = [self bitsInRange:NSMakeRange(59, 4)];
            uint8_t scr = [self bitsInRange:NSMakeRange(51, 4)];
            if (setop) {
                if (2 == setop && !direct) /* swap */ {
                    uint8_t srs = [self bitsInRange:NSMakeRange(39, 8)];
                    uint16_t x = [virtualMachine registerForCode:srs];
                    [virtualMachine setValue:[virtualMachine generalPurposeRegister:scr] forRegisterForCode:srs];
                    [virtualMachine setValue:x forGeneralPurposeRegister:scr];
                } else {
                    [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:scr] value2:(direct) ? [self bitsInRange:NSMakeRange(47, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(39, 8)]]] forGeneralPurposeRegister:scr];
                }
            }
            uint8_t comparison = [self bitsInRange:NSMakeRange(54, 3)];
            if (!comparison || [self executeComparison:comparison value1:[virtualMachine generalPurposeRegister:scr] value2:[self bitsInRange:NSMakeRange(55, 1)] ? [self bitsInRange:NSMakeRange(31, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(23, 8)]]]) {
                [virtualMachine executeLinkSubset:[self bitsInRange:NSMakeRange(4, 5)]];
                [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
            }
              break;
        }
        
        case 5: {
            uint8_t direct = [self bitsInRange:NSMakeRange(60, 1)];
            uint8_t setop = [self bitsInRange:NSMakeRange(59, 4)];
            uint8_t scr = [self bitsInRange:NSMakeRange(51, 4)];
            uint8_t comparison = [self bitsInRange:NSMakeRange(54, 3)];
            if (!comparison || [self executeComparison:comparison value1:[virtualMachine generalPurposeRegister:scr] value2:[self bitsInRange:NSMakeRange(55, 1)] ? [self bitsInRange:NSMakeRange(31, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(23, 8)]]]) {
                if (setop) {
                    if (2 == setop && !direct) /* swap */ {
                        uint8_t srs = [self bitsInRange:NSMakeRange(39, 8)];
                        uint16_t x = [virtualMachine registerForCode:srs];
                        [virtualMachine setValue:[virtualMachine generalPurposeRegister:scr] forRegisterForCode:srs];
                        [virtualMachine setValue:x forGeneralPurposeRegister:scr];
                    } else {
                        [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:scr] value2:(direct) ? [self bitsInRange:NSMakeRange(47, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(39, 8)]]] forGeneralPurposeRegister:scr];
                    }
                }
                [virtualMachine executeLinkSubset:[self bitsInRange:NSMakeRange(4, 5)]];
                [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
            }
            break;
        }
        
        case 6: {
            uint8_t comparison = [self bitsInRange:NSMakeRange(54, 3)];
            uint8_t scr = [self bitsInRange:NSMakeRange(51, 4)];
            if (!comparison || [self executeComparison:comparison value1:[virtualMachine generalPurposeRegister:scr] value2:[self bitsInRange:NSMakeRange(55, 1)] ? [self bitsInRange:NSMakeRange(31, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(23, 8)]]]) {
                uint8_t direct = [self bitsInRange:NSMakeRange(60, 1)];
                uint8_t setop = [self bitsInRange:NSMakeRange(59, 4)];
                if (setop) {
                    if (2 == setop && !direct) /* swap */ {
                        uint8_t srs = [self bitsInRange:NSMakeRange(39, 8)];
                        uint16_t x = [virtualMachine registerForCode:srs];
                        [virtualMachine setValue:[virtualMachine generalPurposeRegister:scr] forRegisterForCode:srs];
                        [virtualMachine setValue:x forGeneralPurposeRegister:scr];
                    } else {
                        [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:scr] value2:(direct) ? [self bitsInRange:NSMakeRange(47, 16)] : [virtualMachine registerForCode:[self bitsInRange:NSMakeRange(39, 8)]]] forGeneralPurposeRegister:scr];
                    }
                }
            }
            [virtualMachine executeLinkSubset:[self bitsInRange:NSMakeRange(4, 5)]];
            [virtualMachine conditionallySetHighlightedButton:[self bitsInRange:NSMakeRange(15, 6)]];
            break;
        }
    }
}

@end

@implementation DVDCommand (Private)

- (uint32_t) bitsInRange:(NSRange)range;
{
    uint32_t offset = range.location + 1 - range.length;
    NSAssert(range.length > 0 && range.length < 32, @"Valid range is 1-31");
    NSAssert(range.location < 64, @"Valid range is 0-63");
    NSAssert(offset < 64, @"Valid range is 0-63"); // If we overflow, we'll be *greater* than 63.
    uint64_t m = (1 << range.length) - 1;
    mask |= m << offset;
    return (bits >> offset) & m;
}

- (int) executeComparison:(uint8_t)comparison value1:(uint16_t)value1 value2:(uint16_t)value2
{
    switch (comparison) {
        case 0x01 /* & */: {
            return value1 & value2;
        }
        case 0x02 /* == */: {
            return value1 == value2;
        }
        case 0x03 /* != */: {
            return value1 != value2;
        }
        case 0x04 /* >= */: {
            return value1 >= value2;
        }
        case 0x05 /* > */: {
            return value1 > value2;
        }
        case 0x06 /* <= */: {
            return value1 <= value2;
        }
        case 0x07 /* < */: {
            return value1 < value2;
        }
    }
    [NSException raise:@"DVDCommand" format:@"%s(%d)", __FILE__, __LINE__];
    return 0; /* Never Reached */
}

- (uint16_t) computeOp:(uint8_t)op value1:(uint16_t)value1 value2:(uint16_t)value2
{

    switch (op) {
        case 0x01 /* mov */: {
            return value2;
        }
        case 0x03 /* add */: {
            int32_t result = (int32_t)value1 + (int32_t)value2;
            return (result > 0xFFFF) ? 0xFFFF : result;
        }
        case 0x04 /* sub */: {
            int32_t result = (int32_t)value1 - (int32_t)value2;
            return (result < 0x0000) ? 0x0000 : result;
        }
        case 0x05 /* mul */: {
            uint32_t result = (int32_t)value1 * (int32_t)value2;
            return (result > 0xFFFF) ? 0xFFFF : result;
        }
        case 0x06 /* div */: {
            return (!value2) ? 0xFFFF : value1 / value2;
        }
        case 0x07 /* mod */: {
            return (!value2) ? 0xFFFF : value1 % value2;
        }
        case 0x08 /* rnd */: {
            return 1 + ((uint16_t)((float)value2 * rand() / (RAND_MAX+1.0)));
        }
        case 0x09 /* and */: {
            return value1 & value2;
        }
        case 0x0A /* or */: {
            return value1 | value2;
        }
        case 0x0B /* xor */: {
            return value1 ^ value2;
        }
    }
    [NSException raise:@"DVDCommand" format:@"%s(%d)", __FILE__, __LINE__];
    return 0; /* Never Reached */
}
    
@end

@implementation DVDVirtualMachine (DVDCommand)

- (uint16_t) registerForCode:(uint8_t)rn
{
    if (rn <= 0x0F) {
        return [self generalPurposeRegister:rn];
    } else if ((rn >= 0x80) && (rn <= 0x97)) {
        return [self systemParameterRegister:rn - 0x80];
    } else {
        [NSException raise:@"DVDCommand" format:@"%s(%d)", __FILE__, __LINE__];
        return 0; /* Never Reached */
    }
}

- (void) setValue:(uint16_t)value forRegisterForCode:(uint8_t)rn
{
    if (rn <= 0x0F) {
        [self setValue:value forGeneralPurposeRegister:rn];
    } else if ((rn >= 0x80) && (rn <= 0x97)) {
        [self setValue:value forSystemParameterRegister:rn - 0x80];
    } else {
        [NSException raise:@"DVDCommand" format:@"%s(%d)", __FILE__, __LINE__];
    }
}

- (void) conditionallySetHighlightedButton:(uint8_t)btn
{
    if (btn) {
        [self setValue:btn << 10 forSystemParameterRegister:8];
    }
}

- (void) executeLinkSubset:(uint8_t)code
{
    switch (code) {
        case 0x01: {
            [self executeLinkTopCell];
            break;
        }
        case 0x02: {
            [self executeLinkNextCell];
            break;
        }
        case 0x03: {
            [self executeLinkPrevCell];
            break;
        }
        case 0x05: {
            [self executeLinkTopPG];
            break;
        }
        case 0x06: {
            [self executeLinkNextPG];
            break;
        }
        case 0x07: {
            [self executeLinkPrevPG];
            break;
        }
        case 0x09: {
            [self executeLinkTopPGC];
            break;
        }
        case 0x0A: {
            [self executeLinkNextPGC];
            break;
        }
        case 0x0B: {
            [self executeLinkPrevPGC];
            break;
        }
        case 0x0C: {
            [self executeLinkGoUpPGC];
            break;
        }
        case 0x0D: {
            [self executeLinkTailPGC];
            break;
        }
        case 0x10: {
            [self executeRSM];
            break;
        }
    }
}

@end

