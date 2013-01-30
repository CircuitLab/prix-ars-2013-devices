#import <Foundation/Foundation.h>

@interface NNArgs : NSObject
{
    @private
    NSMutableArray* array_;
}

@property(nonatomic, readonly) NSArray* array;
@property(nonatomic, readonly) NSUInteger count;

+ (id)args;
- (id)add:(id)value;
- (id)addAll:(NSArray*)array;
- (id)get:(NSUInteger)index;

@end
