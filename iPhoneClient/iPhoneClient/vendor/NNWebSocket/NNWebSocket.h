#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "NNWebSocketOptions.h"
#import "NNWebSocketFrame.h"
#import "NNEventEmitter.h"

@class NNWebSocketState;

#define NNWEBSOCKET_ERROR_DOMAIN @"NNWebSocketErrorDmain"

typedef enum {
    // 1xx: connection error
    NNWebSocketErrorUnsupportedScheme = 100,
    NNWebSocketErrorHttpResponse,
    NNWebSocketErrorHttpResponseHeader,
    NNWebSocketErrorHttpResponseStatus,
    NNWebSocketErrorHttpResponseHeaderUpgrade,
    NNWebSocketErrorHttpResponseHeaderConnection,
    NNWebSocketErrorHttpResponseHeaderWebSocketAccept,
    // 2xx: wire format error
    NNWebSocketErrorReceiveFrameMask = 200,
} NNWebSocketErrors;

@interface NNWebSocket : NNEventEmitter
{
    @private
    NNWebSocketOptions* options_;
    GCDAsyncSocket* socket_;
    NNWebSocketState* state_;
    NSString* scheme_;
    NSString* host_;
    UInt16 port_;
    NSString* resource_;
    NSString* protocols_;
    NSString* origin_;
    NSString* expectedAcceptKey_;
    NNWebSocketFrame* currentFrame_;
    UInt64 readPayloadRemains_;
    NSUInteger readyPayloadDividedCnt_;
    NSNumber* closeCode_;
    BOOL clientInitiatedClosure_;
}
- (id)initWithURL:(NSURL*)url origin:(NSString*)origin protocols:(NSString*)protocols;
- (id)initWithURL:(NSURL *)url origin:(NSString *)origin protocols:(NSString *)protocols options:(NNWebSocketOptions*)options;
- (void)connect;
- (void)disconnect;
- (void)disconnectWithStatus:(NSUInteger)status;
- (void)send:(NNWebSocketFrame*)frame;
@end
