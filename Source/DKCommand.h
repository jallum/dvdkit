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

@class DKVirtualMachine;

@interface DKCommand : NSObject {
    uint64_t bits;
    uint64_t mask;
    int row;
    NSMutableString* description;
}

@property (readonly) uint64_t bits;
@property (readonly) uint64_t mask;
@property (readonly) int row;



+ (id) commandWith64Bits:(uint64_t)bits;
+ (id) commandWith64Bits:(uint64_t)bits row:(int)row;

+ (id) commandWithData:(NSData*)data;
+ (id) commandWithData:(NSData*)data row:(int)row;

- (id) initWith64Bits:(uint64_t)bits row:(int)row;
- (id) initWithData:(NSData*)data row:(int)row;

- (void) executeAgainstVirtualMachine:(DKVirtualMachine*)virtualMachine;

- (uint32_t) bitsInRange:(NSRange)range;
- (NSString*) description;

@end

extern NSString* const DVDCommandException;
