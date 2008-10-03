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

NSString* const DVDManagerInformationException = @"DVDManagerInformation";

@interface DVDManagerInformation (Private)
- (NSArray*) parsePGCITfromData:(NSData*)data offset:(uint32_t)_offset;
@end

@implementation DVDManagerInformation
@synthesize firstPlayProgramChain;
@synthesize titleTrackSearchPointerTable;

+ (id) managerInformationWithData:(NSData*)data
{
    return [[[DVDManagerInformation alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data, @"Shouldn't be nil");
    if (self = [super init]) {
        const uint8_t* bytes = [data bytes];
        if ([data length] < 224) {
            [NSException raise:DVDManagerInformationException format:@"Video Manager Information (.IFO) data appears to be truncated."];
        } else if (0 != memcmp("DVDVIDEO-VMG", bytes, 12)) {
            [NSException raise:DVDManagerInformationException format:@"Invalid signature in the Video Manager Information (.IFO) data."];
        }

        /*  Grab the fields that we care about.
         */
        lastSector = OSReadBigInt32(bytes, 12);
        specificationVersion = OSReadBigInt16(bytes, 32);
        categoryAndMask = OSReadBigInt32(bytes, 34);
        numberOfVolumes = OSReadBigInt16(bytes, 38);
        volumeNumber = OSReadBigInt16(bytes, 40);
        side = bytes[42];
        numberOfTitleSets = OSReadBigInt16(bytes, 62);
        positionCode = OSReadBigInt64(bytes, 96);
        /**/
        uint32_t first_play_pgc = OSReadBigInt32(bytes, 132);
        /**/
        uint32_t tt_srpt = OSReadBigInt32(bytes, 196);
        uint32_t vmgm_pgci_ut = OSReadBigInt32(bytes, 200);
        uint32_t vmgm_c_adt = OSReadBigInt32(bytes, 216);

        /*  We could read these from the file, but they can be unreliable...
         *  and are easy enough to calculate.
         */
        uint32_t vmgi_last_sector = ([data length] >> 11) - 1;
        uint32_t vmgi_last_byte = [data length] - 1;
        
        /*  Sanity checks  
         */
        if (0 == numberOfVolumes) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        } else if (0 == volumeNumber) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        } else if (volumeNumber > numberOfVolumes) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        } else if (side != 1 && side != 2) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        } else if (0 == numberOfTitleSets) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        }
        
        
        /*  First Play Program Chain.
         */
        if (first_play_pgc && (first_play_pgc <= vmgi_last_byte)) {
            firstPlayProgramChain = [DVDProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(first_play_pgc, vmgi_last_byte - first_play_pgc + 1)]];
        }
        
        /*  Title/Track Search Pointer Table.
         */
        if (tt_srpt && (tt_srpt <= vmgi_last_sector)) {
            const uint8_t* p = bytes + (tt_srpt << 11);
            uint16_t nr_of_srpts = OSReadBigInt16(p, 0);
            p += 8;
            const uint8_t* lp = p + (nr_of_srpts * 12);
            
            if (!nr_of_srpts || nr_of_srpts > 99) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            } else if ((lp - p + 8 - 1) > vmgi_last_byte) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            } 
            
            titleTrackSearchPointerTable = [NSMutableArray arrayWithCapacity:nr_of_srpts];
            int i = 1;
            while (p < lp) {
                uint16_t nr_of_ptts = OSReadBigInt16(p, 2);
                [titleTrackSearchPointerTable addObject:[DVDTitleTrackSearchPointer partOfTitleSearchPointerWithData:[data subdataWithRange:NSMakeRange(p - bytes, 12 + (4 * nr_of_ptts))] index:i++]];
                p += 12;
            }
        }
        
        /*  Cell Address Table
         */
        if (vmgm_c_adt && (vmgm_c_adt <= vmgi_last_sector)) {
            const uint8_t* p = bytes + (vmgm_c_adt << 11);
            uint32_t last_byte = MIN(vmgi_last_byte, OSReadBigInt32(p, 4));
            const uint8_t* lp = p + last_byte + 1;
            p += 8;
            uint16_t nr_of_c_adts = (lp - p) / 12;
            
            if ((lp - p) % 12) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            } 
            
            cellAddressTable = [NSMutableArray arrayWithCapacity:nr_of_c_adts];
            while (p < lp) {
                [cellAddressTable addObject:[DVDCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p - bytes, 12)]]];
                p += 12;
            }
        }
        
        /*  Menu Program Chain Information Map (by language)
         */
        if (vmgm_pgci_ut && (vmgm_pgci_ut <= vmgi_last_sector)) {
            const uint8_t* bp = bytes + (vmgm_pgci_ut << 11);
            const uint8_t* p = bp;
            uint16_t nr_of_lus = OSReadBigInt16(p, 0);
            uint32_t last_byte = MIN(vmgi_last_byte, OSReadBigInt32(p, 4));
            p += 8;

            if (!nr_of_lus || nr_of_lus > 100) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            }

            menuProgramChainInformationTablesByLanguage = [NSMutableDictionary dictionaryWithCapacity:nr_of_lus];
            for (int i = 0; i < nr_of_lus; i++, p += 8) {
                uint16_t languageCode = OSReadBigInt16(p, 0);
                uint32_t pgcit_start_byte = OSReadBigInt32(p, 4);

                if ((pgcit_start_byte + 8 - 1) > last_byte) {
                    [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
                }
                
                [menuProgramChainInformationTablesByLanguage setObject:[self parsePGCITfromData:data offset:(vmgm_pgci_ut << 11) + pgcit_start_byte] forKey:[NSNumber numberWithShort:languageCode]];
            }
        }
        
        [menuProgramChainInformationTablesByLanguage retain];
        [firstPlayProgramChain retain];
        [titleTrackSearchPointerTable retain];
        [cellAddressTable retain];
    }
    return self;
}

