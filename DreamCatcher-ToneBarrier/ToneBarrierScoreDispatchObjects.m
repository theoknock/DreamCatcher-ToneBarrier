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
    }
    
    return self;
}


static dispatch_queue_t _tone_barrier_dispatch_queue = nil;

+ (void)setTone_barrier_dispatch_queue:(dispatch_queue_t)tone_barrier_dispatch_queue
{
    _tone_barrier_dispatch_queue = dispatch_queue_create("Tone Barrier Dispatch Queue", DISPATCH_QUEUE_CONCURRENT);
}

+ (dispatch_queue_t)tone_barrier_dispatch_queue
{
    return _tone_barrier_dispatch_queue;
}

static dispatch_source_t _tone_barrier_dispatch_source = nil;

+ (void)setTone_barrier_dispatch_source:(dispatch_source_t)tone_barrier_dispatch_source
{
    _tone_barrier_dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, _tone_barrier_dispatch_queue);
}

+ (dispatch_source_t)tone_barrier_dispatch_source
{
    return _tone_barrier_dispatch_source;
}

@end
