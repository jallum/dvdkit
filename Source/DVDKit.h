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
        uint32_t time_play_or_search : 1,       //  0
        ptt_play_or_search : 1,                 //  1
        title_play : 1,                         //  2
        stop : 1,                               //  3
        go_up : 1,                              //  4
        time_or_ptt_search : 1,                 //  5
        top_pg_or_prev_pg_search : 1,           //  6
        next_pg_search : 1,                     //  7
        forward_scan : 1,                       //  8
        backward_scan : 1,                      //  9
        menu_call_title : 1,                    //  10
        menu_call_root : 1,                     //  11
        menu_call_subpicture : 1,               //  12
        menu_call_audio : 1,                    //  13
        menu_call_angle : 1,                    //  14
        menu_call_ptt : 1,                      //  15
        resume : 1,                             //  16
        button_select_or_activate : 1,          //  17
        still_off : 1,                          //  18
        pause_on : 1,                           //  19
        audio_stream_change : 1,                //  20
        subpicture_stream_change : 1,           //  21
        angle_change : 1,                       //  22
        karaoke_audio_mix_change : 1,           //  23
        video_presentation_mode_change : 1      //  24
        ;
    } values;
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
