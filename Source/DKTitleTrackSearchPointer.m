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

@implementation DKTitleTrackSearchPointer
@synthesize index;
@synthesize angles;
@synthesize titleSetNumber;
@synthesize trackNumber;


+ (id) partOfTitleSearchPointerWithData:(NSData*)data index:(uint16_t)index
{
    return [[[DKTitleTrackSearchPointer alloc] initWithData:data index:index] autorelease];
}

- (id) initWithData:(NSData*)data index:(uint16_t)_index
{
    NSAssert(data, @"Shouldn't be nil");
    if (self = [super init]) {
        index = _index;
        const void* title_info = [data bytes]; 
        
        memcpy(&pb_ty, (uint8_t*)title_info + offsetof(title_info_t, pb_ty), sizeof(DKPlaybackFlags));
        nr_of_ptts = OSReadBigInt16(title_info, offsetof(title_info_t, nr_of_ptts));
        parental_id = OSReadBigInt16(title_info, offsetof(title_info_t, parental_id));
        title_set_sector = OSReadBigInt32(title_info, offsetof(title_info_t, title_set_sector));
        title_set_nr = OSReadBigInt8(title_info, offsetof(title_info_t, title_set_nr));
        vts_ttn = OSReadBigInt8(title_info, offsetof(title_info_t, vts_ttn));
        nr_of_angles = OSReadBigInt8(title_info, offsetof(title_info_t, nr_of_angles));
    }
    return self;
}

- (NSData*) saveAsData:(NSError**)error
{
    title_info_t title_info;
    bzero(&title_info, sizeof(title_info_t));
    memcpy(&title_info.pb_ty, &pb_ty, sizeof(DKPlaybackFlags));
    OSWriteBigInt16(&title_info, offsetof(title_info_t, nr_of_ptts), nr_of_ptts);
    OSWriteBigInt16(&title_info, offsetof(title_info_t, parental_id), parental_id);
    OSWriteBigInt32(&title_info, offsetof(title_info_t, title_set_sector), title_set_sector);
    OSWriteBigInt8(&title_info, offsetof(title_info_t, title_set_nr), title_set_nr);
    OSWriteBigInt8(&title_info, offsetof(title_info_t, vts_ttn), vts_ttn);
    OSWriteBigInt8(&title_info, offsetof(title_info_t, nr_of_angles), nr_of_angles);
    return [NSData dataWithBytes:&title_info length:sizeof(title_info_t)];
}

- (uint8_t) titleSetNumber
{
    return title_set_nr;
}

- (uint8_t) trackNumber
{
    return vts_ttn;
}

- (uint8_t) angles
{
    return nr_of_angles;
}

@end