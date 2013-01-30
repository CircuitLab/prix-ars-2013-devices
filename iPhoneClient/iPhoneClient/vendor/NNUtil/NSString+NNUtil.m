#import "NSString+NNUtil.h"

@implementation NSString(NNUtil)

- (NSString*)stringByLeftTrimmingCharactersInSet:(NSCharacterSet*)characterSet;
{
    NSUInteger len = [self length];
    if (len == 0) return [NSString string];
    unichar buff[len];
    [self getCharacters:buff range:NSMakeRange(0, len)];
    int pos = 0;
    while (pos < len && [characterSet characterIsMember:buff[pos]]) {pos++;}
    return [self substringFromIndex:pos];
}

- (NSString*)stringByRightTrimmingCharactersInSet:(NSCharacterSet*)characterSet;
{
    NSUInteger len = [self length];
    if (len == 0) return [NSString string];
    unichar buff[len];
    [self getCharacters:buff range:NSMakeRange(0, len)];
    int pos = len - 1;
    while (pos >= 0 && [characterSet characterIsMember:buff[pos]]) {pos--;}
    return [self substringToIndex:pos + 1];    
}

@end
