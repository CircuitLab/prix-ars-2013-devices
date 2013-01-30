#import <Foundation/Foundation.h>

@interface NNBase64 : NSObject
{
    @private
    unsigned char* charTable_;
    unsigned char reverseCharTable_[128];
}

+ (NNBase64*)base64;
+ (NNBase64*)base64URLSafe;
- (id)initWithCharacters:(const char*)chars;
- (NSString*)encode:(NSData*)data;
- (NSData*)decode:(NSString*)str;

@end
