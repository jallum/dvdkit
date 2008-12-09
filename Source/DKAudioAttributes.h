#import <Cocoa/Cocoa.h>

@interface DKAudioAttributes : NSObject {
    DKAudioFormat audio_format;
    BOOL has_multichannel_extension;
    DKAudioApplicationMode application_mode;
    int quantization;
    int sample_frequency;
    int channels;
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t code_extension;
    uint8_t app_info_value;
}

+ (id) audioAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end
