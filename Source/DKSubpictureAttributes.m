#import "DVDKit.h"
#import "DVDKit+Private.h"

@implementation DKSubpictureAttributes

@synthesize code_mode;
@synthesize lang_code;
@synthesize lang_extension;
@synthesize code_extension;


+ (id) subpictureAttributesWithData:(NSData*)data
{
    return [[[DKSubpictureAttributes alloc] initWithData:data] autorelease];
}

- (id) initWithData:(NSData*)data
{
    NSAssert(data && [data length] == sizeof(subp_attr_t), @"wtf?");
    if (self = [super init]) {
        const subp_attr_t* subp_attr = [data bytes];
        
        code_mode = subp_attr->code_mode;
        if (subp_attr->lang_type == 1) {
            lang_code = OSReadBigInt16(&subp_attr->lang_code, 0);
        }
        lang_extension = OSReadBigInt8(&subp_attr->lang_extension, 0);
        code_extension = OSReadBigInt8(&subp_attr->code_extension, 0);
    }
    return self;
}

- (BOOL) isEqual:(DKSubpictureAttributes*)anObject
{
	if(self == anObject)
	{
		return YES;
		
	}
	else return (
		[self class] == [anObject class]
		&& (anObject->code_mode == code_mode)
		&& (anObject->lang_code == lang_code)
		&& (anObject->lang_extension == lang_extension)
		&& (anObject->code_extension == code_extension)
		 );
		
}

- (NSData*) saveAsData:(NSError**)_error
{
    NSMutableData* data = [NSMutableData dataWithLength:sizeof(subp_attr_t)];
    subp_attr_t* subp_attr = [data mutableBytes];

    subp_attr->code_mode = code_mode;
    if (lang_code != 0) {
        subp_attr->lang_type = 1;
        OSWriteBigInt16(&subp_attr->lang_code, 0, lang_code);
    }
    OSWriteBigInt8(&subp_attr->lang_extension, 0, lang_extension);
    OSWriteBigInt8(&subp_attr->code_extension, 0, code_extension);

    return data;
}

@end
