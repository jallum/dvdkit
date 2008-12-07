

#define OSReadBigInt8(x, y)     (((uint8_t*)x)[y])
#define OSWriteBigInt8(x, y, z) (void)(((uint8_t*)x)[y] = z)

typedef struct vmgm_video_attr_t vmgm_video_attr_t;
struct vmgm_video_attr_t {
    uint16_t 
#ifdef LITTLE_ENDIAN
    allow_automatic_letterbox : 1,
    allow_automatic_panandscan : 1,
    display_aspect_ratio : 2,
    video_format : 2,
    mpeg_version : 2,
    /**/
    film_mode : 1,
    letterboxed : 1,
    picture_size : 2,
    /**/
    bit_rate : 1,
    __zero_1 : 1,
    line21_cc_2 : 1,
    line21_cc_1 : 1;
#else
    mpeg_version : 2,
    video_format : 2,
    display_aspect_ratio : 2,
    allow_automatic_panandscan : 1,
    allow_automatic_letterbox : 1,
    /**/
    line21_cc_1 : 1,
    line21_cc_2 : 1,
    __zero_1 : 1,
    bit_rate : 1,
    /**/
    picture_size : 2,
    letterboxed : 1,
    film_mode : 1;
#endif
} __attribute__ ((packed));

typedef struct vmgm_audio_attr_t vmgm_audio_attr_t;
struct vmgm_audio_attr_t {
    uint16_t
#ifdef LITTLE_ENDIAN
    audio_format : 3,
    multichannel_extension : 1,
    lang_type : 2,
    application_mode : 2,
    /**/
    quantization : 2,
    sample_frequency : 2,
    __zero_1 : 1,
    channels : 3;
#else
    application_mode : 2,
    lang_type : 2,
    multichannel_extension : 1,
    audio_format : 3,
    /**/
    channels : 3,
    __zero_1 : 1,
    sample_frequency : 2,
    quantization : 2;
#endif
    char lang_code[2];
    uint8_t lang_extension;
    uint8_t code_extension;
    uint8_t __zero_2;
    union {
        uint8_t value;
        struct {
            uint8_t
#ifdef LITTLE_ENDIAN
            mode : 1,
            mc_intro : 1,
            version : 2,
            channel_assignment : 3,
            __zero_1 : 1;
#else
            __zero_1 : 1,
            channel_assignment : 3,
            version : 2,
            mc_intro : 1,
            mode : 1;
#endif
        } __attribute__ ((packed)) karaoke;
        struct {
            uint8_t
#ifdef LITTLE_ENDIAN
            __zero_1 : 3,
            dolby_encoded : 1,
            __zero_2 : 4;
#else
            __zero_2 : 4,
            dolby_encoded : 1,
            __zero_1 : 3;
#endif
        } __attribute__ ((packed)) surround;
    } __attribute__ ((packed)) app_info;
} __attribute__ ((packed));

typedef struct vmgm_subp_attr_t vmgm_subp_attr_t;
struct vmgm_subp_attr_t {
    uint8_t
#ifdef LITTLE_ENDIAN
    lang_type : 2,
    __zero_1 : 3,
    code_mode : 3;
#else
    code_mode : 3,
    __zero_1 : 3,
    type : 2;
#endif
    uint8_t __zero_2;
    char lang_code[2];
    uint8_t lang_extension;
    uint8_t code_extension;
} __attribute__ ((packed));

typedef struct vmgi_mat_t vmgi_mat_t;
struct vmgi_mat_t {
    int8_t vmg_identifier[12];
    uint32_t vmg_last_sector;
    uint8_t __zero_1[12];
    uint32_t vmgi_last_sector;
    uint8_t __zero_2;
    uint8_t specification_version;
    uint32_t vmg_category;
    uint16_t vmg_nr_of_volumes;
    uint16_t vmg_this_volume_nr;
    uint8_t disc_side;
    uint8_t __zero_3[19];
    uint16_t vmg_nr_of_title_sets;
    int8_t provider_identifier[32];
    uint64_t vmg_pos_code;
    uint8_t __zero_4[24];
    uint32_t vmgi_last_byte;
    uint32_t first_play_pgc;
    uint8_t __zero_5[56];
    uint32_t vmgm_vobs;
    /**/
    uint32_t tt_srpt;           
    uint32_t vmgm_pgci_ut;      
    uint32_t ptl_mait;
    uint32_t vmg_vts_atrt;
    uint32_t txtdt_mgi;         
    uint32_t vmgm_c_adt;        
    uint32_t vmgm_vobu_admap;   
    /**/
    uint8_t __zero_6[32];
    vmgm_video_attr_t vmgm_video_attr;
    uint8_t __zero_7;
    uint8_t nr_of_vmgm_audio_streams;
    vmgm_audio_attr_t vmgm_audio_attr[8];
    uint8_t __zero_8[16];
    uint16_t nr_of_vmgm_subp_streams;
    vmgm_subp_attr_t vmgm_subp_attr;
    uint8_t __zero_9[164];
} __attribute__ ((packed));

typedef struct tt_srpt_t tt_srpt_t;
struct tt_srpt_t {
    uint16_t nr_of_srpts;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct title_info_t title_info_t;
struct title_info_t {
    dvd_playback_type_t pb_ty;
    uint8_t nr_of_angles;
    uint16_t nr_of_ptts;
    uint16_t parental_id;
    uint8_t title_set_nr;
    uint8_t vts_ttn;
    uint32_t title_set_sector;
} __attribute__ ((packed));

typedef struct vmgi_pgci_ut_t vmgm_pgci_ut_t;
struct vmgi_pgci_ut_t {
    uint16_t nr_of_lus;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct pgci_lu_t pgci_lu_t;
struct pgci_lu_t {
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t exists;
    uint32_t pgcit_start_byte;
} __attribute__ ((packed));

typedef struct pgcit_t pgcit_t;
struct pgcit_t {
    uint16_t nr_of_pgci_srp;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct pgci_srp_t pgci_srp_t;
struct pgci_srp_t {
    uint8_t  entry_id;
#ifdef LITTLE_ENDIAN
    unsigned int unknown1   : 4;
    unsigned int block_type : 2;
    unsigned int block_mode : 2;
#else
    unsigned int block_mode : 2;
    unsigned int block_type : 2;
    unsigned int unknown1   : 4;
#endif  
    uint16_t ptl_id_mask;
    uint32_t pgc_start_byte;
} __attribute__ ((packed));

typedef struct vmgm_c_adt_t vmgm_c_adt_t;
struct vmgm_c_adt_t {
    uint16_t nr_of_c_adts;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct cell_adr_t cell_adr_t;
struct cell_adr_t {
    uint16_t vob_id;
    uint8_t cell_id;
    uint8_t __zero_1;
    uint32_t start_sector;
    uint32_t last_sector;
} __attribute__ ((packed));

typedef struct vts_atrt_t vmg_vts_atrt_t;
struct vts_atrt_t {
    uint16_t nr_of_vtss;
    uint16_t __zero_1;
    uint32_t last_byte;
} __attribute__ ((packed));

typedef struct ptl_mait_t ptl_mait_t;
struct ptl_mait_t {
    uint16_t nr_of_countries;
    uint16_t nr_of_vtss;
    uint32_t last_byte;
} __attribute__ ((packed));













