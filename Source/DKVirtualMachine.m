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
#import <sys/time.h>

NSString* const DVDVirtualMachineException = @"DVDVirtualMachine";

#ifndef DEBUG
#define NSLog(...)    
#endif

enum {
    STOP,
    FIRST_PLAY,
    PGC_CHANGED,
    PGC_START,
    PGC_PRE_COMMANDS,
    PGC_BREAK,
    PGC_PROGRAM,
    PGC_CELL,
    PGC_PGN_SET,
    PGC_CELL_POST,
    PGC_POST_COMMANDS,
};

@interface DKVirtualMachine (Private)
@property (readonly) NSArray* pgcit;
- (void) executeCommand:(DKCommand*)command;
- (void) executeCommands:(NSArray*)commands withState:(int)_state;
@end

@implementation DKVirtualMachine
@synthesize titleSet;
@synthesize domain;
@synthesize delegate;
@synthesize userInfo;
@synthesize programChain;
@synthesize prohibitedUserOperations;

+ (int) programNumberForCell:(int)cell usingMap:(NSArray*)map
{
    int pgcn = 1;
    for (NSNumber* n in map) {
        if (cell >= [n intValue]) {
            break;
        }
        pgcn++;
    }
    return pgcn;
}

+ (int) partOfTitleForProgramNumber:(int)programNumber usingSearchTable:(NSArray*)searchTable 
{
    int pttn = 1;
    for (DKPartOfTitle* partOfTitle in searchTable) {
        if (programNumber >= [partOfTitle programNumber]) {
            break;
        }
    }
    return pttn;
}

+ (id) virtualMachineWithDataSource:(id)dataSource
{
    return [[[DKVirtualMachine alloc] initWithDataSource:dataSource] autorelease];
}

- (id) initWithDataSource:(id)_dataSource;
{
    NSAssert(_dataSource, @"Shouldn't be nil");
    if (self = [super init]) {
        dataSource = [_dataSource retain];

        bzero(SPRM, sizeof(SPRM));
        bzero(GPRM, sizeof(GPRM));

        SPRM[0]  = 0x656E;          /* Player Menu Languange code */
        SPRM[1]  = 15;              /* 15 == NONE */
        SPRM[2]  = 62;              /* 62 == NONE */
        SPRM[3]  = 1;
        SPRM[7]  = 1;
        SPRM[8]  = 1 << 10;
        SPRM[12] = ('U'<<8)|'S';    /* Parental Management Country Code */
        SPRM[13] = 15;              /* Parental Level */
        SPRM[14] = 0x0C00;          /* Try Pan&Scan */
        SPRM[16] = 0x656E;          /* Initial Language Code for Audio */
        SPRM[18] = 0x656E;          /* Initial Language Code for Spu */

        state = FIRST_PLAY;
    }
    return self;
}

- (void) dealloc
{
    [dataSource release];
    [mainMenuInformation release];
    [titleSet release];
    [programChain release];
    [titleInformation release];
    [userInfo release];
    [delegate release];
    [super dealloc];
}

- (id) mutableCopyWithZone:(NSZone*)zone
{
    DKVirtualMachine* copy = NSCopyObject(self, 0, zone);
    if (copy) {
        [copy->dataSource retain];
        [copy->mainMenuInformation retain];
        [copy->titleSet retain];
        [copy->programChain retain];
        [copy->titleInformation retain];
        [copy->userInfo retain];
        [copy->delegate retain];
    }
    return copy;
}

- (void) setDelegate:(id)_delegate
{
    if (delegate != _delegate) {
        [delegate release];
        delegate = [_delegate retain];

        delegateHasWillExecuteProgramChain = [delegate respondsToSelector:@selector(virtualMachine:willExecuteProgramChain:)];
        delegateHasWillExecuteCommandAtIndexOfSectionForProgramChain = [delegate respondsToSelector:@selector(virtualMachine:willExecuteCommandAtIndex:ofSection:forProgramChain:)];
    }
}

