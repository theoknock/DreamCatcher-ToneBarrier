//
//  ToneBarrierScorePlayer.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//


//
//  ToneBarrierScorePlayer.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import "ToneBarrierScorePlayer.h"
#include "Randomizer.h"
#include "Score.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GameKit/GameKit.h>
#import <objc/runtime.h>

typedef uint32_t AVAudioPlayerNodeCount, AVAudioPlayerNodeIndex;

//- (double(^)(double, double))Trill
//{
//    return ^double(double time, double trill)
//    {
//        return pow(2.0 * pow(sinf(M_PI * time * trill), 2.0) * 0.5, 4.0);
//    };
//}

@interface ToneBarrierScorePlayer ()

@end

@implementation ToneBarrierScorePlayer

static ToneBarrierScorePlayer * sharedPlayer = NULL;
+ (nonnull ToneBarrierScorePlayer *)sharedPlayer;
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^{
        if (!sharedPlayer)
        {
            sharedPlayer = [[self alloc] init];
        }
    });
    
    return sharedPlayer;
}

- (instancetype)init
{
    if (self == [super init])
    {
        [self setupEngine];
    }
    
    return self;
}

- (BOOL)setupEngine
{
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.mainNode = [self.audioEngine mainMixerNode];
    AVAudioChannelCount channelCount = [self.mainNode outputFormatForBus:0].channelCount;
    const double sampleRate = [self.mainNode outputFormatForBus:0].sampleRate;
    self.audioFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:sampleRate channels:channelCount];
    
    return (self.audioEngine != nil) ? TRUE : FALSE;
}

- (BOOL)startEngine
{
    __autoreleasing NSError *error = nil;
    if ([self.audioEngine startAndReturnError:&error])
    {
        NSLog(@"1/3. AudioEngine started: %@", error.description);
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error)
        {
            NSLog(@"1/3. AudioSession category could not be set: %@", [error description]);
            return FALSE;
        } else {
            NSLog(@"2/3. AudioSession configured %@", [error description]);
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (error)
            {
                NSLog(@"2/3. AudioSession could not be activated: %@", [error description]);
                return FALSE;
            } else {
                NSLog(@"3/3. AudioSession activated%@", [error description]);
                return TRUE;
            }
        }
    } else {
        NSLog(@"1/3. AudioEngine could not be started: %@", [error description]);
        return FALSE;
    }
}

typedef void (^PlayedToneCompletionBlock)(void);
typedef void (^BufferRenderedCompletionBlock)(AVAudioPCMBuffer * _Nonnull, PlayedToneCompletionBlock _Nonnull);

typedef double (^Normalize)(double, double, double);
Normalize normalize = ^double(double min, double max, double value)
{
    double result = (value - min) / (max - min);
    
    return result;
};

typedef double (^FrequencySample)(double, double);
FrequencySample sample_frequency = ^(double time, double frequency)
{
    double result = sinf(M_PI * time * ^double(double frequency) {
        return ((frequency / (2000.0 - 400.0) * (12.0 - 4.0)) + 4.0);
    } (frequency));
    
    return result;
};

typedef double (^AmplitudeSample)(double, double);
AmplitudeSample sample_amplitude = ^(double time, double gain)
{
    double result = sinf((M_PI_PI * time) / 2) * gain;
    
    return result;
};

