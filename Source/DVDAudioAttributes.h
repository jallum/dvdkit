#import <Cocoa/Cocoa.h>

typedef enum {
    kDKAudioFormatAC3 = 0,
    kDKAudioFormatMPEG1 = 2,
    kDKAudioFormatMPEG2Extended = 3,
    kDKAudioFormatLPCM = 4,
    kDKAudioFormatDTS = 6,
} dvd_audio_format_t;

typedef enum {
    kDKAudioApplocationModeUnspecified = 0,
    kDKAudioApplocationModeKaraoke = 1,
    kDKAudioApplocationModeSurroundSound = 2,
} dvd_audio_application_mode_t;

@interface DVDAudioAttributes : NSObject {
    dvd_audio_format_t audio_format;
    BOOL has_multichannel_extension;
    dvd_audio_application_mode_t application_mode;
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

@end
