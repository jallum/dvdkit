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

NSString* const DVDTitleSetException = @"DVDTitleSet";

NSString* const kDKTitleSetInformationSection_VTS_PTT_SRPT      = @"vts_ptt_srpt";
NSString* const kDKTitleSetInformationSection_VTSM_C_ADT        = @"vtsm_c_adt";
NSString* const kDKTitleSetInformationSection_VTS_C_ADT         = @"vts_c_adt";
NSString* const kDKTitleSetInformationSection_VTSM_VOBU_ADMAP   = @"vtsm_vobu_admap";
NSString* const kDKTitleSetInformationSection_VTS_VOBU_ADMAP    = @"vts_vobu_admap";
NSString* const kDKTitleSetInformationSection_VTSM_PGCI_UT      = @"vtsm_pgci_ut";
NSString* const kDKTitleSetInformationSection_VTS_PGCIT         = @"vts_pgcit";
NSString* const kDKTitleSetInformationSection_VTS_TMAPT         = @"vts_tmapt";

@interface DKTitleSetInformation (Private)
/*  Read  */
+ (NSMutableArray*) _readPartOfTitleSearchTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
+ (NSMutableArray*) _readCellAddressTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
+ (NSData*) _readTimeMapTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
+ (NSMutableData*) _readVobuAddressMapFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
+ (NSMutableArray*) _readProgramChainInformationTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;
+ (NSMutableDictionary*) _readMenuProgramChainInformationTablesByLanguageFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors;

/*  Save  */
+ (NSMutableData*) _saveMenuProgramChainInformationTablesByLanguage:(NSDictionary*)menuProgramChainInformationTablesByLanguage errors:(NSMutableArray*)errors;
+ (NSMutableData*) _saveProgramChainInformationTable:(NSArray*)programChainInformationTable errors:(NSMutableArray*)errors;
+ (NSMutableData*) _saveVobuAddressMap:(NSData*)vobuAddressMap errors:(NSMutableArray*)errors;
+ (NSMutableData*) _saveCellAddressTable:(NSArray*)cellAddressTable errors:(NSMutableArray*)errors;
+ (NSMutableData*) _savePartOfTitleSearchTable:(NSArray*)partOfTitleSearchTable errors:(NSMutableArray*)errors;
+ (NSMutableData*) _saveTimeMapTable:(NSData*)timeMapTable errors:(NSMutableArray*)errors;
@end

@implementation DKTitleSetInformation
@synthesize index;
@synthesize programChainInformationTable;
@synthesize partOfTitleSearchTable;

+ (NSArray*) availableSections
{
    static NSArray* array;
    if (!array) {
        array = [[NSArray alloc] initWithObjects:
            kDKTitleSetInformationSection_VTS_PTT_SRPT,
            kDKTitleSetInformationSection_VTSM_C_ADT,
            kDKTitleSetInformationSection_VTS_C_ADT,
            kDKTitleSetInformationSection_VTSM_VOBU_ADMAP, 
            kDKTitleSetInformationSection_VTS_VOBU_ADMAP,
            kDKTitleSetInformationSection_VTSM_PGCI_UT,
            kDKTitleSetInformationSection_VTS_PGCIT,
            kDKTitleSetInformationSection_VTS_TMAPT,
            nil
        ];
    }
    return array;
}

+ (id) titleSetInformationWithDataSource:(id<DKDataSource>)dataSource index:(uint16_t)index error:(NSError**)error
{
    return [[[DKTitleSetInformation alloc] initWithDataSource:dataSource index:index error:error] autorelease];
}

