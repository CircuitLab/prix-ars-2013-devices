#import "NNArgs.h"

@implementation NNArgs

@synthesize array = array_;

+ (NNArgs*)args
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        array_ = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [array_ release];
    [super dealloc];
}

- (id)add:(id)value
{
    [array_ addObject:value ? value : [NSNull null]];
     return self;
}

- (id)addAll:(NSArray *)array
{
    [array_ addObjectsFromArray:array];
    return self;
}

- (id)get:(NSUInteger)index
{
    if (array_.count <= index) {
        return nil;
    }
    id obj = [array_ objectAtIndex:index];
    return [NSNull null] == obj ? nil : obj;
}

- (NSUInteger)count
{
    return array_.count;
}

@end
