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

@interface DVDVirtualMachine (DVDCommand)
- (uint16_t) registerForCode:(uint8_t)rn;
- (void) setValue:(uint16_t)value forRegisterForCode:(uint8_t)rn;
- (void) conditionallySetHighlightedButton:(uint8_t)btn;
- (void) executeLinkSubset:(uint8_t)code;
@end

@interface DVDCommand (Private)
- (uint32_t) bitsInRange:(NSRange)range;
- (int) executeComparison:(uint8_t)comparison value1:(uint16_t)value1 value2:(uint16_t)value2;
- (uint16_t) computeOp:(uint8_t)op value1:(uint16_t)value1 value2:(uint16_t)value2;
@end
