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

@property (readonly, nonatomic) NSInteger index;
@property (assign, nonatomic) uint16_t specificationVersion;
@property (assign, nonatomic) uint32_t categoryAndMask;
@property (retain, nonatomic) NSMutableArray* partOfTitleSearchTable;

@property (retain, nonatomic) DKVideoAttributes* menuVideoAttributes;
@property (retain, nonatomic) NSMutableArray* menuAudioAttributes;
@property (retain, nonatomic) DKSubpictureAttributes* menuSubpictureAttributes;
@property (retain, nonatomic) NSMutableDictionary* menuProgramChainInformationTablesByLanguage;
@property (retain, nonatomic) NSMutableArray* menuCellAddressTable;   
@property (assign, nonatomic) CFMutableBitVectorRef menuVobuAddressMap;// RETAINED

@property (retain, nonatomic) DKVideoAttributes* videoAttributes;
@property (retain, nonatomic) NSMutableArray* audioAttributes;
@property (retain, nonatomic) NSMutableArray* subpictureAttributes;
@property (retain, nonatomic) NSMutableArray* programChainInformationTable;
@property (retain, nonatomic) NSMutableArray* cellAddressTable;

@property (assign, nonatomic) CFMutableBitVectorRef vobuAddressMap;   // RETAINED
@property (retain, nonatomic) NSData* timeMapTable;            


- (NSArray*) menuProgramChainInformationTableForLanguageCode:(uint16_t)languageCode;
- (NSData*) saveAsData:(NSError**)error lengthOfMenuVOB:(uint32_t)lengthOfMenuVOB lengthOfVideoVOB:(uint32_t)lengthOfVideoVOB;

@end

extern NSString* const DVDTitleSetException;
