#import <Cocoa/Cocoa.h>

@interface DKSubpictureAttributes : NSObject {
    int code_mode;
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t code_extension;
}
@property (assign) int code_mode;
@property (assign) uint16_t lang_code;
@property (assign) uint8_t lang_extension;
@property (assign) uint8_t code_extension;




+ (id) subpictureAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end
