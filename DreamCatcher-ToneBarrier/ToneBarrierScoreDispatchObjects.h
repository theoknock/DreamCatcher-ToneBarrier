//
//  ToneBarrierScoreDispatch.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/16/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToneBarrierScoreDispatchObjects : NSObject

+ (nonnull ToneBarrierScoreDispatchObjects *)sharedDispatchObjects;

@property (strong, nonatomic) dispatch_queue_t tone_barrier_dispatch_queue;
@property (strong, nonatomic) dispatch_source_t tone_barrier_dispatch_source;

@end

NS_ASSUME_NONNULL_END
