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

@interface DKTitleSetInformation : NSObject {
    NSInteger index;
    /**/
    uint16_t specificationVersion;
    uint32_t categoryAndMask;
    /**/
    DKVideoAttributes* menuVideoAttributes;
    NSMutableArray* menuAudioAttributes;
    DKSubpictureAttributes* menuSubpictureAttributes; 
    NSMutableDictionary* menuProgramChainInformationTablesByLanguage;
    NSMutableArray* menuCellAddressTable;
    CFMutableBitVectorRef menuVobuAddressMap;
    /**/
    DKVideoAttributes* videoAttributes;
    NSMutableArray* audioAttributes;
    NSMutableArray* subpictureAttributes; 
    NSMutableArray* programChainInformationTable;
    NSMutableArray* cellAddressTable;
    CFMutableBitVectorRef vobuAddressMap;
    /**/
    NSData* timeMapTable;
    NSMutableArray* partOfTitleSearchTable;
    /**/
    NSArray* preferredSectionOrder;
}

+ (id) titleSetInformationWithDataSource:(id<DKDataSource>)dataSource index:(uint16_t)index error:(NSError**)error;

- (id) initWithDataSource:(id<DKDataSource>)dataSource index:(uint16_t)index error:(NSError**)error;

@property (readonly) NSInteger index;
@property (assign) uint16_t specificationVersion;
@property (assign) uint32_t categoryAndMask;
@property (retain) NSMutableArray* partOfTitleSearchTable;

@property (retain) DKVideoAttributes* menuVideoAttributes;
@property (retain) NSMutableArray* menuAudioAttributes;
@property (retain) DKSubpictureAttributes* menuSubpictureAttributes;
@property (retain) NSMutableDictionary* menuProgramChainInformationTablesByLanguage;
@property (retain) NSMutableArray* menuCellAddressTable;   
@property (assign) CFMutableBitVectorRef menuVobuAddressMap;// RETAINED

@property (retain) DKVideoAttributes* videoAttributes;
@property (retain) NSMutableArray* audioAttributes;
@property (retain) NSMutableArray* subpictureAttributes;
@property (retain) NSMutableArray* programChainInformationTable;
@property (retain) NSMutableArray* cellAddressTable;

@property (assign) CFMutableBitVectorRef vobuAddressMap;   // RETAINED
@property (retain) NSData* timeMapTable;            


- (NSArray*) menuProgramChainInformationTableForLanguageCode:(uint16_t)languageCode;
- (NSData*) saveAsData:(NSError**)error lengthOfMenuVOB:(uint32_t)lengthOfMenuVOB lengthOfVideoVOB:(uint32_t)lengthOfVideoVOB;

@end

extern NSString* const DVDTitleSetException;
