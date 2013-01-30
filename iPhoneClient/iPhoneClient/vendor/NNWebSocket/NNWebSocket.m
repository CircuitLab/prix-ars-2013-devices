#import <CommonCrypto/CommonDigest.h>
#import "NNWebSocket.h"
#import "NNWebSocketDebug.h"
#import "NNBase64.h"

#define WEBSOCKET_GUID @"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
#define WEBSOCKET_PROTOCOL_VERSION 8
#define WEBSOCKET_STATUS_NORMAL 1000
#define TAG_OPENING_HANDSHAKE 100
#define TAG_READ_HEAD 200
#define TAG_READ_EXT_PAYLOAD_LENGTH 300
#define TAG_READ_MASKING_KEY 400
#define TAG_READ_PAYLOAD 500
#define TAG_WRITE_FRAME 600
#define TAG_CLOSING_HANDSHAKE 700

#define SHARED_STATE_METHOD() \
+ (NNWebSocketState*)sharedState \
{ \
    static id instance_ = nil; \
    static dispatch_once_t once; \
    dispatch_once(&once, ^{ \
        instance_ = [[self alloc] init]; \
    }); \
    return instance_; \
}


typedef enum {
    NNWebSocketStatusNormalEnd = 1000,
    NNWebSocketStatusGoingAway = 1001,
    NNWebSocketStatusProtocolError = 1002,
    NNWebSocketStatusDataTypeError = 1003,
    NNWebSocketStatusFrameTooLarge = 1004,
    NNWebSocketStatusNoStatus = 1005,
    NNWebSocketStatusDisconnectWithoutClosing = 1006,
    NNWebSocketStatusInvalidUTF8Text = 1007
} NNWebSocketStatus;

////////////////////////////////////////////////////////////////////
// Interfaces
////////////////////////////////////////////////////////////////////

@interface NNWebSocket()
@property(nonatomic, retain) NNWebSocketOptions* options;
@property(nonatomic, retain) GCDAsyncSocket* socket;
@property(nonatomic, assign) NNWebSocketState* state;
@property(nonatomic, retain) NSString* scheme;
@property(nonatomic, retain) NSString* host;
@property(nonatomic, assign) UInt16 port;
@property(nonatomic, retain) NSString* resource;
@property(nonatomic, retain) NSString* protocols;
@property(nonatomic, retain) NSString* origin;
@property(nonatomic, retain) NSString* expectedAcceptKey;
@property(nonatomic, retain) NNWebSocketFrame* currentFrame;
@property(nonatomic, assign) UInt64 readPayloadRemains;
@property(nonatomic, assign) NSUInteger readPayloadSplitCount;
@property(nonatomic, retain) NSNumber* closeCode;
@property(nonatomic, assign) BOOL clientInitiatedClosure;
- (void)didConnect;
- (void)didConnectFailed:(NSError*)error;
- (void)didDisconnect:(BOOL)clientInitiated status:(NSUInteger)status error:(NSError*)error;
- (void)didReceive:(NNWebSocketFrame*)frame;
- (void)changeState:(NNWebSocketState *)newState;
@end

// Abstract states =================================================

@interface NNWebSocketState : NSObject
- (void)didEnter:(NNWebSocket*)ctx;
- (void)didExit:(NNWebSocket*)ctx;
- (void)connect:(NNWebSocket*)ctx;
- (void)disconnect:(NNWebSocket*)ctx status:(NSUInteger)status;
- (void)send:(NNWebSocket*)ctx frame:(NNWebSocketFrame*)frame;
- (void)didOpen:(NNWebSocket*)ctx;
- (void)didClose:(NNWebSocket*)ctx error:(NSError*)error;
- (void)didRead:(NNWebSocket*)ctx data:(NSData*)data tag:(long)tag;
- (void)didWrite:(NNWebSocket*)ctx tag:(long)tag;
@end

// Concrete states =================================================

@interface NNWebSocketStateDisconnected : NNWebSocketState
+ (id)sharedState;
@end

@interface NNWebSocketStateConnecting : NNWebSocketState
+ (id)sharedState;
- (NSString*)createWebsocketKey;
- (NSString*)createExpectedWebsocketAccept:(NSString*)key;
- (void)fail:(NNWebSocket*)ctx code:(NSInteger)code;
- (void)handshake:(NNWebSocket*)ctx;
@end

