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

NSString* const kDKTitleSetInformationSection_VTS_PTT_SRPT = @"vts_ptt_srpt";
NSString* const kDKTitleSetInformationSection_VTSM_C_ADT = @"vtsm_c_adt";
NSString* const kDKTitleSetInformationSection_VTSM_VOBU_ADMAP = @"vtsm_vobu_admap";
NSString* const kDKTitleSetInformationSection_VTS_VOBU_ADMAP = @"vts_vobu_admap";
NSString* const kDKManagerInformationSection_VTSM_PGCI_UT = @"vtsm_pgci_ut";
NSString* const kDKTitleSetInformationSection_VTS_PGCIT = @"vts_pgcit";

@interface DKTitleSetInformation (Private)
- (NSArray*) parsePGCITfromData:(NSData*)data offset:(uint32_t)_offset;
@end

@implementation DKTitleSetInformation
@synthesize index;
@synthesize programChainInformationTable;
@synthesize partOfTitleSearchTable;

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
        specificationVersion = OSReadBigInt8(&vts_mat->specification_version, 0);
        vts_category = OSReadBigInt32(&vts_mat->vts_category, 0);

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
        
        
        /*  "Part of Title" Search Table.
         */
        uint32_t offset_of_vts_ptt_srpt = OSReadBigInt32(&vts_mat->vts_ptt_srpt, 0);
        if (offset_of_vts_ptt_srpt && (offset_of_vts_ptt_srpt <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_PTT_SRPT forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_ptt_srpt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vts_ptt_srpt << 11];
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
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vts_ptt_srpt << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  Parse the table  */
            partOfTitleSearchTable = [[NSMutableArray alloc] initWithCapacity:nr_of_srpts];  
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
                [partOfTitleSearchTable addObject:ptts];
            }
        }
        
        
        /*  Menu Cell Address Table
         */
        uint32_t offset_of_vtsm_c_adt = OSReadBigInt32(&vts_mat->vtsm_c_adt, 0);
        if (offset_of_vtsm_c_adt && (offset_of_vtsm_c_adt <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTSM_C_ADT forKey:[NSNumber numberWithUnsignedInt:offset_of_vtsm_c_adt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vtsm_c_adt << 11];
            const vtsm_c_adt_t* vtsm_c_adt = [data bytes];
            uint16_t nr_of_c_adts = OSReadBigInt16(&vtsm_c_adt->nr_of_c_adts, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&vtsm_c_adt->last_byte, 0);
            
            /*  Sanity Checking / Data Repair  */
            uint32_t calculated_nr_of_c_adts = (last_byte - sizeof(vtsm_c_adt_t)) / sizeof(cell_adr_t);
            if (nr_of_c_adts != calculated_nr_of_c_adts) {
                if (errors) {
                    [errors addObject:DKErrorWithCode(kDKMenuCellAddressTableError, [NSString stringWithFormat:DKLocalizedString(@"Corrected nr_of_c_adts (was %d, is now %d)", nil), nr_of_c_adts, calculated_nr_of_c_adts], NSLocalizedDescriptionKey, nil)];
                }
                nr_of_c_adts = calculated_nr_of_c_adts;
            } 
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vtsm_c_adt << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  Parse the table  */
            menuCellAddressTable = [[NSMutableArray alloc] initWithCapacity:nr_of_c_adts];
            for (int i = 1, p = sizeof(vtsm_c_adt_t); i <= nr_of_c_adts; i++, p += sizeof(cell_adr_t)) {
                [menuCellAddressTable addObject:[DKCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p, sizeof(cell_adr_t))]]];
            }
        }
        

        /*  Cell Address Table
         */
        uint32_t offset_of_vts_c_adt = OSReadBigInt32(&vts_mat->vts_c_adt, 0);
        if (offset_of_vts_c_adt && (offset_of_vts_c_adt <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTSM_C_ADT forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_c_adt]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vts_c_adt << 11];
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
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vts_c_adt << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  Parse the table  */
            cellAddressTable = [[NSMutableArray alloc] initWithCapacity:nr_of_c_adts];
            for (int i = 1, p = sizeof(vts_c_adt_t); i <= nr_of_c_adts; i++, p += sizeof(cell_adr_t)) {
                [cellAddressTable addObject:[DKCellAddress cellAddressWithData:[data subdataWithRange:NSMakeRange(p, sizeof(cell_adr_t))]]];
            }
        }
        
        /*  Menu VOBU Address Map
         */
        uint32_t offset_of_vtsm_vobu_admap = OSReadBigInt32(&vts_mat->vtsm_vobu_admap, 0);
        if (offset_of_vtsm_vobu_admap && (offset_of_vtsm_vobu_admap <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTSM_VOBU_ADMAP forKey:[NSNumber numberWithUnsignedInt:offset_of_vtsm_vobu_admap]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vtsm_vobu_admap << 11];
            uint32_t last_byte = 1 + OSReadBigInt32([data bytes], 0);
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vtsm_vobu_admap << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  
             *  TODO: Additional Decoding  
             */
            
            /*  Retain the table  */
            menuVobuAddressMap = [[data subdataWithRange:NSMakeRange(4, last_byte - 4)] retain];
        }
        
        /*  VOBU Address Map
         */
        uint32_t offset_of_vts_vobu_admap = OSReadBigInt32(&vts_mat->vts_vobu_admap, 0);
        if (offset_of_vts_vobu_admap && (offset_of_vts_vobu_admap <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_VOBU_ADMAP forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_vobu_admap]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vts_vobu_admap << 11];
            uint32_t last_byte = 1 + OSReadBigInt32([data bytes], 0);
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vts_vobu_admap << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  
             *  TODO: Additional Decoding
             */
            
            /*  Retain the table  */
            vobuAddressMap = [[data subdataWithRange:NSMakeRange(4, last_byte - 4)] retain];
        }
        

        /*  Program Chain Information Table
         */
        uint32_t offset_of_vts_pgcit = OSReadBigInt32(&vts_mat->vts_pgcit, 0);
        if (offset_of_vts_pgcit && (offset_of_vts_pgcit <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKTitleSetInformationSection_VTS_PGCIT forKey:[NSNumber numberWithUnsignedInt:offset_of_vts_pgcit]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vts_pgcit << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const vtsm_pgc_t* vtsm_pgc = [data bytes];
            uint16_t nr_of_pgci_srp = OSReadBigInt16(&vtsm_pgc->nr_of_pgci_srp, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&vtsm_pgc->last_byte, 0);
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vts_pgcit << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            programChainInformationTable = [[NSMutableArray alloc] initWithCapacity:nr_of_pgci_srp];
            for (int i = 0, p = sizeof(vtsm_pgc_t); i < nr_of_pgci_srp; i++, p += sizeof(pgci_srp_t)) {
                const pgci_srp_t* pgci_srp = [[data subdataWithRange:NSMakeRange(p, sizeof(pgci_srp_t))] bytes];
                uint8_t entry_id = OSReadBigInt8(&pgci_srp->entry_id, 0);
                uint16_t ptl_id_mask = OSReadBigInt16(&pgci_srp->ptl_id_mask, 0);
                uint32_t pgc_start_byte = OSReadBigInt32(&pgci_srp->pgc_start_byte, 0);
                NSError* programChainError = nil;
                [programChainInformationTable addObject:[DKProgramChainSearchPointer programChainSearchPointerWithEntryId:entry_id parentalMask:ptl_id_mask programChain:[DKProgramChain programChainWithData:[data subdataWithRange:NSMakeRange(pgc_start_byte, last_byte - pgc_start_byte)] error:errors ? &programChainError : NULL]]];
                if (programChainError) {
                    if (programChainError.code == kDKMultipleErrorsError) {
                        [errors addObjectsFromArray:[programChainError.userInfo objectForKey:NSDetailedErrorsKey]];
                    } else {
                        [errors addObject:programChainError];
                    }
                }
            }
        }
        

        /*  Menu Program Chain Information Map (by language)
         */
        uint32_t offset_of_vtsm_pgci_ut = OSReadBigInt32(&vts_mat->vtsm_pgci_ut, 0);
        if (offset_of_vtsm_pgci_ut && (offset_of_vtsm_pgci_ut <= vtsi_last_sector)) {
            [sectionOrdering setObject:kDKManagerInformationSection_VTSM_PGCI_UT forKey:[NSNumber numberWithUnsignedInt:offset_of_vtsm_pgci_ut]];
            NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset_of_vtsm_pgci_ut << 11];
            NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
            const vtsm_pgci_ut_t* vtsm_pgci_ut = [data bytes];
            uint16_t nr_of_lus = OSReadBigInt16(&vtsm_pgci_ut->nr_of_lus, 0);
            uint32_t last_byte = 1 + OSReadBigInt32(&vtsm_pgci_ut->last_byte, 0);
            
            /*  Sanity Checking / Data Repair  */
            if (nr_of_lus > 99) {
                if (errors) {
                    [errors addObject:DKErrorWithCode(kDKTitleSetProgramChainInformationMapError, nil)];
                }
                nr_of_lus = 99;
            }
            
            /*  Have we already read all that we need?  */
            if (last_byte > [data length]) {
                data = [dataSource requestDataOfLength:last_byte fromOffset:(offset_of_vtsm_pgci_ut << 11)];
            } else {
                data = [data subdataWithRange:NSMakeRange(0, last_byte)];
            }
            
            /*  Parse the tables  */
            menuProgramChainInformationTablesByLanguage = [[NSMutableDictionary alloc] initWithCapacity:nr_of_lus];
            for (int i = 0, p = sizeof(vtsm_pgci_ut_t); i < nr_of_lus; i++, p += 8) {
                const vtsm_lu_t* vtsm_lu = [[data subdataWithRange:NSMakeRange(p, sizeof(vtsm_lu_t))] bytes];
                uint16_t lang_code = OSReadBigInt16(&vtsm_lu->lang_code, 0);
                uint32_t vtsm_pgc_start_byte = OSReadBigInt32(&vtsm_lu->pgcit_start_byte, 0);
                
                const vtsm_pgc_t* vtsm_pgc = [[data subdataWithRange:NSMakeRange(vtsm_pgc_start_byte, sizeof(vtsm_pgc_t))] bytes];
                uint16_t nr_of_pgci_srp = OSReadBigInt16(&vtsm_pgc->nr_of_pgci_srp, 0);
                uint32_t vtsm_pgc_last_byte = 1 + OSReadBigInt32(&vtsm_pgc->last_byte, 0);
                
                if (errors && ((vtsm_pgc_start_byte + vtsm_pgc_last_byte) > last_byte)) {
                    // TODO: Correct last_byte?
                    [errors addObject:DKErrorWithCode(kDKTitleSetProgramChainInformationMapError, nil)];
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
                [menuProgramChainInformationTablesByLanguage setObject:table forKey:[NSNumber numberWithShort:lang_code]];
                [table release];
            }
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
    return nil;
}

@end
