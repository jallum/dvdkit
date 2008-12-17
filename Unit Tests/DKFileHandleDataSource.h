#import <Cocoa/Cocoa.h>
#import <DVDKit/DVDKit.h>

@interface DKFileHandleDataSource : NSObject <DKDataSource> {
    NSFileHandle* fileHandle;
}

- (id) initWithFileHandle:(NSFileHandle*)fileHandle;
- (NSData*) requestDataOfLength:(uint32_t)length fromOffset:(uint32_t)offset;

@end