@interface NNWebSocketStateConnected : NNWebSocketState
+ (id)sharedState;
- (void)readHeader:(NNWebSocket*)ctx;
- (void)readExtPayloadLength:(NNWebSocket*)ctx;
- (void)readPayload:(NNWebSocket*)ctx;
- (void)didReadHeader:(NNWebSocket*)ctx data:(NSData*)data;
- (void)didReadExtPayloadLength:(NNWebSocket*)ctx data:(NSData*)data;
- (void)didReadPayload:(NNWebSocket*)ctx data:(NSData*)data;
- (void)fail:(NNWebSocket*)ctx code:(NSInteger)code;

@end

@interface NNWebSocketStateDisconnecting : NNWebSocketStateConnected
+ (id)sharedState;
@end

////////////////////////////////////////////////////////////////////
// Implementations
////////////////////////////////////////////////////////////////////

@implementation NNWebSocket
@synthesize options = options_;
@synthesize socket = socket_;
@synthesize state = state_;
@synthesize scheme = scheme_;
@synthesize host = host_;
@synthesize port = port_;
@synthesize resource = resource_;
@synthesize protocols = protocols_;
@synthesize origin = origin_;
@synthesize expectedAcceptKey = expectedAcceptKey_;
@synthesize currentFrame = currentFrame_;
@synthesize readPayloadRemains = readPayloadRemains_;
@synthesize readPayloadSplitCount = readyPayloadDividedCnt_;
@synthesize closeCode = closeCode_;
@synthesize clientInitiatedClosure = clientInitiatedClosure_;
- (id)initWithURL:(NSURL*)url origin:(NSString*)origin protocols:(NSString*)protocols
{
    TRACE();
    return [self initWithURL:url origin:origin protocols:protocols options:nil];
}
- (id)initWithURL:(NSURL*)url origin:(NSString*)origin protocols:(NSString*)protocols options:(NNWebSocketOptions*)options
{
    TRACE();
    self = [super init];
    if (self) {
        NNWebSocketOptions* opts = [[options copy] autorelease];
        if (!opts) {
            opts = [NNWebSocketOptions options];
        }
        self.options = opts;
        self.scheme = url.scheme;
        self.host = url.host;
        self.port = [url.port unsignedIntValue];
        NSMutableString* resource = [NSMutableString stringWithString:url.path];
        if ([resource length] == 0) {
            [resource appendString:@"/"];
        }
        if (url.query) {
            [resource appendFormat:@"?%@", url.query];
        }
        self.resource = resource;
        self.origin = origin ? origin : url.host;
        self.protocols = protocols;
        self.state = [NNWebSocketStateDisconnected sharedState];
        self.socket = [[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()] autorelease];
    }
    return self;
}
- (void)dealloc
{
    TRACE();
    self.options = nil;
    self.socket.delegate = nil;
    self.state = nil;
    self.scheme = nil;
    self.socket = nil;
    self.host = nil;
    self.resource = nil;
    self.protocols = nil;
    self.origin = nil;
    self.expectedAcceptKey = nil;
    self.currentFrame = nil;
    self.closeCode = nil;
    [super dealloc];
}
- (void)connect
{
    TRACE();
    [self.state connect:self];
}
- (void)disconnect
{
    TRACE();
    [self disconnectWithStatus:WEBSOCKET_STATUS_NORMAL];
}
- (void)disconnectWithStatus:(NSUInteger)status
{
    TRACE();
    [self.state disconnect:self status:status];
}
- (void)send:(NNWebSocketFrame*)frame
{
    TRACE();
    [self.state send:self frame:frame];
}
- (void)didConnect
{
    TRACE();
    [self changeState:[NNWebSocketStateConnected sharedState]];
    [self emit:@"connect"];
}
- (void)didConnectFailed:(NSError*)error;
{
    TRACE();
    [self changeState:[NNWebSocketStateDisconnected sharedState]];
    NNArgs* args = [[NNArgs args] add:error];
    [self emit:@"connect_failed" args:args];
}
- (void)didDisconnect:(BOOL)clientInitiated status:(NSUInteger)status error:(NSError *)error
{
    TRACE();
    [self changeState:[NNWebSocketStateDisconnected sharedState]];
    NSNumber* ci = [NSNumber numberWithBool:clientInitiated];
    NSNumber* st = [NSNumber numberWithUnsignedInt:status];
    NNArgs* args = [[[[NNArgs args] add:ci] add:st] add:error];
    [self emit:@"disconnect" args:args];
}
- (void)didReceive:(NNWebSocketFrame*)frame
{
    TRACE();
    [self emit:@"receive" args:[[NNArgs args] add:frame]];
}
- (void)changeState:(NNWebSocketState *)newState
{
    TRACE();
    [state_ didExit:self];
    state_ = newState;
    [state_ didEnter:self];
}

