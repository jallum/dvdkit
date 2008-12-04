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

- (NSData*) saveAsData:(NSError**)_error
{
    vmgm_audio_attr_t vmgm_audio_attr;
    bzero(&vmgm_audio_attr, sizeof(vmgm_audio_attr_t));
    vmgm_audio_attr.audio_format = audio_format;
    vmgm_audio_attr.multichannel_extension = has_multichannel_extension;
    vmgm_audio_attr.application_mode = application_mode;
    vmgm_audio_attr.quantization = quantization;
    vmgm_audio_attr.sample_frequency = sample_frequency;
    vmgm_audio_attr.channels = channels - 1;
    if (lang_code != 0) {
        vmgm_audio_attr.lang_type = 1;
        OSWriteBigInt16(&vmgm_audio_attr.lang_code, 0, lang_code);
    }
    vmgm_audio_attr.lang_extension = lang_extension;
    vmgm_audio_attr.code_extension = code_extension;
    vmgm_audio_attr.app_info.value = app_info_value;
    return [NSData dataWithBytes:&vmgm_audio_attr length:sizeof(vmgm_audio_attr_t)];
}


@end
