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
    BOOL bit_rate;
    BOOL line21_cc_2;
    BOOL line21_cc_1;
}

+ (id) videoAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end