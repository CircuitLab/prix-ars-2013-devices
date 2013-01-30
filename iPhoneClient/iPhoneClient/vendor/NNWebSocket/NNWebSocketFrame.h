#import <Foundation/Foundation.h>

typedef enum {
    NNWebSocketFrameOpcodeConitunuation = 0x0,
    NNWebSocketFrameOpcodeText = 0x1,
    NNWebSocketFrameOpcodeBinary = 0x2,
    NNWebSocketFrameOpcodeReservedNonControl1 = 0x03,
    NNWebSocketFrameOpcodeReservedNonControl2 = 0x04,
    NNWebSocketFrameOpcodeReservedNonControl3 = 0x05,
    NNWebSocketFrameOpcodeReservedNonControl4 = 0x06,
    NNWebSocketFrameOpcodeReservedNonControl5 = 0x07,
    NNWebSocketFrameOpcodeClose = 0x8,
    NNWebSocketFrameOpcodePing = 0x9,
    NNWebSocketFrameOpcodePong = 0xA
} NNWebSocketFrameOpcode;

typedef enum {
    NNWebSocketFrameMaskFin = 0x80,
    NNWebSocketFrameMaskRsv1 = 0x40,
    NNWebSocketFrameMaskRsv2 = 0x20,
    NNWebSocketFrameMaskRsv3 = 0x10,
    NNWebSocketFrameMaskOpcode = 0x0f,
    NNWebSocketFrameMaskMask = 0x80,
    NNWebSocketFrameMaskPayloadLength = 0x7f
} NNWebSocketFrameMask;

@interface NNWebSocketFrame : NSObject
{
    @private
    BOOL fin_;
    BOOL rsv1_;
    BOOL rsv2_;
    BOOL rsv3_;
    NNWebSocketFrameOpcode opcode_;
    BOOL mask_;
    UInt8 payloadLength_;
    UInt64 extendedPayloadLength_;
    UInt8* maskingKey_;
    NSData* payload_;
}
@property(nonatomic, assign) BOOL fin;
@property(nonatomic, assign) BOOL rsv1;
@property(nonatomic, assign) BOOL rsv2;
@property(nonatomic, assign) BOOL rsv3;
@property(nonatomic, readonly, assign) NNWebSocketFrameOpcode opcode;
@property(nonatomic, assign) BOOL mask;
@property(nonatomic, assign) UInt8 payloadLength;
@property(nonatomic, assign) UInt64 extendedPayloadLength;
@property(nonatomic, assign) UInt8* maskingKey;
@property(assign, getter=payloadString, setter=setPayloadString:) NSString* payloadString;
@property(assign, getter=payloadData, setter=setPayloadData:) NSData* payloadData;
+ (id)frameText;
+ (id)frameBinary;
+ (id)frameContinuation;
+ (id)frameClose;
+ (id)framePing;
+ (id)framePong;
+ (id)frameWithOpcode:(NNWebSocketFrameOpcode)opcode;
- (id)initWithOpcode:(NNWebSocketFrameOpcode)opcode;
- (NSData*)dataFrame;
@end
