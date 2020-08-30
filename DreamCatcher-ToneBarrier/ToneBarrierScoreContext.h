//
//  ToneBarrierScoreContext.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/29/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ToneBarrierScoreDelegate <NSObject>

- (void)createAudioBufferWithFormat:(AVAudioFormat * _Nonnull)audioFormat completionBlock:(CreateAudioBufferCompletionBlock _Nonnull )createAudioBufferCompletionBlock;

@end

@interface ToneBarrierScoreContext : NSObject

@property (assign) id<ToneBarrierScoreDelegate> player;

@end

NS_ASSUME_NONNULL_END
