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
#import "DVDKit.h"

@implementation DVDProgramChainSearchPointer
@synthesize entryId;
@synthesize programChain;

+ (id) programChainSearchPointerWithEntryId:(uint8_t)entry_id parentalMask:(uint16_t)ptl_id_mask programChain:(DVDProgramChain*)programChain
{
    return [[[DVDProgramChainSearchPointer alloc] initWithEntryId:entry_id parentalMask:ptl_id_mask programChain:programChain] autorelease];
}

- (id) initWithEntryId:(uint8_t)_entry_id parentalMask:(uint16_t)_ptl_id_mask programChain:(DVDProgramChain*)_programChain
{
    if (self = [super init]) {
        entryId = _entry_id;
        ptl_id_mask = _ptl_id_mask;
        programChain = [_programChain retain];
    }
    return self;
}

- (void) dealloc
{
    [programChain release];
    [super dealloc];
}

@end