- (DKMainMenuInformation*) mainMenuInformation
{
    if (!mainMenuInformation) {
        mainMenuInformation = [[dataSource mainMenuInformation] retain];
        if (!mainMenuInformation) {
            [NSException raise:DVDVirtualMachineException format:@"Video manager information is required"];
        }
    }
    return mainMenuInformation;
}

- (DKUserOperationFlags) prohibitedUserOperations
{
    return [programChain prohibitedUserOperations];
}

- (BOOL) trackingRegisterUsage
{
    return SPRM_mask || GPRM_mask;
}

- (BOOL) usedSystemParameterRegister:(uint8_t)index
{
    return (((SPRM_read | SPRM_write) & SPRM_mask) & (1 << index)) > 0;
}

- (void) setTrackUsage:(BOOL)value forSystemParameterRegister:(uint8_t)index
{
    NSAssert(index < 24, @"Valid range of registers is 0-23.");
    uint32_t mask = 1 << index;
    if (value) {
        SPRM_mask |= mask;
        SPRM_read &= ~mask;
        SPRM_write &= ~mask;
    } else {
        SPRM_mask &= ~mask;
    }
}

- (id) state
{
    NSMutableData* data = [NSMutableData dataWithLength:(3 * 4) + (16 * 2) + (4 * 2) + (3 * 2) + (5 * 2)];
    uint8_t* bytes = [data mutableBytes];
    
    OSWriteBigInt32(bytes, 0, SPRM_mask);
    OSWriteBigInt32(bytes, 4, SPRM_read);
    OSWriteBigInt32(bytes, 8, SPRM_write);
    bytes += 3 * 4;
    
    for (int i = 0; i < 16; i++, bytes += 2) {
        OSWriteBigInt16(bytes, 0, GPRM[i]);
    }

    OSWriteBigInt16(bytes, 0, SPRM[7]);
    OSWriteBigInt16(bytes, 2, SPRM[8]);
    OSWriteBigInt16(bytes, 4, SPRM[14]);
    OSWriteBigInt16(bytes, 6, SPRM[20]);
    bytes += 4 * 2;

    OSWriteBigInt16(bytes, 0, resume.enabled);
    OSWriteBigInt16(bytes, 2, resume.cell);
    OSWriteBigInt16(bytes, 4, resume.vts);
    bytes += 3 * 2;

    for (int i = 0; i < 5; i++, bytes += 2) {
        OSWriteBigInt16(bytes, 0, resume.REGS[i]);
    }
    
    return data;
}

