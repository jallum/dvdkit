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

@interface DKTitleTrackSearchPointer : NSObject {
    DKPlaybackFlags playbackFlags;
    uint16_t nr_of_ptts;
    uint16_t parental_id;
    uint32_t title_set_sector;
    uint8_t title_set_nr;
    uint8_t vts_ttn;
    uint8_t nr_of_angles;
    /**/
    uint16_t index;
}

+ (id) partOfTitleSearchPointerWithData:(NSData*)data index:(uint16_t)index;

- (id) initWithData:(NSData*)data index:(uint16_t)index;

@property (readwrite) DKPlaybackFlags playbackFlags;
@property (assign) uint16_t nr_of_ptts;
@property (assign) uint16_t parental_id;
@property (assign) uint32_t title_set_sector;
@property (assign) uint8_t title_set_nr;
@property (assign) uint8_t vts_ttn;
@property (assign) uint8_t nr_of_angles;
@property (assign) uint16_t index;

@end
