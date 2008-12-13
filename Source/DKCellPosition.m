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

@implementation DKCellPosition

+ (id) cellPositionWithNumber:(uint8_t)_number vobId:(uint16_t)_vobId
{
    return [[[DKCellPosition alloc] initWithNumber:_number vobId:_vobId] autorelease];
}

+ (id) cellPositionWithData:(NSData*)data error:(NSError**)error
{
    return [[[DKCellPosition alloc] initWithData:data error:error] autorelease];
}

- (id) initWithNumber:(uint8_t)_number vobId:(uint16_t)_vobId
{
    if (self = [super init]) {
        number = _number;
        vobId = _vobId;
    }
    return self;
}

- (id) initWithData:(NSData*)data error:(NSError**)error
{
    NSAssert(data, @"wtf?");
    NSAssert([data length] == sizeof(cell_position_t), @"wtf?");
    if (self = [super init]) {
        const cell_position_t* cell_position = [data bytes];
        number = OSReadBigInt8(&cell_position->cell_nr, 0);
        vobId = OSReadBigInt16(&cell_position->vob_id_nr, 0);
    }
    return self;
}


- (NSData*) saveAsData:(NSError**)error
{
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(cell_position_t)];
    cell_position_t* cell_position = [data mutableBytes];
    
    OSWriteBigInt8(&cell_position->cell_nr, 0, number);
    OSWriteBigInt16(&cell_position->vob_id_nr, 0, vobId);

    return data;
}

@end