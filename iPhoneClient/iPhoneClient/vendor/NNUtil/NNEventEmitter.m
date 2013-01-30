#import "NNEventEmitter.h"
#import "NNDebug.h"

@interface NNEventEmitter()

@property(nonatomic, retain) NSMutableDictionary* eventListenerGroup;
@property(nonatomic, retain) NSMutableDictionary* onceEventListenerGroup;

- (NSMutableArray*)listeners:(NSMutableDictionary*)listenerGroup eventName:(NSString*)eventName;
- (void)fire:(NSMutableArray*)listeners args:(NNArgs*)args;

@end

@implementation NNEventEmitter

@synthesize eventListenerGroup = eventListenerGroup_;
@synthesize onceEventListenerGroup = onceEventListenerGroup_;

- (id)init
{
    self = [super init];
    if (self) {
        self.eventListenerGroup = [NSMutableDictionary dictionary];
        self.onceEventListenerGroup = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.eventListenerGroup = nil;
    self.onceEventListenerGroup = nil;
    [super dealloc];
}

- (void)on:(NSString*)eventName listener:(NNEventListener)listener
{
    if (!listener) return;
    NSMutableArray* listeners = [self listeners:self.eventListenerGroup eventName:eventName];
    [listeners addObject:[[listener copy] autorelease]];
}

- (void)once:(NSString*)eventName listener:(NNEventListener)listener
{
    if (!listener) return;
    NSMutableArray* listeners = [self listeners:self.onceEventListenerGroup eventName:eventName];
    [listeners addObject:[[listener copy] autorelease]];
}

- (void)emit:(NSString*)eventName;
{
    [self emit:eventName args:nil];
}

- (void)emit:(NSString*)eventName args:(NNArgs*)args
{
    [self fire:[self.eventListenerGroup objectForKey:eventName] args:args];
    NSMutableArray* onceListeners = [self.onceEventListenerGroup objectForKey:eventName];
    [self fire:onceListeners args:args];
    [onceListeners removeAllObjects];     

}

- (NSArray*)listeners:(id)eventName
{
    NSMutableArray* listeners = [self listeners:self.eventListenerGroup eventName:eventName];
    NSMutableArray* onceListeners = [self listeners:self.onceEventListenerGroup eventName:eventName];
    NSArray* array = [NSMutableArray arrayWithArray:listeners];
    return [array arrayByAddingObjectsFromArray:onceListeners];
}

- (void)removeLisitener:(NSString*)eventName listener:(NNEventListener)listener
{
    NSMutableArray* listeners = nil;
    listeners = [self listeners:self.eventListenerGroup eventName:eventName];
    [listeners removeObject:listener];
    listeners = [self listeners:self.onceEventListenerGroup eventName:eventName];    
    [listeners removeObject:listener];    
}

- (NSMutableArray*)listeners:(NSMutableDictionary*)listenerGroup eventName:(NSString*)eventName
{
    NSMutableArray* list = [listenerGroup objectForKey:eventName];
    if (!list) {
        list = [NSMutableArray array];
        [listenerGroup setObject:list forKey:eventName];
    }
    return list;
}

- (void)fire:(NSMutableArray*)listeners args:(NNArgs*)args
{
    if (!listeners) return;
    dispatch_queue_t queue = dispatch_get_main_queue();
    for (NNEventListener block in listeners) {
        dispatch_async(queue, ^{
            block(args);
        });
    }
}

@end
