#import <Cocoa/Cocoa.h>

@interface DKSubpictureAttributes : NSObject {
    int lang_type;
    int code_mode;
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t code_extension;
}

@property (assign, nonatomic) int code_mode;
@property (assign, nonatomic) uint16_t lang_code;
@property (assign, nonatomic) uint8_t lang_extension;
@property (assign, nonatomic) uint8_t code_extension;

+ (id) subpictureAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end