- (id) initWithDataSource:(id<DKDataSource>)dataSource index:(uint16_t)_index error:(NSError**)error
{
    NSAssert(dataSource, @"Shouldn't be nil");
    NSAssert(_index > 0 && _index < 100, @"Valid range of title set index is 1-99");
    if (self = [super init]) {
        index = _index;

        NSMutableArray* errors = !error ? nil : [NSMutableArray array];
        NSMutableDictionary* sectionOrdering = [NSMutableDictionary dictionary];
        NSData* header = [dataSource requestDataOfLength:1 << 11 fromOffset:0];
        NSAssert(header && ([header length] == 1 << 11), @"wtf?");
        const vts_mat_t* vts_mat = [header bytes];
        if (0 != memcmp("DVDVIDEO-VTS", &vts_mat->vts_identifier, sizeof(vts_mat->vts_identifier))) {
            [NSException raise:kDKManagerInformationException format:DKLocalizedString(@"Invalid signature in the Video Title Set Information (.IFO) data.", nil)];
        }


        /*
         */
        specificationVersion = OSReadBigInt16(&vts_mat->specification_version, 0);
        categoryAndMask = OSReadBigInt32(&vts_mat->vts_category, 0);

        //uint32_t vtsi_last_byte = 1 + OSReadBigInt32(&vts_mat->vtsi_last_byte, 0);
        uint32_t vtsi_last_sector = 1 + OSReadBigInt32(&vts_mat->vtsi_last_sector, 0);
        
        
        /*  Menu Video/Audio/Subpicture Attributes
         */
        menuVideoAttributes = [DKVideoAttributes videoAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vts_mat_t, vtsm_video_attr), sizeof(video_attr_t))]];
        uint16_t nr_of_vtsm_audio_streams = OSReadBigInt16(&vts_mat->nr_of_vtsm_audio_streams, 0);
        if (nr_of_vtsm_audio_streams) {
            if (nr_of_vtsm_audio_streams > 8) {
                if (errors) {
                    [errors addObject:DKErrorWithCode(kDKNumberOfAudioStreamsError, DKLocalizedString(@"The number of audio streams cannot be greater than 8.", nil), NSLocalizedDescriptionKey, nil)];                    
                }
                nr_of_vtsm_audio_streams = 8;
            }
            menuAudioAttributes = [[NSMutableArray alloc] initWithCapacity:nr_of_vtsm_audio_streams];
            for (int i = 0; i < nr_of_vtsm_audio_streams; i++) {
                [menuAudioAttributes addObject:[DKAudioAttributes audioAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vts_mat_t, vtsm_audio_attr[i]), sizeof(audio_attr_t))]]];
            }
        }
        uint16_t nr_of_vtsm_subp_streams = OSReadBigInt16(&vts_mat->nr_of_vtsm_subp_streams, 0);
        if (nr_of_vtsm_subp_streams > 1) {
            if (errors) {
                [errors addObject:DKErrorWithCode(kDKNumberOfSubpictureAttributesError, DKLocalizedString(@"The number of subpicture streams cannot be greater than one.", nil), NSLocalizedDescriptionKey, nil)];                    
            }
            nr_of_vtsm_subp_streams = 1;
        }
        if (nr_of_vtsm_subp_streams) {
            menuSubpictureAttributes = [DKSubpictureAttributes subpictureAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vts_mat_t, vtsm_subp_attr), sizeof(subp_attr_t))]];
        }

        
        /*  Video/Audio/Subpicture Attributes
         */
        videoAttributes = [DKVideoAttributes videoAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vts_mat_t, vts_video_attr), sizeof(video_attr_t))]];
        uint16_t nr_of_vts_audio_streams = OSReadBigInt16(&vts_mat->nr_of_vts_audio_streams, 0);
        if (nr_of_vts_audio_streams) {
            if (nr_of_vts_audio_streams > 8) {
                if (errors) {
                    [errors addObject:DKErrorWithCode(kDKNumberOfAudioStreamsError, DKLocalizedString(@"The number of audio streams cannot be greater than 8.", nil), NSLocalizedDescriptionKey, nil)];                    
                }
                nr_of_vts_audio_streams = 8;
            }
            audioAttributes = [[NSMutableArray alloc] initWithCapacity:nr_of_vts_audio_streams];
            for (int i = 0; i < nr_of_vts_audio_streams; i++) {
                [audioAttributes addObject:[DKAudioAttributes audioAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vts_mat_t, vts_audio_attr[i]), sizeof(audio_attr_t))]]];
            }
        }
        uint16_t nr_of_vts_subp_streams = OSReadBigInt16(&vts_mat->nr_of_vts_subp_streams, 0);
        if (nr_of_vts_subp_streams) {
            if (nr_of_vts_subp_streams > 32) {
                if (errors) {
                    [errors addObject:DKErrorWithCode(kDKNumberOfSubpictureStreamsError, DKLocalizedString(@"The number of subpicture streams cannot be greater than 32.", nil), NSLocalizedDescriptionKey, nil)];                    
                }
                nr_of_vts_subp_streams = 32;
            }
            subpictureAttributes = [[NSMutableArray alloc] initWithCapacity:nr_of_vts_subp_streams];
            for (int i = 0; i < nr_of_vts_subp_streams; i++) {
                [subpictureAttributes addObject:[DKSubpictureAttributes subpictureAttributesWithData:[header subdataWithRange:NSMakeRange(offsetof(vts_mat_t, vts_subp_attr[i]), sizeof(subp_attr_t))]]];
            }
        }
        
        
        /*  Read/Parse additional sections
         */
        uint32_t offset_of_vts_ptt_srpt = OSReadBigInt32(&vts_mat->vts_ptt_srpt, 0);
        if (offset_of_vts_ptt_srpt && (offset_of_vts_ptt_srpt <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_PTT_SRPT forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_ptt_srpt]];
            partOfTitleSearchTable = [[DKTitleSetInformation _readPartOfTitleSearchTableFromDataSource:dataSource offset:offset_of_vts_ptt_srpt errors:errors] retain];
        }
        uint32_t offset_of_vtsm_c_adt = OSReadBigInt32(&vts_mat->vtsm_c_adt, 0);
        if (offset_of_vtsm_c_adt && (offset_of_vtsm_c_adt <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTSM_C_ADT forKey:[NSNumber numberWithUnsignedInt:offset_of_vtsm_c_adt]];
            menuCellAddressTable = [[DKTitleSetInformation _readCellAddressTableFromDataSource:dataSource offset:offset_of_vtsm_c_adt errors:errors] retain];
        }
        uint32_t offset_of_vts_c_adt = OSReadBigInt32(&vts_mat->vts_c_adt, 0);
        if (offset_of_vts_c_adt && (offset_of_vts_c_adt <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_C_ADT forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_c_adt]];
            cellAddressTable = [[DKTitleSetInformation _readCellAddressTableFromDataSource:dataSource offset:offset_of_vts_c_adt errors:errors] retain];
        }
        uint32_t offset_of_vtsm_vobu_admap = OSReadBigInt32(&vts_mat->vtsm_vobu_admap, 0);
        if (offset_of_vtsm_vobu_admap && (offset_of_vtsm_vobu_admap <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTSM_VOBU_ADMAP forKey:[NSNumber numberWithUnsignedInt:offset_of_vtsm_vobu_admap]];
            menuVobuAddressMap = [[DKTitleSetInformation _readVobuAddressMapFromDataSource:dataSource offset:offset_of_vtsm_vobu_admap errors:errors] retain];
        }
        uint32_t offset_of_vts_vobu_admap = OSReadBigInt32(&vts_mat->vts_vobu_admap, 0);
        if (offset_of_vts_vobu_admap && (offset_of_vts_vobu_admap <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_VOBU_ADMAP forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_vobu_admap]];
            vobuAddressMap = [[DKTitleSetInformation _readVobuAddressMapFromDataSource:dataSource offset:offset_of_vts_vobu_admap errors:errors] retain];
        }
        uint32_t offset_of_vts_pgcit = OSReadBigInt32(&vts_mat->vts_pgcit, 0);
        if (offset_of_vts_pgcit && (offset_of_vts_pgcit <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_PGCIT forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_pgcit]];
            programChainInformationTable = [[DKTitleSetInformation _readProgramChainInformationTableFromDataSource:dataSource offset:offset_of_vts_pgcit errors:errors] retain];
        }
        uint32_t offset_of_vtsm_pgci_ut = OSReadBigInt32(&vts_mat->vtsm_pgci_ut, 0);
        if (offset_of_vtsm_pgci_ut && (offset_of_vtsm_pgci_ut <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTSM_PGCI_UT forKey:[NSNumber numberWithUnsignedInt:offset_of_vtsm_pgci_ut]];
            menuProgramChainInformationTablesByLanguage = [[DKTitleSetInformation _readMenuProgramChainInformationTablesByLanguageFromDataSource:dataSource offset:offset_of_vtsm_pgci_ut errors:errors] retain];
        }
        uint32_t offset_of_vts_tmapt = OSReadBigInt32(&vts_mat->vts_tmapt, 0);
        if (offset_of_vts_tmapt && (offset_of_vts_tmapt <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_TMAPT forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_tmapt]];
            timeMapTable = [[DKTitleSetInformation _readTimeMapTableFromDataSource:dataSource offset:offset_of_vts_tmapt errors:errors] retain];
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

