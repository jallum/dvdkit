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


@implementation DKPartOfTitle
@synthesize programChainNumber;
@synthesize programNumber;


+ (id) partOfTitleWithData:(NSData*)data error:(NSError**)error
{
    return [[[DKPartOfTitle alloc] initWithData:data error:error] autorelease];
}

- (id) initWithData:(NSData*)data error:(NSError**)error
{
    NSAssert(data, @"wtf?");
    NSAssert([data length] >= sizeof(ptt_info_t), @"wtf?");
    if (self = [super init]) {
        const ptt_info_t* ptt_info = [data bytes];
    
        programChainNumber = OSReadBigInt16(&ptt_info->pgcn, 0);
        programNumber = OSReadBigInt16(&ptt_info->pgn, 0);
    }
    return self;
}

- (NSData*) saveAsData:(NSError**)error
{
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(ptt_info_t)];
    ptt_info_t* ptt_info = [data mutableBytes];
    
    OSWriteBigInt16(&ptt_info->pgcn, 0, programChainNumber);
    OSWriteBigInt16(&ptt_info->pgn, 0, programNumber);
    
    return data;
}

@end
