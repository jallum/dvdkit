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

NSString* const kDKManagerInformationSection_TT_SRPT          = @"tt_srpt";
NSString* const kDKManagerInformationSection_PTL_MAIT         = @"ptl_mait";
NSString* const kDKManagerInformationSection_VMG_VTS_ATRT     = @"vmg_vts_atrt";
NSString* const kDKManagerInformationSection_VMGM_PGCI_UT     = @"vmgm_pgci_ut";
NSString* const kDKManagerInformationSection_TXTDT_MGI        = @"txtdt_mgi";
NSString* const kDKManagerInformationSection_VMGM_C_ADT       = @"vmgm_c_adt";
NSString* const kDKManagerInformationSection_VMGM_VOBU_ADMAP  = @"vmgm_vobu_admap";

static NSArray* ALL_SECTIONS;

@interface DVDManagerInformation (Private)
- (NSArray*) parsePGCITfromData:(NSData*)data offset:(uint32_t)_offset;
@end

@implementation DVDManagerInformation
@synthesize firstPlayProgramChain;
@synthesize titleTrackSearchPointerTable;
@synthesize menuProgramChainInformationTablesByLanguage;

+ (void) initialize
{
    if (self == [DVDManagerInformation class]) {
        ALL_SECTIONS = [[NSArray alloc] initWithObjects:
            kDKManagerInformationSection_TT_SRPT,
            kDKManagerInformationSection_PTL_MAIT,
            kDKManagerInformationSection_VMG_VTS_ATRT, 
            kDKManagerInformationSection_VMGM_PGCI_UT,
            kDKManagerInformationSection_TXTDT_MGI,
            kDKManagerInformationSection_VMGM_C_ADT,
            kDKManagerInformationSection_VMGM_VOBU_ADMAP,
            nil
        ];
    }
}

+ (id) managerInformationWithDataSource:(id<DVDDataSource>)dataSource
{
    return [[[DVDManagerInformation alloc] initWithDataSource:dataSource] autorelease];
}

