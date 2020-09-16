//
//  ToneBarrierScoreDispatch.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/16/20.
//

#import "ToneBarrierScoreDispatchObjects.h"

@implementation ToneBarrierScoreDispatchObjects

static ToneBarrierScoreDispatchObjects * sharedDispatchObjects = NULL;
+ (nonnull ToneBarrierScoreDispatchObjects *)sharedDispatchObjects;
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^{
        if (!sharedDispatchObjects)
        {
            sharedDispatchObjects = [[self alloc] init];
        }
    });
    
    return sharedDispatchObjects;
}

- (instancetype)init
{
    if (self == [super init])
    {
        self.tone_barrier_dispatch_queue = dispatch_queue_create("Tone Barrier Dispatch Queue", DISPATCH_QUEUE_CONCURRENT);
        self.tone_barrier_dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, self.tone_barrier_dispatch_queue);
    }
    
    return self;
}

@end
