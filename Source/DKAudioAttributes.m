#import "DVDKit.h"
#import "DVDKit+Private.h"

@implementation DKAudioAttributes

@synthesize audio_format;
@synthesize has_multichannel_extension;
@synthesize application_mode;
@synthesize quantization;
@synthesize sample_frequency;
@synthesize channels;
@synthesize lang_code;
@synthesize lang_extension;
@synthesize code_extension;
@synthesize app_info_value;

+ (id) audioAttributesWithData:(NSData*)data
{
    return [[[DKAudioAttributes alloc] initWithData:data] autorelease];
}


- (id) initWithData:(NSData*)data
{
    NSAssert(data && [data length] == sizeof(audio_attr_t), @"wtf?");
    if (self = [super init]) {
        const audio_attr_t* audio_attr = [data bytes];

        audio_format = audio_attr->audio_format;
        has_multichannel_extension = audio_attr->multichannel_extension;
        application_mode = audio_attr->application_mode;
        quantization = audio_attr->quantization;
        sample_frequency = audio_attr->sample_frequency;
        channels = 1 + audio_attr->channels;
        if (audio_attr->lang_type == 1) {
            lang_code = OSReadBigInt16(&audio_attr->lang_code, 0);
        }
        lang_extension = audio_attr->lang_extension;
        code_extension = audio_attr->code_extension;
        app_info_value = audio_attr->app_info.value;
    }
    return self;
}

- (BOOL) isEqual:(id)anObject
{
	
	DKAudioAttributes* audioAttributesObject = (DKAudioAttributes*)anObject;
	
	if([audioAttributesObject audio_format] != audio_format)
		return NO;
	if([audioAttributesObject has_multichannel_extension] != has_multichannel_extension)
		return NO;
	if([audioAttributesObject application_mode] != application_mode)
		return NO;
	if([audioAttributesObject quantization] != quantization)
	   return NO;
	if([audioAttributesObject sample_frequency] != sample_frequency)
		return NO;
	if([audioAttributesObject channels] != channels)
		return NO;
	if([audioAttributesObject lang_code] != lang_code)
		return NO;
	if([audioAttributesObject lang_extension] != lang_extension)
		return NO;
	if([audioAttributesObject code_extension] != code_extension)
		return NO;
	if([audioAttributesObject app_info_value] != app_info_value)
		return NO;
	
	
	return YES;
	
}

- (NSData*) saveAsData:(NSError**)_error
{
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(audio_attr_t)];
    audio_attr_t* audio_attr = [data mutableBytes];
    
    audio_attr->audio_format = audio_format;
    audio_attr->multichannel_extension = has_multichannel_extension;
    audio_attr->application_mode = application_mode;
    audio_attr->quantization = quantization;
    audio_attr->sample_frequency = sample_frequency;
    audio_attr->channels = channels - 1;
    if (lang_code != 0) {
        audio_attr->lang_type = 1;
        OSWriteBigInt16(&audio_attr->lang_code, 0, lang_code);
    }
    audio_attr->lang_extension = lang_extension;
    audio_attr->code_extension = code_extension;
    audio_attr->app_info.value = app_info_value;
 
    return data;
}


@end
