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
 * DVDKit is distributed in the hope that it will be useful,
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
#import "DVDKit+Private.h"

NSString* const DKCommandException = @"DKCommand";

static inline uint64_t extractBits(uint64_t bits, int location, int length)
{
    uint32_t offset = location + 1 - length;
    assert(length > 0 && length < 32);
    assert(location < 64);
    assert(offset < 64); // If we overflow, we'll be *greater* than 63.
    return (bits >> offset) & ((1L << length) - 1);
}

@implementation DKCommand
@synthesize bits;
@synthesize row;

+ (id) commandWith64Bits:(uint64_t)bits
{
    return [DKCommand commandWith64Bits:bits row:-1];
}

+ (id) commandWith64Bits:(uint64_t)bits row:(int)row
{
    return [[[DKCommand alloc] initWith64Bits:bits row:row] autorelease];
}

+ (id) commandWithData:(NSData*)data
{
    return [DKCommand commandWithData:data row:-1];
}

+ (id) commandWithData:(NSData*)data row:(int)row
{
    return [[[DKCommand alloc] initWithData:data row:row] autorelease];
}

- (id) initWith64Bits:(uint64_t)_bits row:(int)_row;
{
    if (self = [super init]) {
        bits = _bits;
        row = _row;
    }
    return self;
}

- (id) initWithData:(NSData*)data row:(int)_row;
{
    NSAssert(data, @"Shouldn't be nil");
    NSAssert([data length] == 8, @"Must be 8 bytes");
    if (self = [super init]) {
        bits = OSReadBigInt64([data bytes], 0x00);
        row = _row;
    }
    return self;
}

- (void) dealloc
{
    [description release], description = nil;
    [super dealloc];
}

- (BOOL) isEqual:(DKCommand*)anObject
{
    if (self == anObject) {
        return YES;
    } else return (
        [self class] == [anObject class]
        && anObject->bits == bits
        && anObject->row == row
    );
}

