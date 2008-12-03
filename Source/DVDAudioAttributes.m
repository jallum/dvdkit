#import "DVDKit.h"
#import "DVDKit+Private.h"

@implementation DVDAudioAttributes

+ (id) audioAttributesWithData:(NSData*)data
{
    return [[[DVDAudioAttributes alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data && [data length] == sizeof(vmgm_audio_attr_t), @"wtf?");
    if (self = [super init]) {
        const vmgm_audio_attr_t* vmgm_audio_attr = [data bytes];
        audio_format = vmgm_audio_attr->audio_format;
        has_multichannel_extension = vmgm_audio_attr->multichannel_extension;
        application_mode = vmgm_audio_attr->application_mode;
        quantization = vmgm_audio_attr->quantization;
        sample_frequency = vmgm_audio_attr->sample_frequency;
        channels = 1 + vmgm_audio_attr->channels;
        if (vmgm_audio_attr->lang_type == 1) {
            lang_code = OSReadBigInt16(&vmgm_audio_attr->lang_code, 0);
        }
        lang_extension = vmgm_audio_attr->lang_extension;
        code_extension = vmgm_audio_attr->code_extension;
        app_info_value = vmgm_audio_attr->app_info.value;
    }
    return self;
}

@end
