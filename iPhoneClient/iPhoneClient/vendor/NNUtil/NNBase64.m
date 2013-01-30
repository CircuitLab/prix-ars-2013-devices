#import "NNBase64.h"
#import "NSString+NNUtil.h"

#define PADDING_CHAR '='
#define INVALID_DECODED_BYTE 99

// Basic base64 encoded characters
static const char* kBase64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
// URL safe base64 encoded characters
static const char* kBase64SafeChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

@implementation NNBase64

+ (id)base64
{
    return [[[NNBase64 alloc] initWithCharacters:kBase64Chars] autorelease];
}

+ (id)base64URLSafe
{
    return [[[NNBase64 alloc] initWithCharacters:kBase64SafeChars] autorelease];
}

- (id)initWithCharacters:(const char*)chars
{
    self = [super init];
    if (self) {
        // Initialize reverse table with invalid decoded byte
        memset(reverseCharTable_, INVALID_DECODED_BYTE, sizeof(reverseCharTable_));
        int tLen = strlen(chars);
        // Set decoded bytes to reverse table
        for (int i=0; i<tLen; i++) {
            reverseCharTable_[chars[i]] = i;
        }
        charTable_ = (unsigned char*)chars;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString*)encode:(NSData*)data
{
    if (!data || ![data length]) return nil;
    unsigned char* inBuff = (unsigned char*)[data bytes];
    int inPos = 0;
    int inLen = [data length];
    int outPos = 0;
    // Calculate number of characters after encoding
    int outLen = (inLen * 4 + 2) / 3;
    // Add number of characters for padding
    outLen += (4 - outLen % 4) % 4;
    NSMutableData* outData = [NSMutableData dataWithLength:outLen];
    unsigned char* outBuff = (unsigned char*)[outData mutableBytes];
    unsigned int bitBuff = 0;
    int bitLen = 0;
    while (inPos < inLen || bitLen > 0) {
        // Working bit buffer is not enough
        if (bitLen < 6) {
            if (inPos < inLen) {
                // Accumulate bits from input buffer
                bitBuff = bitBuff << 8 | inBuff[inPos++];
                bitLen  += 8;
            } else {
                // Adjust remains to 6 bits
                bitBuff <<= (6 - bitLen);
                bitLen = 6;
            }
        }
        int shift = bitLen - 6;
        // Take next 6 bits from bit buffer
        unsigned int ch = bitBuff >> shift;
        // Left justify bit buffer
        bitBuff -= ch << shift;
        bitLen -= 6;
        // Get encoded character and write to output buffer
        outBuff[outPos++] = charTable_[ch];
    }
    while(outPos < outLen) {
        // padding
        outBuff[outPos++] = '=';
    }
    NSString* outStr = [[[NSString alloc] initWithData:outData encoding:NSASCIIStringEncoding] autorelease];
    return outStr;
}

- (NSData*)decode:(NSString*)str;
{
    int inLen = [str length];
    if (inLen % 4 || !inLen) return nil;
    // Calculate number of characters after decoding
    int outLen = (inLen * 3 + 3) / 4;
    NSString* trimedStr = [str stringByRightTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
    int trimedInLen = [trimedStr length];
    const char* inBuff = [trimedStr cStringUsingEncoding:NSASCIIStringEncoding];
    int inPos = 0;
    NSMutableData* outData = [NSMutableData dataWithLength:outLen];
    unsigned char* outBuff = (unsigned char*)[outData mutableBytes];
    int outPos = 0;
    unsigned int bitBuff = 0;
    int bitLen = 0;
    while (inPos < trimedInLen || bitLen > 0) {
        // Working bit buffer is not enough
        if (bitLen < 8) {
            if (inPos < trimedInLen) {
                unsigned char ch = inBuff[inPos++];
                if (PADDING_CHAR == ch) return nil;
                // Convert encoded character into original 6 bits
                unsigned char num = reverseCharTable_[ch];
                if (num > 63) return nil;
                // Accumulate bits from input buffer
                bitBuff = bitBuff << 6 | (num & 0x3f);
                bitLen  += 6;
            } else {
                break;
            }
        } else {
            int shift = bitLen - 8;
            // Take next byte from bit buffer
            unsigned int byte = bitBuff >> shift;
            // write to output buffer
            outBuff[outPos++] = byte;
            // Left justify bit buffer
            bitBuff -= byte << shift;
            bitLen -= 8;
        }
    }
    // Set actual length to output buffer
    [outData setLength:outPos];
    return outData;
}

@end
