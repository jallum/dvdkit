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

NSString* const DVDTitleSetException = @"DVDTitleSet";

@interface DVDTitleSet (Private)
- (NSArray*) parsePGCITfromData:(NSData*)data offset:(uint32_t)_offset;
@end

@implementation DVDTitleSet
@synthesize index;
@synthesize programChainInformationTable;
@synthesize partOfTitleSearchTable;

+ (id) titleSetWithData:(NSData*)data index:(uint16_t)index
{
    return [[[DVDTitleSet alloc] initWithData:data index:index] autorelease];
}

- (id) initWithData:(NSData*)data index:(uint16_t)_index
{
    NSAssert(data, @"Shouldn't be nil");
    NSAssert(_index > 0 && _index < 100, @"Valid range of title set index is 1-99");
    if (self = [super init]) {
        const uint8_t* bytes = [data bytes];
        if (bytes == NULL) {
            [NSException raise:DVDTitleSetException format:@"Video Manager Information (.IFO) data appears to be corrupted (Reason #%d).", __LINE__];
        } else if ([data length] < 224) {
            [NSException raise:DVDTitleSetException format:@"Video Manager Information (.IFO) data appears to be truncated."];
        } else if (0 != memcmp("DVDVIDEO-VTS", bytes, 12)) {
            [NSException raise:DVDTitleSetException format:@"Invalid signature in the Video Manager Information (.IFO) data."];
        }

        index = _index;

        /*  Grab the fields that we care about.
         */
        /**/
        uint32_t vts_ptt_srpt = OSReadBigInt32(bytes, 200);
        uint32_t vts_pgcit = OSReadBigInt32(bytes, 204);
        uint32_t vtsm_pgci_ut = OSReadBigInt32(bytes, 208);
        uint32_t vtsm_c_adt = OSReadBigInt32(bytes, 216);
        uint32_t vtsm_vobu_admap = OSReadBigInt32(bytes, 220);
        uint32_t vts_c_adt = OSReadBigInt32(bytes, 224);
        uint32_t vts_vobu_admap = OSReadBigInt32(bytes, 228);

        /*  We could read these from the file, but they can be unreliable...
         *  and are easy enough to calculate.
         */
        uint32_t vtsi_last_sector = ([data length] >> 11) - 1;
        uint32_t vtsi_last_byte = [data length] - 1;

        /*  Part of Title Search Pointer Table.
         */
        if (vts_ptt_srpt && (vts_ptt_srpt <= vtsi_last_sector)) {
            const uint8_t* bp = bytes + (vts_ptt_srpt << 11);
            const uint8_t* p = bp;
            uint16_t nr_of_srpts = OSReadBigInt16(p, 0);
            uint32_t last_byte = MIN(vtsi_last_byte - (vts_ptt_srpt << 11), OSReadBigInt32(p, 4));
            p += 8;
            
            if (!nr_of_srpts || nr_of_srpts > 99) {
                [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
            }
            
            partOfTitleSearchTable = [NSMutableArray arrayWithCapacity:nr_of_srpts];
            for (int i = 0; i < nr_of_srpts; i++, p += 4) {
                uint32_t start_byte = OSReadBigInt32(p, 0);
                uint32_t length = ((i < nr_of_srpts - 1) ? OSReadBigInt32(p, 4) : last_byte + 1) - start_byte;
                uint16_t nr_of_ptts = length / 4;
                NSMutableArray* ptts = [NSMutableArray arrayWithCapacity:nr_of_ptts];
                for (const uint8_t* x = bp + start_byte, *lx = x + length; x < lx; x += 4) {
                    [ptts addObject:[DVDPartOfTitle partOfTitleWithProgramChain:OSReadBigInt16(x, 0) program:OSReadBigInt16(x, 2)]];
                }
                [partOfTitleSearchTable addObject:ptts];
            }
        }
        
        /*  Menu Cell Address Table
         */
        if (vtsm_c_adt && (vtsm_c_adt <= vtsi_last_sector)) {
            const uint8_t* p = bytes + (vtsm_c_adt << 11);
            uint32_t last_byte = MIN(vtsi_last_byte - (vtsm_c_adt << 11), OSReadBigInt32(p, 4));
            const uint8_t* lp = p + last_byte + 1;
            p += 8;
            uint16_t nr_of_c_adts = (lp - p) / 12;
            
            if ((lp - p) % 12) {
                [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
            } 
            
            menuCellAddressTable = [NSMutableArray arrayWithCapacity:nr_of_c_adts];
            while (p < lp) {
                [menuCellAddressTable addObject:[DVDCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p - bytes, 12)]]];
                p += 12;
            }
        }

        /*  Cell Address Table
         */
        if (vts_c_adt && (vts_c_adt <= vtsi_last_sector)) {
            const uint8_t* p = bytes + (vts_c_adt << 11);
            uint32_t last_byte = MIN(vtsi_last_byte - (vts_c_adt << 11), OSReadBigInt32(p, 4));
            const uint8_t* lp = p + last_byte + 1;
            p += 8;
            uint16_t nr_of_c_adts = (lp - p) / 12;
            
            if ((lp - p) % 12) {
                [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
            } 
            
            cellAddressTable = [NSMutableArray arrayWithCapacity:nr_of_c_adts];
            while (p < lp) {
                [cellAddressTable addObject:[DVDCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p - bytes, 12)]]];
                p += 12;
            }
        }
        
        /*  Menu VOBU Address Map
         */
        if (vtsm_vobu_admap && (vtsm_vobu_admap <= vtsi_last_sector)) {
            const uint8_t* p = bytes + (vtsm_vobu_admap << 11);
            uint32_t last_byte = MIN(vtsi_last_byte - (vtsm_vobu_admap << 11), OSReadBigInt32(p, 0));
            const uint8_t* lp = p + last_byte + 1;
            p += 4;
            vtsmVobuAdMap_nr = (lp - p) / 4;
            
            if ((lp - p) % 4) {
                [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
            }
            
            vtsmVobuAdMap = calloc(vtsmVobuAdMap_nr, 4);
            for (uint32_t* e = vtsmVobuAdMap; p < lp; p += 4) {
                *e++ = OSReadBigInt32(p, 0);
            }
        }
        
        /*  VOBU Address Map
         */
        if (vts_vobu_admap && (vts_vobu_admap <= vtsi_last_sector)) {
            const uint8_t* p = bytes + (vts_vobu_admap << 11);
            uint32_t last_byte = MIN(vtsi_last_byte - (vts_vobu_admap << 11), OSReadBigInt32(p, 0));
            const uint8_t* lp = p + last_byte + 1;
            p += 4;
            vtsVobuAdMap_nr = (lp - p) / 4;
            
            if ((lp - p) % 4) {
                [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
            }
            
            vtsVobuAdMap = calloc(vtsVobuAdMap_nr, 4);
            for (uint32_t* e = vtsVobuAdMap; p < lp; p += 4) {
                *e++ = OSReadBigInt32(p, 0);
            }
        }

        /*  Program Chain Information Table
         */
        if (vts_pgcit && (vts_pgcit <= vtsi_last_sector)) {
            programChainInformationTable = [self parsePGCITfromData:data offset:(vts_pgcit << 11)];
        }
        
        /*  Menu Program Chain Information Map (by language)
         */
        if (vtsm_pgci_ut && (vtsm_pgci_ut <= vtsi_last_sector)) {
            const uint8_t* bp = bytes + (vtsm_pgci_ut << 11);
            const uint8_t* p = bp;
            uint16_t nr_of_lus = OSReadBigInt16(p, 0);
            uint32_t last_byte = MIN(vtsi_last_byte - (vtsm_pgci_ut << 11), OSReadBigInt32(p, 4));
            p += 8;

            if (!nr_of_lus || nr_of_lus > 100) {
                [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
            }

            menuProgramChainInformationTablesByLanguage = [NSMutableDictionary dictionaryWithCapacity:nr_of_lus];
            for (int i = 0; i < nr_of_lus; i++, p += 8) {
                uint16_t languageCode = OSReadBigInt16(p, 0);
                uint32_t pgcit_start_byte = OSReadBigInt32(p, 4);

                if ((pgcit_start_byte + 8 - 1) > last_byte) {
                    [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
                }
                
                [menuProgramChainInformationTablesByLanguage setObject:[self parsePGCITfromData:data offset:(vtsm_pgci_ut << 11) + pgcit_start_byte] forKey:[NSNumber numberWithShort:languageCode]];
            }
        }
        
        [menuProgramChainInformationTablesByLanguage retain];
        [partOfTitleSearchTable retain];
        [menuCellAddressTable retain];
        [cellAddressTable retain];
        [programChainInformationTable retain];
    }
    return self;
}

- (void) dealloc
{
    if (vtsVobuAdMap) {
        free(vtsVobuAdMap);
    }
    if (vtsmVobuAdMap) {
        free(vtsmVobuAdMap);
    }
    [menuProgramChainInformationTablesByLanguage release];
    [programChainInformationTable release];
    [menuCellAddressTable release];
    [cellAddressTable release];
    [partOfTitleSearchTable release];
    [super dealloc];
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
        [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
    }

    NSMutableArray* pgcit = [NSMutableArray arrayWithCapacity:nr_of_pgci_srp];
    for (int i = 0; i < nr_of_pgci_srp; i++, p += 8) {
        uint8_t entry_id = p[0];
        uint16_t ptl_id_mask = OSReadBigInt16(p, 2);
        uint32_t pgc_start_byte = OSReadBigInt32(p, 4);

        if ((pgc_start_byte + 8) >= last_byte) {
            [NSException raise:DVDTitleSetException format:@"%s(%d)", __FILE__, __LINE__];
        }
        
        [pgcit addObject:[DVDProgramChainSearchPointer programChainSearchPointerWithEntryId:entry_id parentalMask:ptl_id_mask programChain:[DVDProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(_offset + pgc_start_byte, (last_byte - pgc_start_byte) + 1)]]]];
    }
    
    return pgcit;
}

@end