- (void) executeAgainstVirtualMachine:(DKVirtualMachine*)virtualMachine
{
#ifdef DEBUG
//    NSLog(@"%@", self);
#endif
    uint8_t type = extractBits(bits, 63, 3);
    if (type > 6) {
        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
    } else switch (type) {
        case 0: {
            uint8_t command = extractBits(bits, 51, 4);
            uint8_t comparison = extractBits(bits, 54, 3);
            if (command && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:extractBits(bits, 39, 8)] value2:extractBits(bits, 55, 1) ? extractBits(bits, 31, 16) : [virtualMachine registerForCode:extractBits(bits, 23, 8)]])) switch (command) {
                case 1: {
                    [virtualMachine executeGoto:extractBits(bits, 7, 8)];
                    break;
                }
                
                case 2: {
                    [virtualMachine executeBreak];
                    break;
                }

                case 3: {
                    [virtualMachine setTmpPML:extractBits(bits, 11, 4) line:extractBits(bits, 7, 8)];
                    break;
                }
                    
                default: {
                    [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                }
            }
            break;
        }
        
        case 1: {
            uint8_t command = extractBits(bits, 51, 4);
            uint8_t comparison = extractBits(bits, 54, 3);
            if (extractBits(bits, 60, 1)) {
                if (command && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:extractBits(bits, 15, 8)] value2:[virtualMachine registerForCode:extractBits(bits, 7, 8)]])) switch (command) {
                    case 1: {        
                        [virtualMachine stop];
                        break;
                    }
                        
                    case 2: {
                        [virtualMachine executeJumpTT:extractBits(bits, 23, 8)];
                        break;
                    }
                        
                    case 3: {
                        [virtualMachine executeJumpVTS_TT:extractBits(bits, 23, 8)];
                        break;
                    }
                        
                    case 5: {
                        [virtualMachine executeJumpVTS_PTT:extractBits(bits, 23, 8) pttn:extractBits(bits, 43, 12)];
                        break;
                    }
                        
                    case 6: {
                        switch (extractBits(bits, 23, 2)) {
                            case 0: {
                                [virtualMachine executeJumpSS_FP];
                                break;
                            }
                        
                            case 1: {
                                [virtualMachine executeJumpSS_VMGM_menu:extractBits(bits, 20, 5)];
                                break;
                            }
                            
                            case 2: {
                                [virtualMachine executeJumpSS_VTSM_menu:extractBits(bits, 20, 5) vts:extractBits(bits, 31, 8) ttn:extractBits(bits, 39, 8)];
                                break;
                            }
                            
                            case 3: {
                                [virtualMachine executeJumpSS_VMGM_pgcn:extractBits(bits, 47, 16)];
                                break;
                            }
                        }
                        break;
                    }
                        
                    case 8: {
                        switch (extractBits(bits, 23, 2)) {
                            case 0: {
                                [virtualMachine executeCallSS_FP];
                                break;
                            }
                            
                            case 1: {
                                [virtualMachine executeCallSS_VMGM_menu:extractBits(bits, 20, 5) resumeCell:extractBits(bits, 31, 8)];
                                break;
                            }
                            
                            case 2: {
                                [virtualMachine executeCallSS_VTSM_menu:extractBits(bits, 20, 5) resumeCell:extractBits(bits, 31, 8)];
                                break;
                            }
                            
                            case 3: {
                                [virtualMachine executeCallSS_VMGM_pgcn:extractBits(bits, 47, 16) resumeCell:extractBits(bits, 31, 8)];
                                break;
                            }
                        }
                        break;
                    }
                        
                    default: {
                        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                    }
                }
            } else {
                if (command && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:extractBits(bits, 39, 8)] value2:extractBits(bits, 55, 1) ? extractBits(bits, 31, 16) : [virtualMachine registerForCode:extractBits(bits, 23, 8)]])) switch (command) {
                    case 1: {
                        [virtualMachine executeLinkSubset:extractBits(bits, 4, 5)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    case 4: {
                        [virtualMachine executeLinkPGCN:extractBits(bits, 15, 16)];
                        break;
                    }
                        
                    case 5: {
                        [virtualMachine executeLinkPTTN:extractBits(bits, 9, 10)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    case 6: {
                        [virtualMachine executeLinkPGN:extractBits(bits, 7, 8)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    case 7: {
                        [virtualMachine executeLinkCell:extractBits(bits, 7, 8)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    default: {
                        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                    }
                }
            }
            break;
        }

        case 2: {
            uint8_t direct = extractBits(bits, 60, 1);
            uint8_t set = extractBits(bits, 59, 4);
            uint8_t comparison = extractBits(bits, 54, 3);
            if (set && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:extractBits(bits, 15, 8)] value2:[virtualMachine registerForCode:extractBits(bits, 7, 8)]])) {
                switch (set) {
                    case 1: {
                        if (extractBits(bits, 39, 1)) {
                            [virtualMachine setValue:(direct) ? extractBits(bits, 38, 7) : [virtualMachine generalPurposeRegister:extractBits(bits, 35, 4)] forSystemParameterRegister:1];
                        }
                        
                        if (extractBits(bits, 31, 1)) {
                            [virtualMachine setValue:(direct) ? extractBits(bits, 30, 7) : [virtualMachine generalPurposeRegister:extractBits(bits, 27, 4)] forSystemParameterRegister:2];
                        }
                        
                        if (extractBits(bits, 23, 1)) {
                            [virtualMachine setValue:(direct) ? extractBits(bits, 22, 7) : [virtualMachine generalPurposeRegister:extractBits(bits, 19, 4)] forSystemParameterRegister:3];
                        }
                        break;
                    }
                        
                    case 2: {
                        [virtualMachine setValue:(direct) ? extractBits(bits, 47, 16) : [virtualMachine registerForCode:extractBits(bits, 39, 8)] forSystemParameterRegister:9];
                        [virtualMachine setValue:extractBits(bits, 31, 16) forSystemParameterRegister:10];
                        break;
                    }
                        
                    case 3: {
                        uint8_t index = extractBits(bits, 19, 4);
                        [virtualMachine setMode:extractBits(bits, 23, 1) forGeneralPurposeRegister:index];
                        [virtualMachine setValue:(direct) ? extractBits(bits, 47, 16) : [virtualMachine registerForCode:extractBits(bits, 39, 8)] forGeneralPurposeRegister:index];
                        break;
                    }
                        
                    case 6: {
                        [virtualMachine setValue:(direct) ? extractBits(bits, 31, 16) : [virtualMachine generalPurposeRegister:extractBits(bits, 19, 4)] forSystemParameterRegister:8];
                        break;
                    }
                        
                    default: {
                        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                    }
                }
                if (!comparison) switch (extractBits(bits, 51, 4)) {
                    case 0: {
                        /* NOP */
                        break;
                    }

                    case 1: {
                        [virtualMachine executeLinkSubset:extractBits(bits, 4, 5)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    case 4: {
                        [virtualMachine executeLinkPGCN:extractBits(bits, 15, 16)];
                        break;
                    }
                        
                    case 5: {
                        [virtualMachine executeLinkPTTN:extractBits(bits, 9, 10)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    case 6: {
                        [virtualMachine executeLinkPGN:extractBits(bits, 7, 8)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    case 7: {
                        [virtualMachine executeLinkCell:extractBits(bits, 7, 8)];
                        [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                        break;
                    }
                        
                    default: {
                        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                    }
                }
            }
            break;
        }
        
        case 3: {
            uint8_t direct = extractBits(bits, 60, 1);
            uint8_t setop = extractBits(bits, 59, 4);
            uint8_t comparison = extractBits(bits, 54, 3);
            if (setop && (!comparison || [self executeComparison:comparison value1:[virtualMachine registerForCode:extractBits(bits, 47, 8)] value2:extractBits(bits, 55, 1) ? extractBits(bits, 15, 16) : [virtualMachine registerForCode:extractBits(bits, 7, 8)]])) {
                uint8_t srd = extractBits(bits, 35, 4);
                if (2 == setop && !direct) /* swap */ {
                    uint8_t srs = extractBits(bits, 23, 8);
                    uint16_t x = [virtualMachine registerForCode:srs];
                    [virtualMachine setValue:[virtualMachine generalPurposeRegister:srd] forRegisterForCode:srs];
                    [virtualMachine setValue:x forGeneralPurposeRegister:srd];
                } else {
                    [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:srd] value2:(direct) ? extractBits(bits, 31, 16) : [virtualMachine registerForCode:extractBits(bits, 23, 8)]] forGeneralPurposeRegister:srd];
                }
                if (!comparison) {
                    switch (extractBits(bits, 51, 4)) {
                        case 0: {
                            /* NOP */
                            break;
                        }
                            
                        case 1: {
                            [virtualMachine executeLinkSubset:extractBits(bits, 4, 5)];
                            [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                            break;
                        }
                            
                        case 4: {
                            [virtualMachine executeLinkPGCN:extractBits(bits, 15, 16)];
                            break;
                        }
                            
                        case 5: {
                            [virtualMachine executeLinkPTTN:extractBits(bits, 9, 10)];
                            [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                            break;
                        }
                            
                        case 6: {
                            [virtualMachine executeLinkPGN:extractBits(bits, 7, 8)];
                            [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                            break;
                        }
                            
                        case 7: {
                            [virtualMachine executeLinkCell:extractBits(bits, 7, 8)];
                            [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
                            break;
                        }
                            
                        default: {
                            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                        }
                    }
                }
            }
            break;
        }
        
        case 4: {
            uint8_t direct = extractBits(bits, 60, 1);
            uint8_t setop = extractBits(bits, 59, 4);
            uint8_t scr = extractBits(bits, 51, 4);
            if (setop) {
                if (2 == setop && !direct) /* swap */ {
                    uint8_t srs = extractBits(bits, 39, 8);
                    uint16_t x = [virtualMachine registerForCode:srs];
                    [virtualMachine setValue:[virtualMachine generalPurposeRegister:scr] forRegisterForCode:srs];
                    [virtualMachine setValue:x forGeneralPurposeRegister:scr];
                } else {
                    [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:scr] value2:(direct) ? extractBits(bits, 47, 16) : [virtualMachine registerForCode:extractBits(bits, 39, 8)]] forGeneralPurposeRegister:scr];
                }
            }
            uint8_t comparison = extractBits(bits, 54, 3);
            if (!comparison || [self executeComparison:comparison value1:[virtualMachine generalPurposeRegister:scr] value2:extractBits(bits, 55, 1) ? extractBits(bits, 31, 16) : [virtualMachine registerForCode:extractBits(bits, 23, 8)]]) {
                [virtualMachine executeLinkSubset:extractBits(bits, 4, 5)];
                [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
            }
            break;
        }
        
        case 5: {
            uint8_t direct = extractBits(bits, 60, 1);
            uint8_t setop = extractBits(bits, 59, 4);
            uint8_t scr = extractBits(bits, 51, 4);
            uint8_t comparison = extractBits(bits, 54, 3);
            if (!comparison || [self executeComparison:comparison value1:[virtualMachine generalPurposeRegister:scr] value2:extractBits(bits, 55, 1) ? extractBits(bits, 31, 16) : [virtualMachine registerForCode:extractBits(bits, 23, 8)]]) {
                if (setop) {
                    if (2 == setop && !direct) /* swap */ {
                        uint8_t srs = extractBits(bits, 39, 8);
                        uint16_t x = [virtualMachine registerForCode:srs];
                        [virtualMachine setValue:[virtualMachine generalPurposeRegister:scr] forRegisterForCode:srs];
                        [virtualMachine setValue:x forGeneralPurposeRegister:scr];
                    } else {
                        [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:scr] value2:(direct) ? extractBits(bits, 47, 16) : [virtualMachine registerForCode:extractBits(bits, 39, 8)]] forGeneralPurposeRegister:scr];
                    }
                }
                [virtualMachine executeLinkSubset:extractBits(bits, 4, 5)];
                [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
            }
            break;
        }
        
        case 6: {
            uint8_t comparison = extractBits(bits, 54, 3);
            uint8_t scr = extractBits(bits, 51, 4);
            if (!comparison || [self executeComparison:comparison value1:[virtualMachine generalPurposeRegister:scr] value2:extractBits(bits, 55, 1) ? extractBits(bits, 31, 16) : [virtualMachine registerForCode:extractBits(bits, 23, 8)]]) {
                uint8_t direct = extractBits(bits, 60, 1);
                uint8_t setop = extractBits(bits, 59, 4);
                if (setop) {
                    if (2 == setop && !direct) /* swap */ {
                        uint8_t srs = extractBits(bits, 39, 8);
                        uint16_t x = [virtualMachine registerForCode:srs];
                        [virtualMachine setValue:[virtualMachine generalPurposeRegister:scr] forRegisterForCode:srs];
                        [virtualMachine setValue:x forGeneralPurposeRegister:scr];
                    } else {
                        [virtualMachine setValue:[self computeOp:setop value1:[virtualMachine generalPurposeRegister:scr] value2:(direct) ? extractBits(bits, 47, 16) : [virtualMachine registerForCode:extractBits(bits, 39, 8)]] forGeneralPurposeRegister:scr];
                    }
                }
            }
            [virtualMachine executeLinkSubset:extractBits(bits, 4, 5)];
            [virtualMachine conditionallySetHighlightedButton:extractBits(bits, 15, 6)];
            break;
        }
                
        default: {
            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
        }
    }
}

static void appendMnemonic(DKCommand* command, NSMutableString* string);

- (NSString*) description
{
    if (!description) {
        description = [[NSMutableString alloc] init];
        if (self->row >= 0) {
            [description appendFormat:@"(%03d) ", row + 1];
        } else {
            [description appendString:@"      "];
        }
        [description appendFormat:@"%016llx | ", bits];
        int length = [description length];
        @try {
            appendMnemonic(self, description);
        } @catch (id exception) {
            [description deleteCharactersInRange:NSMakeRange(length, [description length] - length)];
            [description appendString:@"<INVALID INSTRUCTION>"];
        }
    }
    return description;
}

- (uint32_t) bitsInRange:(NSRange)range
{
    NSAssert(range.length > 0 && range.length < 32, @"Valid range is 1-31");
    NSAssert(range.location < 64, @"Valid range is 0-63");
    NSAssert((range.location + 1 - range.length) < 64, @"Valid range is 0-63"); // If we overflow, we'll be *greater* than 63.
    return extractBits(bits, range.location, range.length);
}

@end

@implementation DKCommand (Private)

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
    [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
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
    [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
    return 0; /* Never Reached */
}

static const char *cmp_op_table[] = {
    NULL, "&", "==", "!=", ">=", ">", "<=", "<"
};

static const char *set_op_table[] = {
    NULL, "=", "<->", "+=", "-=", "*=", "/=", "%=", "rnd", "&=", "|=", "^="
};

static const char *link_table[] = {
    "LinkNoLink",  "LinkTopC",    "LinkNextC",   "LinkPrevC",
    NULL,          "LinkTopPG",   "LinkNextPG",  "LinkPrevPG",
    NULL,          "LinkTopPGC",  "LinkNextPGC", "LinkPrevPGC",
    "LinkGoUpPGC", "LinkTailPGC", NULL,          NULL,
    "RSM"
};

static const char *system_reg_table[] = {
    "Menu Description Language Code",
    "Audio Stream Number",
    "Sub-picture Stream Number",
    "Angle Number",
    "Title Track Number",
    "VTS Title Track Number",
    "VTS PGC Number",
    "PTT Number for One_Sequential_PGC_Title",
    "Highlighted Button Number",
    "Navigation Timer",
    "Title PGC Number for Navigation Timer",
    "Audio Mixing Mode for Karaoke",
    "Country Code for Parental Management",
    "Parental Level",
    "Player Configurations for Video",
    "Player Configurations for Audio",
    "Initial Language Code for Audio",
    "Initial Language Code Extension for Audio",
    "Initial Language Code for Sub-picture",
    "Initial Language Code Extension for Sub-picture",
    "Player Regional Code",
    "Reserved 21",
    "Reserved 22",
    "Reserved 23"
};

static void appendSystemRegister(uint16_t reg, NSMutableString* string) 
{
    [string appendFormat:@"%s (SRPM:%d)", system_reg_table[reg], reg];
}

static void appendGeneralRegister(uint8_t reg, NSMutableString* string) 
{
    [string appendFormat:@"g[%d]", reg];
}

static void appendRegister(uint8_t reg, NSMutableString* string) 
{
    if (reg & 0x80) {
        appendSystemRegister(reg & 0x7f, string);
    } else {
        appendGeneralRegister(reg & 0x7f, string);
    }
}

static void appendComparisonOp(uint8_t op, NSMutableString* string) 
{
    [string appendFormat:@" %s ", cmp_op_table[op]];
}

static void appendSetOp(uint8_t op, NSMutableString* string) 
{
    [string appendFormat:@" %s ", set_op_table[op]];
}

static void appendRegOrData1(DKCommand* command, NSMutableString* string, int immediate, int start) 
{
    if (immediate) {
        uint32_t i = [command bitsInRange:NSMakeRange(start, 16)];
        [string appendFormat:@"0x%x", i];
        if (isprint(i & 0xff) && isprint((i>>8) & 0xff)) {
            [string appendFormat:@" (\"%c%c\")", (char)((i>>8) & 0xff), (char)(i & 0xff)];
        }
    } else {
        appendRegister([command bitsInRange:NSMakeRange(start - 8, 8)], string);
    }
}

static void appendRegOrData2(DKCommand* command, NSMutableString* string, int immediate, int start) 
{
    if (immediate) {
        [string appendFormat:@"0x%x", [command bitsInRange:NSMakeRange(start - 1, 7)]];
    } else {
        [string appendFormat:@"g[%d]", [command bitsInRange:NSMakeRange(start - 4, 4)]];
    }
}

static void appendRegOrData3(DKCommand* command, NSMutableString* string, int immediate, int start) 
{
    if (immediate) {
        uint32_t i = [command bitsInRange:NSMakeRange(start, 16)];
        [string appendFormat:@"0x%x", i];
        if (isprint(i & 0xff) && isprint((i>>8) & 0xff)) {
            [string appendFormat:@" (\"%c%c\")", (char)((i>>8) & 0xff), (char)(i & 0xff)];
        } else {
            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
        }
    } else {
        appendRegister([command bitsInRange:NSMakeRange(start, 8)], string);
    }
}

static void appendIf1(DKCommand* command, NSMutableString* string) 
{
    uint8_t op = [command bitsInRange:NSMakeRange(54, 3)];
    if (op) {
        [string appendFormat:@"if ("];
        appendGeneralRegister([command bitsInRange:NSMakeRange(39,8)], string);
        appendComparisonOp(op, string);
        appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(55,1)], 31);
        [string appendFormat:@") "];
    }
}

static void appendIf2(DKCommand* command, NSMutableString* string) 
{
    uint8_t op = [command bitsInRange:NSMakeRange(54, 3)];
    if (op) {
        [string appendFormat:@"if ("];
        appendRegister([command bitsInRange:NSMakeRange(15, 8)], string);
        appendComparisonOp(op, string);
        appendRegister([command bitsInRange:NSMakeRange(7, 8)], string);
        [string appendFormat:@") "];
    }
}

static void appendIf3(DKCommand* command, NSMutableString* string) 
{
    uint8_t op = [command bitsInRange:NSMakeRange(54, 3)];    
    if (op) {
        [string appendFormat:@"if ("];
        appendGeneralRegister([command bitsInRange:NSMakeRange(43, 4)], string);
        appendComparisonOp(op, string);
        appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(55, 1)], 15);
        [string appendFormat:@") "];
    }
}

static void appendIf4(DKCommand* command, NSMutableString* string) 
{
    uint8_t op = [command bitsInRange:NSMakeRange(54, 3)];
    if (op) {
        [string appendFormat:@"if ("];
        appendGeneralRegister([command bitsInRange:NSMakeRange(51, 4)], string);
        appendComparisonOp(op, string);
        appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(55, 1)], 31);
        [string appendFormat:@") "];
    }
}

static void appendIf5(DKCommand* command, NSMutableString* string) 
{
    uint8_t op = [command bitsInRange:NSMakeRange(54, 3)];
    int set_immediate = [command bitsInRange:NSMakeRange(60, 1)];
    if (op) {
        if (set_immediate) {
            [string appendFormat:@"if ("];
            appendGeneralRegister([command bitsInRange:NSMakeRange(31, 8)], string);
            appendComparisonOp(op, string);
            appendRegister([command bitsInRange:NSMakeRange(23, 8)], string);
            [string appendFormat:@") "];
        } else {
            [string appendFormat:@"if ("];
            appendGeneralRegister([command bitsInRange:NSMakeRange(39, 8)], string);
            appendComparisonOp(op, string);
            appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(55, 1)], 31);
            [string appendFormat:@") "];
        }
    }
}

static void appendSpecial(DKCommand* command, NSMutableString* string) 
{
    uint8_t op = [command bitsInRange:NSMakeRange(51, 4)];
    switch (op) {
        case 0: {
            [string appendFormat:@"Nop"];
            break;
        }
            
        case 1: {
            [string appendFormat:@"Goto %d", [command bitsInRange:NSMakeRange(7, 8)]];
            break;
        }
            
        case 2: {
            [string appendFormat:@"Break"];
            break;
        }

        case 3: {
            [string appendFormat:@"SetTmpPML %d, Goto %d", [command bitsInRange:NSMakeRange(11, 4)], [command bitsInRange:NSMakeRange(7, 8)]];
            break;
        }
            
        default: {
            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
        }
    }
}

static void appendLinkSub(DKCommand* command, NSMutableString* string) 
{
    uint32_t linkop = [command bitsInRange:NSMakeRange(7, 8)];
    uint32_t button = [command bitsInRange:NSMakeRange(15, 6)];
    if (linkop < sizeof(link_table)/sizeof(char *) && link_table[linkop] != NULL) {
        [string appendFormat:@"%s", link_table[linkop]];
        if (button) {
            [string appendFormat:@" (button %d)", button];
        }
    } else {
        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
    }
}

static void appendLink(DKCommand* command, NSMutableString* string, int optional) 
{
    uint8_t op = [command bitsInRange:NSMakeRange(51, 4)];
    if (optional && op) {
        [string appendFormat:@", "];
    }
    
    switch (op) {
        case 0: {
            if (!optional) {
                [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
            }
            break;
        }
    
        case 1: {
            appendLinkSub(command, string);
            break;
        }

        case 4: {
            [string appendFormat:@"LinkPGCN %d", [command bitsInRange:NSMakeRange(14, 15)]];
            break;
        }
        
        case 5: {
            [string appendFormat:@"LinkPTT %d", [command bitsInRange:NSMakeRange(9, 10)]];
            int button = [command bitsInRange:NSMakeRange(15, 6)];
            if (button) {
                [string appendFormat:@" (button %d)", button];
            }
            break;
        }
        
        case 6: {
            [string appendFormat:@"LinkPGN %d", [command bitsInRange:NSMakeRange(6, 7)]];
            int button = [command bitsInRange:NSMakeRange(15, 6)];
            if (button) {
                [string appendFormat:@" (button %d)", button];
            }
            break;
        }
        
        case 7: {
            [string appendFormat:@"LinkCN %d", [command bitsInRange:NSMakeRange(7, 8)]];
            int button = [command bitsInRange:NSMakeRange(15, 6)];
            if (button) {
                [string appendFormat:@" (button %d)", button];
            }
            break;
        }
        
        default: {
            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
        }
    }
}

static void appendJump(DKCommand* command, NSMutableString* string) 
{
    switch ([command bitsInRange:NSMakeRange(51, 4)]) {
        case 1: {
            [string appendFormat:@"Exit"];
            break;
        }

        case 2: {
            [string appendFormat:@"JumpTT %d", [command bitsInRange:NSMakeRange(22, 7)]];
            break;
        }

        case 3: {
            [string appendFormat:@"JumpVTS_TT %d", [command bitsInRange:NSMakeRange(22, 7)]];
            break;
        }
            
        case 5: {
            [string appendFormat:@"JumpVTS_PTT %d:%d", [command bitsInRange:NSMakeRange(22, 7)], [command bitsInRange:NSMakeRange(41, 10)]];
            break;
        }
            
        case 6: {
            switch ([command bitsInRange:NSMakeRange(23, 2)]) {
                case 0: {
                    [string appendFormat:@"JumpSS FP"];
                    break;
                }
                    
                case 1: {
                    [string appendFormat:@"JumpSS VMGM (menu %d)", [command bitsInRange:NSMakeRange(19, 4)]];
                    break;
                }
                    
                case 2: {
                    [string appendFormat:@"JumpSS VTSM (vts %d, title %d, menu %d)", [command bitsInRange:NSMakeRange(30, 7)], [command bitsInRange:NSMakeRange(38, 7)], [command bitsInRange:NSMakeRange(19, 4)]];
                    break;
                }
                    
                case 3: {
                    [string appendFormat:@"JumpSS VMGM (pgc %d)", [command bitsInRange:NSMakeRange(46, 15)]];
                    break;
                }

                default: {
                    [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                }
            }
            break;
        }

        case 8: {
            switch ([command bitsInRange:NSMakeRange(23, 2)]) {
                case 0: {
                    [string appendFormat:@"CallSS FP (rsm_cell %d)", [command bitsInRange:NSMakeRange(31, 8)]];
                    break;
                }

                case 1: {
                    [string appendFormat:@"CallSS VMGM (menu %d, rsm_cell %d)", [command bitsInRange:NSMakeRange(19, 4)], [command bitsInRange:NSMakeRange(31, 8)]];
                    break;
                }

                case 2: {
                    [string appendFormat:@"CallSS VTSM (menu %d, rsm_cell %d)", [command bitsInRange:NSMakeRange(19, 4)], [command bitsInRange:NSMakeRange(31, 8)]];
                    break;
                }
                    
                case 3: {
                    [string appendFormat:@"CallSS VMGM (pgc %d, rsm_cell %d)", [command bitsInRange:NSMakeRange(46, 15)], [command bitsInRange:NSMakeRange(31, 8)]];
                    break;
                }

                default: {
                    [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
                }
            }
            break;
        }

        default: {
            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
        }
    }
}

static void appendSystemSet(DKCommand* command, NSMutableString* string) 
{
    switch ([command bitsInRange:NSMakeRange(59, 4)]) {
        case 1: {
            for (int i = 1; i <= 3; i++) {
                if ([command bitsInRange:NSMakeRange(47 - (i*8), 1)]) {
                    appendSystemRegister(i, string);
                    [string appendFormat:@" = "];
                    appendRegOrData2(command, string, [command bitsInRange:NSMakeRange(60, 1)], 47 - (i*8) );
//                    [string appendFormat:@" "];
                }
            }
            break;
        }
    
        case 2: {
            appendSystemRegister(9, string);
            [string appendFormat:@" = "];
            appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(60, 1)], 47);
            [string appendFormat:@" "];
            appendSystemRegister(10, string);
            [string appendFormat:@" = %d", [command bitsInRange:NSMakeRange(30, 15)]]; /*  ?? */
            break;
        }

        case 3: {
            [string appendFormat:@"SetMode "];
            if ([command bitsInRange:NSMakeRange(23, 1)]) {
                [string appendFormat:@"Counter "];
            } else {
                [string appendFormat:@"Register "];
            }
            appendGeneralRegister([command bitsInRange:NSMakeRange(19, 4)], string);
            appendSetOp(0x1, string);
            appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(60, 1)], 47);
            break;
        }
            
        case 6: {
            appendSystemRegister(8, string);
            if ([command bitsInRange:NSMakeRange(60, 1)]) {
                [string appendFormat:@" = 0x%x", [command bitsInRange:NSMakeRange(31, 16)]];
                int button = [command bitsInRange:NSMakeRange(31, 6)];
                if (button) {
                    [string appendFormat:@" (button %d)", button];
                }
            } else {
                [string appendFormat:@" = g[%d]", [command bitsInRange:NSMakeRange(19, 4)]];
            }
            break;
        }
            
        default: {
            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
        }
    }
}

