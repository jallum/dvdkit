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
#import <stdarg.h>

NSString* const kDKManagerInformationException = @"DKManagerInformation";

NSString* const kDKManagerInformationSection_TT_SRPT          = @"tt_srpt";
NSString* const kDKManagerInformationSection_PTL_MAIT         = @"ptl_mait";
NSString* const kDKManagerInformationSection_VMG_VTS_ATRT     = @"vmg_vts_atrt";
NSString* const kDKManagerInformationSection_VMGM_PGCI_UT     = @"vmgm_pgci_ut";
NSString* const kDKManagerInformationSection_TXTDT_MGI        = @"txtdt_mgi";
NSString* const kDKManagerInformationSection_VMGM_C_ADT       = @"vmgm_c_adt";
NSString* const kDKManagerInformationSection_VMGM_VOBU_ADMAP  = @"vmgm_vobu_admap";

@interface DKMainMenuInformation (Private)
- (NSMutableArray*) _readTitleTrackSearchPointerTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
- (NSData*) _readParentalManagementInformationTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
- (NSData*) _readTitleSetAttributeTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
- (NSMutableDictionary*) _readMenuProgramChainInformationTablesByLanguageFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
- (NSData*) _readTextDataFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
- (NSMutableArray*) _readCellAddressTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
- (NSData*) _readVobuAddressMapFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
@end

@implementation DKMainMenuInformation
@synthesize firstPlayProgramChain;
@synthesize titleTrackSearchPointerTable;
@synthesize menuProgramChainInformationTablesByLanguage;