+ (NSMutableArray*) _readPartOfTitleSearchTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    const vts_ptt_srpt_t* vts_ptt_srpt = [data bytes];
    uint16_t nr_of_srpts = OSReadBigInt16(&vts_ptt_srpt->nr_of_srpts, 0);
    uint32_t last_byte = 1 + OSReadBigInt32(&vts_ptt_srpt->last_byte, 0);
    
    /*  Sanity Checking / Data Repair  */
    if (nr_of_srpts > 99) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKPartOfTitleSearchPointerTableError, nil)];
        }
        nr_of_srpts = 99;
    }
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  Parse the table  */
    NSMutableArray* table = [NSMutableArray arrayWithCapacity:nr_of_srpts];  
    const uint8_t* bytes = [data bytes];
    const uint8_t* p = bytes + sizeof(vts_ptt_srpt_t);
    for (int i = 0; i < nr_of_srpts; i++, p += 4) {
        uint32_t start_byte = OSReadBigInt32(p, 0);
        uint32_t length = ((i < nr_of_srpts - 1) ? OSReadBigInt32(p, 4) : last_byte) - start_byte;
        uint16_t nr_of_ptts = length / 4;
        NSMutableArray* ptts = [NSMutableArray arrayWithCapacity:nr_of_ptts];
        for (uint32_t x = start_byte, lx = x + length; x < lx; x += 4) {
            NSError* partOfTitleError = nil;
            [ptts addObject:[DKPartOfTitle partOfTitleWithData:[data subdataWithRange:NSMakeRange(x, sizeof(ptt_info_t))] error:errors ? &partOfTitleError : NULL]];
            if (partOfTitleError) {
                if (partOfTitleError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[partOfTitleError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:partOfTitleError];
                }
            }
        }
        [table addObject:ptts];
    }

    return table;
}