static void appendSet1(DKCommand* command, NSMutableString* string) 
{
    uint8_t set_op = [command bitsInRange:NSMakeRange(59, 4)];
    if (set_op) {
        appendGeneralRegister([command bitsInRange:NSMakeRange(35, 4)], string);
        appendSetOp(set_op, string);
        appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(60, 1)], 31);
    } else {
        [string appendFormat:@"NOP"];
    }
}

static void appendSet2(DKCommand* command, NSMutableString* string) 
{
    uint8_t set_op = [command bitsInRange:NSMakeRange(59, 4)];
    if (set_op) {
        appendGeneralRegister([command bitsInRange:NSMakeRange(51, 4)], string);
        appendSetOp(set_op, string);
        appendRegOrData1(command, string, [command bitsInRange:NSMakeRange(60, 1)], 47);
    } else {
        [string appendFormat:@"NOP"];
    }
}

static void appendSet3(DKCommand* command, NSMutableString* string) 
{
    uint8_t set_op = [command bitsInRange:NSMakeRange(59, 4)];
    if (set_op) {
        appendGeneralRegister([command bitsInRange:NSMakeRange(51, 4)], string);
        appendSetOp(set_op, string);
        appendRegOrData3(command, string, [command bitsInRange:NSMakeRange(60, 1)], 47);
    } else {
        [string appendFormat:@"NOP"];
    }
}

