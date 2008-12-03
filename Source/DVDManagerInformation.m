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

NSString* const DVDManagerInformationException = @"DVDManagerInformation";

@interface DVDManagerInformation (Private)
- (NSArray*) parsePGCITfromData:(NSData*)data offset:(uint32_t)_offset;
@end

@implementation DVDManagerInformation
@synthesize firstPlayProgramChain;
@synthesize titleTrackSearchPointerTable;

+ (id) managerInformationWithDataSource:(id<DVDDataSource>)dataSource
{
    return [[[DVDManagerInformation alloc] initWithDataSource:dataSource] autorelease];
}

- (id) initWithDataSource:(id<DVDDataSource>)dataSource
{
    NSAssert(dataSource, @"Shouldn't be nil");
    if (self = [super init]) {
        NSData* header = [dataSource requestDataOfLength:1 << 11 fromOffset:0];
        NSAssert(header && ([header length] == 1 << 11), @"wtf?");
        const vmgi_mat_t* vmgi_mat = [header bytes];
        if (0 != memcmp("DVDVIDEO-VMG", &vmgi_mat->vmg_identifier, 12)) {
            [NSException raise:DVDManagerInformationException format:@"Invalid signature in the Video Manager Information (.IFO) data."];
        }
        
        
        /*
         */
        specificationVersion = OSReadBigInt16(&vmgi_mat->specification_version, 0);
        categoryAndMask = OSReadBigInt32(&vmgi_mat->vmg_category, 0);
        numberOfVolumes = OSReadBigInt16(&vmgi_mat->vmg_nr_of_volumes, 0);
        volumeNumber = OSReadBigInt16(&vmgi_mat->vmg_this_volume_nr, 0);
        side = vmgi_mat->disc_side;
        numberOfTitleSets = OSReadBigInt16(&vmgi_mat->vmg_nr_of_title_sets, 0);
        pointOfSaleCode = OSReadBigInt64(&vmgi_mat->vmg_pos_code, 0);
        vmgm_vobs = OSReadBigInt32(&vmgi_mat->vmgm_vobs, 0);
        nr_of_vmgm_audio_streams = vmgi_mat->nr_of_vmgm_audio_streams;
        nr_of_vmgm_subp_streams = OSReadBigInt16(&vmgi_mat->nr_of_vmgm_subp_streams, 0);
        
        
        /*
         */
        uint32_t vmgi_last_byte = 1 + OSReadBigInt32(&vmgi_mat->vmgi_last_byte, 0);
        uint32_t vmgi_last_sector = 1 + OSReadBigInt32(&vmgi_mat->vmgi_last_sector, 0);
        
        
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

        
        /*  Video/Audio/Subpicture Attributes
         */
        menuVideoAttributes = [DVDVideoAttributes videoAttributesWithData:[NSData dataWithBytesNoCopy:(void*)&vmgi_mat->vmgm_video_attr length:sizeof(vmgm_video_attr_t)]];
        if (nr_of_vmgm_audio_streams) {
            NSMutableArray* table = [NSMutableArray array];
            for (int i = 0, iMax = MIN(8, nr_of_vmgm_audio_streams); i < iMax; i++) {
                [table addObject:[DVDAudioAttributes audioAttributesWithData:[NSData dataWithBytesNoCopy:(void*)&vmgi_mat->vmgm_audio_attr[i] length:sizeof(vmgm_audio_attr_t)]]];
            }
            menuAudioAttributes = [table retain];
        }
        
        
        /*  First Play Program Chain.
         */
        uint32_t first_play_pgc = OSReadBigInt32(&vmgi_mat->first_play_pgc, 0);
        if (first_play_pgc < sizeof(vmgi_mat)) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        } else if (first_play_pgc >= vmgi_last_byte) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        } else if (vmgi_last_byte < [header length]) {
            firstPlayProgramChain = [DVDProgramChain programChainWithData:[header subdataWithRange:NSMakeRange(first_play_pgc, vmgi_last_byte - first_play_pgc)]];
        } else {
            firstPlayProgramChain = [DVDProgramChain programChainWithData:[dataSource requestDataOfLength:vmgi_last_byte - first_play_pgc fromOffset:first_play_pgc]];
        }
        if (!firstPlayProgramChain) {
            [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
        }
        
        NSMutableDictionary* sectionOrdering = [NSMutableDictionary dictionary];
        
        /*  Title/Track Search Pointer Table.
         */
        uint32_t offset_of_tt_srpt = OSReadBigInt32(&vmgi_mat->tt_srpt, 0);
        if (offset_of_tt_srpt && (offset_of_tt_srpt <= vmgi_last_sector)) {
            [sectionOrdering setObject:@"tt_srpt" forKey:[NSNumber numberWithUnsignedInt:offset_of_tt_srpt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_tt_srpt << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const tt_srpt_t* tt_srpt = [data bytes];
            uint16_t nr_of_srpts = OSReadBigInt16(&tt_srpt->nr_of_srpts, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&tt_srpt->last_byte, 0);
            
            /*  Sanity Checking  */
            if (!nr_of_srpts || nr_of_srpts > 99) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            } else if (last_byte < (sizeof(tt_srpt) + (nr_of_srpts * 12))) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            } 
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_tt_srpt << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  Parse the table  */
            NSMutableArray* table = [NSMutableArray arrayWithCapacity:nr_of_srpts];
            for (int i = 1, p = sizeof(tt_srpt_t); i <= nr_of_srpts; i++, p += sizeof(title_info_t)) {
                [table addObject:[DVDTitleTrackSearchPointer partOfTitleSearchPointerWithData:[data subdataWithRange:NSMakeRange(p, sizeof(title_info_t))] index:i]];
            }
            if (nr_of_srpts != [table count]) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            }
            titleTrackSearchPointerTable = [table retain];
        }
        

        /*  Parental Management Information Table
         */
        uint32_t offset_of_ptl_mait = OSReadBigInt32(&vmgi_mat->ptl_mait, 0);
        if (offset_of_ptl_mait && (offset_of_ptl_mait <= vmgi_last_sector)) {
            [sectionOrdering setObject:@"ptl_mait" forKey:[NSNumber numberWithUnsignedInt:offset_of_ptl_mait]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_ptl_mait << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const ptl_mait_t* ptl_mait = [data bytes];
//            uint16_t nr_of_vtss = OSReadBigInt16(&vmg_vts_atrt->nr_of_vtss, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&ptl_mait->last_byte, 0);
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_ptl_mait << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  
             *  TODO: Additional Decoding  
             */
            
            /*  Retain the table  */
            parentalManagementInformationTable = [[data subdataWithRange:NSMakeRange(sizeof(ptl_mait_t), last_byte - sizeof(ptl_mait_t))] retain];
        }
        
        
        /*  Video Title Set Attribute Table
         */
        uint32_t offset_of_vmg_vts_atrt = OSReadBigInt32(&vmgi_mat->vmg_vts_atrt, 0);
        if (offset_of_vmg_vts_atrt && (offset_of_vmg_vts_atrt <= vmgi_last_sector)) {
            [sectionOrdering setObject:@"vmg_vts_atrt" forKey:[NSNumber numberWithUnsignedInt:offset_of_vmg_vts_atrt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vmg_vts_atrt << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const vmg_vts_atrt_t* vmg_vts_atrt = [data bytes];
//            uint16_t nr_of_vtss = OSReadBigInt16(&vmg_vts_atrt->nr_of_vtss, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&vmg_vts_atrt->last_byte, 0);

            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vmg_vts_atrt << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  
             *  TODO: Additional Decoding  
             */
            
            /*  Retain the table  */
            titleSetAttributeTable = [[data subdataWithRange:NSMakeRange(sizeof(vmg_vts_atrt_t), last_byte - sizeof(vmg_vts_atrt_t))] retain];
        }
            
        
        /*  Menu Program Chain Information Map (by language)
         */
        uint32_t offset_of_vmgm_pgci_ut = OSReadBigInt32(&vmgi_mat->vmgm_pgci_ut, 0);
        if (offset_of_vmgm_pgci_ut && (offset_of_vmgm_pgci_ut <= vmgi_last_sector)) {
            [sectionOrdering setObject:@"vmgm_pgci_ut" forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_pgci_ut]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vmgm_pgci_ut << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const vmgm_pgci_ut_t* vmgm_pgci_ut = [data bytes];
            uint16_t nr_of_lus = OSReadBigInt16(&vmgm_pgci_ut->nr_of_lus, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&vmgm_pgci_ut->last_byte, 0);
            
            /*  Sanity Checking  */
            if (!nr_of_lus || nr_of_lus > 99) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            } 
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vmgm_pgci_ut << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  Parse the tables  */
            NSMutableDictionary* tablesByLanguage = [NSMutableDictionary dictionaryWithCapacity:nr_of_lus];
            for (int i = 0, p = sizeof(vmgm_pgci_ut_t); i < nr_of_lus; i++, p += 8) {
                const pgci_lu_t* pgci_lu = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_lu_t))] bytes];
                uint16_t lang_code = OSReadBigInt16(&pgci_lu->lang_code, 0);
                uint32_t pgcit_start_byte = OSReadBigInt32(&pgci_lu->pgcit_start_byte, 0);
                
                const pgcit_t* pgcit = [[data subdataWithRange:NSMakeRange(pgcit_start_byte, sizeof(pgcit_t))] bytes];
                uint16_t nr_of_pgci_srp = OSReadBigInt16(&pgcit->nr_of_pgci_srp, 0);
                uint32_t pgcit_last_byte = 1 + OSReadBigInt32(&pgcit->last_byte, 0);
                
                if ((pgcit_start_byte + pgcit_last_byte) > last_byte) {
                    [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
                }
                
                NSMutableArray* table = [NSMutableArray array];
                for (int i = 0, p = pgcit_start_byte + sizeof(pgcit_t); i < nr_of_pgci_srp; i++, p += sizeof(pgci_srp_t)) {
                    const pgci_srp_t* pgci_srp = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_srp_t))] bytes];
                    uint8_t entry_id = pgci_srp->entry_id;
                    uint16_t ptl_id_mask = OSReadBigInt16(&pgci_srp->ptl_id_mask, 0);
                    uint32_t pgc_start_byte = OSReadBigInt32(&pgci_srp->pgc_start_byte, 0);
                    [table addObject:[DVDProgramChainSearchPointer programChainSearchPointerWithEntryId:entry_id parentalMask:ptl_id_mask programChain:[DVDProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(pgcit_start_byte + pgc_start_byte, pgcit_last_byte - pgc_start_byte)]]]];
                }
                if (nr_of_pgci_srp != [table count]) {
                    [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
                }
                [tablesByLanguage setObject:table forKey:[NSNumber numberWithShort:lang_code]];
            }
            if (nr_of_lus != [tablesByLanguage count]) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            }
            menuProgramChainInformationTablesByLanguage = [tablesByLanguage retain];
        }
        
        
        /*  Text Data
         */
        uint32_t offset_of_txtdt_mgi = OSReadBigInt32(&vmgi_mat->txtdt_mgi, 0);
        if (offset_of_txtdt_mgi && (offset_of_txtdt_mgi <= vmgi_last_sector)) {
            [sectionOrdering setObject:@"txtdt_mgi" forKey:[NSNumber numberWithUnsignedInt:offset_of_txtdt_mgi]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_txtdt_mgi << 11];
            uint32_t last_byte = 1 + OSReadBigInt32([data bytes], 0);
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_txtdt_mgi << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }

            /*  
             *  TODO: Additional Decoding  
             */
            
            /*  Retain the table  */
            textData = [[data subdataWithRange:NSMakeRange(4, last_byte - 4)] retain]; 
        }
        
        
        /*  Cell Address Table
         */
        uint32_t offset_of_vmgm_c_adt = OSReadBigInt32(&vmgi_mat->vmgm_c_adt, 0);
        if (offset_of_vmgm_c_adt && (offset_of_vmgm_c_adt <= vmgi_last_sector)) {
            [sectionOrdering setObject:@"vmgm_c_adt" forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_c_adt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vmgm_c_adt << 11];
            const vmgm_c_adt_t* vmgm_c_adt = [data bytes];
            uint16_t nr_of_c_adts = OSReadBigInt16(&vmgm_c_adt->nr_of_c_adts, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&vmgm_c_adt->last_byte, 0);
            
            /*  Sanity Checking  */
            if (last_byte < (sizeof(vmgm_c_adt) + (nr_of_c_adts * sizeof(vmgm_c_adt_t)))) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            } 
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vmgm_c_adt << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  Parse the table  */
            NSMutableArray* table = [NSMutableArray arrayWithCapacity:nr_of_c_adts];
            for (int i = 1, p = sizeof(vmgm_c_adt_t); i <= nr_of_c_adts; i++, p += sizeof(cell_adr_t)) {
                [table addObject:[DVDCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p, sizeof(cell_adr_t))]]];
            }
            if (nr_of_c_adts != [table count]) {
                [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
            }
            cellAddressTable = [table retain];
        }
        
        
        /*  Menu VOBU Address Map
         */
        uint32_t offset_of_vmgm_vobu_admap = OSReadBigInt32(&vmgi_mat->vmgm_vobu_admap, 0);
        if (offset_of_vmgm_vobu_admap && (offset_of_vmgm_vobu_admap <= vmgi_last_sector)) {
            [sectionOrdering setObject:@"vmgm_vobu_admap" forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_vobu_admap]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vmgm_vobu_admap << 11];
            uint32_t last_byte = 1 + OSReadBigInt32([data bytes], 0);
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_txtdt_mgi << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }

            /*  
             *  TODO: Additional Decoding  
             */
            
            /*  Retain the table  */
            menuVobuAddressMap = [[data subdataWithRange:NSMakeRange(4, last_byte - 4)] retain];
        }
     

        /*  Using the information gathered while reading, determine the order
         *  that the sections should be written in, should we choose to do so
         *  at a later point.
         */
        sectionOrder = [sectionOrdering objectsForKeys:[sectionOrdering keysSortedByValueUsingSelector:@selector(compare:)] notFoundMarker:[NSNull null]];
    }
    return self;     
}

- (void) dealloc
{
    [firstPlayProgramChain retain];
    [titleTrackSearchPointerTable retain];
    [parentalManagementInformationTable retain];
    [titleSetAttributeTable retain];
    [menuProgramChainInformationTablesByLanguage retain];
    [textData retain];
    [cellAddressTable retain];
    [menuVobuAddressMap retain];
    [sectionOrder retain];
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

- (uint16_t) regionMask
{
    return categoryAndMask & 0x1FF;
}

@end