+ (NSMutableArray*) _readCellAddressTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    const vts_c_adt_t* vts_c_adt = [data bytes];
    uint16_t nr_of_c_adts = OSReadBigInt16(&vts_c_adt->nr_of_c_adts, 0);
    uint32_t last_byte = 1 + OSReadBigInt32(&vts_c_adt->last_byte, 0);
    
    /*  Sanity Checking / Data Repair  */
    uint32_t calculated_nr_of_c_adts = (last_byte - sizeof(vts_c_adt_t)) / sizeof(cell_adr_t);
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
    for (int i = 1, p = sizeof(vts_c_adt_t); i <= nr_of_c_adts; i++, p += sizeof(cell_adr_t)) {
        [table addObject:[DKCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p, sizeof(cell_adr_t))]]];
    }

    return table;
}

+ (NSData*) _readTimeMapTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    uint32_t last_byte = 1 + OSReadBigInt32([data bytes], 4);
    
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

+ (NSData*) _readVobuAddressMapFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
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
            
+ (NSMutableArray*) _readProgramChainInformationTableFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    const vtsm_pgc_t* vts_pgc = [data bytes];
    uint16_t nr_of_pgci_srp = OSReadBigInt16(&vts_pgc->nr_of_pgci_srp, 0);
    uint32_t last_byte = 1 + OSReadBigInt32(&vts_pgc->last_byte, 0);
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    NSMutableArray* table = [NSMutableArray arrayWithCapacity:nr_of_pgci_srp];
    for (int i = 0, p = sizeof(vtsm_pgc_t); i < nr_of_pgci_srp; i++, p += sizeof(pgci_srp_t)) {
        const pgci_srp_t* pgci_srp = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_srp_t))] bytes];
        uint8_t entry_id = OSReadBigInt8(&pgci_srp->entry_id, 0);
        uint16_t ptl_id_mask = OSReadBigInt16(&pgci_srp->ptl_id_mask, 0);
        uint32_t pgc_start_byte = OSReadBigInt32(&pgci_srp->pgc_start_byte, 0);
        NSError* programChainError = nil;
        [table addObject:[DKProgramChainSearchPointer programChainSearchPointerWithEntryId:entry_id parentalMask:ptl_id_mask programChain:[DKProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(pgc_start_byte, last_byte - pgc_start_byte)] error:errors ? &programChainError : NULL]]];
        if (programChainError) {
            if (programChainError.code == kDKMultipleErrorsError) {
                [errors addObjectsFromArray:[programChainError.userInfo objectForKey:NSDetailedErrorsKey]];
            } else {
                [errors addObject:programChainError];
            }
        }
    }

    return table;
}

+ (NSMutableDictionary*) _readMenuProgramChainInformationTablesByLanguageFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    const vtsm_pgci_ut_t* vts_pgci_ut = [data bytes];
    uint16_t nr_of_lus = OSReadBigInt16(&vts_pgci_ut->nr_of_lus, 0);
    uint32_t last_byte = 1 + OSReadBigInt32(&vts_pgci_ut->last_byte, 0);
    
    /*  Sanity Checking / Data Repair  */
    if (nr_of_lus > 99) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKTitleSetProgramChainInformationMapError, nil)];
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
        uint32_t vts_pgc_start_byte = OSReadBigInt32(&vtsm_lu->pgcit_start_byte, 0);
        
        const vtsm_pgc_t* vts_pgc = [[data subdataWithRange:NSMakeRange(vts_pgc_start_byte, sizeof(vtsm_pgc_t))] bytes];
        uint16_t nr_of_pgci_srp = OSReadBigInt16(&vts_pgc->nr_of_pgci_srp, 0);
        uint32_t vts_pgc_last_byte = 1 + OSReadBigInt32(&vts_pgc->last_byte, 0);
        
        if (errors && ((vts_pgc_start_byte + vts_pgc_last_byte) > last_byte)) {
            // TODO: Correct last_byte?
            [errors addObject:DKErrorWithCode(kDKTitleSetProgramChainInformationMapError, nil)];
        }
        
        NSMutableArray* table = [[NSMutableArray alloc] initWithCapacity:nr_of_pgci_srp];
        for (int i = 0, p = vts_pgc_start_byte + sizeof(vtsm_pgc_t); i < nr_of_pgci_srp; i++, p += sizeof(pgci_srp_t)) {
            const pgci_srp_t* pgci_srp = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_srp_t))] bytes];
            uint8_t entry_id = OSReadBigInt8(&pgci_srp->entry_id, 0);
            uint16_t ptl_id_mask = OSReadBigInt16(&pgci_srp->ptl_id_mask, 0);
            uint32_t pgc_start_byte = OSReadBigInt32(&pgci_srp->pgc_start_byte, 0);
            NSError* programChainError = nil;
            [table addObject:[DKProgramChainSearchPointer programChainSearchPointerWithEntryId:entry_id parentalMask:ptl_id_mask programChain:[DKProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(vts_pgc_start_byte + pgc_start_byte, vts_pgc_last_byte - pgc_start_byte)] error:errors ? &programChainError : NULL]]];
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
                                                           
