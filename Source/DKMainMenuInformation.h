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

@class DKVideoAttributes;
@class DKSubpictureAttributes;
@class DKProgramChain;
@class DKTitleTrackSearchPointer;

@interface DKMainMenuInformation : NSObject {
    uint16_t specificationVersion;
    uint32_t categoryAndMask;
    uint16_t numberOfVolumes;
    uint16_t volumeNumber;
    uint8_t side;
    uint16_t numberOfTitleSets;
    uint64_t pointOfSaleCode;
    NSString* providerId;
    /**/
    DKVideoAttributes* menuVideoAttributes;
    NSMutableArray* menuAudioAttributes;
    DKSubpictureAttributes* menuSubpictureAttributes; 
    /**/
    DKProgramChain* firstPlayProgramChain;
    NSMutableArray* titleTrackSearchPointerTable;
    NSMutableData* parentalManagementInformationTable;
    NSMutableData* titleSetAttributeTable;
    NSMutableDictionary* menuProgramChainInformationTablesByLanguage;
    NSMutableData* textData;
    NSMutableArray* menuCellAddressTable;
    CFMutableBitVectorRef menuVobuAddressMap;
    /**/
    NSArray* preferredSectionOrder;
}

@property (assign, nonatomic) uint16_t specificationVersion;
@property (assign, nonatomic) uint32_t categoryAndMask;
@property (assign, nonatomic) uint16_t numberOfVolumes;
@property (assign, nonatomic) uint16_t volumeNumber;
@property (assign, nonatomic) uint8_t side;
@property (assign, nonatomic) uint16_t numberOfTitleSets;
@property (assign, nonatomic) uint64_t pointOfSaleCode;
@property (retain, nonatomic) NSString* providerId;
@property (retain, nonatomic) DKVideoAttributes* menuVideoAttributes;
@property (retain, nonatomic) NSMutableArray* menuAudioAttributes;
@property (retain, nonatomic) DKSubpictureAttributes* menuSubpictureAttributes;
@property (retain, nonatomic) DKProgramChain* firstPlayProgramChain;
@property (retain, nonatomic) NSMutableArray* titleTrackSearchPointerTable;
@property (retain, nonatomic) NSMutableDictionary* menuProgramChainInformationTablesByLanguage;
@property (readonly, nonatomic) uint16_t regionMask;
@property (retain, nonatomic) NSMutableArray* menuCellAddressTable;
@property (assign, nonatomic) CFMutableBitVectorRef menuVobuAddressMap;
@property (retain, nonatomic) NSMutableData* titleSetAttributeTable;

+ (id) mainMenuInformationWithDataSource:(id<DKDataSource>)dataSource error:(NSError**)error;
- (id) initWithDataSource:(id<DKDataSource>)dataSource error:(NSError**)error;

- (DKTitleTrackSearchPointer*) titleTrackSearchPointerForTitleSet:(uint16_t)vts track:(uint8_t)ttn;
- (NSArray*) menuProgramChainInformationTableForLanguageCode:(uint16_t)languageCode;

- (NSData*) saveAsData:(NSError**)error lengthOfMenuVOB:(uint32_t)lengthOfMenuVOB;

@end

extern NSString* const kDKMainMenuInformationException;


