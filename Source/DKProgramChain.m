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

NSString* const DVDProgramChainException = @"DVDProgramChain";

@implementation DKProgramChain

@synthesize playback_time;
@synthesize prohibitedUserOperations;
@synthesize nextProgramChainNumber;
@synthesize previousProgramChainNumber;
@synthesize goUpProgramChainNumber;
@synthesize still_time;
@synthesize pg_playback_mode;
@synthesize preCommands;
@synthesize postCommands;
@synthesize cellCommands;
@synthesize programMap;
@synthesize cellPlaybackTable;
@synthesize cellPositionTable;
@synthesize userInfo;

- (void) dealloc
{
    [programMap release], programMap = nil;
    [preCommands release], preCommands = nil;
    [postCommands release], postCommands = nil;
    [cellCommands release], cellCommands = nil;
    [cellPlaybackTable release], cellPlaybackTable = nil;
    [cellPositionTable release], cellPositionTable = nil;
    [userInfo release], userInfo = nil;
    [super dealloc];
}

static NSArray* NO_ELEMENTS;

+ (void) initialize
{
    if (self == [DKProgramChain class]) {
        NO_ELEMENTS = [[NSArray alloc] init];
    }
}

+  programChainWithData:(NSData*)data error:(NSError**)error
{
    return [[[DKProgramChain alloc] initWithData:data error:error] autorelease];
}