+ (NSArray*) availableSections
{
    static NSArray* array;
    if (!array) {
        array = [[NSArray alloc] initWithObjects:
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
    return array;
}

+ (id) mainMenuInformationWithDataSource:(id<DKDataSource>)dataSource error:(NSError**)error
{
    return [[[DKMainMenuInformation alloc] initWithDataSource:dataSource error:error] autorelease];
}

- (id) initWithDataSource:(id<DKDataSource>)dataSource error:(NSError**)error
{
    NSAssert(dataSource, @"Shouldn't be nil");
    NSAssert(sizeof(vmgi_mat_t) == 0x200, @"Should be 512 bytes");
    if (self = [super init]) {
        NSMutableArray* errors = !error ? nil : [NSMutableArray array];
        NSMutableDictionary* sectionOrdering = [NSMutableDictionary dictionary];
        NSData* header = [dataSource requestDataOfLength:1 << 11 fromOffset:0];
        NSAssert(header && ([header length] == 1 << 11), @"wtf?");
        const vmgi_mat_t* vmgi_mat = [header bytes];
        if (0 != memcmp("DVDVIDEO-VMG", &vmgi_mat->vmg_identifier, sizeof(vmgi_mat->vmg_identifier))) {
            [NSException raise:kDKManagerInformationException format:DKLocalizedString(@"Invalid signature in the Video Manager Information (.IFO) data.", nil)];
        }
        
        
        /*
         */
        specificationVersion = OSReadBigInt8(&vmgi_mat->specification_version, 0);
        categoryAndMask = OSReadBigInt32(&vmgi_mat->vmg_category, 0);
        numberOfVolumes = OSReadBigInt16(&vmgi_mat->vmg_nr_of_volumes, 0);
        volumeNumber = OSReadBigInt16(&vmgi_mat->vmg_this_volume_nr, 0);
        side = OSReadBigInt8(&vmgi_mat->disc_side, 0);
        numberOfTitleSets = OSReadBigInt16(&vmgi_mat->vmg_nr_of_title_sets, 0);
        pointOfSaleCode = OSReadBigInt64(&vmgi_mat->vmg_pos_code, 0);
        vmgm_vobs = OSReadBigInt32(&vmgi_mat->vmgm_vobs, 0);
        
        
        /*  Sanity checks / Data Repair
         */
        if (0 == numberOfVolumes) {
            if (errors) {
                [errors addObject:DKErrorWithCode(kDKNumberOfVolumesError, DKLocalizedString(@"The number of volumes cannot be zero.", nil), NSLocalizedDescriptionKey, nil)];
            }
            numberOfVolumes = 1;
        }
        if (0 == volumeNumber) {
            if (errors) {
                [errors addObject:DKErrorWithCode(kDKVolumeNumberError, DKLocalizedString(@"The volume number cannot be zero.", nil), NSLocalizedDescriptionKey, nil)];
            }
            volumeNumber = 1;
        }
        if (volumeNumber > numberOfVolumes) {
            if (errors) {
                [errors addObject:DKErrorWithCode(kDKVolumeNumberError, DKLocalizedString(@"The volume number cannot be greater than the number of volumes.", nil), NSLocalizedDescriptionKey, nil)];
            }
            volumeNumber = numberOfVolumes;
        }
        if (side != 1 && side != 2) {
            if (errors) {
                [errors addObject:DKErrorWithCode(kDKDiscSideError, DKLocalizedString(@"The disc side must be 1 or 2.", nil), NSLocalizedDescriptionKey, nil)];
            }
            side = 1;
        }
        if (0 == numberOfTitleSets) {
            if (errors) {
                [errors addObject:DKErrorWithCode(kDKNumberOfTitleSetsError, DKLocalizedString(@"The number of title sets cannot be zero.", nil), NSLocalizedDescriptionKey, nil)];
            }
            numberOfTitleSets = 1;
        }
        
        
        /*  Video/Audio/Subpicture Attributes
         */
        menuVideoAttributes = [DKVideoAttributes videoAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vmgi_mat_t, vmgm_video_attr), sizeof(video_attr_t))]];
        uint16_t nr_of_vmgm_audio_streams = OSReadBigInt16(&vmgi_mat->nr_of_vmgm_audio_streams, 0);
        if (nr_of_vmgm_audio_streams) {
            if (nr_of_vmgm_audio_streams > 8) {
                if (errors) {
                    [errors addObject:DKErrorWithCode(kDKNumberOfAudioStreamsError, DKLocalizedString(@"The number of audio streams cannot be greater than 8.", nil), NSLocalizedDescriptionKey, nil)];                    
                }
                nr_of_vmgm_audio_streams = 8;
            }
            NSMutableArray* table = [NSMutableArray array];
            for (int i = 0; i < nr_of_vmgm_audio_streams; i++) {
                [table addObject:[DKAudioAttributes audioAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vmgi_mat_t, vmgm_audio_attr[i]), sizeof(audio_attr_t))]]];
            }
            menuAudioAttributes = [table retain];
        }
        uint16_t nr_of_vmgm_subp_streams = OSReadBigInt16(&vmgi_mat->nr_of_vmgm_subp_streams, 0);
        if (nr_of_vmgm_subp_streams > 1) {
            if (errors) {
                [errors addObject:DKErrorWithCode(kDKNumberOfSubpictureAttributesError, DKLocalizedString(@"The number of subpicture streams cannot be greater than one.", nil), NSLocalizedDescriptionKey, nil)];                    
            }
            nr_of_vmgm_subp_streams = 1;
        }
        if (nr_of_vmgm_subp_streams) {
            menuSubpictureAttributes = [DKSubpictureAttributes subpictureAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vmgi_mat_t, vmgm_subp_attr), sizeof(subp_attr_t))]];
        }
        
        
        /*
         */
        uint32_t vmgi_last_byte = 1 + OSReadBigInt32(&vmgi_mat->vmgi_last_byte, 0);
        uint32_t vmgi_last_sector = 1 + OSReadBigInt32(&vmgi_mat->vmgi_last_sector, 0);
        
        
        /*  First Play Program Chain.
         */
        uint32_t first_play_pgc = OSReadBigInt32(&vmgi_mat->first_play_pgc, 0);
        if (errors) {
            if (first_play_pgc < sizeof(vmgi_mat)) {
                [errors addObject:DKErrorWithCode(kDKFirstPlayProgramChainError, DKLocalizedString(@"The offset of the first-play program chain must be greater than or equal to 512.", nil), NSLocalizedDescriptionKey, nil)];
            }
            if (first_play_pgc >= vmgi_last_byte) {
                [errors addObject:DKErrorWithCode(kDKFirstPlayProgramChainError, DKLocalizedString(@"The offset of the first-play program chain must be less than the length of the VMGI header.", nil), NSLocalizedDescriptionKey, nil)];
            }
        }
        NSError* firstPlayProgramChainError = nil;
        NSData* firstPlayProgramChainData = (vmgi_last_byte < [header length]) ? [header subdataWithRange:NSMakeRange(first_play_pgc, vmgi_last_byte - first_play_pgc)] : [dataSource requestDataOfLength:vmgi_last_byte - first_play_pgc fromOffset:first_play_pgc];
        firstPlayProgramChain = [DKProgramChain programChainWithData:firstPlayProgramChainData error:errors ? &firstPlayProgramChainError : NULL];
        if (firstPlayProgramChainError) {
            if (firstPlayProgramChainError.code == kDKMultipleErrorsError) {
                [errors addObjectsFromArray:[firstPlayProgramChainError.userInfo objectForKey:NSDetailedErrorsKey]];
            } else {
                [errors addObject:firstPlayProgramChainError];
            }
        }
        if (errors && !firstPlayProgramChain) {
            [errors addObject:DKErrorWithCode(kDKFirstPlayProgramChainError, DKLocalizedString(@"The VMGI must contain a first-play program chain.", nil), NSLocalizedDescriptionKey, nil)];
        }
        
        
        /*  Read/Parse additional sections
         */
        uint32_t offset_of_tt_srpt = OSReadBigInt32(&vmgi_mat->tt_srpt, 0);
        if (offset_of_tt_srpt && (offset_of_tt_srpt <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_TT_SRPT forKey:[NSNumber numberWithUnsignedInt:offset_of_tt_srpt]];
            titleTrackSearchPointerTable = [[self _readTitleTrackSearchPointerTableFromDataSource:dataSource offset:offset_of_tt_srpt errors:errors] retain]; 
        }
        uint32_t offset_of_ptl_mait = OSReadBigInt32(&vmgi_mat->ptl_mait, 0);
        if (offset_of_ptl_mait && (offset_of_ptl_mait <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_PTL_MAIT forKey:[NSNumber numberWithUnsignedInt:offset_of_ptl_mait]];
            parentalManagementInformationTable = [[self _readParentalManagementInformationTableFromDataSource:dataSource offset:offset_of_ptl_mait errors:errors] retain];
        }
        uint32_t offset_of_vmg_vts_atrt = OSReadBigInt32(&vmgi_mat->vmg_vts_atrt, 0);
        if (offset_of_vmg_vts_atrt && (offset_of_vmg_vts_atrt <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMG_VTS_ATRT forKey:[NSNumber numberWithUnsignedInt:offset_of_vmg_vts_atrt]];
            titleSetAttributeTable = [[self _readTitleSetAttributeTableFromDataSource:dataSource offset:offset_of_vmg_vts_atrt errors:errors] retain];
        }
        uint32_t offset_of_vmgm_pgci_ut = OSReadBigInt32(&vmgi_mat->vmgm_pgci_ut, 0);
        if (offset_of_vmgm_pgci_ut && (offset_of_vmgm_pgci_ut <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMGM_PGCI_UT forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_pgci_ut]];
            menuProgramChainInformationTablesByLanguage = [[self _readMenuProgramChainInformationTablesByLanguageFromDataSource:dataSource offset:offset_of_vmgm_pgci_ut errors:errors] retain];
        }
        uint32_t offset_of_txtdt_mgi = OSReadBigInt32(&vmgi_mat->txtdt_mgi, 0);
        if (offset_of_txtdt_mgi && (offset_of_txtdt_mgi <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_TXTDT_MGI forKey:[NSNumber numberWithUnsignedInt:offset_of_txtdt_mgi]];
            textData = [[self _readTextDataFromDataSource:dataSource offset:offset_of_txtdt_mgi errors:errors] retain];
        }
        uint32_t offset_of_vmgm_c_adt = OSReadBigInt32(&vmgi_mat->vmgm_c_adt, 0);
        if (offset_of_vmgm_c_adt && (offset_of_vmgm_c_adt <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMGM_C_ADT forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_c_adt]];
            cellAddressTable = [[self _readCellAddressTableFromDataSource:dataSource offset:offset_of_vmgm_c_adt errors:errors] retain];
        }
        uint32_t offset_of_vmgm_vobu_admap = OSReadBigInt32(&vmgi_mat->vmgm_vobu_admap, 0);
        if (offset_of_vmgm_vobu_admap && (offset_of_vmgm_vobu_admap <= vmgi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VMGM_VOBU_ADMAP forKey:[NSNumber numberWithUnsignedInt:offset_of_vmgm_vobu_admap]];
            menuVobuAddressMap = [[self _readVobuAddressMapFromDataSource:dataSource offset:offset_of_vmgm_vobu_admap errors:errors] retain];
        }
        
        
        /*  Using the information gathered while reading, determine the order
         *  that the sections should be written in, should we choose to do so
         *  at a later point.
         */
        preferredSectionOrder = [sectionOrdering objectsForKeys:[[sectionOrdering allKeys] sortedArrayUsingSelector:@selector(compare:)] notFoundMarker:[NSNull null]];
        
        if (errors) {
            int errorCount = [errors count];
            if (0 == errorCount) {
                *error = nil;
            } else if (1 == errorCount) {
                *error = [errors objectAtIndex:0];
            } else {
                *error = DKErrorWithCode(kDKMultipleErrorsError, errors, NSDetailedErrorsKey, nil);
            }
        }
    }
    return self;     
}
            
