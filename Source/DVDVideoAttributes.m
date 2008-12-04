#import "DVDKit.h"
#import "DVDKit+Private.h"

static dvd_picture_size_t PICTURE_SIZE_TABLE[4][4] = {
    /* NTSC */
    { kDFPictureSize720x480, kDFPictureSize704x480, kDFPictureSize352x480, kDFPictureSize352x240 },

    /* PAL */
    { kDFPictureSize720x576, kDFPictureSize704x576, kDFPictureSize352x576, kDFPictureSize352x288 },

    /* Unknown */
    { kDFPictureSizeUnknown, kDFPictureSizeUnknown, kDFPictureSizeUnknown, kDFPictureSizeUnknown },

    /* Unknown */
    { kDFPictureSizeUnknown, kDFPictureSizeUnknown, kDFPictureSizeUnknown, kDFPictureSizeUnknown },
};

@implementation DVDVideoAttributes

+ (id) videoAttributesWithData:(NSData*)data
{
    return [[[DVDVideoAttributes alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data && [data length] == sizeof(vmgm_video_attr_t), @"wtf?");
    if (self = [super init]) {
        const vmgm_video_attr_t* vmgm_video_attr = [data bytes];
        allowAutomaticLetterbox = vmgm_video_attr->allow_automatic_letterbox;
        allowAutomaticPanAndScan = vmgm_video_attr->allow_automatic_panandscan;
        display_aspect_ratio = vmgm_video_attr->display_aspect_ratio;
        video_format = vmgm_video_attr->video_format;
        mpeg_version = vmgm_video_attr->mpeg_version;
        /**/
        film_mode = vmgm_video_attr->film_mode;
        letterboxed = vmgm_video_attr->letterboxed;
        picture_size = PICTURE_SIZE_TABLE[vmgm_video_attr->video_format][vmgm_video_attr->picture_size];
        /**/
        bit_rate = vmgm_video_attr->bit_rate;
        line21_cc_2 = vmgm_video_attr->line21_cc_2;
        line21_cc_1 = vmgm_video_attr->line21_cc_1;
    }
    return self;
}

- (NSData*) saveAsData:(NSError**)_error
{
    vmgm_video_attr_t vmgm_video_attr;
    bzero(&vmgm_video_attr, sizeof(vmgm_video_attr_t));
    vmgm_video_attr.allow_automatic_letterbox = allowAutomaticLetterbox;
    vmgm_video_attr.allow_automatic_panandscan = allowAutomaticPanAndScan;
    vmgm_video_attr.display_aspect_ratio = display_aspect_ratio;
    vmgm_video_attr.video_format = video_format;
    vmgm_video_attr.mpeg_version = mpeg_version;
    vmgm_video_attr.film_mode = film_mode;
    vmgm_video_attr.letterboxed = letterboxed;
    vmgm_video_attr.picture_size = picture_size & 0x03;
    vmgm_video_attr.bit_rate = bit_rate;
    vmgm_video_attr.line21_cc_1 = line21_cc_1;
    vmgm_video_attr.line21_cc_2 = line21_cc_2;
    return [NSData dataWithBytes:&vmgm_video_attr length:sizeof(vmgm_video_attr_t)];
}

@end