- (void) dealloc
{
    [menuVobuAddressMap release];
    [vobuAddressMap release];
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

- (NSData*) saveAsData:(NSError**)error
{
    NSMutableArray* errors = !error ? nil : [NSMutableArray array];
    NSMutableData* data = [NSMutableData data];
    
    /*
     */
    [data increaseLengthBy:sizeof(vts_mat_t)];  
    vts_mat_t vts_mat;
    bzero(&vts_mat, sizeof(vts_mat_t));
    memcpy(vts_mat.vts_identifier, "DVDVIDEO-VTS", sizeof(vts_mat.vts_identifier));
    
    /*
     */
    OSWriteBigInt16(&vts_mat.specification_version, 0, specificationVersion);
    OSWriteBigInt32(&vts_mat.vts_category, 0, categoryAndMask);

    
    /*  Menu Video / Audio / Subpicture Attributes
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
            memcpy(&vts_mat.vtsm_video_attr, [menuVideoAttributesData bytes], sizeof(video_attr_t));
        }
    } else if (errors) {
        [errors addObject:DKErrorWithCode(kDKNumberOfVideoAttributesError, nil)];
    }
    uint16_t nr_of_vtsm_audio_streams = [menuAudioAttributes count];
    if (nr_of_vtsm_audio_streams > 8) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKNumberOfAudioStreamsError, nil)];
        }
        nr_of_vtsm_audio_streams = 8;
    }
    if (nr_of_vtsm_audio_streams) {
        OSWriteBigInt16(&vts_mat.nr_of_vtsm_audio_streams, 0, nr_of_vtsm_audio_streams);
        for (int i = 0; i < nr_of_vtsm_audio_streams; i++) {
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
                memcpy(&vts_mat.vtsm_audio_attr[i], [menuAudioAttributesData bytes], sizeof(audio_attr_t));
            }
        }
    }
    if (menuSubpictureAttributes) {
        OSWriteBigInt16(&vts_mat.nr_of_vtsm_subp_streams, 0, 1);
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
            memcpy(&vts_mat.vtsm_subp_attr, [menuSubpictureAttributesData bytes], sizeof(subp_attr_t));
        }
    }


    /*  Title Set Video / Audio / Subpicture Attributes
     */
    if (videoAttributes) {
        NSError* videoAttributesError = nil;
        NSData* videoAttributesData = [videoAttributes saveAsData:errors ? &videoAttributesError : NULL];
        if (videoAttributesError) {
            if (videoAttributesError.code == kDKMultipleErrorsError) {
                [errors addObjectsFromArray:[videoAttributesError.userInfo objectForKey:NSDetailedErrorsKey]];
            } else {
                [errors addObject:videoAttributesError];
            }
        }
        if (videoAttributesData) {
            memcpy(&vts_mat.vts_video_attr, [videoAttributesData bytes], sizeof(video_attr_t));
        }
    } else if (errors) {
        [errors addObject:DKErrorWithCode(kDKNumberOfVideoAttributesError, nil)];
    }
    uint16_t nr_of_vts_audio_streams = [audioAttributes count];
    if (nr_of_vts_audio_streams > 8) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKNumberOfAudioStreamsError, nil)];
        }
        nr_of_vts_audio_streams = 8;
    }
    if (nr_of_vts_audio_streams) {
        OSWriteBigInt16(&vts_mat.nr_of_vts_audio_streams, 0, nr_of_vts_audio_streams);
        for (int i = 0; i < nr_of_vts_audio_streams; i++) {
            NSError* audioAttributesError = nil;
            NSData* audioAttributesData = [[audioAttributes objectAtIndex:i] saveAsData:errors ? &audioAttributesError : NULL];
            if (audioAttributesError) {
                if (audioAttributesError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[audioAttributesError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:audioAttributesError];
                }
            }
            if (audioAttributesData) {
                memcpy(&vts_mat.vts_audio_attr[i], [audioAttributesData bytes], sizeof(audio_attr_t));
            }
        }
    }
    uint16_t nr_of_vts_subp_streams = [subpictureAttributes count];
    if (nr_of_vts_subp_streams > 32) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKNumberOfSubpictureStreamsError, nil)];
        }
        nr_of_vts_subp_streams = 32;
    }
    if (nr_of_vts_subp_streams) {
        OSWriteBigInt16(&vts_mat.nr_of_vts_subp_streams, 0, nr_of_vts_subp_streams);
        for (int i = 0; i < nr_of_vts_subp_streams; i++) {
            NSError* subpictureAttributesError = nil;
            NSData* subpictureAttributesData = [[subpictureAttributes objectAtIndex:i] saveAsData:errors ? &subpictureAttributesError : NULL];
            if (subpictureAttributesError) {
                if (subpictureAttributesError.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[subpictureAttributesError.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:subpictureAttributesError];
                }
            }
            if (subpictureAttributesData) {
                memcpy(&vts_mat.vts_subp_attr[i], [subpictureAttributesData bytes], sizeof(subp_attr_t));
            }
        }
    }
    

    /*  Align to the next sector boundary.
     */
    OSWriteBigInt32(&vts_mat.vtsi_last_byte, 0, [data length]);
    uint32_t amountToAlign = 0x800 - ([data length] & 0x07FF);
    if (amountToAlign != 0x800) {
        [data increaseLengthBy:amountToAlign];
    }
    NSAssert(([data length] & 0x07FF) == 0, @"Sections not sector-aligned?");
    
    
    /*  Determine the proper order, and then write out the various sections.
     */
    NSMutableArray* sectionOrder = [[preferredSectionOrder mutableCopy] autorelease];
    for (NSString* section in [DKTitleSetInformation availableSections]) {
        if (![sectionOrder containsObject:section]) {
            [sectionOrder addObject:section];
        }
    }
    for (NSString* section in sectionOrder) {
        NSMutableData* sectionData = nil;
        NSAssert(([data length] & 0x07FF) == 0, @"Sections not sector-aligned?");

        if ([section isEqualToString:kDKTitleSetInformationSection_VTS_PTT_SRPT]) {
            if (![partOfTitleSearchTable count]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _savePartOfTitleSearchTable:partOfTitleSearchTable errors:errors];
            OSWriteBigInt32(&vts_mat.vts_ptt_srpt, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKTitleSetInformationSection_VTSM_C_ADT]) {
            if (![menuCellAddressTable count]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _saveCellAddressTable:menuCellAddressTable errors:errors];
            OSWriteBigInt32(&vts_mat.vtsm_c_adt, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKTitleSetInformationSection_VTS_C_ADT]) {
            if (![cellAddressTable count]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _saveCellAddressTable:cellAddressTable errors:errors];
            OSWriteBigInt32(&vts_mat.vts_c_adt, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKTitleSetInformationSection_VTSM_VOBU_ADMAP]) {
            if (![menuVobuAddressMap length]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _saveVobuAddressMap:menuVobuAddressMap errors:errors];
            OSWriteBigInt32(&vts_mat.vtsm_vobu_admap, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKTitleSetInformationSection_VTS_VOBU_ADMAP]) {
            if (![vobuAddressMap length]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _saveVobuAddressMap:vobuAddressMap errors:errors];
            OSWriteBigInt32(&vts_mat.vts_vobu_admap, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKTitleSetInformationSection_VTSM_PGCI_UT]) {
            if (![menuProgramChainInformationTablesByLanguage count]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _saveMenuProgramChainInformationTablesByLanguage:menuProgramChainInformationTablesByLanguage errors:errors];
            OSWriteBigInt32(&vts_mat.vtsm_pgci_ut, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKTitleSetInformationSection_VTS_PGCIT]) {
            if (![programChainInformationTable count]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _saveProgramChainInformationTable:programChainInformationTable errors:errors];
            OSWriteBigInt32(&vts_mat.vts_pgcit, 0, [data length] >> 11);
        } else if ([section isEqualToString:kDKTitleSetInformationSection_VTS_TMAPT]) {
            if (![timeMapTable length]) {
                continue;
            }
            sectionData = [DKTitleSetInformation _saveTimeMapTable:timeMapTable errors:errors];
            OSWriteBigInt32(&vts_mat.vts_tmapt, 0, [data length] >> 11);
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
    uint32_t vtsi_last_sector = [data length] >> 11;
    OSWriteBigInt32(&vts_mat.vtsi_last_sector, 0, vtsi_last_sector - 1);
    OSWriteBigInt32(&vts_mat.vts_last_sector, 0, (vtsi_last_sector * 2) - 1);
    OSWriteBigInt32(&vts_mat.vtsm_vobs, 0, vtsi_last_sector);
    
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
    
    memcpy([data mutableBytes], &vts_mat, sizeof(vts_mat_t));
    return data;
}

+ (NSMutableData*) _saveMenuProgramChainInformationTablesByLanguage:(NSDictionary*)menuProgramChainInformationTablesByLanguage errors:(NSMutableArray*)errors
{
    uint16_t nr_of_lus = [menuProgramChainInformationTablesByLanguage count];
    if (nr_of_lus > 99) {
        if (errors) {
            [errors addObject:DKErrorWithCode(kDKNumberOfMenuProgramChainLanguageUnitsError, nil)];
        }
        nr_of_lus = 99;
    }
    
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(vtsm_pgci_ut_t) + (nr_of_lus * sizeof(vtsm_lu_t))];
    int i = 0;
    for (NSNumber* languageCode in menuProgramChainInformationTablesByLanguage) {
        NSArray* table = [menuProgramChainInformationTablesByLanguage objectForKey:languageCode];
        uint32_t vtsm_lu_start_byte = sizeof(vtsm_pgci_ut_t) + (i * sizeof(vtsm_lu_t));
        
        uint32_t vtsm_pgc_start_byte = [data length];
        uint16_t nr_of_pgci_srp = [table count];
        [data increaseLengthBy:sizeof(vtsm_pgc_t) + (nr_of_pgci_srp * sizeof(pgci_srp_t))];
        int j = 0;
        for (DKProgramChainSearchPointer* programChainSearchPointer in table) {
            pgci_srp_t pgci_srp;
            bzero(&pgci_srp, sizeof(pgci_srp_t));
            OSWriteBigInt8(&pgci_srp.entry_id, 0, [programChainSearchPointer entryId]);
            OSWriteBigInt16(&pgci_srp.ptl_id_mask, 0, [programChainSearchPointer ptl_id_mask]);
            OSWriteBigInt32(&pgci_srp.pgc_start_byte, 0, [data length] - vtsm_pgc_start_byte);
            [data replaceBytesInRange:NSMakeRange(vtsm_pgc_start_byte + sizeof(vtsm_pgc_t) + (j * sizeof(pgci_srp_t)), sizeof(pgci_srp_t)) withBytes:&pgci_srp];
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
                [data appendData:programChainData];
            }
        }
        
        vtsm_pgc_t vtsm_pgc;
        bzero(&vtsm_pgc, sizeof(vtsm_pgc_t));
        OSWriteBigInt16(&vtsm_pgc.nr_of_pgci_srp, 0, nr_of_pgci_srp);
        OSWriteBigInt32(&vtsm_pgc.last_byte, 0, [data length] - vtsm_pgc_start_byte - 1);
        [data replaceBytesInRange:NSMakeRange(vtsm_pgc_start_byte, sizeof(vtsm_pgc_t)) withBytes:&vtsm_pgc];
        
        vtsm_lu_t vtsm_lu;
        bzero(&vtsm_lu, sizeof(vtsm_lu_t));
        OSWriteBigInt16(&vtsm_lu.lang_code, 0, [languageCode unsignedShortValue]);
        OSWriteBigInt8(&vtsm_lu.exists, 0, 0x80);
        OSWriteBigInt32(&vtsm_lu.pgcit_start_byte, 0, vtsm_pgc_start_byte);
        [data replaceBytesInRange:NSMakeRange(vtsm_lu_start_byte, sizeof(vtsm_lu_t)) withBytes:&vtsm_lu];
        i++;
    }
    
    vtsm_pgci_ut_t vtsm_pgci_ut;
    bzero(&vtsm_pgci_ut, sizeof(vtsm_pgci_ut));
    OSWriteBigInt16(&vtsm_pgci_ut.nr_of_lus, 0, nr_of_lus);
    OSWriteBigInt32(&vtsm_pgci_ut.last_byte, 0, [data length] - 1);
    [data replaceBytesInRange:NSMakeRange(0, sizeof(vtsm_pgci_ut_t)) withBytes:&vtsm_pgci_ut];
    
    return data;
}