- (NSMutableArray*) _readTitleTrackSearchPointerTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    const tt_srpt_t* tt_srpt = [data bytes];
    uint16_t nr_of_srpts = OSReadBigInt16(&tt_srpt->nr_of_srpts, 0);
    uint32_t last_byte = 1 + OSReadBigInt32(&tt_srpt->last_byte, 0);
    
    /*  Sanity Checking / Data Repair  */
    if (nr_of_srpts > 99) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKTitleTrackSearchPointerTableError, nil)];
        }
        nr_of_srpts = 99;
    }
    uint32_t calculated_last_byte = sizeof(tt_srpt_t) + (nr_of_srpts * sizeof(title_info_t));
    if (last_byte != calculated_last_byte) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKTitleTrackSearchPointerTableError, [NSString stringWithFormat:DKLocalizedString(@"Corrected last_byte (was %d, is now %d)", nil), last_byte, calculated_last_byte], NSLocalizedDescriptionKey, nil)];
        }
        last_byte = calculated_last_byte;
    }
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  Parse the table  */
    NSMutableArray* table = [NSMutableArray arrayWithCapacity:nr_of_srpts];
    for (int i = 1, p = sizeof(tt_srpt_t); i <= nr_of_srpts; i++, p += sizeof(title_info_t)) {
        [table addObject:[DKTitleTrackSearchPointer partOfTitleSearchPointerWithData:[data subdataWithRange:NSMakeRange(p, sizeof(title_info_t))] index:i]];
    }

    return table;
}

