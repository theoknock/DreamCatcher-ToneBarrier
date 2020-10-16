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
                          
//typedef void (^BufferRenderer)(AVAudioFormat * _Nonnull, AVAudioSession * _Nonnull,
//                          void (^)(AVAudioPCMBuffer * _Nonnull,
//                                   void (^)(AVAudioPlayerNode * _Nonnull)));
    

//typedef void (^RenderBuffer)(AVAudioPlayerNode * _Nonnull,
//                               void (^BufferRenderer)(AVAudioFormat * _Nonnull, AVAudioSession * _Nonnull,
//                                                    void (^BufferRendered)(AVAudioPCMBuffer * _Nonnull,
//                                                             void (^ConsumeBuffer)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull,
//                                                                      void (^BufferConsumed)(AVAudioPlayerNode * _Nonnull)))));


typedef struct AudioEngineStatus
{
    enum : unsigned int {
        AudioEngineStatusPlaying,
        AudioEngineStatusStopped,
        AudioEngineStatusError
    } status;
} AudioEngineStatus;

// To explicitly start or stop audio engine without testing isRunning property (which does not indicate whether tone barrier is actually playing)
typedef struct AudioEngineCommand
{
    enum : unsigned int {
        AudioEngineCommandPlay,
        AudioEngineCommandStop,
        AudioEngineCommandPause,
        AudioEngineCommandInit,
        AudioEngineCommandStart
    } command;
} AudioEngineCommand;


@interface ToneBarrierScorePlayer : NSObject

+ (nonnull ToneBarrierScorePlayer *)sharedPlayer;

@property (nonatomic, strong) AVAudioEngine * _Nonnull audioEngine;
@property (nonatomic, strong) AVAudioPlayerNode * _Nullable playerNode;
@property (nonatomic, strong) AVAudioPlayerNode * _Nullable playerNodeAux;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mainNode;
@property (nonatomic, strong) AVAudioMixerNode * _Nullable  mixerNode;
@property (nonatomic, strong) AVAudioFormat * _Nullable     audioFormat;
@property (nonatomic, strong) AVAudioUnitReverb * _Nullable reverb;
@property (nonatomic, strong) AVAudioPCMBuffer * pcmBuffer;
@property (nonatomic, strong) AVAudioPCMBuffer * pcmBufferAux;

@property (nonatomic, strong) MPRemoteCommandCenter * commandCenter;
@property (nonatomic, strong) NSMutableDictionary<NSString *, id> * nowPlayingInfo;

@property (strong, nonatomic) dispatch_queue_t audio_engine_status_dispatch_queue;
@property (strong, nonatomic) dispatch_source_t audio_engine_status_dispatch_source;

@property (strong, nonatomic) dispatch_queue_t audio_engine_command_dispatch_queue;
@property (strong, nonatomic) dispatch_source_t audio_engine_command_dispatch_source;

- (BOOL)play;

@end

NS_ASSUME_NONNULL_END