- (DKCellPlayback*) nextCellPlayback
{
    @try {
        int watchdog = 0;
        SPRM_read = SPRM_write = 0;
        GPRM_read = GPRM_write = 0;
        while (state != STOP) {
            switch (state) {
                case FIRST_PLAY: {
                    domain = kDKDomainFirstPlay;
                    [programChain release];
                    programChain = [[[self mainMenuInformation] firstPlayProgramChain] retain];
                    [titleSet release];
                    titleSet = nil;
                    if (delegateHasWillExecuteProgramChain) {
                        [delegate virtualMachine:self willExecuteProgramChain:programChain];
                    }
                    state = PGC_START;
                    break;
                }
                
                case PGC_CHANGED: {
                    [programChain release];
                    programChain = [[[[self pgcit] objectAtIndex:(SPRM[6] - 1)] programChain] retain];
                    if (delegateHasWillExecuteProgramChain) {
                        [delegate virtualMachine:self willExecuteProgramChain:programChain];
                    }
                    state = PGC_START;
                    break;
                }
                
                case PGC_START: {
                    state = PGC_PRE_COMMANDS;
                    break;
                }
                
                case PGC_PRE_COMMANDS: {
                    [self executeCommands:[programChain preCommands] withState:PGC_PRE_COMMANDS];
                    if (state == PGC_PRE_COMMANDS || state == PGC_BREAK) {
                        state = PGC_PROGRAM;
                    }
                    break;
                }
                
                case PGC_PROGRAM: {
                    if (domain == kDKDomainVideoTitleSet) {
                        programNumber = [[[[titleSet partOfTitleSearchTable] objectAtIndex:(SPRM[5] - 1)] objectAtIndex:(SPRM[7] - 1)] programNumber];
                    } else {
                        programNumber = 1;
                    }
                    state = PGC_PGN_SET;
                    break;
                }
                
                case PGC_PGN_SET: {
                    NSArray* programMap = [programChain programMap];
                    if (programNumber && (programNumber <= [programMap count])) {
                        cell = [[programMap objectAtIndex:(programNumber - 1)] intValue];
                        state = PGC_CELL;
                    } else {
                        cell = programNumber = 0;
                        state = PGC_POST_COMMANDS;
                    }
                    break;
                }
                
                case PGC_CELL: {
                    NSArray* programMap = [programChain programMap];
                    int newProgramNumber = 0;
                    const int maxProgramNumber = [programMap count];
                    while (newProgramNumber < maxProgramNumber && cell >= [[programMap objectAtIndex:newProgramNumber] intValue]) {
                        newProgramNumber++;
                    }
                    NSArray* cellPlaybackTable = [programChain cellPlaybackTable];
                    if (newProgramNumber == maxProgramNumber && cell > [cellPlaybackTable count]) {
                        cell = programNumber = 0;
                        state = PGC_POST_COMMANDS;
                        break;
                    } else {
                        programNumber = newProgramNumber;
                        if (domain == kDKDomainVideoTitleSet) {
                            SPRM[7] = [DKVirtualMachine partOfTitleForProgramNumber:programNumber usingSearchTable:[[titleSet partOfTitleSearchTable] objectAtIndex:(SPRM[5] - 1)]];
                        }
                        state = PGC_CELL_POST;
                        return [[[cellPlaybackTable objectAtIndex:(cell - 1)] retain] autorelease];
                    }
                }
                
                case PGC_CELL_POST: {
                    NSArray* cellPlaybackTable = [programChain cellPlaybackTable];
                    DKCellPlayback* cellPlayback = [cellPlaybackTable objectAtIndex:(cell - 1)];
                    const int index = [cellPlayback postCommandIndex];
                    NSArray* cellCommands = [programChain cellCommands];
                    if (index && (index <= [cellCommands count])) {
                        DKCommand* command = [cellCommands objectAtIndex:(index - 1)];
                        if (delegateHasWillExecuteCommandAtIndexOfSectionForProgramChain) {
                            [delegate virtualMachine:self willExecuteCommandAtIndex:(index - 1) ofSection:kDKProgramChainSectionCellCommand forProgramChain:programChain];
                        }
                        [self executeCommand:command];
                    }
                    if (state == PGC_CELL_POST) {
                        cell++;
                        state = PGC_CELL;
                    }
                    break;
                }

                case PGC_POST_COMMANDS: {
                    [self executeCommands:[programChain postCommands] withState:PGC_POST_COMMANDS];
                    if (state == PGC_POST_COMMANDS || state == PGC_BREAK || (state == PGC_PGN_SET && (1 > programNumber || programNumber > [[programChain programMap] count]))) {
                        uint16_t nextProgramChainNumber = [programChain nextProgramChainNumber];
                        if (nextProgramChainNumber) {
                            SPRM[6] = nextProgramChainNumber;
                            state = PGC_CHANGED;
                        } else {
                            state = STOP;
                        }
                    }
                    break;
                }
            }

            if (++watchdog == 10000) {
                NSLog(@"Watchdog instruction count exceeded.  Stopping.");
                state = STOP;
            }
        }
    } @catch (NSException* exception) {
        [exception raise];
    }
    return nil;
}

- (uint16_t) peekGeneralPurposeRegister:(uint8_t)index
{
    if (index >= 16) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    return GPRM[index];
}

- (uint16_t) generalPurposeRegister:(uint8_t)index
{
    if (index >= 16) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    GPRM_read |= (1 << index);
    return GPRM[index];
}

- (uint16_t) peekSystemParameterRegister:(uint8_t)index
{
    if (index >= 24) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    return SPRM[index];
}