- (NSData*) _readParentalManagementInformationTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    const ptl_mait_t* ptl_mait = [data bytes];
    uint32_t last_byte = 1 + OSReadBigInt32(&ptl_mait->last_byte, 0);
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  
     *  TODO: Additional Decoding  
     */
    
    return data;
}

- (NSData*) _readTitleSetAttributeTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?");
    const vmg_vts_atrt_t* vmg_vts_atrt = [data bytes];
    uint32_t last_byte = 1 + OSReadBigInt32(&vmg_vts_atrt->last_byte, 0);
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  
     *  TODO: Additional Decoding  
     */
    
    return data;
}

- (NSMutableDictionary*) _readMenuProgramChainInformationTablesByLanguageFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    const vtsm_pgci_ut_t* vtsm_pgci_ut = [data bytes];
    uint16_t nr_of_lus = OSReadBigInt16(&vtsm_pgci_ut->nr_of_lus, 0);
    uint32_t last_byte = 1 + OSReadBigInt32(&vtsm_pgci_ut->last_byte, 0);
    
    /*  Sanity Checking / Data Repair  */
    if (nr_of_lus > 99) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKMenuProgramChainInformationMapError, nil)];
        }
        nr_of_lus = 99;
    }
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  Parse the tables  */
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:nr_of_lus];
    for (int i = 0, p = sizeof(vtsm_pgci_ut_t); i < nr_of_lus; i++, p += 8) {
        const vtsm_lu_t* vtsm_lu = [[data subdataWithRange:NSMakeRange(p, sizeof(vtsm_lu_t))] bytes];
        uint16_t lang_code = OSReadBigInt16(&vtsm_lu->lang_code, 0);
        uint32_t vtsm_pgc_start_byte = OSReadBigInt32(&vtsm_lu->pgcit_start_byte, 0);
        
        const vtsm_pgc_t* vtsm_pgc = [[data subdataWithRange:NSMakeRange(vtsm_pgc_start_byte, sizeof(vtsm_pgc_t))] bytes];
        uint16_t nr_of_pgci_srp = OSReadBigInt16(&vtsm_pgc->nr_of_pgci_srp, 0);
        uint32_t vtsm_pgc_last_byte = 1 + OSReadBigInt32(&vtsm_pgc->last_byte, 0);
        
        if (errors && ((vtsm_pgc_start_byte + vtsm_pgc_last_byte) > last_byte)) {
            // TODO: Correct last_byte?
            [errors addObject:DKErrorWithCode(kDKMenuProgramChainInformationMapError, nil)];
        }
        
        NSMutableArray* table = [[NSMutableArray alloc] initWithCapacity:nr_of_pgci_srp];
        for (int i = 0, p = vtsm_pgc_start_byte + sizeof(vtsm_pgc_t); i < nr_of_pgci_srp; i++, p += sizeof(pgci_srp_t)) {
            const pgci_srp_t* pgci_srp = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_srp_t))] bytes];
            uint8_t entry_id = OSReadBigInt8(&pgci_srp->entry_id, 0);
            uint16_t ptl_id_mask = OSReadBigInt16(&pgci_srp->ptl_id_mask, 0);
            uint32_t pgc_start_byte = OSReadBigInt32(&pgci_srp->pgc_start_byte, 0);
            NSError* programChainError = nil;
            [table addObject:[DKProgramChainSearchPointer programChainSearchPointerWithEntryId:entry_id parentalMask:ptl_id_mask programChain:[DKProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(vtsm_pgc_start_byte + pgc_start_byte, vtsm_pgc_last_byte - pgc_start_byte)] error:errors ? &programChainError : NULL]]];
            if (programChainError) {
                if (programChainError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[programChainError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:programChainError];
                }
            }
        }
        [dictionary setObject:table forKey:[NSNumber numberWithShort:lang_code]];
        [table release];
    }
    
    return dictionary;
}

