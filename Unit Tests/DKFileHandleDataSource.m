#import "DKFileHandleDataSource.h"

@implementation DKFileHandleDataSource

- (id) initWithFileHandle:(NSFileHandle*)_fileHandle
{
    NSAssert(_fileHandle, @"wtf?");
    if (self = [super init]) {
        fileHandle = [_fileHandle retain];
    }
    return self;
}

- (NSData*) requestDataOfLength:(uint32_t)length fromOffset:(uint32_t)offset
{
    [fileHandle seekToFileOffset:offset];
    return [fileHandle readDataOfLength:length];
}

@end
