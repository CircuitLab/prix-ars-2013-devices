#import "NNWebSocketOptions.h"
#import "NNWebSocketDebug.h"

@implementation NNWebSocketOptions
@synthesize connectTimeout = connectTimeout_;
@synthesize readTimeout = readTimeout_;
@synthesize writeTimeout = writeTimeout_;
@synthesize tlsSettings = tlsSettings_;
@synthesize maxPayloadSize = maxPayloadSize_;
@synthesize enableBackgroundingOnSocket = enableBackgroundingOnSocket_;
+(NNWebSocketOptions*)options
{
    TRACE();
    return [[[self alloc] init] autorelease];
}
- (id)init
{
    TRACE();
    self = [super init];
    if (self) {
        self.connectTimeout = 5;
        self.readTimeout = 5;
        self.writeTimeout = 5;
        self.maxPayloadSize = 16384;
        self.enableBackgroundingOnSocket = NO;
    }
    return self;
}
-(void)dealloc
{
    TRACE();
    self.tlsSettings = nil;
    [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
    TRACE();
    NNWebSocketOptions* o = [[NNWebSocketOptions allocWithZone:zone] init];
    if (o) {
        o.connectTimeout = self.connectTimeout;
        o.readTimeout = self.readTimeout;
        o.writeTimeout = self.writeTimeout;
        o.tlsSettings = [[self.tlsSettings copyWithZone:zone] autorelease];
        o.maxPayloadSize = self.maxPayloadSize;
        o.enableBackgroundingOnSocket = self.enableBackgroundingOnSocket;
    }
    return o;
}
@end
