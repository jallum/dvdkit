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

typedef enum {
    kDKBlockTypeNone = 0,
    kDKBlockTypeAngle = 1,
} DKBlockType;

typedef enum {
    kDKBlockModeNotInBlock = 0,
    kDKBlockModeFirstCell = 1,
    kDKBlockModeInBlock = 2,
    kDKBlockModeLastCell = 3,
} DKBlockMode;

@interface DKCellPlayback : NSObject <NSCopying> {
    BOOL seamless_angle;
    BOOL stc_discontinuity;
    BOOL interleaved;
    BOOL seamless_play;
    DKBlockType blockType;
    DKBlockMode blockMode;
    BOOL restricted;
    BOOL playback_mode;
    /**/
    uint8_t stillTime;
    uint8_t postCommandIndex;
    DKTime playbackTime;
    uint32_t firstSector;
    uint32_t firstInterleavingUnitSector;
    uint32_t lastVideoObjectUnitStartSector;
    uint32_t lastSector;
}

+ (id) cellPlaybackWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

@property (readonly) uint32_t firstSector;
@property (readonly) uint32_t lastSector;
@property (readonly) uint8_t postCommandIndex;
@property (readonly) DKBlockType blockType;
@property (readonly) DKBlockMode blockMode;

@end

extern NSString* const DVDCellPlaybackException;
