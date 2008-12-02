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

@implementation DVDCellAddress
@synthesize vob_id;
@synthesize cell_id;
@synthesize start_sector;
@synthesize last_sector;


+ (id) cellAddressWithData:(NSData*)data
{
    return [[[DVDCellAddress alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data && [data length] == sizeof(cell_adr_t), @"wtf?");
    if (self = [super init]) {
        const cell_adr_t* cell_adr = [data bytes];
        vob_id = OSReadBigInt16(&cell_adr->vob_id, 0);
        cell_id = cell_adr->cell_id;
        start_sector = OSReadBigInt32(&cell_adr->start_sector, 0);
        last_sector = OSReadBigInt32(&cell_adr->last_sector, 0);
    }
    return self;
}

@end
