#import "SSignal.h"

static dispatch_block_t recursiveBlock(void (^block)(dispatch_block_t recurse))
{
    return ^
    {
        block(recursiveBlock(block));
    };
}

@interface SSignal (Catch)

- (SSignal *)catch:(SSignal *(^)(id error))f;
- (SSignal *)restart;
- (SSignal *)retryIf:(bool (^)(id error))predicate;

@end
