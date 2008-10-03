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

@interface DVDTitleTrackSearchPointer : NSObject {
    uint16_t index;
    dvd_playback_type_t pb_ty;
    uint8_t  angles;
    uint16_t parental_id;
    uint8_t  titleSetNumber;
    uint8_t  trackNumber;
    uint32_t title_set_sector;
    /**/
    NSMutableArray* partsOfTitle;
}

+ (id) partOfTitleSearchPointerWithData:(NSData*)data index:(uint16_t)index;

- (id) initWithData:(NSData*)data index:(uint16_t)index;

@property (readonly) uint8_t titleSetNumber;
@property (readonly) uint8_t trackNumber;
@property (readonly) uint16_t index;
@property (readonly) uint8_t angles;
@property (readonly) NSArray* partsOfTitle;

@end