- (NSData*) _readTextDataFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    
    /*  
     *  TODO: Additional Decoding  
     */
    
    return data;
}

- (NSMutableArray*) _readCellAddressTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    const vmgm_c_adt_t* vmgm_c_adt = [data bytes];
    uint16_t nr_of_c_adts = OSReadBigInt16(&vmgm_c_adt->nr_of_c_adts, 0);
    uint32_t last_byte = 1 + OSReadBigInt32(&vmgm_c_adt->last_byte, 0);
    
    /*  Sanity Checking / Data Repair  */
    uint32_t calculated_nr_of_c_adts = (last_byte - sizeof(vmgm_c_adt_t)) / sizeof(cell_adr_t);
    if (nr_of_c_adts != calculated_nr_of_c_adts) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKMenuCellAddressTableError, [NSString stringWithFormat:DKLocalizedString(@"Corrected nr_of_c_adts (was %d, is now %d)", nil), nr_of_c_adts, calculated_nr_of_c_adts], NSLocalizedDescriptionKey, nil)];
        }
        nr_of_c_adts = calculated_nr_of_c_adts;
    } 
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  Parse the table  */
    NSMutableArray* table = [NSMutableArray arrayWithCapacity:nr_of_c_adts];
    for (int i = 1, p = sizeof(vmgm_c_adt_t); i <= nr_of_c_adts; i++, p += sizeof(cell_adr_t)) {
        [table addObject:[DKCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p, sizeof(cell_adr_t))]]];
    }
    
    return table;
}

- (NSData*) _readVobuAddressMapFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    uint32_t last_byte = 1 + OSReadBigInt32([data bytes], 0);
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  
     *  TODO: Additional Decoding  
     */
    
    return [data subdataWithRange:NSMakeRange(4, last_byte - 4)];
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