- (uint16_t) systemParameterRegister:(uint8_t)index
{
    if (index >= 24) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    SPRM_read |= (1 << index);
    return SPRM[index];
}

- (void) setValue:(uint16_t)value forGeneralPurposeRegister:(uint8_t)index
{
    if (index >= 16) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    GPRM_write |= (1 << index);
    GPRM[index] = value & 0xFFFF;
}

- (void) setValue:(uint16_t)value forSystemParameterRegister:(uint8_t)index
{
    if (index >= 24) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    SPRM_write |= (1 << index);
    SPRM[index] = value & 0xFFFF;
}

- (void) setMode:(BOOL)mode forGeneralPurposeRegister:(uint8_t)index
{
    if (index >= 16) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    /* Do I need to implement this? */
}

- (void) stop
{
    state = STOP;
}

- (void) setTmpPML:(uint8_t)pml line:(uint8_t)line
{
}

- (void) executeGoto:(uint8_t)_line
{
    instructionCounter = _line - 1;
}

- (void) executeBreak
{
    state = PGC_BREAK;
}

- (void) executeJumpTT:(uint8_t)tt
{
    [titleInformation release];
    titleInformation = [[[[self mainMenuInformation] titleTrackSearchPointerTable] objectAtIndex:(tt - 1)] retain];
    SPRM[4] = [titleInformation index];
    uint16_t vts = [titleInformation title_set_nr];
    uint16_t ttn = [titleInformation vts_ttn];
    if (!titleSet || [titleSet index] != vts) {
        [titleSet release];
        titleSet = [[dataSource titleSetInformationAtIndex:vts] retain];
    }
    [self executeJumpVTS_TT:ttn];
}

- (void) executeJumpVTS_TT:(uint8_t)ttn
{
    [self executeJumpVTS_PTT:ttn pttn:1];
}

- (void) executeJumpVTS_PTT:(uint8_t)ttn pttn:(uint16_t)pttn
{
    if (SPRM[4] != [titleInformation index]) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    NSArray* partOfTitleSearchTable = [titleSet partOfTitleSearchTable];
    if (!ttn || ttn > [partOfTitleSearchTable count]) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    NSArray* partOfTitleTable = [partOfTitleSearchTable objectAtIndex:(ttn - 1)];
    if (!pttn || pttn > [partOfTitleTable count]) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    DKPartOfTitle* partOfTitle = [partOfTitleTable objectAtIndex:(pttn - 1)];
    resume.enabled &= (domain == kDKDomainVideoTitleSet);
    domain = kDKDomainVideoTitleSet;
    /**/
    SPRM[5] = ttn;
    SPRM[6] = [partOfTitle programChainNumber];
    SPRM[7] = pttn;
    /**/
    state = PGC_CHANGED;
}

- (void) executeJumpSS_FP
{
    resume.enabled = NO;
    state = FIRST_PLAY;
}

- (void) executeJumpSS_VTSM_menu:(uint8_t)menu vts:(uint8_t)vts ttn:(uint8_t)ttn
{
    if (vts) {
        if (!titleSet || [titleSet index] != vts) {
            [titleSet release];
            titleSet = [[dataSource titleSetInformationAtIndex:vts] retain];
        }
    } else {
        vts = [titleSet index];
    }
    [titleInformation release];
    titleInformation = [[[self mainMenuInformation] titleTrackSearchPointerForTitleSet:vts track:ttn] retain];
    resume.enabled &= (domain == kDKDomainVideoTitleSetMenu);
    domain = kDKDomainVideoTitleSetMenu;
    DKProgramChainSearchPointer* foundSearchPointer = nil;
    uint8_t entryId = 0x80 | menu;
    NSArray* pgcit = [self pgcit];
    for (DKProgramChainSearchPointer* pcsp in pgcit) {
        if ([pcsp entryId] == entryId) {
            foundSearchPointer = pcsp;
            break;
        }
    }
    if (!foundSearchPointer) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    /**/
    SPRM[4] = [titleInformation index];
    SPRM[5] = ttn;
    SPRM[6] = 1 + [pgcit indexOfObject:foundSearchPointer];
    SPRM[7] = 0;
    /**/
    state = PGC_CHANGED;
}

