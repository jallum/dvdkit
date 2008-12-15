#import "DVDKit.h"
#import "DVDKit+Private.h"

@implementation DKSubpictureAttributes

+ (id) subpictureAttributesWithData:(NSData*)data
{
    return [[[DKSubpictureAttributes alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data && [data length] == sizeof(subp_attr_t), @"wtf?");
    if (self = [super init]) {
        const subp_attr_t* vmgm_subp_attr = [data bytes];
        
        code_mode = vmgm_subp_attr->code_mode;
        if (vmgm_subp_attr->lang_type == 1) {
            lang_code = OSReadBigInt16(&vmgm_subp_attr->lang_code, 0);
        }
        lang_extension = vmgm_subp_attr->lang_extension;
        code_extension = vmgm_subp_attr->code_extension;
    }
    return self;
}

- (NSData*) saveAsData:(NSError**)_error
{
    subp_attr_t vmgm_subp_attr;
    bzero(&vmgm_subp_attr, sizeof(subp_attr_t));
    vmgm_subp_attr.code_mode = code_mode;
    if (lang_code != 0) {
        vmgm_subp_attr.lang_type = 1;
        OSWriteBigInt16(&vmgm_subp_attr.lang_code, 0, lang_code);
    }
    vmgm_subp_attr.lang_extension = lang_extension;
    vmgm_subp_attr.code_extension = code_extension;
    return [NSData dataWithBytes:&vmgm_subp_attr length:sizeof(subp_attr_t)];
}

@end