- initWithData:(NSData*)data error:(NSError**)error
{
    if (self = [super init]) {
        NSMutableArray* errors = nil;

        const pgc_t* pgc = [data bytes];
        uint8_t nr_of_programs = OSReadBigInt8(&pgc->nr_of_programs, 0);
        uint8_t nr_of_cells = OSReadBigInt8(&pgc->nr_of_cells, 0);
        memcpy(&playback_time, &pgc->playback_time, sizeof(DKTime));
        memcpy(&prohibitedUserOperations, &pgc->prohibited_ops, sizeof(DKUserOperationFlags));
        
        if (nr_of_cells < nr_of_programs) {
            [NSException raise:DVDProgramChainException format:@"%s(%d)", __FILE__, __LINE__];
        }

        for (int i = 0; i < 8; i++) {
            audio_control[i] = OSReadBigInt16(&pgc->audio_control[i], 0);
        }
        
        for (int i = 0; i < 32; i++) {
            subp_control[i] = OSReadBigInt32(&pgc->subp_control[i], 0);
        }
        
        nextProgramChainNumber = OSReadBigInt16(&pgc->next_pgc_nr, 0);
        previousProgramChainNumber = OSReadBigInt16(&pgc->prev_pgc_nr, 0);
        goUpProgramChainNumber = OSReadBigInt16(&pgc->goup_pgc_nr, 0);
        still_time = OSReadBigInt8(&pgc->still_time, 0);
        pg_playback_mode = OSReadBigInt8(&pgc->pg_playback_mode, 0);
        
        for (int i = 0; i < 16; i++) {
            palette[i] = OSReadBigInt32(&pgc->palette[i], 0);
        }
        
        uint16_t command_tbl_offset = OSReadBigInt16(&pgc->command_tbl_offset, 0);
        uint16_t program_map_offset = OSReadBigInt16(&pgc->program_map_offset, 0);
        uint16_t cell_playback_offset = OSReadBigInt16(&pgc->cell_playback_offset, 0);
        uint16_t cell_position_offset = OSReadBigInt16(&pgc->cell_position_offset, 0);
       
        if (!nr_of_programs) {
            if (still_time || pg_playback_mode || program_map_offset || cell_playback_offset || cell_position_offset) {
                if (errors) {
                    //TODO: [errors addObject:DKErrorWithCode(, DKLocalizedString(@"", nil), NSLocalizedDescriptionKey, nil)];
                }
                still_time = pg_playback_mode = program_map_offset = cell_playback_offset = cell_position_offset = 0;
            }
        } else {
            if (!program_map_offset || !cell_playback_offset || !cell_position_offset) {
                if (errors) {
                    //TODO: [errors addObject:DKErrorWithCode(, DKLocalizedString(@"", nil), NSLocalizedDescriptionKey, nil)];
                }
            }
        }

        preCommands = [[NSMutableArray alloc] init]; 
        postCommands = [[NSMutableArray alloc] init]; 
        cellCommands = [[NSMutableArray alloc] init]; 
        if (command_tbl_offset != 0) {
            uint32_t p = command_tbl_offset;
            uint16_t nr_of_pre_commands = OSReadBigInt16(pgc, p + 0); 
            uint16_t nr_of_post_commands = OSReadBigInt16(pgc, p + 2); 
            uint16_t nr_of_cell_commands = OSReadBigInt16(pgc, p + 4); 
            uint16_t last_byte = 1 + OSReadBigInt16(pgc, p + 6); 
            
            if ((8 + (8 * (nr_of_pre_commands + nr_of_post_commands + nr_of_cell_commands))) > last_byte) {
                [NSException raise:DVDProgramChainException format:@"%s(%d)", __FILE__, __LINE__];
            }
            p += 8;
            
            if (nr_of_pre_commands) {
                int row = 0;
                while (nr_of_pre_commands--) {
                    [preCommands addObject:[DKCommand commandWith64Bits:OSReadBigInt64(pgc, p) row:row]];
                    p += 8;
                    row++;
                }
            }
            if (nr_of_post_commands) {
                int row = 0;
                while (nr_of_post_commands--) {
                    [postCommands addObject:[DKCommand commandWith64Bits:OSReadBigInt64(pgc, p) row:row]];
                    p += 8;
                    row++;
                }
            }
            if (nr_of_cell_commands) {
                int row = 0;
                while (nr_of_cell_commands--) {
                    [cellCommands addObject:[DKCommand commandWith64Bits:OSReadBigInt64(pgc, p) row:row]];
                    p += 8;
                    row++;
                }
            }
        }

        if (program_map_offset) {
            programMap = [[NSMutableArray alloc] initWithCapacity:nr_of_programs];
            for (int i = 0; i < nr_of_programs; i++) {
                [programMap addObject:[NSNumber numberWithInt:OSReadBigInt8(pgc, program_map_offset + i)]];
            }
        }

        if (cell_playback_offset && nr_of_cells) {
            cellPlaybackTable = [[NSMutableArray alloc] initWithCapacity:nr_of_cells];
            for (uint32_t p = cell_playback_offset, lp = p + (nr_of_cells * sizeof(cell_playback_t)); p < lp; p += sizeof(cell_playback_t)) {
                [cellPlaybackTable addObject:[DKCellPlayback cellPlaybackWithData:[data subdataWithRange:NSMakeRange(p, sizeof(cell_playback_t))]]];
            }
        }
        
        if (cell_position_offset && nr_of_cells) {
            cellPositionTable = [[NSMutableArray alloc] initWithCapacity:nr_of_cells];
            for (uint32_t p = cell_position_offset, lp = p + (nr_of_cells * sizeof(cell_position_t)); p < lp; p += sizeof(cell_position_t)) {
                NSError* cellPositionError = nil;
                [cellPositionTable addObject:[DKCellPosition cellPositionWithData:[data subdataWithRange:NSMakeRange(p, sizeof(cell_position_t))] error:errors ? &cellPositionError : nil]];
                if (cellPositionError) {
                    if (cellPositionError.code == kDKMultipleErrorsError) {
                        [errors addObjectsFromArray:[cellPositionError.userInfo objectForKey:NSDetailedErrorsKey]];
                    } else {
                        [errors addObject:cellPositionError];
                    }
                }
            }
        }
        
        if (errors) {
            int errorCount = [errors count];
            if (0 == errorCount) {
                *error = nil;
            } else if (1 == errorCount) {
                *error = [errors objectAtIndex:0];
            } else {
                *error = DKErrorWithCode(kDKMultipleErrorsError, errors, NSDetailedErrorsKey, nil);
            }
        }
    }
    return self;
}

