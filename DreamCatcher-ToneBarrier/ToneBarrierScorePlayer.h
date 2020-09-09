//
//  ToneBarrierScorePlayer.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^BufferConsumed)(
                               void (^RenderBuffer)(AVAudioPlayerNode * _Nonnull));

typedef void (^ConsumeBuffer)(AVAudioPlayerNode * _Nonnull,
                              void (^)(AVAudioPlayerNode * _Nonnull));

typedef void (^BufferRendered)(void (^)(AVAudioPCMBuffer * _Nonnull,
                                   void (^)(AVAudioPlayerNode * _Nonnull,
                                            void (^)(AVAudioPlayerNode * _Nonnull))));
                          
typedef void (^BufferRenderer)(AVAudioFormat * _Nonnull, AVAudioSession * _Nonnull,
                          void (^)(AVAudioPCMBuffer * _Nonnull,
                                   void (^)(AVAudioPlayerNode * _Nonnull)));
                          
typedef void (^RenderBuffer)(AVAudioPlayerNode * _Nonnull,
                               void (^BufferRenderer)(AVAudioFormat * _Nonnull, AVAudioSession * _Nonnull,
                                                    void (^BufferRendered)(AVAudioPCMBuffer * _Nonnull,
                                                             void (^ConsumeBuffer)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull,
                                                                      void (^BufferConsumed)(AVAudioPlayerNode * _Nonnull)))));


@interface ToneBarrierScorePlayer : NSObject

+ (nonnull ToneBarrierScorePlayer *)sharedPlayer;

@property (nonatomic, strong) AVAudioEngine * _Nonnull audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode * _Nullable playerNode;
@property (nonatomic, strong) AVAudioPlayerNode * _Nullable playerNodeAux;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mainNode;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mixerNode;
@property (nonatomic, strong) AVAudioFormat * _Nullable     audioFormat;
@property (nonatomic, strong) AVAudioUnitReverb * _Nullable reverb;

@property (nonatomic, strong) MPRemoteCommandCenter * commandCenter;


- (BOOL)play;


@end

NS_ASSUME_NONNULL_END
