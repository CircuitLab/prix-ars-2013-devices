#import <Foundation/Foundation.h>

@interface NSString(NNUtil)

- (NSString*)stringByLeftTrimmingCharactersInSet:(NSCharacterSet*)characterSet;
- (NSString*)stringByRightTrimmingCharactersInSet:(NSCharacterSet*)characterSet;

@end