+ (NSMutableData*) _saveProgramChainInformationTable:(NSArray*)programChainInformationTable errors:(NSMutableArray*)errors
{
    uint16_t nr_of_pgci_srp = [programChainInformationTable count];
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(vtsm_pgc_t) + (nr_of_pgci_srp * sizeof(pgci_srp_t))];

    int i = 0;
    for (DKProgramChainSearchPointer* programChainSearchPointer in programChainInformationTable) {
        pgci_srp_t pgci_srp;
        bzero(&pgci_srp, sizeof(pgci_srp_t));
        OSWriteBigInt8(&pgci_srp.entry_id, 0, [programChainSearchPointer entryId]);
        OSWriteBigInt16(&pgci_srp.ptl_id_mask, 0, [programChainSearchPointer ptl_id_mask]);
        OSWriteBigInt32(&pgci_srp.pgc_start_byte, 0, [data length]);
        [data replaceBytesInRange:NSMakeRange(sizeof(vtsm_pgc_t) + (i * sizeof(pgci_srp_t)), sizeof(pgci_srp_t)) withBytes:&pgci_srp];
        i++;
        
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
            [data appendData:programChainData];
        }
    }
    
    vtsm_pgc_t vtsm_pgc;
    bzero(&vtsm_pgc, sizeof(vtsm_pgc_t));
    OSWriteBigInt16(&vtsm_pgc.nr_of_pgci_srp, 0, nr_of_pgci_srp);
    OSWriteBigInt32(&vtsm_pgc.last_byte, 0, [data length] - 1);
    [data replaceBytesInRange:NSMakeRange(0, sizeof(vtsm_pgc_t)) withBytes:&vtsm_pgc];

    return data;
}

