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

@implementation DVDProgramChain
@synthesize prohibitedUserOperations;
@synthesize preCommands;
@synthesize cellCommands;
@synthesize postCommands;
@synthesize programMap;
@synthesize cellPlaybackTable;
@synthesize nextProgramChainNumber;
@synthesize previousProgramChainNumber;
@synthesize goUpProgramChainNumber;

static NSArray* NO_ELEMENTS;

+ (void) initialize
{
    if (self == [DVDProgramChain class]) {
        NO_ELEMENTS = [[NSArray alloc] init];
    }
}

+  programChainWithData:(NSData*)data
{
    return [[[DVDProgramChain alloc] initWithData:data] autorelease];
}

- initWithData:(NSData*)data
{
    if (self = [super init]) {
        const uint8_t* bytes = [data bytes];
        if (0 != OSReadBigInt16(bytes, 0)) {
            [NSException raise:@"Ripper" format:@"%s(%d)", __FILE__, __LINE__];
        }

        nr_of_programs = bytes[2];
        nr_of_cells = bytes[3];
        playback_time.hour = bytes[4];
        playback_time.minute = bytes[5];
        playback_time.second = bytes[6];
        playback_time.frame_u = bytes[7];
        prohibitedUserOperations.bits = OSReadBigInt32(bytes, 8);
        
        if (nr_of_cells < nr_of_programs) {
            [NSException raise:@"Ripper" format:@"%s(%d)", __FILE__, __LINE__];
        }

        for (int i = 0; i < 8; i++) {
            audio_control[i] = OSReadBigInt16(bytes, 12 + (i << 1));
        }
        
        for (int i = 0; i < 32; i++) {
            subp_control[i] = OSReadBigInt32(bytes, 28 + (i << 2));
        }
        
        nextProgramChainNumber = OSReadBigInt16(bytes, 156);
        previousProgramChainNumber = OSReadBigInt16(bytes, 158);
        goUpProgramChainNumber = OSReadBigInt16(bytes, 160);
        still_time = bytes[162];
        pg_playback_mode = bytes[163];
        
        for (int i = 0; i < 16; i++) {
            palette[i] = OSReadBigInt32(bytes, 164 + (i << 2));
        }
        
        uint16_t command_tbl_offset = OSReadBigInt16(bytes, 228);
        uint16_t program_map_offset = OSReadBigInt16(bytes, 230);
        uint16_t cell_playback_offset = OSReadBigInt16(bytes, 232);
        uint16_t cell_position_offset = OSReadBigInt16(bytes, 234);

        if (!nr_of_programs) {
            if (still_time || pg_playback_mode || program_map_offset || cell_playback_offset || cell_position_offset) {
#ifdef STRICT
                [NSException raise:@"Ripper" format:@"%s(%d)", __FILE__, __LINE__];
#else
                still_time = pg_playback_mode = program_map_offset = cell_playback_offset = cell_position_offset = 0;
#endif
            }
        } else {
            if (!program_map_offset || !cell_playback_offset || !cell_position_offset) {
                [NSException raise:@"Ripper" format:@"%s(%d)", __FILE__, __LINE__];
            }
        }

        preCommands = (id)NO_ELEMENTS; 
        postCommands = (id)NO_ELEMENTS;
        cellCommands = (id)NO_ELEMENTS;
        if (command_tbl_offset != 0) {
            const uint8_t* p = bytes + command_tbl_offset;
            uint16_t nr_of_pre_commands = OSReadBigInt16(p, 0); 
            uint16_t nr_of_post_commands = OSReadBigInt16(p, 2); 
            uint16_t nr_of_cell_commands = OSReadBigInt16(p, 4); 
            uint16_t last_byte = OSReadBigInt16(p, 6); 
            
            if (((8 + (8 * (nr_of_pre_commands + nr_of_post_commands + nr_of_cell_commands)))-1) > last_byte) {
                [NSException raise:@"Ripper" format:@"%s(%d)", __FILE__, __LINE__];
            }
            p += 8;
            
            if (nr_of_pre_commands) {
                preCommands = [NSMutableArray arrayWithCapacity:nr_of_pre_commands]; 
                int row = 0;
                while (nr_of_pre_commands--) {
                    [preCommands addObject:[DVDCommand commandWithData:[data subdataWithRange:NSMakeRange(p - bytes, 8)] row:row]];
                    p += 8;
                    row++;
                }
            }
            if (nr_of_post_commands) {
                postCommands = [NSMutableArray arrayWithCapacity:nr_of_post_commands];
                int row = 0;
                while (nr_of_post_commands--) {
                    [postCommands addObject:[DVDCommand commandWithData:[data subdataWithRange:NSMakeRange(p - bytes, 8)] row:row]];
                    p += 8;
                    row++;
                }
            }
            if (nr_of_cell_commands) {
                cellCommands = [NSMutableArray arrayWithCapacity:nr_of_cell_commands];
                int row = 0;
                while (nr_of_cell_commands--) {
                    [cellCommands addObject:[DVDCommand commandWithData:[data subdataWithRange:NSMakeRange(p - bytes, 8)] row:row]];
                    p += 8;
                    row++;
                }
            }
        }

        if (program_map_offset) {
            programMap = [NSMutableArray arrayWithCapacity:nr_of_programs];
            for (int i = 0; i < nr_of_programs; i++) {
                [programMap addObject:[NSNumber numberWithInt:bytes[program_map_offset + i]]];
            }
        }

        if (!cell_playback_offset || !nr_of_cells) {
            cellPlaybackTable = (id)NO_ELEMENTS;
        } else {
            cellPlaybackTable = [NSMutableArray arrayWithCapacity:nr_of_cells];
            for (const uint8_t* p = bytes + cell_playback_offset, *lp = p + (nr_of_cells * 24); p < lp; p += 24) {
                [cellPlaybackTable addObject:[DVDCellPlayback cellPlaybackWithData:[data subdataWithRange:NSMakeRange(p - bytes, 24)]]];
            }
        }
        
        if (!cell_position_offset || !nr_of_cells) {
            cellPositionTable = (id)NO_ELEMENTS;
        } else {
            cellPositionTable = [NSMutableArray arrayWithCapacity:nr_of_cells];
            for (const uint8_t* p = bytes + cell_position_offset, *lp = p + (nr_of_cells * 4); p < lp; p += 4) {
                uint16_t vob_id_nr = OSReadBigInt16(p, 0);
                uint8_t cell_nr = p[3];                
                [cellPositionTable addObject:[DVDCellPosition cellPositionWithNumber:cell_nr vobId:vob_id_nr]];
            }
        }

        [preCommands retain];
        [postCommands retain];
        [cellCommands retain];
        [cellPlaybackTable retain];
        [cellPositionTable retain];
        [programMap retain];
    }
    return self;
}

- (void) dealloc
{
    [programMap release];
    [preCommands release];
    [postCommands release];
    [cellCommands release];
    [cellPlaybackTable release];
    [cellPositionTable release];
    [super dealloc];
}

@end
