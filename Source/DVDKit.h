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
#import <Foundation/Foundation.h>

@protocol DKDataSource
- (NSData*) requestDataOfLength:(uint32_t)length fromOffset:(uint32_t)offset;
@end

typedef struct DKTime DKTime;
struct DKTime {
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
    uint8_t frame_u; /* The two high bits are the frame rate. */
} __attribute__ ((packed));

typedef struct DKCommandBytes DKCommandBytes;
struct DKCommandBytes {
    uint8_t bytes[8];
} __attribute__ ((packed));

typedef struct DKUserOperationFlags DKUserOperationFlags;
struct DKUserOperationFlags {
    uint32_t
#if BYTE_ORDER == LITTLE_ENDIAN
    /* 31 - 24 */
    video_pres_mode_change : 1,
    __zero_1 : 7,
    
    /* 23 - 16 */
    resume : 1,
    button_select_or_activate : 1,
    still_off : 1,
    pause_on : 1,
    audio_stream_change : 1,
    subpic_stream_change : 1,
    angle_change : 1,
    karaoke_audio_pres_mode_change : 1,
    
    /* 15 - 8 */
    forward_scan : 1,
    backward_scan : 1,
    title_menu_call : 1,
    root_menu_call : 1,
    subpic_menu_call : 1,
    audio_menu_call : 1,
    angle_menu_call : 1,
    chapter_menu_call : 1,
    
    /* 7 - 0 */ 
    title_or_time_play : 1,
    chapter_search_or_play : 1,
    title_play : 1,
    stop : 1,
    go_up : 1,
    time_or_chapter_search : 1,
    prev_or_top_pg_search : 1,
    next_pg_search : 1;
#else
    /* 24 - 31 */
    __zero_1 : 7,
    video_pres_mode_change : 1,
    
    /* 16 - 23 */
    karaoke_audio_pres_mode_change : 1,
    angle_change : 1,
    subpic_stream_change : 1,
    audio_stream_change : 1,
    pause_on : 1,
    still_off : 1,
    button_select_or_activate : 1,
    resume : 1,
    
    /* 8 - 15 */
    chapter_menu_call : 1,
    angle_menu_call : 1,
    audio_menu_call : 1,
    subpic_menu_call : 1,
    root_menu_call : 1,
    title_menu_call : 1,
    backward_scan : 1,
    forward_scan : 1,
    
    /* 0 - 7 */ 
    next_pg_search : 1,
    prev_or_top_pg_search : 1,
    time_or_chapter_search : 1,
    go_up : 1,
    stop : 1,
    title_play : 1,
    chapter_search_or_play : 1,
    title_or_time_play : 1;
#endif
} __attribute__ ((packed));

typedef struct DKPlaybackFlags DKPlaybackFlags;
struct DKPlaybackFlags {
    uint8_t 
#if BYTE_ORDER == LITTLE_ENDIAN
    title_or_time_play : 1,                 
    chapter_search_or_play : 1,             
    jlc_exists_in_tt_dom : 1,               
    jlc_exists_in_button_cmd : 1,           
    jlc_exists_in_prepost_cmd : 1,          
    jlc_exists_in_cell_cmd : 1,             
    multi_or_random_pgc_title : 1,
    __zero_1 : 1;
#else
    __zero_1 : 1,
    multi_or_random_pgc_title : 1,
    jlc_exists_in_cell_cmd : 1,             
    jlc_exists_in_prepost_cmd : 1,          
    jlc_exists_in_button_cmd : 1,           
    jlc_exists_in_tt_dom : 1,               
    chapter_search_or_play : 1,             
    title_or_time_play : 1;
#endif
} __attribute__ ((packed));

typedef enum {
    kDKDomainFirstPlay = 1,
    kDKDomainVideoTitleSet = 2,
    kDKDomainVideoManagerMenu = 4,
    kDKDomainVideoTitleSetMenu = 8
} DKDomain;

typedef enum {
    kDKAspectRatioUnknown = -1,
    /**/
    kDKAspectRatio4By3 = 0,
    kDKAspectRatio16By9 = 3,
} DKAspectRatio;

typedef enum {
    kDKVideoFormatUnknown = -1,
    /**/
    kDKVideoFormatNTSC = 0,
    kDKVideoFormatPAL = 1,
} DKVideoFormat;

typedef enum {
    kDKMPEGVersion1 = 0,
    kDKMPEGVersion2 = 1,
} DKMPEGVersion;

typedef enum {
    kDKPictureSizeUnknown = -1,
    
    /* NTSC */
    kDKPictureSize720x480,
    kDKPictureSize704x480,
    kDKPictureSize352x480,
    kDKPictureSize352x240,
    
    /* PAL */
    kDKPictureSize720x576,
    kDKPictureSize704x576,
    kDKPictureSize352x576,
    kDKPictureSize352x288,
} DKPictureSize;

typedef enum {
    kDKAudioFormatAC3 = 0,
    kDKAudioFormatMPEG1 = 2,
    kDKAudioFormatMPEG2Extended = 3,
    kDKAudioFormatLPCM = 4,
    kDKAudioFormatDTS = 6,
} DKAudioFormat;

typedef enum {
    kDKAudioApplocationModeUnspecified = 0,
    kDKAudioApplocationModeKaraoke = 1,
    kDKAudioApplocationModeSurroundSound = 2,
} DKAudioApplicationMode;

typedef enum {
    kDKBlockTypeNone = 0,
    kDKBlockTypeAngle = 1,
} DKBlockType;

typedef enum {
    kDKBlockModeNotInBlock = 0,
    kDKBlockModeFirstCell = 1,
    kDKBlockModeInBlock = 2,
    kDKBlockModeLastCell = 3,
} DKBlockMode;


#import "DKVirtualMachine.h"
#import "DKMainMenuInformation.h"
#import "DKTitleSetInformation.h"
#import "DKProgramChain.h"
#import "DKProgramChainSearchPointer.h"
#import "DKCellAddress.h"
#import "DKCellPlayback.h"
#import "DKCommand.h"
#import "DKCellPosition.h"
#import "DKPartOfTitle.h"
#import "DKTitleTrackSearchPointer.h"
#import "DKVideoAttributes.h"
#import "DKSubpictureAttributes.h"
#import "DKAudioAttributes.h"
