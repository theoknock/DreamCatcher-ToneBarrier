//
//  ToneBarrierScorePlayer.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void (^PlayedToneCompletionBlock)(void);
typedef void (^BufferRenderedCompletionBlock)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, PlayedToneCompletionBlock _Nonnull);
typedef void (^RenderBuffer)(AVAudioPlayerNode * _Nonnull, AVAudioSession *, AVAudioFormat *, void (^)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, void (^)(void)));

@interface ToneBarrierScorePlayer : NSObject

+ (nonnull ToneBarrierScorePlayer *)sharedPlayer;

@property (nonatomic, strong) AVAudioEngine * _Nonnull audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode * _Nullable playerNode;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mainNode;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mixerNode;
@property (nonatomic, strong) AVAudioFormat * _Nullable     audioFormat;
@property (nonatomic, strong) AVAudioUnitReverb * _Nullable reverb;

@property (copy, nonatomic) void (^RenderBuffer)(AVAudioPlayerNode * _Nonnull, AVAudioSession *, AVAudioFormat *, void (^)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, void (^)(void)));

- (BOOL)play;


@end

NS_ASSUME_NONNULL_END
