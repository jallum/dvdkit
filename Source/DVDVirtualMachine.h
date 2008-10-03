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

@class DVDManagerInformation;
@class DVDProgramChain;
@class DVDTitleTrackSearchPointer;
@class DVDTitleSet;
@class DVDCellPlayback;
@class DVDCommand;

@interface DVDVirtualMachine : NSObject <NSMutableCopying> {
    id dataSource;
    uint16_t SPRM[24];
    uint16_t GPRM[16];
    uint32_t SPRM_read;
    uint32_t GPRM_read;
    uint32_t SPRM_mask;
    uint32_t SPRM_write;
    uint32_t GPRM_write;
    uint32_t GPRM_mask;
    /**/
    struct {
        BOOL enabled;
        int cell;
        int vts;
        dvd_domain_t domain;
        uint32_t REGS[5];
    } resume;
    /**/
    DVDManagerInformation* videoManagerInformation;
    int state;
    /**/
    dvd_domain_t domain;
    DVDTitleSet* titleSet;
    DVDProgramChain* programChain;
    int programNumber;
    int instructionCounter;
    DVDTitleTrackSearchPointer* titleInformation;
    int cell;
    id userInfo;
}

+ (id) virtualMachineWithDataSource:(id)delegate;

- (id) initWithDataSource:(id)delegate;

@property (readonly) dvd_user_ops_t prohibitedUserOperations;
@property (readonly) DVDTitleSet* titleSet;
@property (readonly) dvd_domain_t domain;
@property (readonly) BOOL trackingRegisterUsage;
@property (retain) id userInfo;

- (id) state;

- (DVDCellPlayback*) nextCellPlayback;

- (BOOL) usedSystemParameterRegister:(uint8_t)index;

- (uint16_t) peekGeneralPurposeRegister:(uint8_t)index;
- (uint16_t) peekSystemParameterRegister:(uint8_t)index;

- (uint16_t) generalPurposeRegister:(uint8_t)index;
- (uint16_t) systemParameterRegister:(uint8_t)index;

- (void) setValue:(uint16_t)value forGeneralPurposeRegister:(uint8_t)index;
- (void) setValue:(uint16_t)value forSystemParameterRegister:(uint8_t)index;

- (void) setTrackUsage:(BOOL)value forSystemParameterRegister:(uint8_t)index;

- (void) setMode:(BOOL)mode forGeneralPurposeRegister:(uint8_t)index;
- (void) setTmpPML:(uint8_t)pml line:(uint8_t)line;

- (void) stop;
- (void) executeGoto:(uint8_t)line;
- (void) executeBreak;
- (void) executeJumpTT:(uint8_t)ttn;
- (void) executeJumpVTS_TT:(uint8_t)ttn;
- (void) executeJumpVTS_PTT:(uint8_t)ttn pttn:(uint16_t)pttn;
- (void) executeJumpSS_FP;
- (void) executeJumpSS_VMGM_menu:(uint8_t)menu;
- (void) executeJumpSS_VTSM_menu:(uint8_t)menu vts:(uint8_t)vts ttn:(uint8_t)ttn;
- (void) executeJumpSS_VMGM_pgcn:(uint16_t)pgcn;
- (void) executeCallSS_FP;
- (void) executeCallSS_VMGM_menu:(uint8_t)menu resumeCell:(uint8_t)cell;
- (void) executeCallSS_VTSM_menu:(uint8_t)menu resumeCell:(uint8_t)cell;
- (void) executeCallSS_VMGM_pgcn:(uint16_t)pgcn resumeCell:(uint8_t)cell;
- (void) executeLinkPGCN:(uint16_t)pgcn;
- (void) executeLinkPTTN:(uint16_t)pttn;
- (void) executeLinkPGN:(uint8_t)pgn;
- (void) executeLinkCell:(uint8_t)cn;
- (void) executeLinkTopCell;
- (void) executeLinkNextCell;
- (void) executeLinkPrevCell;
- (void) executeLinkTopPG;
- (void) executeLinkNextPG;
- (void) executeLinkPrevPG;
- (void) executeLinkTopPGC;
- (void) executeLinkNextPGC;
- (void) executeLinkPrevPGC;
- (void) executeLinkGoUpPGC;
- (void) executeLinkTailPGC;
- (void) executeRSM;

@end

@interface NSObject (VirtualMachineDataSource)

- (DVDManagerInformation*) videoManagerInformation;
- (DVDTitleSet*) titleSetAtIndex:(NSInteger)index;

@end
