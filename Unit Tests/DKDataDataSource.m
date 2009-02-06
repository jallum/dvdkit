
#import "DKDataDataSource.h"


@implementation DKDataDataSource

- (id) initWithNSData:(NSData*)_data
{
    NSAssert(_data, @"wtf?");
    if (self = [super init]) {
        data = [_data retain];
    }
    return self;
}

- (NSData*) requestDataOfLength:(uint32_t)length fromOffset:(uint32_t)offset
{
    
	NSAssert(length, @"wtf");
	NSRange dataRange = NSMakeRange(offset, length);
	
	if(dataRange.location != NSNotFound)
		return [data subdataWithRange:dataRange];
	else
		return nil;	
}
@end