+ (NSMutableData*) _saveVobuAddressMap:(NSData*)vobuAddressMap errors:(NSMutableArray*)errors
{
    uint32_t last_byte = sizeof(uint32_t) + [vobuAddressMap length];
    NSMutableData* data = [NSMutableData dataWithLength:last_byte];
    uint8_t* base = [data mutableBytes];
    OSWriteBigInt32(base, 0, last_byte - 1);
    
    memcpy(base + 4, [vobuAddressMap bytes], [vobuAddressMap length]);
    
    return data;
}

+ (NSMutableData*) _saveCellAddressTable:(NSArray*)cellAddressTable errors:(NSMutableArray*)errors
{
    uint16_t nr_of_c_adts = [cellAddressTable count];
    uint32_t last_byte = sizeof(vmgm_c_adt_t) + (nr_of_c_adts * sizeof(cell_adr_t));
    NSMutableData* data = [NSMutableData dataWithLength:last_byte];
    uint8_t* base = [data mutableBytes];
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
    
    return data;
}

+ (NSMutableData*) _savePartOfTitleSearchTable:(NSArray*)partOfTitleSearchTable errors:(NSMutableArray*)errors
{
    uint16_t nr_of_srpts = [partOfTitleSearchTable count];
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(vts_ptt_srpt_t) + (nr_of_srpts * sizeof(uint32_t))];

    for (int i = 0, p = sizeof(vts_ptt_srpt_t); i < nr_of_srpts; i++, p += sizeof(uint32_t)) {
        uint32_t start_byte = OSSwapHostToBigInt32([data length]);
        [data replaceBytesInRange:NSMakeRange(p, sizeof(uint32_t)) withBytes:&start_byte];

        for (DKPartOfTitle* partOfTitle in [partOfTitleSearchTable objectAtIndex:i]) {
            NSError* vts_ptt_srpt_error = nil;
            NSData* vts_ptt_srpt_data = [partOfTitle saveAsData:errors ? &vts_ptt_srpt_error : NULL];
            if (vts_ptt_srpt_error) {
                if (vts_ptt_srpt_error.code == kDKMultipleErrorsError) {
                    [errors addObjectsFromArray:[vts_ptt_srpt_error.userInfo objectForKey:NSDetailedErrorsKey]];
                } else {
                    [errors addObject:vts_ptt_srpt_error];
                }
            }
            if (vts_ptt_srpt_data) {
                [data appendData:vts_ptt_srpt_data];
            }
        }
    }
    
    vts_ptt_srpt_t vts_ptt_srpt;
    bzero(&vts_ptt_srpt, sizeof(vts_ptt_srpt_t));
    OSWriteBigInt16(&vts_ptt_srpt.nr_of_srpts, 0, nr_of_srpts);
    OSWriteBigInt32(&vts_ptt_srpt.last_byte, 0, [data length] - 1);
    [data replaceBytesInRange:NSMakeRange(0, sizeof(vts_ptt_srpt_t)) withBytes:&vts_ptt_srpt];
    
    return data;
}

+ (NSMutableData*) _saveTimeMapTable:(NSData*)timeMapTable errors:(NSMutableArray*)errors
{
    return [NSMutableData dataWithData:timeMapTable];
}


@end
