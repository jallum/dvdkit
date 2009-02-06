#import "DVDKit.h"
#import "DVDKit+Private.h"

NSString* const kDVDKitErrorDomain = @"DVDKit";

NSError* __DKErrorWithCode(DKErrorCode code, ...)
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
    va_list ap;
    va_start(ap, code);
    id object = va_arg(ap, id);
    while (object) {
        id key = va_arg(ap, id);
        [userInfo setObject:object forKey:key];
        object = va_arg(ap, id);
    }
    return [NSError errorWithDomain:kDVDKitErrorDomain code:code userInfo:userInfo];
}

@implementation NSObject (DVDKit_Private)

+ (CFBitVectorRef) _readVobuAddressMapFromDataSource:(id<DKDataSource>)dataSource offset:(uint32_t)offset errors:(NSMutableArray*)errors
{
    NSData* data = [dataSource requestDataOfLength:1 << 11 fromOffset:offset << 11];
    NSAssert(data && ([data length] == 1 << 11), @"wtf?"); 
    uint32_t last_byte = 1 + OSReadBigInt32([data bytes], 0);
    
    /*  Have we already read all that we need?  */
    if (last_byte > [data length]) {
        data = [dataSource requestDataOfLength:last_byte fromOffset:(offset << 11)];
    } else {
        data = [data subdataWithRange:NSMakeRange(0, last_byte)];
    }
    
    /*  Parse the table  */
    CFMutableBitVectorRef bitmap = CFBitVectorCreateMutable(NULL, 0);
    uint32_t max_sector = CFBitVectorGetCount(bitmap);
    const void* base = [data bytes];
    for (int i = last_byte - 4; i >= 4; i -= 4) {
        uint32_t sector = OSReadBigInt32(base, i);
        if (sector >= kDKMaxSectorsPerVOBSet) {
            [errors addObject:DKErrorWithCode(kDKVobuAddressTableError, [NSString stringWithFormat:DKLocalizedString(@"Illegal VOBU Address (0x%08x), skipping.", nil), sector], NSLocalizedDescriptionKey, nil)];
            continue;
        }
        if (sector >= max_sector) {
            max_sector = sector + 1;
            CFBitVectorSetCount(bitmap, max_sector);
        }
        CFBitVectorSetBitAtIndex(bitmap, sector, 1);
    }
    
    return (CFBitVectorRef)[(id)bitmap autorelease];
}

+ (NSMutableData*) _saveVobuAddressMap:(CFBitVectorRef)vobuAddressMap errors:(NSMutableArray*)errors
{
    CFRange range = CFRangeMake(0, CFBitVectorGetCount(vobuAddressMap));
    uint32_t last_byte = sizeof(uint32_t) + (4 * CFBitVectorGetCountOfBit(vobuAddressMap, range, 1));
    NSMutableData* data = [NSMutableData dataWithLength:last_byte];
    void* base = [data mutableBytes];
    OSWriteBigInt32(base, 0, last_byte - 1);
    
    int i = 4;
    uint32_t sector = 0;
    while (kCFNotFound != (sector = CFBitVectorGetFirstIndexOfBit(vobuAddressMap, range, 1))) {
        OSWriteBigInt32(base, i, sector); 
        range.length -= (sector - range.location) + 1;
        range.location = sector + 1;
        i += 4;
    }
    
    return data;
}

@end
