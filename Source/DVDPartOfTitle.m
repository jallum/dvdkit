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

@implementation DVDPartOfTitle
@synthesize programChainNumber;
@synthesize programNumber;

+ (id) partOfTitleWithProgramChain:(uint16_t)programChain program:(uint16_t)program
{
    return [[[DVDPartOfTitle alloc] initWithProgramChain:programChain program:program] autorelease];
}

- (id) initWithProgramChain:(uint16_t)_programChain program:(uint16_t)_program
{
    if (self = [super init]) {
        programChainNumber = _programChain;
        programNumber = _program;
    }
    return self;
}

@end
