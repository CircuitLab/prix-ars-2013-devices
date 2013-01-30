#import "NNWebSocketFrame.h"
#import "NNWebSocketDebug.h"

@interface NNWebSocketFrame()
@property(assign, getter=payload, setter=setPayload:) NSData* payload;

- (NSData*)payloadData;
- (void)setPayloadData:(NSData*)data;
- (NSString*)payloadString;
- (void)setPayloadString:(NSString*)string;
@end

@implementation NNWebSocketFrame
@synthesize fin = fin_;
@synthesize rsv1 = rsv1_;
@synthesize rsv2 = rsv2_;
@synthesize rsv3 = rsv3_;
@synthesize opcode = opcode_;
@synthesize mask = mask_;
@synthesize payloadLength = payloadLength_;
@synthesize extendedPayloadLength = extendedPayloadLength_;
@synthesize maskingKey = maskingKey_;
+ (id)frameWithOpcode:(NNWebSocketFrameOpcode)opcode
{
    TRACE();
    NNWebSocketFrame* frame = [[[NNWebSocketFrame alloc] initWithOpcode:opcode] autorelease];
    frame.fin = YES;
    frame.mask = YES;
    return frame;
}
+ (id)frameText
{
    TRACE();
    return [NNWebSocketFrame frameWithOpcode:NNWebSocketFrameOpcodeText];
}
+ (id)frameBinary
{
    TRACE();
    return [NNWebSocketFrame frameWithOpcode:NNWebSocketFrameOpcodeBinary];
}
+ (id)frameContinuation
{
    TRACE();
    return [NNWebSocketFrame frameWithOpcode:NNWebSocketFrameOpcodeConitunuation];
}
+ (id)frameClose
{
    TRACE();
    return [NNWebSocketFrame frameWithOpcode:NNWebSocketFrameOpcodeClose];
}
+ (id)framePing
{
    TRACE();
    return [NNWebSocketFrame frameWithOpcode:NNWebSocketFrameOpcodePing];
}
+ (id)framePong
{
    TRACE();
    return [NNWebSocketFrame frameWithOpcode:NNWebSocketFrameOpcodePong];
}
- (id)initWithOpcode:(NNWebSocketFrameOpcode)opcode
{
    TRACE();
    self = [super init];
    if (self) {
        self.fin = YES;
        opcode_ = opcode;
        self.mask = YES;
    }
    return self;
}
- (void)dealloc
{
    TRACE();
    self.payload = nil;
    [super dealloc];
}
- (NSData*)dataFrame
{
    TRACE();
    // Calculate frame byte size
    NSUInteger payloadLen = [self.payload length];
    NSUInteger headerLen = 0;
    if (payloadLen <= 125) {
        headerLen = 2;
    } else if (payloadLen <= UINT16_MAX) {
        headerLen = 4;
    } else {
        headerLen = 10;
    }
    if (self.mask) {
        headerLen += 4;
    }
    // Init buffers
    NSUInteger cnt = 0;
    UInt8 headerBuff[headerLen];
    memset(headerBuff, 0, sizeof(headerBuff));
    // fin
    if (self.fin) {
        headerBuff[cnt] += NNWebSocketFrameMaskFin;
    }
    // opcode
    headerBuff[cnt] += self.opcode & 0xf;
    // mask
    cnt++;
    if (self.mask) {
        headerBuff[cnt] += NNWebSocketFrameMaskMask;
    }
    // payload len
    if (payloadLen <= 125) {
        headerBuff[cnt] += payloadLen;
    } else if (payloadLen <= UINT16_MAX) {
        headerBuff[cnt] += 126;
        UInt16 l = payloadLen;
        headerBuff[++cnt] = (l & 0xff00) >> 8;
        headerBuff[++cnt] = (l & 0x00ff);
    } else {
        headerBuff[cnt] += 127;
        UInt64 l = payloadLen;
        for (int i=8; i>0; i--) {
            int shift = (i - 1) * 8;
            headerBuff[++cnt] = (l >> shift) & 0xff;
        }
    }
    // masking key
    UInt8 maskingKey[4];
    if (self.mask) {
        UInt32 src = arc4random();
        for (int i=4; i>0; i--) {
            int shift = (i -1) * 8;
            UInt8 k = (src >> shift) & 0xff;
            maskingKey[4- i] = k;
            headerBuff[++cnt] = k;
        }
    }
    // payload
    NSMutableData* maskedData = [NSMutableData dataWithData:self.payload];
    UInt8* payloadBuff = (UInt8*)[maskedData mutableBytes];
    if (self.mask) {
        NSUInteger len = [self.payload length];
        for (int i=0; i<len; i++) {
            payloadBuff[i] ^= maskingKey[i % 4];
        }
    }
    NSMutableData* dataFrame = [NSMutableData data];
    [dataFrame appendBytes:headerBuff length:headerLen];
    [dataFrame appendData:maskedData];
    return dataFrame;
}
- (NSString*)payloadString
{
    TRACE();
    if (!self.payload) {
        return @"";
    }
    return [[[NSString alloc] initWithData:self.payload encoding:NSUTF8StringEncoding] autorelease];
}
- (void)setPayloadString:(NSString *)payloadString
{
    TRACE();
    self.payload = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSData*)payloadData
{
    TRACE();
    return self.payload;
}
- (void)setPayloadData:(NSData *)payloadData
{
    TRACE();
    self.payload = payloadData;
}
- (void)setPayload:(NSData *)payload
{
    TRACE();
    if (payload_ != payload) {
        [payload_ release];
        payload_ = [payload retain];
        NSUInteger len = [payload_ length];
        if (len <= 125) {
            self.payloadLength = len;
        } else {
            self.payloadLength = len <= UINT16_MAX ? 126 : 127;
            self.extendedPayloadLength = len;
        }
    }
}
- (NSData*)payload
{
    TRACE();
    return payload_;
}
@end
