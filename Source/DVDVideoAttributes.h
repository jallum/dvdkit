#import <Cocoa/Cocoa.h>

typedef enum {
    kDKAspectRatioUnknown = -1,
    /**/
    kDKAspectRatio4By3 = 0,
    kDKAspectRatio16By9 = 3,
} dvd_aspect_ratio_t;

typedef enum {
    kDKVideoFormatUnknown = -1,
    /**/
    kDKVideoFormatNTSC = 0,
    kDKVideoFormatPAL = 1,
} dvd_video_format_t;

typedef enum {
    kDKMPEGVersion1 = 0,
    kDKMPEGVersion2 = 1,
} dvd_mpeg_version_t;

typedef enum {
    kDFPictureSizeUnknown = -1,
    
    /* NTSC */
    kDFPictureSize720x480,
    kDFPictureSize704x480,
    kDFPictureSize352x480,
    kDFPictureSize352x240,

    /* PAL */
    kDFPictureSize720x576,
    kDFPictureSize704x576,
    kDFPictureSize352x576,
    kDFPictureSize352x288,
} dvd_picture_size_t;

@interface DVDVideoAttributes : NSObject {
    BOOL allowAutomaticLetterbox;
    BOOL allowAutomaticPanAndScan;
    dvd_aspect_ratio_t display_aspect_ratio;
    dvd_video_format_t video_format;
    dvd_mpeg_version_t mpeg_version;
    /**/
    BOOL film_mode;
    BOOL letterboxed;
    dvd_picture_size_t picture_size;
    /**/
    BOOL bit_rate;
    BOOL line21_cc_2;
    BOOL line21_cc_1;
}

+ (id) videoAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;


@end
