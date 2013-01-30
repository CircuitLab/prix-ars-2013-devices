#import <Foundation/Foundation.h>
#import "NNArgs.h"

typedef void (^NNEventListener)(NNArgs* args);

@interface NNEventEmitter : NSObject
{
   @private
    NSMutableDictionary* eventListenerGroup_;
    NSMutableDictionary* onceEventListenerGroup_;    

}

- (id)init;
- (void)on:(NSString*)eventName listener:(NNEventListener)listener;
- (void)once:(NSString*)eventName listener:(NNEventListener)listener;
- (void)emit:(NSString*)eventName;
- (void)emit:(NSString*)eventName args:(NNArgs*)event;
- (NSArray*)listeners:eventName;
- (void)removeLisitener:(NSString*)eventName listener:(NNEventListener)listener;

@end
