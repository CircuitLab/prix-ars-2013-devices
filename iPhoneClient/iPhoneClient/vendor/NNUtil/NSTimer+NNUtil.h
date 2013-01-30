#import <Foundation/Foundation.h>

typedef NSTimeInterval (^NNTimerBlock)();
const extern NSTimeInterval NNTimerBlockCotinue;
const extern NSTimeInterval NNTimerBlockFinish;

@interface NSTimer (NNUtil)

+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(NNTimerBlock)block;
+ (NSTimer*)timerWithTimeInterval:(NSTimeInterval)seconds block:(NNTimerBlock)block;

@end