- (BOOL) isEqual:(DKProgramChain*)anObject
{
	if (self == anObject) {
        return YES;
    } else return (
        [self class] == [anObject class]
        && anObject->playback_time.frame_u == playback_time.frame_u
        && anObject->playback_time.hour == playback_time.hour
        && anObject->playback_time.minute == playback_time.minute
        && anObject->playback_time.second == playback_time.second
        && anObject->prohibitedUserOperations.angle_change == prohibitedUserOperations.angle_change
        && anObject->prohibitedUserOperations.angle_menu_call == prohibitedUserOperations.angle_menu_call
        && anObject->prohibitedUserOperations.audio_menu_call == prohibitedUserOperations.audio_menu_call
        && anObject->prohibitedUserOperations.audio_stream_change == prohibitedUserOperations.audio_stream_change
        && anObject->prohibitedUserOperations.backward_scan == prohibitedUserOperations.backward_scan
        && anObject->prohibitedUserOperations.button_select_or_activate == prohibitedUserOperations.button_select_or_activate
        && anObject->prohibitedUserOperations.chapter_menu_call == prohibitedUserOperations.chapter_menu_call
        && anObject->prohibitedUserOperations.forward_scan == prohibitedUserOperations.forward_scan
        && anObject->prohibitedUserOperations.go_up == prohibitedUserOperations.go_up
        && anObject->prohibitedUserOperations.karaoke_audio_pres_mode_change == prohibitedUserOperations.karaoke_audio_pres_mode_change
        && anObject->prohibitedUserOperations.next_pg_search == prohibitedUserOperations.next_pg_search
        && anObject->prohibitedUserOperations.pause_on == prohibitedUserOperations.pause_on
        && anObject->prohibitedUserOperations.prev_or_top_pg_search == prohibitedUserOperations.prev_or_top_pg_search
        && anObject->prohibitedUserOperations.resume == prohibitedUserOperations.resume
        && anObject->prohibitedUserOperations.root_menu_call == prohibitedUserOperations.root_menu_call
        && anObject->prohibitedUserOperations.still_off == prohibitedUserOperations.still_off
        && anObject->prohibitedUserOperations.stop == prohibitedUserOperations.stop
        && anObject->prohibitedUserOperations.subpic_menu_call == prohibitedUserOperations.subpic_menu_call
        && anObject->prohibitedUserOperations.subpic_stream_change == prohibitedUserOperations.subpic_stream_change
        && anObject->prohibitedUserOperations.time_or_chapter_search == prohibitedUserOperations.time_or_chapter_search
        && anObject->prohibitedUserOperations.title_menu_call == prohibitedUserOperations.title_menu_call
        && anObject->prohibitedUserOperations.title_or_time_play == prohibitedUserOperations.title_or_time_play
        && anObject->prohibitedUserOperations.title_play == prohibitedUserOperations.title_play
        && anObject->prohibitedUserOperations.video_pres_mode_change == prohibitedUserOperations.video_pres_mode_change
        && anObject->nextProgramChainNumber == nextProgramChainNumber
        && anObject->previousProgramChainNumber == previousProgramChainNumber
        && anObject->goUpProgramChainNumber == goUpProgramChainNumber
        && anObject->still_time == still_time
        && anObject->pg_playback_mode == pg_playback_mode
        && (anObject->preCommands == preCommands || [anObject->preCommands isEqualToArray:preCommands])
        && (anObject->cellCommands == cellCommands || [anObject->cellCommands isEqualToArray:cellCommands])
        && (anObject->postCommands == postCommands || [anObject->postCommands isEqualToArray:postCommands])
        && (anObject->programMap == programMap || [anObject->programMap isEqualToArray:programMap])
        && (anObject->cellPlaybackTable == cellPlaybackTable || [anObject->cellPlaybackTable isEqualToArray:cellPlaybackTable])
        && (anObject->cellPositionTable == cellPositionTable || [anObject->cellPositionTable isEqualToArray:cellPositionTable])
    );
}

