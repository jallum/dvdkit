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

@implementation DVDCellPlayback
@synthesize firstSector;
@synthesize lastSector;
@synthesize postCommand;

+ (id) cellPlaybackWithData:(NSData*)data
{
    return [[[DVDCellPlayback alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data, @"Shouldn't be nil");
    NSAssert([data length] == 24, @"Must be 24 bytes.");
    if (self = [super init]) {
        const uint8_t* bytes = [data bytes];
        
        flags.bits = OSReadBigInt16(bytes, 0);
        stillTime = bytes[2];
        postCommand = bytes[3];
        playbackTime.hour = bytes[4];
        playbackTime.minute = bytes[5];
        playbackTime.second = bytes[6];
        playbackTime.frame_u = bytes[7];
        firstSector = OSReadBigInt32(bytes, 8);
        firstInterleavingUnitSector = OSReadBigInt32(bytes, 12);
        lastVideoObjectUnitStartSector = OSReadBigInt32(bytes, 16);
        lastSector = OSReadBigInt32(bytes, 20);
        
        if (lastVideoObjectUnitStartSector > lastVideoObjectUnitStartSector) {
            [NSException raise:@"Ripper" format:@"%s(%d)", __FILE__, __LINE__];
        } else if (lastVideoObjectUnitStartSector > lastSector) {
            [NSException raise:@"Ripper" format:@"%s(%d)", __FILE__, __LINE__];
        }
    }
    return self;
}

- (id) copyWithZone:(NSZone*)zone
{
    return [self retain];
}

- (int) blockMode
{
    return flags.values.block_mode;
}

@end
