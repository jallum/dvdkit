#import <Cocoa/Cocoa.h>

@interface DKVideoAttributes : NSObject {
    BOOL allowAutomaticLetterbox;
    BOOL allowAutomaticPanAndScan;
    DKAspectRatio display_aspect_ratio;
    DKVideoFormat video_format;
    DKMPEGVersion mpeg_version;
    /**/
    BOOL film_mode;
    BOOL letterboxed;
    DKPictureSize picture_size;
    /**/
    BOOL constantBitRate;
    BOOL line21_cc_2;
    BOOL line21_cc_1;
}

@property (assign) DKMPEGVersion mpeg_version;
@property (assign) DKVideoFormat video_format;
@property (assign) DKAspectRatio display_aspect_ratio;
@property (assign) BOOL film_mode;
@property (assign) BOOL letterboxed;
@property (assign) DKPictureSize picture_size;
@property (assign) BOOL constantBitRate;
@property (assign) BOOL line21_cc_2;
@property (assign) BOOL line21_cc_1;











+ (id) videoAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end
