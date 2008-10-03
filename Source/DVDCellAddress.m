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

@implementation DVDCellAddress

+ (id) cellAddressWithData:(NSData*)data
{
    return [[[DVDCellAddress alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data, @"Shouldn't be nil");
    NSAssert([data length] == 12, @"Must be 12 bytes");
    if (self = [super init]) {
        const uint8_t* bytes = [data bytes];

        vob_id = OSReadBigInt16(bytes, 0);
        cell_id = bytes[2];
        start_sector = OSReadBigInt32(bytes, 4);
        last_sector = OSReadBigInt32(bytes, 8);
    }
    return self;
}

@end
