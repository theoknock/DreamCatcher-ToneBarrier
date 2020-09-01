//
//  ToneBarrierScorePlayer.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

//typedef void (^BufferConsumedCompletionBlock)(void);
//typedef void (^ConsumeBufferBlock)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, BufferConsumedCompletionBlock);
//typedef void (^BufferRenderedCompletionBlock)(ConsumeBufferBlock);
//typedef void (^RenderBufferBlock)(AVAudioSession * _Nonnull, AVAudioFormat * _Nonnull, BufferRenderedCompletionBlock);


@interface ToneBarrierScorePlayer : NSObject

+ (nonnull ToneBarrierScorePlayer *)sharedInstance;

@property (nonatomic, strong) AVAudioEngine * _Nonnull audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode * _Nullable playerNode;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mainNode;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mixerNode;
@property (nonatomic, strong) AVAudioFormat * _Nullable     audioFormat;
@property (nonatomic, strong) AVAudioUnitReverb * _Nullable reverb;

- (BOOL)play;

//@property (copy, nonatomic, readwrite) BufferConsumedCompletionBlock bufferConsumed;
//@property (copy, nonatomic, readwrite)  void (^ _Nonnull (^ _Nonnull buffer_consumed)(void))(AVAudioSession * _Nonnull, AVAudioFormat * _Nonnull /*, BufferRenderedCompletionBlock*/);
//@property (copy, nonatomic, readwrite) ConsumeBufferBlock consumeBuffer;
//@property (copy, nonatomic, readwrite) BufferRenderedCompletionBlock bufferRendered;
//@property (copy, nonatomic, readwrite) RenderBufferBlock renderBuffer;







@end

NS_ASSUME_NONNULL_END