// AsyncSocket Delegate -----------------------------------
- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
    TRACE();
    [state_ didOpen:self];
}
- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag
{
    TRACE();
    [state_ didRead:self data:data tag:tag];
}
- (void)socket:(GCDAsyncSocket *)socket didWriteDataWithTag:(long)tag;
{
    TRACE();
    [state_ didWrite:self tag:tag];
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    TRACE();
    [state_ didClose:self error:error];
}
@end


// Abstract state impls ============================================

@implementation NNWebSocketState
- (void)didEnter:(NNWebSocket*)ctx{}
- (void)didExit:(NNWebSocket*)ctx{}
- (void)connect:(NNWebSocket*)ctx{}
- (void)disconnect:(NNWebSocket*)ctx status:(NSUInteger)status{}
- (void)send:(NNWebSocket*)ctx frame:(NNWebSocketFrame*)frame{}
- (void)fail:(NNWebSocket*)ctx code:(NSInteger)code{}
- (void)didOpen:(NNWebSocket*)ctx{}
- (void)didClose:(NNWebSocket*)ctx error:(NSError*)error{}
- (void)didRead:(NNWebSocket*)ctx data:(NSData*)data tag:(long)tag{}
- (void)didWrite:(NNWebSocket*)ctx tag:(long)tag{}
@end

// Concrete state impls ============================================

@implementation NNWebSocketStateDisconnected
SHARED_STATE_METHOD()
- (void)didEnter:(NNWebSocket *)ctx
{
    TRACE();
    ctx.closeCode = nil;
    ctx.clientInitiatedClosure = NO;
    if (ctx.socket.isConnected) {
        [ctx.socket disconnect];
    }
}
- (void)connect:(NNWebSocket*)ctx
{
    TRACE();
    [ctx changeState:[NNWebSocketStateConnecting sharedState]];
}
@end