- (NSData*) saveAsData:(NSError**)error
{
    NSMutableArray* errors = !error ? nil : [NSMutableArray array];
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(pgc_t)];
    pgc_t pgc;
    bzero(&pgc, sizeof(pgc_t));

    memcpy((uint8_t*)&pgc.playback_time, &playback_time, sizeof(DKTime));
    memcpy((uint8_t*)&pgc.prohibited_ops, &prohibitedUserOperations, sizeof(DKUserOperationFlags));
    
    for (int i = 0; i < 8; i++) {
        OSWriteBigInt16(&pgc.audio_control, i << 1, audio_control[i]);
    }
    
    for (int i = 0; i < 32; i++) {
        OSWriteBigInt32(&pgc.subp_control, (i << 2), subp_control[i]);
    }
    
    OSWriteBigInt16(&pgc.next_pgc_nr, 0, nextProgramChainNumber);
    OSWriteBigInt16(&pgc.prev_pgc_nr, 0, previousProgramChainNumber);
    OSWriteBigInt16(&pgc.goup_pgc_nr, 0, goUpProgramChainNumber);
    OSWriteBigInt8(&pgc.still_time, 0, still_time);
    OSWriteBigInt8(&pgc.pg_playback_mode, 0, pg_playback_mode);

    for (int i = 0; i < 16; i++) {
        OSWriteBigInt32(&pgc.palette, (i << 2), palette[i]);
    }
    
    uint16_t nr_of_pre_commands = [preCommands count];
    uint16_t nr_of_post_commands = [postCommands count];
    uint16_t nr_of_cell_commands = [cellCommands count];
    if (nr_of_pre_commands || nr_of_post_commands || nr_of_cell_commands) {
        uint16_t command_tbl_offset = [data length];
        OSWriteBigInt16(&pgc.command_tbl_offset, 0, command_tbl_offset);

        //  TODO: Check for overflow.
        uint16_t last_byte = 8 + (8 * (nr_of_pre_commands + nr_of_post_commands + nr_of_cell_commands));
        [data increaseLengthBy:last_byte];
        uint8_t* base = [data mutableBytes] + command_tbl_offset;

        OSWriteBigInt16(base, 0, nr_of_pre_commands);
        OSWriteBigInt16(base, 2, nr_of_post_commands);
        OSWriteBigInt16(base, 4, nr_of_cell_commands);
        OSWriteBigInt16(base, 6, last_byte - 1);

        uint16_t offset = 8;
        for (DKCommand* command in preCommands) {
            OSWriteBigInt64(base, offset, command.bits);
            offset += 8;
        }
        for (DKCommand* command in postCommands) {
            OSWriteBigInt64(base, offset, command.bits);
            offset += 8;
        }
        for (DKCommand* command in cellCommands) {
            OSWriteBigInt64(base, offset, command.bits);
            offset += 8;
        }
    }
    
    uint8_t nr_of_programs = [programMap count];
    if (nr_of_programs) {
        uint16_t program_map_offset = [data length];
        OSWriteBigInt8(&pgc.nr_of_programs, 0, nr_of_programs);
        OSWriteBigInt16(&pgc.program_map_offset, 0, program_map_offset);
        [data increaseLengthBy:nr_of_programs];
        uint8_t* base = [data mutableBytes] + program_map_offset;
        for (int i = 0; i < nr_of_programs; i++) {
            OSWriteBigInt8(base, i, [[programMap objectAtIndex:i] unsignedCharValue]);
        }
    }
    
    uint8_t nr_of_cells = [cellPlaybackTable count];
    if (nr_of_cells) {
        OSWriteBigInt8(&pgc.nr_of_cells, 0, nr_of_cells);

        uint16_t cell_playback_offset = [data length];
        uint16_t cell_position_offset = cell_playback_offset + (nr_of_cells * sizeof(cell_playback_t));
        OSWriteBigInt16(&pgc.cell_playback_offset, 0, cell_playback_offset);
        OSWriteBigInt16(&pgc.cell_position_offset, 0, cell_position_offset);
        [data increaseLengthBy:nr_of_cells * (sizeof(cell_playback_t) + sizeof(cell_position_t))];
        uint8_t* base = [data mutableBytes] + cell_playback_offset;
        
        for (int i = 0; i < nr_of_cells; i++, base += sizeof(cell_playback_t)) {
            NSError* cellPlaybackError = nil;
            NSData* cellPlaybackData = [[cellPlaybackTable objectAtIndex:i] saveAsData:errors ? &cellPlaybackError : NULL];
            if (cellPlaybackError) {
                if (cellPlaybackError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[cellPlaybackError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:cellPlaybackError];
                }
            }
            if (cellPlaybackData) {
                memcpy(base, [cellPlaybackData bytes], sizeof(cell_playback_t));
            }
        }

        for (int i = 0; i < nr_of_cells; i++, base += sizeof(cell_position_t)) {
            NSError* cellPositionError = nil;
            NSData* cellPositionData = [[cellPositionTable objectAtIndex:i] saveAsData:errors ? &cellPositionError : NULL];
            if (cellPositionError) {
                if (cellPositionError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[cellPositionError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:cellPositionError];
                }
            }
            if (cellPositionData) {
                memcpy(base, [cellPositionData bytes], sizeof(cell_position_t));
            }
        }
    }
    
    if (errors) {
        int errorCount = [errors count];
        if (0 == errorCount) {
            *error = nil;
        } else if (1 == errorCount) {
            *error = [errors objectAtIndex:0];
        } else {
            *error = DKErrorWithCode(kDKMultipleErrorsError, errors, NSDetailedErrorsKey, nil);
        }
    }

    [data replaceBytesInRange:NSMakeRange(0, sizeof(pgc_t)) withBytes:&pgc];
    return data;
}

@end
