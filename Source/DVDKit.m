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