- (id) initWithDataSource:(id<DVDDataSource>)dataSource
{
    NSAssert(dataSource, @"Shouldn't be nil");
    if (self = [super init]) {
        NSMutableDictionary* sectionOrdering = [NSMutableDictionary dictionary];
        NSData* header = [dataSource requestDataOfLength:1 << 11 fromOffset:0];
        NSAssert(header && ([header length] == 1 << 11), @"wtf?");
        const vmgi_mat_t* vmgi_mat = [header bytes];
        if (0 != memcmp("DVDVIDEO-VMG", &vmgi_mat->vmg_identifier, 12)) {
            [NSException raise:DVDManagerInformationException format:@"Invalid signature in the Video Manager Information (.IFO) data."];
        }
        
        
        /*
         */
        specificationVersion = OSReadBigInt16(vmgi_mat, offsetof(vmgi_mat_t, specification_version));
        categoryAndMask = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmg_category));
        numberOfVolumes = OSReadBigInt16(vmgi_mat, offsetof(vmgi_mat_t, vmg_nr_of_volumes));
        volumeNumber = OSReadBigInt16(vmgi_mat, offsetof(vmgi_mat_t, vmg_this_volume_nr));
        side = OSReadBigInt8(vmgi_mat, offsetof(vmgi_mat_t, disc_side));
        numberOfTitleSets = OSReadBigInt16(vmgi_mat, offsetof(vmgi_mat_t, vmg_nr_of_title_sets));
        pointOfSaleCode = OSReadBigInt64(vmgi_mat, offsetof(vmgi_mat_t, vmg_pos_code));
        vmgm_vobs = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmgm_vobs));
        
        
        /*
         */
        uint32_t vmgi_last_byte = 1 + OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmgi_last_byte));
        uint32_t vmgi_last_sector = 1 + OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmgi_last_sector));
        
        
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
        uint8_t nr_of_vmgm_audio_streams = vmgi_mat->nr_of_vmgm_audio_streams;
        if (nr_of_vmgm_audio_streams) {
            NSMutableArray* table = [NSMutableArray array];
            for (int i = 0, iMax = MIN(8, nr_of_vmgm_audio_streams); i < iMax; i++) {
                [table addObject:[DVDAudioAttributes audioAttributesWithData:[NSData dataWithBytesNoCopy:(void*)&vmgi_mat->vmgm_audio_attr[i] length:sizeof(vmgm_audio_attr_t)]]];
            }
            menuAudioAttributes = [table retain];
        }
        uint16_t nr_of_vmgm_subp_streams = OSReadBigInt16(vmgi_mat, offsetof(vmgi_mat_t, nr_of_vmgm_subp_streams));
        if (nr_of_vmgm_subp_streams) {
            menuSubpictureAttributes = [DVDSubpictureAttributes subpictureAttributesWithData:[NSData dataWithBytesNoCopy:(void*)&vmgi_mat->vmgm_subp_attr length:sizeof(vmgm_subp_attr_t)]];
        }
        
        
        /*  First Play Program Chain.
         */
        uint32_t first_play_pgc = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, first_play_pgc));
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
        
        
        /*  Title/Track Search Pointer Table.
         */
        uint32_t offset_of_tt_srpt = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, tt_srpt));
        if (offset_of_tt_srpt && (offset_of_tt_srpt <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_TT_SRPT forKey:[NSNumber numberWithUnsignedInt:offset_of_tt_srpt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_tt_srpt << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const void* tt_srpt = [data bytes];
            uint16_t nr_of_srpts = OSReadBigInt16(tt_srpt, offsetof(tt_srpt_t, nr_of_srpts));
            uint32_t last_byte = 1 + OSReadBigInt32(tt_srpt, offsetof(tt_srpt_t, last_byte));
            
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
        uint32_t offset_of_ptl_mait = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, ptl_mait));
        if (offset_of_ptl_mait && (offset_of_ptl_mait <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_PTL_MAIT forKey:[NSNumber numberWithUnsignedInt:offset_of_ptl_mait]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_ptl_mait << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const void* ptl_mait = [data bytes];
            uint32_t last_byte = 1 + OSReadBigInt32(ptl_mait, offsetof(ptl_mait_t, last_byte));
            
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
        uint32_t offset_of_vmg_vts_atrt = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmg_vts_atrt));
        if (offset_of_vmg_vts_atrt && (offset_of_vmg_vts_atrt <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMG_VTS_ATRT forKey:[NSNumber numberWithUnsignedInt:offset_of_vmg_vts_atrt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vmg_vts_atrt << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const void* vmg_vts_atrt = [data bytes];
            uint32_t last_byte = 1 + OSReadBigInt32(vmg_vts_atrt, offsetof(vmg_vts_atrt_t, last_byte));

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
        uint32_t offset_of_vmgm_pgci_ut = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmgm_pgci_ut));
        if (offset_of_vmgm_pgci_ut && (offset_of_vmgm_pgci_ut <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMGM_PGCI_UT forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_pgci_ut]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vmgm_pgci_ut << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const void* vmgm_pgci_ut = [data bytes];
            uint16_t nr_of_lus = OSReadBigInt16(vmgm_pgci_ut, offsetof(vmgm_pgci_ut_t, nr_of_lus));
            uint32_t last_byte = 1 + OSReadBigInt32(vmgm_pgci_ut, offsetof(vmgm_pgci_ut_t, last_byte));
            
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
                const void* pgci_lu = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_lu_t))] bytes];
                uint16_t lang_code = OSReadBigInt16(pgci_lu, offsetof(pgci_lu_t, lang_code));
                uint32_t pgcit_start_byte = OSReadBigInt32(pgci_lu, offsetof(pgci_lu_t, pgcit_start_byte));
                
                const void* pgcit = [[data subdataWithRange:NSMakeRange(pgcit_start_byte, sizeof(pgcit_t))] bytes];
                uint16_t nr_of_pgci_srp = OSReadBigInt16(pgcit, offsetof(pgcit_t, nr_of_pgci_srp));
                uint32_t pgcit_last_byte = 1 + OSReadBigInt32(pgcit, offsetof(pgcit_t, last_byte));
                
                if ((pgcit_start_byte + pgcit_last_byte) > last_byte) {
                    [NSException raise:DVDManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
                }
                
                NSMutableArray* table = [NSMutableArray array];
                for (int i = 0, p = pgcit_start_byte + sizeof(pgcit_t); i < nr_of_pgci_srp; i++, p += sizeof(pgci_srp_t)) {
                    const void* pgci_srp = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_srp_t))] bytes];
                    uint8_t entry_id = OSReadBigInt8(pgci_srp, offsetof(pgci_srp_t, entry_id));
                    uint16_t ptl_id_mask = OSReadBigInt16(pgci_srp, offsetof(pgci_srp_t, ptl_id_mask));
                    uint32_t pgc_start_byte = OSReadBigInt32(pgci_srp, offsetof(pgci_srp_t, pgc_start_byte));
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
        uint32_t offset_of_txtdt_mgi = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, txtdt_mgi));
        if (offset_of_txtdt_mgi && (offset_of_txtdt_mgi <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_TXTDT_MGI forKey:[NSNumber numberWithUnsignedInt:offset_of_txtdt_mgi]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_txtdt_mgi << 11];
            
            /*  
             *  TODO: Additional Decoding  
             */
            
            /*  Retain the table  */
            textData = [data retain]; 
        }
        
        
        /*  Cell Address Table
         */
        uint32_t offset_of_vmgm_c_adt = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmgm_c_adt));
        if (offset_of_vmgm_c_adt && (offset_of_vmgm_c_adt <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMGM_C_ADT forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_c_adt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vmgm_c_adt << 11];
            const void* vmgm_c_adt = [data bytes];
            uint16_t nr_of_c_adts = OSReadBigInt16(vmgm_c_adt, offsetof(vmgm_c_adt_t, nr_of_c_adts));
            uint32_t last_byte = 1 + OSReadBigInt32(vmgm_c_adt, offsetof(vmgm_c_adt_t, last_byte));
            
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
        uint32_t offset_of_vmgm_vobu_admap = OSReadBigInt32(vmgi_mat, offsetof(vmgi_mat_t, vmgm_vobu_admap));
        if (offset_of_vmgm_vobu_admap && (offset_of_vmgm_vobu_admap <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMGM_VOBU_ADMAP forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_vobu_admap]];
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
        preferredSectionOrder = [sectionOrdering objectsForKeys:[sectionOrdering keysSortedByValueUsingSelector:@selector(compare:)] notFoundMarker:[NSNull null]];
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
    [preferredSectionOrder retain];
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

- (NSData*) saveAsData:(NSError**)_error
{
    NSMutableData* data = [NSMutableData data];
    
    
    /*
     */
    [data increaseLengthBy:sizeof(vmgi_mat_t)];  
    vmgi_mat_t vmgi_mat;
    bzero(&vmgi_mat, sizeof(vmgi_mat_t));
    memcpy(vmgi_mat.vmg_identifier, "DVDVIDEO-VMG", 12);
    

    /*
     */
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, specification_version), specificationVersion);
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmg_category), categoryAndMask);
    OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, vmg_nr_of_volumes), numberOfVolumes);
    OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, vmg_this_volume_nr), volumeNumber);
    OSWriteBigInt8(&vmgi_mat, offsetof(vmgi_mat_t, disc_side), side);
    OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, vmg_nr_of_title_sets), numberOfTitleSets);
    OSWriteBigInt64(&vmgi_mat, offsetof(vmgi_mat_t, vmg_pos_code), pointOfSaleCode);
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgm_vobs), vmgm_vobs);
    
    
    /*  Video/Audio/Subpicture Attributes
     */
    NSData* menuVideoAttributesData = [menuVideoAttributes saveAsData:_error];
    if (!menuVideoAttributesData) {
        return nil;
    }
    memcpy(&vmgi_mat.vmgm_video_attr, [menuVideoAttributesData bytes], sizeof(vmgm_video_attr_t));
    /**/
    uint8_t nr_of_vmgm_audio_streams = vmgi_mat.nr_of_vmgm_audio_streams = [menuAudioAttributes count];
    if (nr_of_vmgm_audio_streams > 8) {
        if (_error) {
            /* TODO: Build Error */
            *_error = nil;
        }
        return nil;
    }
    for (int i = 0; i < nr_of_vmgm_audio_streams; i++) {
        NSData* menuAudioAttributesData = [[menuAudioAttributes objectAtIndex:i] saveAsData:_error];
        if (!menuAudioAttributesData) {
            return nil;
        }
        memcpy(&vmgi_mat.vmgm_audio_attr[i], [menuAudioAttributesData bytes], sizeof(vmgm_audio_attr_t));
    }
    /**/
    if (menuSubpictureAttributes) {
        OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, nr_of_vmgm_subp_streams), 1);
        NSData* menuSubpictureAttributesData = [menuSubpictureAttributes saveAsData:_error];
        if (!menuSubpictureAttributesData) {
            return nil;
        }
        memcpy(&vmgi_mat.vmgm_subp_attr, [menuSubpictureAttributesData bytes], sizeof(vmgm_subp_attr_t));
    }
    

    /*  Append the first play program chain
     */
    if (!firstPlayProgramChain) {
        if (_error) {
            /* TODO: Build Error */
            *_error = nil;
        }
        return nil;
    }
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, first_play_pgc), [data length]);
    //
    //  TODO: Encode and append first play program chain to data.
    //
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgi_last_byte), [data length]);
    uint32_t amountToAlign = 0x800 - ([data length] & 0x07FF);
    if (amountToAlign != 0x800) {
        [data increaseLengthBy:amountToAlign];
    }
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgi_last_sector), ([data length] >> 1) - 1);
        
    
    /*  Determine the proper order, and then write out the various sections.
     */
    NSMutableArray* sectionOrder = [[preferredSectionOrder mutableCopy] autorelease];
    for (NSString* section in ALL_SECTIONS) {
        if (![sectionOrder containsObject:section]) {
            [sectionOrder addObject:section];
        }
    }
    for (NSString* section in sectionOrder) {
        NSAssert([data length] & 0x07FF == 0, @"Sections not sector-aligned?");
        uint32_t offsetOfSection = [data length];
        NSData* sectionData = nil;
        if ([section isEqualToString:kDKManagerInformationSection_TT_SRPT]) {
            if (![titleTrackSearchPointerTable count]) {
                continue;
            }
            
            //  TODO: Encode titleTrackSearchPointerTable
            
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, tt_srpt), offsetOfSection);
        } else if ([section isEqualToString:kDKManagerInformationSection_PTL_MAIT]) {
            if (![parentalManagementInformationTable length]) {
                continue;
            }
            
            // TODO:  Encode parentalManagementInformationTable

            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, ptl_mait), offsetOfSection);
        } else if ([section isEqualToString:kDKManagerInformationSection_VMG_VTS_ATRT]) { 
            if (![titleSetAttributeTable length]) {
                continue;
            }
            
            // TODO:  Encode titleSetAttributeTable
            
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmg_vts_atrt), offsetOfSection);
        } else if ([section isEqualToString:kDKManagerInformationSection_VMGM_PGCI_UT]) {
            if (![menuProgramChainInformationTablesByLanguage count]) {
                continue;
            }
            
            // TODO:  Encode menuProgramChainInformationTablesByLanguage
            
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgm_pgci_ut), offsetOfSection);
        } else if (textData && [section isEqualToString:kDKManagerInformationSection_TXTDT_MGI]) {
            if (![textData length]) {
                continue;
            }
            
            // TODO:  Encode textData
            
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, txtdt_mgi), offsetOfSection);
        } else if (cellAddressTable && [section isEqualToString:kDKManagerInformationSection_VMGM_C_ADT]) {
            if (![cellAddressTable count]) {
                continue;
            }
            
            // TODO:  Encode cellAddressTable

            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgm_c_adt), offsetOfSection);
        } else if (menuVobuAddressMap && [section isEqualToString:kDKManagerInformationSection_VMGM_VOBU_ADMAP]) {
            if (![menuVobuAddressMap length]) {
                continue;
            }
            
            //  TODO: Encode menuVobuAddressMap
            
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgm_vobu_admap), offsetOfSection);
        } else {
            if (_error) {
                /* TODO: Build Error: Invalid section name. */
                *_error = nil;
            }
        }
        
        if (!sectionData) {
            if (_error) {
                /* TODO: Build Error: */
                *_error = nil;
            }
        }
        
        /*  Pad the data to align with the next sector.
         */
        [data appendData:sectionData];
        uint32_t amountToAlign = 0x800 - ([data length] & 0x07FF);
        if (amountToAlign != 0x800) {
            [data increaseLengthBy:amountToAlign];
        }
    }
    
    memcpy([data mutableBytes], &vmgi_mat, sizeof(vmgi_mat_t));
    return data;
}

@end