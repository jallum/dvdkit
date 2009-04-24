#import <Cocoa/Cocoa.h>

@interface DKAudioAttributes : NSObject {
    DKAudioFormat audio_format;
    BOOL has_multichannel_extension;
    DKAudioApplicationMode application_mode;
    int quantization;
    DKAudioSamplingRate sample_frequency;
    int channels;
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t code_extension;
    uint8_t app_info_value;
}

@property (assign, nonatomic) DKAudioFormat audio_format;
@property (assign, nonatomic) BOOL has_multichannel_extension;
@property (assign, nonatomic) DKAudioApplicationMode application_mode;
@property (assign, nonatomic) int quantization;
@property (assign, nonatomic) DKAudioSamplingRate sample_frequency;
@property (assign, nonatomic) int channels;
@property (assign, nonatomic) uint16_t lang_code;
@property (assign, nonatomic) uint8_t lang_extension;
@property (assign, nonatomic) uint8_t code_extension;
@property (assign, nonatomic) uint8_t app_info_value;

+ (id) audioAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end
