#import <Cocoa/Cocoa.h>
#import <DVDKit/DVDKit.h>



@interface DKDataDataSource : NSObject  <DKDataSource> {
	NSData* data;
	
}
- (id) initWithNSData:(NSData*)data;
- (NSData*) requestDataOfLength:(uint32_t)length fromOffset:(uint32_t)offset;

@end