- (void) dealloc
{
    [firstPlayProgramChain release];
    [titleTrackSearchPointerTable release];
    [cellAddressTable release];
    [super dealloc];
}

- (DVDTitleTrackSearchPointer*) titleTrackSearchPointerForTitleSet:(uint16_t)vts track:(uint8_t)ttn;
{
    for (DVDTitleTrackSearchPointer* ti in titleTrackSearchPointerTable) {
        if (vts == [ti titleSetNumber] && ttn == [ti trackNumber]) {
            return [[ti retain] autorelease];
        }
    }
    [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
    return nil; /* Never Reached */
}

- (NSArray*) menuProgramChainInformationTableForLanguageCode:(uint16_t)languageCode
{
    NSArray* table = [menuProgramChainInformationTablesByLanguage objectForKey:[NSNumber numberWithShort:languageCode]];
    if (!table) {
        table = [[menuProgramChainInformationTablesByLanguage allValues] objectAtIndex:0];
    }
    return table;
}

- (NSArray*) parsePGCITfromData:(NSData*)data offset:(uint32_t)_offset  
{
    const uint8_t* bp = [data bytes] + _offset; 
    const uint8_t* p = bp;
    uint16_t nr_of_pgci_srp = OSReadBigInt16(p, 0);
    uint32_t last_byte = OSReadBigInt32(p, 4);
    p += 8;

    if ((_offset + last_byte) >= [data length]) {
        [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
    }

    NSMutableArray* pgcit = [NSMutableArray arrayWithCapacity:nr_of_pgci_srp];
    for (int i = 0; i < nr_of_pgci_srp; i++, p += 8) {
        uint8_t entry_id = p[0];
        uint16_t ptl_id_mask = OSReadBigInt16(p, 2);
        uint32_t pgc_start_byte = OSReadBigInt32(p, 4);

        if ((pgc_start_byte + 8) >= last_byte) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        }
        
        [pgcit addObject:[DVDProgramChainSearchPointer programChainSearchPointerWithEntryId:entry_id parentalMask:ptl_id_mask programChain:[DVDProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(_offset + pgc_start_byte, last_byte - pgc_start_byte + 1)]]]];
    }
    
    return pgcit;
}

- (uint16_t) regionMask
{
    return (categoryAndMask >> 16) & 0x1FF;
}

@end
