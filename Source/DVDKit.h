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

typedef struct {
    uint8_t hour;
    uint8_t minute;
    uint8_t second;
    uint8_t frame_u; /* The two high bits are the frame rate. */
} dvd_time_t;

typedef struct {
    uint8_t bytes[8];
} __attribute__ ((packed)) dvd_cmd_t;


typedef union {
    uint32_t bits;
    struct {
#if BYTE_ORDER == LITTLE_ENDIAN
        /* 0 - 7 */ 
        unsigned int title_or_time_play             : 1;
        unsigned int chapter_search_or_play         : 1;
        unsigned int title_play                     : 1;
        unsigned int stop                           : 1;
        unsigned int go_up                          : 1;
        unsigned int time_or_chapter_search         : 1;
        unsigned int prev_or_top_pg_search          : 1;
        unsigned int next_pg_search                 : 1;
        
        /* 8 - 15 */
        unsigned int forward_scan                   : 1;
        unsigned int backward_scan                  : 1;
        unsigned int title_menu_call                : 1;
        unsigned int root_menu_call                 : 1;
        unsigned int subpic_menu_call               : 1;
        unsigned int audio_menu_call                : 1;
        unsigned int angle_menu_call                : 1;
        unsigned int chapter_menu_call              : 1;
        
        /* 16 - 23 */
        unsigned int resume                         : 1;
        unsigned int button_select_or_activate      : 1;
        unsigned int still_off                      : 1;
        unsigned int pause_on                       : 1;
        unsigned int audio_stream_change            : 1;
        unsigned int subpic_stream_change           : 1;
        unsigned int angle_change                   : 1;
        unsigned int karaoke_audio_pres_mode_change : 1;
        
        /* 24 - 31 */
        unsigned int video_pres_mode_change         : 1;
        unsigned int zero                           : 7;
#else
        /* 31 - 24 */
        unsigned int zero                           : 7;
        unsigned int video_pres_mode_change         : 1;
        
        /* 23 - 16 */
        unsigned int karaoke_audio_pres_mode_change : 1;
        unsigned int angle_change                   : 1;
        unsigned int subpic_stream_change           : 1;
        unsigned int audio_stream_change            : 1;
        unsigned int pause_on                       : 1;
        unsigned int still_off                      : 1;
        unsigned int button_select_or_activate      : 1;
        unsigned int resume                         : 1;

        /* 15 - 8 */
        unsigned int chapter_menu_call              : 1;
        unsigned int angle_menu_call                : 1;
        unsigned int audio_menu_call                : 1;
        unsigned int subpic_menu_call               : 1;
        unsigned int root_menu_call                 : 1;
        unsigned int title_menu_call                : 1;
        unsigned int backward_scan                  : 1;
        unsigned int forward_scan                   : 1;
        
        /* 7 - 0 */ 
        unsigned int next_pg_search                 : 1;
        unsigned int prev_or_top_pg_search          : 1;
        unsigned int time_or_chapter_search         : 1;
        unsigned int go_up                          : 1;
        unsigned int stop                           : 1;
        unsigned int title_play                     : 1;
        unsigned int chapter_search_or_play         : 1;
        unsigned int title_or_time_play             : 1;
#endif
    } __attribute__ ((packed)) values;
} __attribute__ ((packed)) dvd_user_ops_t;


typedef union {
    uint8_t value;
    struct {
        uint8_t title_or_time_play : 1,         //  0
        chapter_search_or_play : 1,             //  1
        jlc_exists_in_tt_dom : 1,               //  2
        jlc_exists_in_button_cmd : 1,           //  3
        jlc_exists_in_prepost_cmd : 1,          //  4
        jlc_exists_in_cell_cmd : 1,             //  5
        multi_or_random_pgc_title : 1           //  6
        ;
    } bits;
} __attribute__ ((packed)) dvd_playback_type_t;

typedef enum {
    FP_DOMAIN   = 1,
    VTS_DOMAIN  = 2,
    VMGM_DOMAIN = 4,
    VTSM_DOMAIN = 8
} dvd_domain_t;  

#import "DVDVirtualMachine.h"
#import "DVDManagerInformation.h"
#import "DVDTitleSet.h"
#import "DVDProgramChain.h"
#import "DVDProgramChainSearchPointer.h"
#import "DVDCellAddress.h"
#import "DVDCellPlayback.h"
#import "DVDCommand.h"
#import "DVDCellPosition.h"
#import "DVDPartOfTitle.h"
#import "DVDTitleTrackSearchPointer.h"