- (void) executeJumpSS_VMGM_menu:(uint8_t)menu
{
    resume.enabled &= (domain == kDKDomainVideoManagerMenu);
    domain = kDKDomainVideoManagerMenu;
    DKProgramChainSearchPointer* foundSearchPointer = nil;
    uint8_t entryId = 0x80 | menu;
    NSArray* pgcit = [self pgcit];
    for (DKProgramChainSearchPointer* pcsp in pgcit) {
        if ([pcsp entryId] == entryId) {
            foundSearchPointer = pcsp;
            break;
        }
    }
    if (!foundSearchPointer) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    [titleSet release];
    titleSet = nil;
    [titleInformation release];
    titleInformation = nil;
    /**/
    SPRM[4] = 0;
    SPRM[5] = 0;
    SPRM[6] = 1 + [pgcit indexOfObject:foundSearchPointer];
    SPRM[7] = 0;
    /**/
    state = PGC_CHANGED;
}

- (void) executeJumpSS_VMGM_pgcn:(uint16_t)pgcn
{
    resume.enabled &= (domain == kDKDomainVideoManagerMenu);
    domain = kDKDomainVideoManagerMenu;
    [titleSet release];
    titleSet = nil;
    [titleInformation release];
    titleInformation = nil;
    /**/
    SPRM[4] = 0;
    SPRM[5] = 0;
    SPRM[6] = pgcn;
    SPRM[7] = 0;
    /**/
    state = PGC_CHANGED;
}

- (void) _saveResumeInfoWithCell:(int)_cell
{
    resume.domain = domain;
    resume.vts = [titleInformation title_set_nr];
    resume.cell = _cell;
    for (int i = 0; i < 5; i++) {
        resume.REGS[i] = SPRM[4 + i];
    }
}

- (void) executeCallSS_FP
{
    [self _saveResumeInfoWithCell:0];
    [self executeJumpSS_FP];
    resume.enabled = YES;
}

- (void) executeCallSS_VMGM_menu:(uint8_t)menu resumeCell:(uint8_t)_cell
{
    [self _saveResumeInfoWithCell:_cell];
    [self executeJumpSS_VMGM_menu:menu];
    resume.enabled = YES;
}

- (void) executeCallSS_VTSM_menu:(uint8_t)menu resumeCell:(uint8_t)_cell
{
    [self _saveResumeInfoWithCell:_cell];
    [self executeJumpSS_VTSM_menu:menu vts:[titleSet index] ttn:1];
    resume.enabled = YES;
}

- (void) executeCallSS_VMGM_pgcn:(uint16_t)pgcn resumeCell:(uint8_t)_cell
{
    [self _saveResumeInfoWithCell:_cell];
    [self executeJumpSS_VMGM_pgcn:pgcn];
    resume.enabled = YES;
}

- (void) executeLinkPGCN:(uint16_t)pgcn
{
    SPRM[6] = pgcn;
    state = PGC_CHANGED;
}

