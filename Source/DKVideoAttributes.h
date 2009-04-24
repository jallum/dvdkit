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

@property (assign, nonatomic) DKMPEGVersion mpeg_version;
@property (assign, nonatomic) DKVideoFormat video_format;
@property (assign, nonatomic) DKAspectRatio display_aspect_ratio;
@property (assign, nonatomic) BOOL film_mode;
@property (assign, nonatomic) BOOL letterboxed;
@property (assign, nonatomic) DKPictureSize picture_size;
@property (assign, nonatomic) BOOL constantBitRate;
@property (assign, nonatomic) BOOL line21_cc_2;
@property (assign, nonatomic) BOOL line21_cc_1;

+ (id) videoAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end
