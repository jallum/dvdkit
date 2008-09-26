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
 * libdvdnav is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
 *
 */

@class DVDProgramChain;
@class DVDTitleTrackSearchPointer;

@interface DVDManagerInformation : NSObject {
    uint32_t lastSector;
    uint16_t specificationVersion;
    uint32_t categoryAndMask;
    uint16_t numberOfVolumes;
    uint16_t volumeNumber;
    uint8_t side;
    uint16_t numberOfTitleSets;
    uint64_t positionCode;
    /**/
    DVDProgramChain* firstPlayProgramChain;
    NSMutableArray* titleTrackSearchPointerTable;
    NSMutableArray* cellAddressTable;
    NSMutableDictionary* menuProgramChainInformationTablesByLanguage;
}

+ (id) managerInformationWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

@property (readonly) DVDProgramChain* firstPlayProgramChain;
@property (readonly) NSArray* titleTrackSearchPointerTable;
@property (readonly) uint16_t regionMask;

- (DVDTitleTrackSearchPointer*) titleTrackSearchPointerForTitleSet:(uint16_t)vts track:(uint8_t)ttn;
- (NSArray*) menuProgramChainInformationTableForLanguageCode:(uint16_t)languageCode;
@end