- (void) executeLinkPTTN:(uint16_t)pttn
{
    if (domain != kDKDomainVideoTitleSet) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    if (!titleSet) {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    DKPartOfTitle* partOfTitle = [[[titleSet partOfTitleSearchTable] objectAtIndex:(SPRM[5] - 1)] objectAtIndex:(pttn - 1)];
    SPRM[6] = [partOfTitle programChainNumber];
    SPRM[7] = pttn;
    /**/
    programNumber = [partOfTitle programNumber];
    state = PGC_PGN_SET;
}

- (void) executeLinkPGN:(uint8_t)pgn
{
    programNumber = pgn;
    state = PGC_PGN_SET;
}

- (void) executeLinkCell:(uint8_t)_cell
{
    cell = _cell;
    state = PGC_CELL;
}

- (void) executeLinkTopCell
{
    cell = [[[programChain programMap] objectAtIndex:programNumber - 1] intValue];
    state = PGC_CELL;
}

- (void) executeLinkNextCell
{
    state = PGC_CELL_POST;
}

- (void) executeLinkPrevCell
{
    cell--;
    state = PGC_CELL;
}

- (void) executeLinkTopPG
{
    programNumber = 1;
    state = PGC_PGN_SET;
}

- (void) executeLinkNextPG
{
    programNumber++;
    state = PGC_PGN_SET;
}

- (void) executeLinkPrevPG
{
    if (programNumber > 1) {
        programNumber--;
    }
    state = PGC_PGN_SET;
}

- (void) executeLinkTopPGC
{
    state = PGC_CHANGED;
}

- (void) executeLinkNextPGC
{
    SPRM[6] = [programChain nextProgramChainNumber];
    state = PGC_CHANGED;
}

- (void) executeLinkPrevPGC
{
    SPRM[6] = [programChain previousProgramChainNumber];
    state = PGC_CHANGED;
}

- (void) executeLinkGoUpPGC
{
    SPRM[6] = [programChain goUpProgramChainNumber];
    state = PGC_CHANGED;
}

- (void) executeLinkTailPGC
{
    state = PGC_POST_COMMANDS;
}

- (void) executeRSM
{
    if (resume.enabled && (domain == kDKDomainVideoManagerMenu || domain == kDKDomainVideoTitleSetMenu)) {
        for (int i = 0; i < 5; i++) {
            SPRM[4 + i] = resume.REGS[i];
        }
        domain = resume.domain;
        if (resume.vts != [titleSet index]) {
            [titleSet release];
            if (domain == kDKDomainVideoTitleSet) {
                titleSet = [[dataSource titleSetInformationAtIndex:resume.vts] retain];
            } else {
                titleSet = nil;
            }
        }
        [programChain release];
        programChain = [[[[self pgcit] objectAtIndex:(SPRM[6] - 1)] programChain] retain];
        if (resume.cell) {
            cell = resume.cell;
            programNumber = [DKVirtualMachine programNumberForCell:cell usingMap:[programChain programMap]];
            state = PGC_CELL;
        } else {
            state = PGC_START;
        }
        resume.enabled = NO;
    } else {
        state = STOP;
    }
}

- (BOOL) resumeEnabled
{
    return resume.enabled;
}

@end

@implementation DKVirtualMachine (Private)

- (NSArray*) pgcit 
{
    switch (domain) {
        case kDKDomainVideoTitleSet: {
            return [titleSet programChainInformationTable];
        }
        case kDKDomainVideoTitleSetMenu: {
            return [titleSet menuProgramChainInformationTableForLanguageCode:SPRM[0]];
        }
        case kDKDomainVideoManagerMenu:
        case kDKDomainFirstPlay: {
            return [[self mainMenuInformation] menuProgramChainInformationTableForLanguageCode:SPRM[0]];
        }
    }
    [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    return nil; /* Not Reached */
}

- (void) executeCommand:(DKCommand*)command
{
    [command executeAgainstVirtualMachine:self];
}

- (void) executeCommands:(NSArray*)commands withState:(int)_state
{
    const int maxCommand = [commands count];
    int section;
    if (_state == PGC_PRE_COMMANDS) {
        section = kDKProgramChainSectionPreCommand;
    } else if (_state == PGC_POST_COMMANDS) {
        section = kDKProgramChainSectionPostCommand;
    } else {
        [NSException raise:DVDVirtualMachineException format:@"%s (%d)", __FILE__, __LINE__];
    }
    for (instructionCounter = 0; (state == _state) && instructionCounter < maxCommand; ) {
        DKCommand* command = [commands objectAtIndex:instructionCounter];
        if (delegateHasWillExecuteCommandAtIndexOfSectionForProgramChain) {
            [delegate virtualMachine:self willExecuteCommandAtIndex:instructionCounter ofSection:section forProgramChain:programChain];
        }
        instructionCounter++;
        [self executeCommand:command];
    }
}

@end