- (DKTitleTrackSearchPointer*) titleTrackSearchPointerForTitleSet:(uint16_t)vts track:(uint8_t)ttn;
{
    for (DKTitleTrackSearchPointer* ti in titleTrackSearchPointerTable) {
        if (vts == [ti titleSetNumber] && ttn == [ti trackNumber]) {
            return [[ti retain] autorelease];
        }
    }
    [NSException raise:kDKManagerInformationException format:@"%s(%d)", __FILE__, __LINE__];
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

- (NSData*) saveAsData:(NSError**)error
{
    NSMutableArray* errors = !error ? nil : [NSMutableArray array];
    NSMutableData* data = [NSMutableData data];
    
    
    /*
     */
    [data increaseLengthBy:sizeof(vmgi_mat_t)];  
    vmgi_mat_t vmgi_mat;
    bzero(&vmgi_mat, sizeof(vmgi_mat_t));
    memcpy(vmgi_mat.vmg_identifier, "DVDVIDEO-VMG", sizeof(vmgi_mat.vmg_identifier));
    
    
    /*
     */
    OSWriteBigInt8(&vmgi_mat, offsetof(vmgi_mat_t, specification_version), specificationVersion);
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmg_category), categoryAndMask);
    OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, vmg_nr_of_volumes), numberOfVolumes);
    OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, vmg_this_volume_nr), volumeNumber);
    OSWriteBigInt8(&vmgi_mat, offsetof(vmgi_mat_t, disc_side), side);
    OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, vmg_nr_of_title_sets), numberOfTitleSets);
    OSWriteBigInt64(&vmgi_mat, offsetof(vmgi_mat_t, vmg_pos_code), pointOfSaleCode);
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgm_vobs), vmgm_vobs);
    
    
    /*  Video Attributes
     */ 
    if (menuVideoAttributes) {
        NSError* menuVideoAttributesError = nil;
        NSData* menuVideoAttributesData = [menuVideoAttributes saveAsData:errors ? &menuVideoAttributesError : NULL];
        if (menuVideoAttributesError) {
            if (menuVideoAttributesError.code == kDKMultipleErrorsError) {
                [errors addObjectsFromArray:[menuVideoAttributesError.userInfo objectForKey:NSDetailedErrorsKey]];
            } else {
                [errors addObject:menuVideoAttributesError];
            }
        }
        if (menuVideoAttributesData) {
            memcpy(&vmgi_mat.vmgm_video_attr, [menuVideoAttributesData bytes], sizeof(video_attr_t));
        }
    } else if (errors) {
        [errors addObject:DKErrorWithCode(kDKNumberOfVideoAttributesError, nil)];
    }
    
    
    /*  Audio Attributes
     */
    uint8_t nr_of_vmgm_audio_streams = vmgi_mat.nr_of_vmgm_audio_streams = [menuAudioAttributes count];
    if (nr_of_vmgm_audio_streams > 8) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKNumberOfAudioStreamsError, nil)];
        }
        nr_of_vmgm_audio_streams = 8;
    }
    if (nr_of_vmgm_audio_streams) {
        OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, nr_of_vmgm_audio_streams), nr_of_vmgm_audio_streams);
        for (int i = 0; i < nr_of_vmgm_audio_streams; i++) {
            NSError* menuAudioAttributesError = nil;
            NSData* menuAudioAttributesData = [[menuAudioAttributes objectAtIndex:i] saveAsData:errors ? &menuAudioAttributesError : NULL];
            if (menuAudioAttributesError) {
                if (menuAudioAttributesError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[menuAudioAttributesError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:menuAudioAttributesError];
                }
            }
            if (menuAudioAttributesData) {
                memcpy(&vmgi_mat.vmgm_audio_attr[i], [menuAudioAttributesData bytes], sizeof(audio_attr_t));
            }
        }
    }
    
    
    /*  Subpicture Attributes
     */
    if (menuSubpictureAttributes) {
        OSWriteBigInt16(&vmgi_mat, offsetof(vmgi_mat_t, nr_of_vmgm_subp_streams), 1);
        NSError* menuSubpictureAttributesError = nil;
        NSData* menuSubpictureAttributesData = [menuSubpictureAttributes saveAsData:errors ? &menuSubpictureAttributesError : NULL];
        if (menuSubpictureAttributesError) {
            if (menuSubpictureAttributesError.code == kDKMultipleErrorsError) {
                [errors addObjectsFromArray:[menuSubpictureAttributesError.userInfo objectForKey:NSDetailedErrorsKey]];
            } else {
                [errors addObject:menuSubpictureAttributesError];
            }
        }
        if (menuSubpictureAttributesData) {
            memcpy(&vmgi_mat.vmgm_subp_attr, [menuSubpictureAttributesData bytes], sizeof(subp_attr_t));
        }
    }
    
    
    /*  Append the first play program chain
     */
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, first_play_pgc), [data length]);
    if (firstPlayProgramChain) {
        NSError* firstPlayProgramChainError = nil;
        NSData* firstPlayProgramChainData = [firstPlayProgramChain saveAsData:errors ? &firstPlayProgramChainError : NULL];
        if (firstPlayProgramChainError) {
            if (firstPlayProgramChainError.code == kDKMultipleErrorsError) {
                [errors addObjectsFromArray:[firstPlayProgramChainError.userInfo objectForKey:NSDetailedErrorsKey]];
            } else {
                [errors addObject:firstPlayProgramChainError];
            }
        }
        if (firstPlayProgramChainData) {
            [data appendData:firstPlayProgramChainData];
        }
    } else if (errors) {
        [errors addObject:DKErrorWithCode(kDKFirstPlayProgramChainError, nil)];
    }
    OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgi_last_byte), [data length]);
    uint32_t amountToAlign = 0x800 - ([data length] & 0x07FF);
    if (amountToAlign != 0x800) {
        [data increaseLengthBy:amountToAlign];
    }
    NSAssert(([data length] & 0x07FF) == 0, @"Sections not sector-aligned?");
    
    
    /*  Determine the proper order, and then write out the various sections.
     */
    NSMutableArray* sectionOrder = [[preferredSectionOrder mutableCopy] autorelease];
    for (NSString* section in [DKMainMenuInformation availableSections]) {
        if (![sectionOrder containsObject:section]) {
            [sectionOrder addObject:section];
        }
    }
    for (NSString* section in sectionOrder) {
        NSMutableData* sectionData = nil;
        NSAssert(([data length] & 0x07FF) == 0, @"Sections not sector-aligned?");
        if ([section isEqualToString:kDKManagerInformationSection_TT_SRPT]) {
            if (![titleTrackSearchPointerTable count]) {
                continue;
            }
            
            uint16_t nr_of_srpts = [titleTrackSearchPointerTable count];
            uint32_t last_byte = sizeof(tt_srpt_t) + (nr_of_srpts * sizeof(title_info_t));
            sectionData = [NSMutableData dataWithLength:last_byte];
            uint8_t* base = [sectionData mutableBytes];
            OSWriteBigInt16(base, offsetof(tt_srpt_t, nr_of_srpts), nr_of_srpts);
            OSWriteBigInt32(base, offsetof(tt_srpt_t, last_byte), last_byte - 1);
            
            for (int i = 0, p = sizeof(tt_srpt_t); i < nr_of_srpts; i++, p += sizeof(title_info_t)) {
                NSError* title_info_error = nil;
                NSData* title_info_data = [[titleTrackSearchPointerTable objectAtIndex:i] saveAsData:errors ? &title_info_error : NULL];
                if (title_info_error) {
                    if (title_info_error.code == kDKMultipleErrorsError) {
                        [errors addObjectsFromArray:[title_info_error.userInfo objectForKey:NSDetailedErrorsKey]];
                    } else {
                        [errors addObject:title_info_error];
                    }
                }
                if (title_info_data) {
                    memcpy(base + p, [title_info_data bytes], sizeof(title_info_t));
                }
            }
            
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, tt_srpt), [data length] >> 11);
        } else if ([section isEqualToString:kDKManagerInformationSection_PTL_MAIT]) {
            if (![parentalManagementInformationTable length]) {
                continue;
            }
            
            sectionData = parentalManagementInformationTable;
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, ptl_mait), [data length] >> 11);
        } else if ([section isEqualToString:kDKManagerInformationSection_VMG_VTS_ATRT]) { 
            if (![titleSetAttributeTable length]) {
                continue;
            }
            
            sectionData = titleSetAttributeTable;
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmg_vts_atrt), [data length] >> 11);
        } else if ([section isEqualToString:kDKManagerInformationSection_VMGM_PGCI_UT]) {
            if (![menuProgramChainInformationTablesByLanguage count]) {
                continue;
            }
            
            uint16_t nr_of_lus = [menuProgramChainInformationTablesByLanguage count];
            if (nr_of_lus > 99) {
                if (errors) {
                    [errors addObject:DKErrorWithCode(kDKNumberOfMenuProgramChainLanguageUnitsError, nil)];
                }
                nr_of_lus = 99;
            }
            
            sectionData = [NSMutableData dataWithLength:sizeof(vmgm_pgci_ut_t) + (nr_of_lus * sizeof(vmgm_lu_t))];
            int i = 0;
            for (NSNumber* languageCode in menuProgramChainInformationTablesByLanguage) {
                NSArray* table = [menuProgramChainInformationTablesByLanguage objectForKey:languageCode];
                uint32_t vmgm_lu_start_byte = sizeof(vmgm_pgci_ut_t) + (i * sizeof(vmgm_lu_t));

                uint32_t vmgm_pgc_start_byte = [sectionData length];
                uint16_t nr_of_pgci_srp = [table count];
                [sectionData increaseLengthBy:sizeof(vmgm_pgc_t) + (nr_of_pgci_srp * sizeof(pgci_srp_t))];
                int j = 0;
                for (DKProgramChainSearchPointer* programChainSearchPointer in table) {
                    pgci_srp_t pgci_srp;
                    bzero(&pgci_srp, sizeof(pgci_srp_t));
                    OSWriteBigInt8(&pgci_srp.entry_id, 0, [programChainSearchPointer entryId]);
                    OSWriteBigInt16(&pgci_srp.ptl_id_mask, 0, [programChainSearchPointer ptl_id_mask]);
                    OSWriteBigInt32(&pgci_srp.pgc_start_byte, 0, [sectionData length] - vmgm_pgc_start_byte);
                    [sectionData replaceBytesInRange:NSMakeRange(vmgm_pgc_start_byte + sizeof(vmgm_pgc_t) + (j * sizeof(pgci_srp_t)), sizeof(pgci_srp_t)) withBytes:&pgci_srp];
                    j++;
                    
                    NSError* programChainError = nil;
                    NSData* programChainData = [programChainSearchPointer.programChain saveAsData:errors ? &programChainError : NULL];
                    if (programChainError) {
                        if (programChainError.code == kDKMultipleErrorsError) {
                            [errors addObjectsFromArray:[programChainError.userInfo objectForKey:NSDetailedErrorsKey]];
                        } else {
                            [errors addObject:programChainError];
                        }
                    }
                    if (programChainData) {
                        [sectionData appendData:programChainData];
                    }
                }

                vmgm_pgc_t vmgm_pgc;
                bzero(&vmgm_pgc, sizeof(vmgm_pgc_t));
                OSWriteBigInt16(&vmgm_pgc.nr_of_pgci_srp, 0, nr_of_pgci_srp);
                OSWriteBigInt32(&vmgm_pgc.last_byte, 0, [sectionData length] - vmgm_pgc_start_byte - 1);
                [sectionData replaceBytesInRange:NSMakeRange(vmgm_pgc_start_byte, sizeof(vmgm_pgc_t)) withBytes:&vmgm_pgc];

                vmgm_lu_t vmgm_lu;
                bzero(&vmgm_lu, sizeof(vmgm_lu_t));
                OSWriteBigInt16(&vmgm_lu.lang_code, 0, [languageCode unsignedShortValue]);
                OSWriteBigInt8(&vmgm_lu.exists, 0, 0x80);
                OSWriteBigInt32(&vmgm_lu.pgcit_start_byte, 0, vmgm_pgc_start_byte);
                [sectionData replaceBytesInRange:NSMakeRange(vmgm_lu_start_byte, sizeof(vmgm_lu_t)) withBytes:&vmgm_lu];
                i++;
            }
            
            vmgm_pgci_ut_t vmgm_pgci_ut;
            bzero(&vmgm_pgci_ut, sizeof(vmgm_pgci_ut));
            OSWriteBigInt16(&vmgm_pgci_ut.nr_of_lus, 0, nr_of_lus);
            OSWriteBigInt32(&vmgm_pgci_ut.last_byte, 0, [sectionData length] - 1);
            [sectionData replaceBytesInRange:NSMakeRange(0, sizeof(vmgm_pgci_ut_t)) withBytes:&vmgm_pgci_ut];
            
            OSWriteBigInt32(&vmgi_mat.vmgm_pgci_ut, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKManagerInformationSection_TXTDT_MGI]) {
            if (![textData length]) {
                continue;
            }
            
            sectionData = textData;
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, txtdt_mgi), [data length] >> 11);
        } else if ([section isEqualToString:kDKManagerInformationSection_VMGM_C_ADT]) {
            if (![cellAddressTable count]) {
                continue;
            }

            uint16_t nr_of_c_adts = [cellAddressTable count];
            uint32_t last_byte = sizeof(vmgm_c_adt_t) + (nr_of_c_adts * sizeof(cell_adr_t));
            sectionData = [NSMutableData dataWithLength:last_byte];
            uint8_t* base = [sectionData mutableBytes];
            OSWriteBigInt16(base, offsetof(vmgm_c_adt_t, nr_of_c_adts), nr_of_c_adts);
            OSWriteBigInt32(base, offsetof(vmgm_c_adt_t, last_byte), last_byte - 1);
            
            for (int i = 0, p = sizeof(vmgm_c_adt_t); i < nr_of_c_adts; i++, p += sizeof(cell_adr_t)) {
                NSError* cell_adr_error = nil;
                NSData* cell_adr_data = [[cellAddressTable objectAtIndex:i] saveAsData:errors ? &cell_adr_error : NULL];
                if (cell_adr_error) {
                    if (cell_adr_error.code == kDKMultipleErrorsError) {
                        [errors addObjectsFromArray:[cell_adr_error.userInfo objectForKey:NSDetailedErrorsKey]];
                    } else {
                        [errors addObject:cell_adr_error];
                    }
                }
                if (cell_adr_data) {
                    memcpy(base + p, [cell_adr_data bytes], sizeof(cell_adr_t));
                }
            }

            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgm_c_adt), [data length] >> 11);
        } else if ([section isEqualToString:kDKManagerInformationSection_VMGM_VOBU_ADMAP]) {
            if (![menuVobuAddressMap length]) {
                continue;
            }
            
            uint32_t last_byte = sizeof(uint32_t) + [menuVobuAddressMap length];
            sectionData = [NSMutableData dataWithLength:last_byte];
            uint8_t* base = [sectionData mutableBytes];
            OSWriteBigInt32(base, 0, last_byte - 1);
            
            memcpy(base + 4, [menuVobuAddressMap bytes], [menuVobuAddressMap length]);
            
            OSWriteBigInt32(&vmgi_mat, offsetof(vmgi_mat_t, vmgm_vobu_admap), [data length] >> 11);
        } else if (errors) {
            NSLog(@"%@", section);
            [errors addObject:DKErrorWithCode(kDKSectionNameError, nil)];
        }
        
        /*  If data was generated for the section, append it to the final 
         *  output and then pad that with zeros to the next sector boundary.
         */
        if (sectionData) {
            [data appendData:sectionData];
            uint32_t amountToAlign = 0x800 - ([data length] & 0x07FF);
            if (amountToAlign != 0x800) {
                [data increaseLengthBy:amountToAlign];
            }
        }
    }

    
    NSAssert(([data length] & 0x07FF) == 0, @"Sections not sector-aligned?");
    uint32_t vmgi_last_sector = [data length] >> 11;
    OSWriteBigInt32(&vmgi_mat.vmgi_last_sector, 0, vmgi_last_sector - 1);
    OSWriteBigInt32(&vmgi_mat.vmg_last_sector, 0, (vmgi_last_sector * 2) - 1);
    OSWriteBigInt32(&vmgi_mat.vmgm_vobs, 0, vmgi_last_sector);
    
    if (errors) {
        int errorCount = [errors count];
        if (0 == errorCount) {
            *error = nil;
        } else if (1 == errorCount) {
            *error = [errors objectAtIndex:0];
        } else {
            *error = DKErrorWithCode(kDKMultipleErrorsError, errors, NSDetailedErrorsKey, nil);
        }
    }
    
    memcpy([data mutableBytes], &vmgi_mat, sizeof(vmgi_mat_t));
    return data;
}

@end