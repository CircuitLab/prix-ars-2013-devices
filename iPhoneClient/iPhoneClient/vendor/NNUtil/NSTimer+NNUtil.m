#import "NSTimer+NNUtil.h"

const NSTimeInterval NNTimerBlockCotinue = 0;
const NSTimeInterval NNTimerBlockFinish = -1;

@interface NSTimer()

+ (void)executeBlock:(NSTimer*)timer;

@end

@implementation NSTimer (NNUtil)

+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(NNTimerBlock)block
{
    return [self scheduledTimerWithTimeInterval:seconds target:self selector:@selector(executeBlock:) userInfo:[[block copy] autorelease] repeats:YES];
}

+ (NSTimer*)timerWithTimeInterval:(NSTimeInterval)seconds block:(NNTimerBlock)block
{
    return [self timerWithTimeInterval:seconds target:self selector:@selector(executeBlock:) userInfo:[[block copy] autorelease] repeats:YES];
}

+ (void)executeBlock:(NSTimer*)timer
{
    NNTimerBlock block = timer.userInfo;
    NSTimeInterval result = block();
    if (result == NNTimerBlockFinish) {
        [timer invalidate];
    } else if (result > 0 || timer.timeInterval != result) {
        [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:result]];
    }
}

@end