@implementation NNWebSocketStateConnecting
SHARED_STATE_METHOD()
- (void)didEnter:(NNWebSocket*)ctx
{
    TRACE();
    if (![@"ws" isEqualToString:ctx.scheme] && ![@"wss" isEqualToString:ctx.scheme]) {
        NSError* error = [NSError errorWithDomain:NNWEBSOCKET_ERROR_DOMAIN code:NNWebSocketErrorUnsupportedScheme userInfo:nil];
        [ctx didConnectFailed:error];
        return;
    }
    LOG(@"Connecting to %@://%@:%d", ctx.scheme, ctx.host, ctx.port);
    [ctx.socket connectToHost:ctx.host onPort:ctx.port withTimeout:ctx.options.connectTimeout error:nil];
}
- (void)didOpen:(NNWebSocket*)ctx
{
    TRACE();
    if ([@"wss" isEqualToString:ctx.scheme]) {
        [ctx.socket startTLS:ctx.options.tlsSettings];
    }
    if (ctx.options.enableBackgroundingOnSocket) {
        [ctx.socket performBlock:^{
            if([ctx.socket enableBackgroundingOnSocket]) {
                LOG(@"Succeed to start on background");
            } else {
                LOG(@"Failed to start on background");                
            }
        }];
    }
    LOG(@"Connected.");
    [self handshake:ctx];
}
- (void)didClose:(NNWebSocket*)ctx error:(NSError*)error
{
    TRACE();
    [ctx didConnectFailed:error];
}
- (void)didWrite:(NNWebSocket *)ctx tag:(long)tag
{
    TRACE();
    NSAssert(tag == TAG_OPENING_HANDSHAKE, @"");
    [ctx.socket readDataToData:[NSData dataWithBytes:"\r\n\r\n" length:4] withTimeout:ctx.options.readTimeout tag:TAG_OPENING_HANDSHAKE];    
}
- (void)didRead:(NNWebSocket *)ctx data:(NSData *)data tag:(long)tag
{
    TRACE();
    NSAssert(tag == TAG_OPENING_HANDSHAKE, @"");
    CFHTTPMessageRef response = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, FALSE);
    if (!CFHTTPMessageAppendBytes(response, [data bytes], [data length])) {
        [self fail:ctx code:NNWebSocketErrorHttpResponse];
        return;
    }
    if (!CFHTTPMessageIsHeaderComplete(response)) {
        [self fail:ctx code:NNWebSocketErrorHttpResponseHeader];
        return;
    }
    CFIndex statusCd = CFHTTPMessageGetResponseStatusCode(response);
    if (statusCd != 101) {
        [self fail:ctx code:NNWebSocketErrorHttpResponseStatus];
        return;
    }
    NSString* upgrade = [(NSString*)CFHTTPMessageCopyHeaderFieldValue(response, CFSTR("Upgrade")) autorelease];
    NSString* connection = [(NSString*)CFHTTPMessageCopyHeaderFieldValue(response, CFSTR("Connection")) autorelease];
    NSString* acceptKey = [(NSString*)CFHTTPMessageCopyHeaderFieldValue(response, CFSTR("Sec-WebSocket-Accept")) autorelease];
    CFRelease(response);
    if (![upgrade isEqualToString:@"websocket"]) {
        [self fail:ctx code:NNWebSocketErrorHttpResponseHeaderUpgrade];
        return;
    }
    if (![connection isEqualToString:@"Upgrade"]) {
        [self fail:ctx code:NNWebSocketErrorHttpResponseHeaderConnection];
        return;
    }
    if (![acceptKey isEqualToString:ctx.expectedAcceptKey]) {
        [self fail:ctx code:NNWebSocketErrorHttpResponseHeaderWebSocketAccept];
        return;
    }
    [ctx didConnect];
}
- (NSString*)createWebsocketKey
{
    TRACE();
    unsigned char keySrc[16];
    for (int i=0; i<16; i++) {
        unsigned char byte = arc4random() % 254;
        keySrc[i] = byte;
    }
    NSData* keyData = [NSData dataWithBytes:keySrc length:16];
    NNBase64* base64 = [NNBase64 base64];
    return [base64 encode:keyData];
}
- (NSString*)createExpectedWebsocketAccept:(NSString*)key
{
    TRACE();
    NSMutableString* str = [NSMutableString stringWithString:key];
    [str appendString:WEBSOCKET_GUID];
    NSData* src = [str dataUsingEncoding:NSASCIIStringEncoding];
    unsigned char wk[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([src bytes], [src length], wk);
    NSData* result = [NSData dataWithBytes:wk length:CC_SHA1_DIGEST_LENGTH];
    NNBase64* base64 = [NNBase64 base64];
    return [base64 encode:result];
}
- (void)fail:(NNWebSocket*)ctx code:(NSInteger)code
{
    TRACE();
    NSError* error = [NSError errorWithDomain:NNWEBSOCKET_ERROR_DOMAIN code:code userInfo:nil];
    [ctx didConnectFailed:error];
}
- (void)handshake:(NNWebSocket*)ctx
{
    TRACE();
    NSString* websocketKey = [self createWebsocketKey];
    ctx.expectedAcceptKey = [self createExpectedWebsocketAccept:websocketKey];
    NSMutableString* handshake = [[[NSMutableString alloc] initWithCapacity:10] autorelease];
    [handshake appendFormat:@"GET %@ HTTP/1.1\r\n", ctx.resource];
    [handshake appendFormat:@"Host:%@\r\n", ctx.host];
    [handshake appendFormat:@"Upgrade: websocket\r\n"];
    [handshake appendFormat:@"Connection: Upgrade\r\n"];
    [handshake appendFormat:@"Sec-WebSocket-Key:%@\r\n", websocketKey];
    [handshake appendFormat:@"Sec-WebSocket-Origin:%@\r\n", ctx.origin];
    if (ctx.protocols && [ctx.protocols length] > 0) {
        [handshake appendFormat:@"Sec-WebSocket-Protocol:%@\r\n", ctx.protocols];
    }
    [handshake appendFormat:@"Sec-WebSocket-Version:%d\r\n", WEBSOCKET_PROTOCOL_VERSION];
    [handshake appendFormat:@"\r\n"];
    NSData* request = [handshake dataUsingEncoding:NSASCIIStringEncoding];
    [ctx.socket writeData:request withTimeout:ctx.options.writeTimeout tag:TAG_OPENING_HANDSHAKE];
    
}
@end

@implementation NNWebSocketStateConnected
SHARED_STATE_METHOD()
- (void)disconnect:(NNWebSocket *)ctx status:(NSUInteger)status
{
    TRACE();
    ctx.closeCode= [NSNumber numberWithUnsignedInt:status];
    ctx.clientInitiatedClosure = YES;
    [ctx changeState:[NNWebSocketStateDisconnecting sharedState]];
}
- (void)send:(NNWebSocket *)ctx frame:(NNWebSocketFrame *)frame
{
    TRACE();
    [ctx.socket writeData:[frame dataFrame] withTimeout:ctx.options.writeTimeout tag:TAG_WRITE_FRAME];
}
- (void)didEnter:(NNWebSocket *)ctx
{
    TRACE();
    [self readHeader:ctx];
}
- (void)didClose:(NNWebSocket*)ctx error:(NSError*)error
{
    TRACE();
    NSUInteger code = ctx.closeCode ? [ctx.closeCode unsignedIntegerValue] : NNWebSocketStatusNoStatus;
    NSError* e = error;
    if (error && [GCDAsyncSocketErrorDomain isEqualToString:error.domain] && error.code == GCDAsyncSocketClosedError) {
        e = nil;
        if (!ctx.closeCode) {
            code = NNWebSocketStatusDisconnectWithoutClosing;            
        }
    }
    [ctx didDisconnect:ctx.clientInitiatedClosure status:code error:e];
}
- (void)didRead:(NNWebSocket *)ctx data:(NSData *)data tag:(long)tag
{
    TRACE();
    if (tag == TAG_READ_HEAD) {
        [self didReadHeader:ctx data:data];
    } else if (tag == TAG_READ_EXT_PAYLOAD_LENGTH) {
        [self didReadExtPayloadLength:ctx data:data];
    } else if (tag == TAG_READ_PAYLOAD) {
        [self didReadPayload:ctx data:data];
    }
}
- (void)readHeader:(NNWebSocket*)ctx
{
    TRACE();
    ctx.currentFrame = nil;
    ctx.readPayloadRemains = 0;
    ctx.readPayloadSplitCount = 0;
    [ctx.socket readDataToLength:2 withTimeout:-1 tag:TAG_READ_HEAD];    
}
- (void)readExtPayloadLength:(NNWebSocket*)ctx
{
    TRACE();
    int payloadLen = ctx.currentFrame.payloadLength;
    NSAssert(payloadLen == 126 || payloadLen == 127, @"");
    NSUInteger readLen = payloadLen == 126 ? 2 : 8;
    [ctx.socket readDataToLength:readLen withTimeout:ctx.options.readTimeout tag:TAG_READ_EXT_PAYLOAD_LENGTH];
}
- (void)readPayload:(NNWebSocket*)ctx
{
    TRACE();
    int payloadLen = ctx.currentFrame.payloadLength;
    UInt64 len = payloadLen <= 125 ? payloadLen : ctx.currentFrame.extendedPayloadLength;
    ctx.readPayloadRemains = len;
    if (len == 0) {
        [self didRead:ctx data:[NSData data] tag:TAG_READ_PAYLOAD];
        return;
    }
    NSUInteger readLen = MIN(len, ctx.options.maxPayloadSize);
    [ctx.socket readDataToLength:readLen withTimeout:ctx.options.readTimeout tag:TAG_READ_PAYLOAD];
}
- (void)didReadHeader:(NNWebSocket*)ctx data:(NSData*)data
{
    TRACE();
    UInt8* b = (UInt8*)[data bytes];
    int opcode = b[0] & NNWebSocketFrameMaskOpcode;
    NNWebSocketFrame* frame = [NNWebSocketFrame frameWithOpcode:opcode];
    frame.fin = (b[0] & NNWebSocketFrameMaskFin) > 0;
    frame.rsv1 = (b[0] & NNWebSocketFrameMaskRsv1) > 0;
    frame.rsv2 = (b[0] & NNWebSocketFrameMaskRsv2) > 0;
    frame.rsv3 = (b[0] & NNWebSocketFrameMaskRsv3) > 0;
    frame.mask = (b[1] & NNWebSocketFrameMaskMask) > 0;
    if (frame.mask) {
        [self fail:ctx code:NNWebSocketErrorReceiveFrameMask];
        return;
    }
    frame.payloadLength = b[1] & NNWebSocketFrameMaskPayloadLength;
    TRACE(@"Received opcode:%d payloadLen:%d",opcode, frame.payloadLength);
    ctx.currentFrame = frame;
    if (frame.payloadLength > 125) {
        [self readExtPayloadLength:ctx];
    } else {
        [self readPayload:ctx];
    }
}
- (void)didReadExtPayloadLength:(NNWebSocket*)ctx data:(NSData*)data
{
    TRACE();
    NSUInteger dataLen = [data length];
    NSAssert(dataLen == 2 || dataLen == 8, @"");
    UInt8* b = (UInt8*)[data bytes];
    int cnt = 0;
    UInt64 extPayloadLen = 0;
    for (int i=dataLen; i>0; i--) {
        int shift = (i -1) * 8;
        extPayloadLen += b[cnt++] << shift;
    }
    ctx.currentFrame.extendedPayloadLength = extPayloadLen;
    [self readPayload:ctx];
}
- (void)didReadPayload:(NNWebSocket*)ctx data:(NSData*)data
{
    TRACE();
    NNWebSocketFrame* curFrame = ctx.currentFrame;
    // check closure
    if (curFrame.opcode == NNWebSocketFrameOpcodeClose) {
        UInt16 status = NNWebSocketStatusNoStatus;
        if ([data length] >= 2) {
            UInt8* b = (UInt8*)[data bytes];
            status = b[0] << 8;
            status += b[1];
        }
        ctx.closeCode = [NSNumber numberWithUnsignedInt:status];
        if (!ctx.clientInitiatedClosure) {
            [ctx changeState:[NNWebSocketStateDisconnecting sharedState]];
        }
        return;
    }
    ctx.readPayloadRemains -= [data length];
    NNWebSocketFrame* frame;
    if (ctx.readPayloadSplitCount == 0) {
        if (ctx.readPayloadRemains == 0) {
            frame = [[curFrame autorelease] retain];
        } else {
            frame = [NNWebSocketFrame frameWithOpcode:curFrame.opcode];
            frame.rsv1 = curFrame.rsv1;
            frame.rsv2 = curFrame.rsv2;
            frame.rsv3 = curFrame.rsv3;
            if (curFrame.fin) {
                frame.fin = NO;
            }
        }
    } else {
        frame = [NNWebSocketFrame frameWithOpcode:NNWebSocketFrameOpcodeConitunuation];
        frame.rsv1 = curFrame.rsv1;
        frame.rsv2 = curFrame.rsv2;
        frame.rsv3 = curFrame.rsv3;
        frame.fin = ctx.readPayloadRemains == 0 && curFrame.fin;
    }
    frame.payloadData = data;
    if (ctx.readPayloadRemains == 0) {
        [self readHeader:ctx];
        [ctx didReceive:frame];
    } else {
        [ctx didReceive:frame];
        ctx.readPayloadSplitCount++;
        NSUInteger readLen = MIN(ctx.readPayloadRemains, ctx.options.maxPayloadSize);
        [ctx.socket readDataToLength:readLen withTimeout:ctx.options.readTimeout tag:TAG_READ_PAYLOAD];
    }
}
- (void)fail:(NNWebSocket*)ctx code:(NSInteger)code
{
    TRACE();
    NSError* error = [NSError errorWithDomain:NNWEBSOCKET_ERROR_DOMAIN code:code userInfo:nil];
    [ctx didDisconnect:NO status:NNWebSocketStatusDataTypeError error:error];
}
@end

@implementation NNWebSocketStateDisconnecting
SHARED_STATE_METHOD()
- (void)disconnect:(NNWebSocket *)ctx status:(NSUInteger)status
{
    TRACE();
    // Do nothing.
}
- (void)send:(NNWebSocket *)ctx frame:(NNWebSocketFrame *)frame
{
    TRACE();
    // Do nothing.
}
- (void)didEnter:(NNWebSocket *)ctx
{
    TRACE();
    NNWebSocketFrame* frame = [NNWebSocketFrame frameClose];
    if (ctx.closeCode) {
        UInt16 c = [ctx.closeCode unsignedIntegerValue];
        UInt8 b[2] = {c >> 8, c & 0xff};
        NSData* payloadData = [NSData dataWithBytes:b length:2];        
        frame.payloadData = payloadData;
    }
    [ctx.socket writeData:[frame dataFrame] withTimeout:ctx.options.writeTimeout tag:TAG_WRITE_FRAME];
}
@end