void appendMnemonic(DKCommand* command, NSMutableString* string)
{
    switch ([command bitsInRange:NSMakeRange(63,3)]) {
        case 0: {
            appendIf1(command, string);
            appendSpecial(command, string);
            break;
        }

        case 1: {
            if([command bitsInRange:NSMakeRange(60,1)]) {
                appendIf2(command, string);
                appendJump(command, string);
            } else {
                appendIf1(command, string);
                appendLink(command, string, 0);
            }
            break;
        }

        case 2: {
            appendIf2(command, string);
            appendSystemSet(command, string);
            appendLink(command, string, 1);
            break;
        }

        case 3: {
            appendIf3(command, string);
            appendSet1(command, string);
            appendLink(command, string, 1);
            break;
            
        }

        case 4: {
            appendSet2(command, string);
            [string appendString:@", "];
            appendIf4(command, string);
            appendLinkSub(command, string);
            break;
        }

        case 5: {
            appendIf5(command, string);
            [string appendString:@"{ "];
            appendSet3(command, string);
            [string appendString:@", "];
            appendLinkSub(command, string);
            [string appendString:@" }"];
            break;
        }

        case 6: {
            appendIf5(command, string);
            [string appendString:@"{ "];
            appendSet3(command, string);
            [string appendString:@" } "];
            appendLinkSub(command, string);
            break;
        }
            
        default: {
            [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
        }
    }
}

@end

@implementation DKVirtualMachine (DKCommand)

- (uint16_t) registerForCode:(uint8_t)rn
{
    if (rn <= 0x0F) {
        return [self generalPurposeRegister:rn];
    } else if ((rn >= 0x80) && (rn <= 0x97)) {
        return [self systemParameterRegister:rn - 0x80];
    } else {
        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
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
        [NSException raise:DKCommandException format:@"%s(%d)", __FILE__, __LINE__];
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

