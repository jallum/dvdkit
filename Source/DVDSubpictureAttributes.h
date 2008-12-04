#import <Cocoa/Cocoa.h>

@interface DVDSubpictureAttributes : NSObject {
    int code_mode;
    uint16_t lang_code;
    uint8_t lang_extension;
    uint8_t code_extension;
}

+ (id) subpictureAttributesWithData:(NSData*)data;

- (id) initWithData:(NSData*)data;

- (NSData*) saveAsData:(NSError**)error;

@end
