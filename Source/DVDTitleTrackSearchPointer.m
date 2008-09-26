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

@implementation DVDTitleTrackSearchPointer
@synthesize angles;
@synthesize index;
@synthesize titleSetNumber;
@synthesize trackNumber;
@synthesize partsOfTitle;

+ (id) partOfTitleSearchPointerWithData:(NSData*)data index:(uint16_t)index
{
    return [[[DVDTitleTrackSearchPointer alloc] initWithData:data index:index] autorelease];
}

- (id) initWithData:(NSData*)data index:(uint16_t)_index
{
    NSAssert(data, @"Shouldn't be nil");
    if (self = [super init]) {
        const uint8_t* bytes = [data bytes];

        index = _index;
        pb_ty.value = bytes[0];
        angles = bytes[1];
        uint16_t nr_of_ptts = OSReadBigInt16(bytes, 2);
        parental_id = OSReadBigInt16(bytes, 4);
        titleSetNumber = bytes[6];
        trackNumber = bytes[7];
        title_set_sector = OSReadBigInt32(bytes, 8);
        
        partsOfTitle = [NSMutableArray arrayWithCapacity:nr_of_ptts];
        for (const uint8_t* p = bytes + 12, *lp = p + (nr_of_ptts * 4); p < lp; p += 4) {
            uint16_t pgcn = OSReadBigInt16(p, 0);
            uint16_t pgn = OSReadBigInt16(p, 2);
            [partsOfTitle addObject:[DVDPartOfTitle partOfTitleWithProgramChain:pgcn program:pgn]];
        }
        
        [partsOfTitle retain];
    }
    return self;
}

- (void) dealloc
{
    [partsOfTitle release];
    [super dealloc];
}

@end