- (BOOL)play
{
    if ([self.audioEngine isRunning])
    {
        [self.playerNode pause];
        [self.playerNodeAux pause];
        
        [self.audioEngine pause];
        
        [self.audioEngine detachNode:self.playerNode];
        self.playerNode = nil;
        [self.audioEngine detachNode:self.playerNodeAux];
        self.playerNodeAux = nil;
        
        [self.audioEngine detachNode:self.reverb];
        self.reverb = nil;
        
        [self.audioEngine detachNode:self.mixerNode];
        self.mixerNode = nil;
        
        [self.audioEngine stop];
        
        return FALSE;
    } else {
        [self setupEngine];
        
        self.playerNode = [[AVAudioPlayerNode alloc] init];
        [self.playerNode setRenderingAlgorithm:AVAudio3DMixingRenderingAlgorithmAuto];
        [self.playerNode setSourceMode:AVAudio3DMixingSourceModeAmbienceBed];
        [self.playerNode setPosition:AVAudioMake3DPoint(0.0, 0.0, 0.0)];
        
        self.playerNodeAux = [[AVAudioPlayerNode alloc] init];
        [self.playerNodeAux setRenderingAlgorithm:AVAudio3DMixingRenderingAlgorithmAuto];
        [self.playerNodeAux setSourceMode:AVAudio3DMixingSourceModeAmbienceBed];
        [self.playerNodeAux setPosition:AVAudioMake3DPoint(0.0, 0.0, 0.0)];
        
        self.mixerNode = [[AVAudioMixerNode alloc] init];
        
        self.reverb = [[AVAudioUnitReverb alloc] init];
        [self.reverb loadFactoryPreset:AVAudioUnitReverbPresetLargeChamber];
        [self.reverb setWetDryMix:50.0];
        
        [self.audioEngine attachNode:self.reverb];
        [self.audioEngine attachNode:self.playerNode];
        [self.audioEngine attachNode:self.playerNodeAux];
        [self.audioEngine attachNode:self.mixerNode];
        
        [self.audioEngine connect:self.playerNode     to:self.mixerNode  format:self.audioFormat];
        [self.audioEngine connect:self.playerNodeAux  to:self.mixerNode  format:self.audioFormat];
        [self.audioEngine connect:self.mixerNode      to:self.reverb     format:self.audioFormat];
        [self.audioEngine connect:self.reverb         to:self.mainNode   format:self.audioFormat];
        
        if ([self startEngine])
        {
            if (![self.playerNode isPlaying]) [self.playerNode play];
            if (![self.playerNodeAux isPlaying]) [self.playerNodeAux play];
            
            __block int playerNodeIndex = 0;
            
            static void(^render_buffer[2])(AVAudioPlayerNode * __strong, struct Randomizer *, struct Randomizer *);
            for (int i = 0; i < 2; i++)
            {
                render_buffer[i] = ^(AVAudioPlayerNode * __strong player_node, struct Randomizer * duration_randomizer, struct Randomizer * frequency_randomizer) {
                    
                    
                    // TO-DO: Write a block that returns four consomamt frequencies, one at a time, to each channel of
                    // each player nodep and, that replemishes its supply when all four are exhausted
                    //                double majorSeventhFrequencyRatios[4]  = {8.0, 10.0, 12.0, 15.0};
                    //                double root_frequency = random_frequency->generate_distributed_random(random_frequency) / majorSeventhFrequencyRatios[0];
                    //                double frequencies[4] = {root_frequency * majorSeventhFrequencyRatios[0] * durations[0],
                    //                                         root_frequency * majorSeventhFrequencyRatios[1] * durations[1],
                    //                                         root_frequency * majorSeventhFrequencyRatios[2] * durations[2],
                    //                                         root_frequency * majorSeventhFrequencyRatios[3] * durations[3]};
                    
                    // This is the buffer_renderer
                    ^(AVAudioPlayerNodeCount player_node_count, AVAudioPlayerNodeIndex player_node_index, AVAudioSession * audio_session, AVAudioFormat * audio_format, BufferRenderedCompletionBlock buffer_rendered)
                    {
                        buffer_rendered(^AVAudioPCMBuffer * (void (^buffer_sample)(AVAudioFrameCount, double, double, float *))
                                        {
                            double duration = duration_randomizer->generate_distributed_random(duration_randomizer);
                            NSLog(@"Node %d\t\tDuration: %f", playerNodeIndex, duration);
                            AVAudioFrameCount frameCount = ([audio_format sampleRate] * duration);
                            [player_node prepareWithFrameCount:frameCount];
                            AVAudioPCMBuffer *pcmBuffer  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audio_format frameCapacity:frameCount];
                            pcmBuffer.frameLength        = frameCount;
                            
                            AVAudioChannelCount channel_count = audio_format.channelCount;
                            double root_freq = frequency_randomizer->generate_distributed_random(frequency_randomizer);
                            NSLog(@"root_freq: %f", root_freq);
                            double harmonic_freq = root_freq * (5.0/4.0);
                            double device_volume = audio_session.outputVolume;
                            double gain_new_max = 1.0 / (channel_count * player_node_count); // 0.5
                            double gain_new_min = 1.0 / gain_new_max; // 2
                            double gain_adjustment = device_volume * (gain_new_max - gain_new_min) + gain_new_min;
                            NSLog(@"gain_adjustment: %f", gain_adjustment);
                            
                            buffer_sample(frameCount,
                                          root_freq,
                                          gain_adjustment,
                                          pcmBuffer.floatChannelData[0]);
                            
                            buffer_sample(frameCount,
                                          harmonic_freq,
                                          gain_adjustment,
                                          (channel_count == 2) ? pcmBuffer.floatChannelData[1] : nil);
                            
                            return pcmBuffer;
                        } (^(AVAudioFrameCount sample_count, double frequency, double gain_adjustment, float * samples)
                           {
                            for (int index = 0; index < sample_count; index++)
                            {
                                double normalized_time = normalize(0.0, sample_count, index);
                                
                                double sine_frequency = sample_frequency(normalized_time, frequency);
                                double sample = sine_frequency * sample_amplitude(normalized_time, gain_adjustment);
                                
                                if (samples) samples[index] = sample;
                            }
                        }), ^{
                            render_buffer[i](player_node, duration_randomizer, frequency_randomizer); });
                    } ((AVAudioPlayerNodeCount)2, playerNodeIndex++, [AVAudioSession sharedInstance], self.audioFormat, ^(AVAudioPCMBuffer * pcm_buffer, PlayedToneCompletionBlock played_tone)
                       {
                        //                        NSLog(@"playerNodeIndex == %d", playerNodeIndex);
                        playerNodeIndex %= 2; // remove playerNodeIndex; each playernode executes its own render_buffer block
                        if ([player_node isPlaying])
                            [player_node scheduleBuffer:pcm_buffer atTime:nil options:AVAudioPlayerNodeBufferInterruptsAtLoop completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack completionHandler:^(AVAudioPlayerNodeCompletionCallbackType callbackType)
                             {
                                if (callbackType == AVAudioPlayerNodeCompletionDataPlayedBack)
                                {
                                    played_tone();
                                }
                            }];
                    });
                };
                render_buffer[i]((i == 0) ? self.playerNode : self.playerNodeAux,
                                 new_randomizer(random_generator_drand48, 0.25, 1.75, 1.0, random_distribution_gamma, 0.25, 1.75, 1.0),
                                 new_randomizer(random_generator_drand48, 400.0, 2000.0, 1.0/3.0, random_distribution_gamma, 400.0, 2000.0, 1.0/3.0));
            }
            
            
            return TRUE;
            
        } else {
            return FALSE;
        }
    }
}

