#import "DVDKit.h"
#import "DVDKit+Private.h"

static DKPictureSize PICTURE_SIZE_TABLE[4][4] = {
    /* NTSC */
    { kDKPictureSize720x480, kDKPictureSize704x480, kDKPictureSize352x480, kDKPictureSize352x240 },

    /* PAL */
    { kDKPictureSize720x576, kDKPictureSize704x576, kDKPictureSize352x576, kDKPictureSize352x288 },

    /* Unknown */
    { kDKPictureSizeUnknown, kDKPictureSizeUnknown, kDKPictureSizeUnknown, kDKPictureSizeUnknown },

    /* Unknown */
    { kDKPictureSizeUnknown, kDKPictureSizeUnknown, kDKPictureSizeUnknown, kDKPictureSizeUnknown },
};

@implementation DKVideoAttributes


@synthesize mpeg_version;


@synthesize video_format;
@synthesize display_aspect_ratio;
@synthesize film_mode;
@synthesize letterboxed;
@synthesize picture_size;
@synthesize bit_rate;
@synthesize line21_cc_2;
@synthesize line21_cc_1;


+ (id) videoAttributesWithData:(NSData*)data
{
    return [[[DKVideoAttributes alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data && [data length] == sizeof(video_attr_t), @"wtf?");
    if (self = [super init]) {
        const video_attr_t* video_attr = [data bytes];

        allowAutomaticLetterbox = video_attr->allow_automatic_letterbox;
        allowAutomaticPanAndScan = video_attr->allow_automatic_panandscan;
        display_aspect_ratio = video_attr->display_aspect_ratio;
        video_format = video_attr->video_format;
        mpeg_version = video_attr->mpeg_version;
        /**/
        film_mode = video_attr->film_mode;
        letterboxed = video_attr->letterboxed;
        picture_size = PICTURE_SIZE_TABLE[video_attr->video_format][video_attr->picture_size];
        /**/
        constantBitRate = video_attr->bit_rate;
        line21_cc_2 = video_attr->line21_cc_2;
        line21_cc_1 = video_attr->line21_cc_1;
    }
    return self;
}

- (NSData*) saveAsData:(NSError**)_error
{
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(video_attr_t)];
    video_attr_t* video_attr = [data mutableBytes];

    video_attr->allow_automatic_letterbox = allowAutomaticLetterbox;
    video_attr->allow_automatic_panandscan = allowAutomaticPanAndScan;
    video_attr->display_aspect_ratio = display_aspect_ratio;
    video_attr->video_format = video_format;
    video_attr->mpeg_version = mpeg_version;
    video_attr->film_mode = film_mode;
    video_attr->letterboxed = letterboxed;
    video_attr->picture_size = picture_size & 0x03;
    video_attr->bit_rate = constantBitRate;
    video_attr->line21_cc_1 = line21_cc_1;
    video_attr->line21_cc_2 = line21_cc_2;

    return data;
}

@end
