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

@class DKCellPlayback;

@interface DKProgramChain : NSObject {
    DKTime playback_time;
    DKUserOperationFlags prohibitedUserOperations;
    uint16_t audio_control[8];
    uint32_t subp_control[32];
    uint16_t nextProgramChainNumber;
    uint16_t previousProgramChainNumber;
    uint16_t goUpProgramChainNumber;
    uint8_t  still_time;
    uint8_t  pg_playback_mode;
    uint32_t palette[16];
    NSMutableArray* preCommands; 
    NSMutableArray* postCommands;
    NSMutableArray* cellCommands;
    NSMutableArray* programMap;
    NSMutableArray* cellPlaybackTable;
    NSMutableArray* cellPositionTable;
    /**/
    id userInfo;
}

@property (assign) DKTime playback_time;
@property (assign) DKUserOperationFlags prohibitedUserOperations;
@property (assign) uint16_t nextProgramChainNumber;
@property (assign) uint16_t previousProgramChainNumber;
@property (assign) uint16_t goUpProgramChainNumber;
@property (assign) uint8_t still_time;
@property (assign) uint8_t pg_playback_mode;
@property (retain) NSMutableArray* preCommands;
@property (retain) NSMutableArray* postCommands;
@property (retain) NSMutableArray* cellCommands;
@property (retain) NSMutableArray* programMap;
@property (retain) NSMutableArray* cellPlaybackTable;
@property (retain) NSMutableArray* cellPositionTable;
@property (retain) id userInfo;
















+ (id) programChainWithData:(NSData*)data error:(NSError**)error;

- (id) initWithData:(NSData*)data error:(NSError**)error;

- (NSData*) saveAsData:(NSError**)error;



@end

extern NSString* const DVDProgramChainException;