//- (void (^)(AVAudioPlayerNode * _Nonnull, AVAudioSession * _Nonnull, AVAudioFormat * _Nonnull, void (^ _Nonnull)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, void (^ _Nonnull)(void))))RenderBuffer
//{
//    ^(AVAudioPlayerNode * _Nonnull player_node, AVAudioPCMBuffer * _Nonnull audio_buffer, AVAudioFormat * _Nonnull audio_format, void (^ _Nonnull blk)(int))
//    {
//
//    } ([AVAudioPlayerNode new], [AVAudioPCMBuffer new], [AVAudioFormat new],
//    ^ (int x){
//
//     }(1));
//}
////
////
//- (BOOL)play
//{
////    // TO-DO: Move the start and stop audioengine to the block chain
////    //        and toggle only a boolean value for start/stop requests
////    //        and decide after/before each buffer plays whether to stop
////    static void (^render_buffer)(AVAudioPlayerNode * _Nonnull, AVAudioSession * _Nonnull, AVAudioFormat * _Nonnull, void (^ _Nonnull)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, void (^ _Nonnull)(void)));
////
////    ^(AVAudioPlayerNode * _Nonnull player_node, AVAudioPCMBuffer * _Nonnull audio_buffer, void (^ _Nonnull blk)(void))
////    {
////
////    } ([AVAudioPlayerNode new], [AVAudioPCMBuffer new], [AVAudioFormat new],
////    ^{
////
////     });
////
////    dispatch_block_t render_buffer = dispatch_block_create(DISPATCH_BLOCK_BARRIER, ^{
////
////        ^(AVAudioPlayerNode * _Nonnull player_node, AVAudioPCMBuffer * _Nonnull audio_buffer, void (^ _Nonnull blk)(void))
////        {
////            blk();
////        } ([AVAudioPlayerNode new], [AVAudioPCMBuffer new], [AVAudioFormat new],
////           ^{
////
////        }());
////
////    });
////
////    // render_buffer: supply properties needed to create a buffer of the specified kind...
////    //              ...and return a block to create it (buffer_renderer)
////    // buffer_renderer: accepts the properties, uses them to create a buffer...
////    //              ...and then returns a block with the buffer (buffer_rendered)
////    // buffer_rendered: returns the buffer and a reference to the player node that will use it...
////    //              ...and then returns a block to schedule the buffer for playback (schedule_buffer)
////    // schedule_buffer: schedules the buffer...
////    //              ...and returns a block to indicate that the buffer has been scheduled and then request another buffer (buffer_scheduled)
////    //
////
////    ^{
////        ^void (AVAudioPlayerNode * _Nonnull player_node, AVAudioSession * _Nonnull audio_session, AVAudioFormat * _Nonnull audio_format,
////               void(^buffer_rendered)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, void (^ _Nonnull)(void))) { };
////    };
////
////
////    ^{
////        ^void (AVAudioPlayerNode * _Nonnull player_node, AVAudioSession * _Nonnull audio_session, AVAudioFormat * _Nonnull audio_format,
////               void(^buffer_rendered)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, void (^ _Nonnull)(void)))
////        {
////
////        }([AVAudioPlayerNode new], [AVAudioSession new], [AVAudioFormat new],
////          ^void (AVAudioPlayerNode * _Nonnull player_node, AVAudioSession * _Nonnull audio_session, AVAudioFormat * _Nonnull audio_format,
////                     void(^)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, void (^ _Nonnull)(void)))
////              {
////
////              };
////    }());
//    
//    
//    struct RandomSource * duration_random_source;
//    struct RandomSource * frequency_random_source;
//    duration_random_source = new(random_generator_drand48, 0.25, 1.75);
//    frequency_random_source = new(random_generator_drand48, 400.0, 2000.0);
//
//    ^ void (AVAudioPlayerNode * _Nonnull __strong player_node, AVAudioSession * _Nonnull __strong audio_session, AVAudioFormat * _Nonnull __strong audio_format, void (^ _Nonnull __strong buffer_rendered)(AVAudioPlayerNode * _Nonnull __strong, AVAudioPCMBuffer * _Nonnull __strong, void (^ _Nonnull __strong)(void)))
//    {
//        (player_node, ^AVAudioPCMBuffer * (void (^buffer_sample)(AVAudioFrameCount, double, double, double, float *, AVAudioChannelCount)) {
//                double duration = duration_random_source->generate_random(duration_random_source);
//                AVAudioFrameCount frameCount = ([audio_format sampleRate] * duration);
//                AVAudioPCMBuffer *pcmBuffer  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audio_format frameCapacity:frameCount];
//                pcmBuffer.frameLength        = frameCount;
//
//                AVAudioChannelCount channel_count = audio_format.channelCount;
//                double root_freq = frequency_random_source->generate_random(frequency_random_source) * duration;
//                double harmonic_freq = root_freq * (5.0/4.0);
//                double device_volume = audio_session.outputVolume;
//                double gain_new_max = 1.0 / (channel_count); // 0.5
//                double gain_new_min = 1.0 / gain_new_max; // 2
//                double gain_adjustment = normalize(gain_new_min, gain_new_max, device_volume);
//
//                buffer_sample(frameCount,
//                              root_freq,
//                              duration,
//                              gain_adjustment,
//                              pcmBuffer.floatChannelData[0],
//                              channel_count);
//
//                buffer_sample(frameCount,
//                              harmonic_freq,
//                              duration,
//                              gain_adjustment,
//                              (channel_count == 2) ? pcmBuffer.floatChannelData[1] : nil,
//                              channel_count);
//
//                return pcmBuffer;
//            } (^(AVAudioFrameCount sampleCount, double frequency, double duration, double output_volume, float * samples, AVAudioChannelCount channel_count)
//               {
//                for (int index = 0; index < sampleCount; index++)
//                {
//                    double normalized_time = normalize(0.0, sampleCount, index);
//                    double sine_frequency = sample_frequency(normalized_time, frequency, channel_count, 1.0);
//                    double sample = (sine_frequency * sample_amplitude(normalized_time, output_volume, channel_count, 1.0));
//
//                    if (samples) samples[index] = sample;
//                }
//            }), ^{
//                render_buffer();
//            });
//        } (self.playerNode, [AVAudioSession sharedInstance], self.audioFormat, ^(AVAudioPlayerNode * player_node, AVAudioPCMBuffer * pcm_buffer, PlayedToneCompletionBlock played_tone)
//           {
//            if ([player_node isPlaying])
//                [player_node scheduleBuffer:pcm_buffer atTime:nil options:AVAudioPlayerNodeBufferInterruptsAtLoop completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack completionHandler:^(AVAudioPlayerNodeCompletionCallbackType callbackType)
//                 {
//                    played_tone();
//                }];
//        });
//    };
//    
//    dispatch_block_t play_tones = dispatch_block_create(0, ^{
//        render_buffer();
//    });
//    
//    dispatch_block_t stop_engine = dispatch_block_create(0, ^{
//        [self.audioEngine pause];
//        [self.audioEngine stop];
//        [self.audioEngine reset];
////        [self.audioEngine detachNode:self.playerNode];
////        self.playerNode = nil;
////
////        [self.audioEngine detachNode:self.reverb];
////        self.reverb = nil;
////
////        [self.audioEngine detachNode:self.mixerNode];
////        self.mixerNode = nil;
//    });
//    
//    dispatch_block_t start_engine = dispatch_block_create(0, ^{
//        // Initialize nodes
//        
//    });
//    
//    if ([self.audioEngine isRunning])
//    {
//        dispatch_async(self->render_buffer_serial_queue, stop_engine);
//    } else {
//        if ()
//        dispatch_async(self->render_buffer_serial_queue, start_engine);
////        if ([self setupEngine])
////        {
//////            dispatch_async(self->render_buffer_serial_queue, start_engine);
////
////            if ([self startEngine] && ([self.audioEngine isRunning]))
////            {
////
////                if ([self.playerNode isPlaying])
////                {
//        if (![self.playerNode isPlaying])
//            [self.playerNode play];
//        
//            render_buffer();
////
////        }
//    }
//    return [self.audioEngine isRunning];
//}

@end
