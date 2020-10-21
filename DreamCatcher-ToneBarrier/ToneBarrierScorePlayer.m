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

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GameKit/GameKit.h>
#import <objc/runtime.h>
#import <mach/mach.h>

#import <Metal/Metal.h>
#import "SignalCalculator.h"

#include <Accelerate/Accelerate.h>

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "time.h"
#include "math.h"

#import "ViewController.h"
#import "ToneBarrierScorePlayer.h"
#import "LogViewDataSource.h"

#include "Randomizer.h"
#include "Tone.h"

#define randomdouble()    (arc4random() / ((unsigned)RAND_MAX))
#define E_NUM 0.5772156649015328606065120900824024310421593359399235988057672348848677267776646709369470632917467495

static float ratio[4] = {1.f,   12.f / 10.f,    15.f / 10.f,    18.f / 10.f};
struct chord
{
    double root_frequency;
    unsigned int ratio_index : 2;
} * dyad;

#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMSync.h>

@interface ToneBarrierScorePlayer ()
{
    double (^signal_frequency)(struct chord *);
}

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
    [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"%@", self.description]
                                              entry:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]
                                     attributeStyle:LogEntryAttributeStyleEvent];
    
    if (self == [super init])
    {
        self.audio_engine_status_dispatch_queue  = dispatch_queue_create_with_target("Audio Engine Status Serial Dispatch Queue", DISPATCH_QUEUE_SERIAL, dispatch_get_main_queue());
        self.audio_engine_status_dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, self.audio_engine_status_dispatch_queue);
        
        self.audio_engine_command_dispatch_queue  = dispatch_queue_create_with_target("Audio Engine Command Serial Dispatch Queue", DISPATCH_QUEUE_SERIAL, dispatch_get_main_queue());
        self.audio_engine_command_dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, self.audio_engine_command_dispatch_queue);
        
        dispatch_source_set_event_handler(self.audio_engine_command_dispatch_source, ^{
            AudioEngineStatus status = [self play];
            dispatch_set_context(self.audio_engine_status_dispatch_source, (void *)status);
            dispatch_source_merge_data(self.audio_engine_status_dispatch_source, 1);
        });
        
        dispatch_resume(self.audio_engine_command_dispatch_source);
        
        [self playingInfo];
        
        self.commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        
        MPRemoteCommandHandlerStatus (^remoteCommandHandler)(MPRemoteCommandEvent * _Nonnull) = ^ MPRemoteCommandHandlerStatus (MPRemoteCommandEvent * _Nonnull event) {
            AudioEngineCommand command;
            if ([[event command] isEqual:self.commandCenter.playCommand])
            {
                command = AudioEngineCommandPlay;
            } else if ([[event command] isEqual:self.commandCenter.stopCommand]) {
                command = AudioEngineCommandStop;
            } else {
                command = AudioEngineCommandStop;
            }
            
            dispatch_set_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, (void *)command);
            dispatch_source_merge_data(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, 1);
            
            return MPRemoteCommandHandlerStatusSuccess;
        };
        
        [self.commandCenter.playCommand addTargetWithHandler:remoteCommandHandler];
        [self.commandCenter.stopCommand addTargetWithHandler:remoteCommandHandler];
        [self.commandCenter.pauseCommand addTargetWithHandler:remoteCommandHandler];
        
        dyad = (struct chord *)malloc(sizeof(struct chord));
        
        signal_frequency = ^ double (struct chord * dyad) {
            if (dyad->ratio_index == 0)
            {
                // Generate random frequency
                dyad->root_frequency = ^ double (double * root_frequency, long random) {
                    *root_frequency = pow(1.059463094f, random) * 440.0;
                    return *root_frequency;
                } (&dyad->root_frequency, ^ long (long random, int n, int m) {
                    long result = random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n);
                    return result;
                } (random(), -8, 24));
                // Store result in dyad->root_frequency
            }
            
            double frequency = dyad->root_frequency * ratio[dyad->ratio_index];
            
            dyad->ratio_index++;
            return frequency;
        };
        
        
        //        // GPU configuration
        //        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        //
        //        SignalCalculator* signal_calculator = [[SignalCalculator alloc] initWithDevice:device];
        ////        [signal_calculator
        //        [signal_calculator sendComputeCommand];
        
    }
    
    return self;
}

- (void)playingInfo
{
    // Define Now Playing Info
    self.nowPlayingInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    
    [self.nowPlayingInfo setObject:@"ToneBarrier" forKey:MPMediaItemPropertyAlbumArtist];
    [self.nowPlayingInfo setObject:@"James Alan Bush" forKey:MPMediaItemPropertyAlbumTitle];
    
    UIImage * image = [UIImage imageNamed:@"AppIcon-Wave-Regular-M-2"];
    CGSize imageBounds = CGSizeMake(180.0, 180.0);
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:imageBounds requestHandler:^UIImage * _Nonnull(CGSize size) {
        return image;
    }];
    
    [self.nowPlayingInfo setObject:(MPMediaItemArtwork *)artwork forKey:MPMediaItemPropertyArtwork];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:(NSDictionary *)self.nowPlayingInfo];
}

- (BOOL)setupEngine
{
    if (self.audioEngine)
        [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"%@", self.description]
                                                  entry:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]
                                         attributeStyle:LogEntryAttributeStyleOperation];
    
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.mainNode = [self.audioEngine mainMixerNode];
    AVAudioChannelCount channelCount = [self.mainNode outputFormatForBus:0].channelCount;
    const double sampleRate = [self.mainNode outputFormatForBus:0].sampleRate;
    self.audioFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:sampleRate channels:channelCount];
    
    [self.audioEngine prepare];
    
    return (self.audioEngine != nil) ? TRUE : FALSE;
}

- (BOOL)startEngine
{
    [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"%@", self.description]
                                              entry:[NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]
                                     attributeStyle:LogEntryAttributeStyleOperation];
    
    __autoreleasing NSError *error = nil;
    if ([self.audioEngine startAndReturnError:&error])
    {
        [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"%@", self.description]
                                                  entry:[NSString stringWithFormat:@"AudioEngine started"]
                                         attributeStyle:LogEntryAttributeStyleSuccess];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error)
        {
            [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioSession category could not be set"]
                                                      entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
                                             attributeStyle:LogEntryAttributeStyleError];
            return FALSE;
        } else {
            [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"%@", self.description]
                                                      entry:[NSString stringWithFormat:@"AudioSession configured"]
                                             attributeStyle:LogEntryAttributeStyleSuccess];
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (error)
            {
                [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioSession could not be activated"]
                                                          entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
                                                 attributeStyle:LogEntryAttributeStyleError];
                return FALSE;
            } else {
                [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"%@", self.description]
                                                          entry:[NSString stringWithFormat:@"AudioSession activated"]
                                                 attributeStyle:LogEntryAttributeStyleSuccess];
                return TRUE;
            }
        }
    } else {
        [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioEngine could not be started"]
                                                  entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
                                         attributeStyle:LogEntryAttributeStyleError];
        return FALSE;
    }
}

typedef double (^Normalize)(double, double, double);
Normalize normalize = ^double(double min, double max, double value)
{
    double result = (value - min) / (max - min);
    
    return result;
};

typedef double (^Scale)(double, double, double, double, double);
Scale scale = ^double(double min_new, double max_new, double val_old, double min_old, double max_old)
{
    double val_new = min_new + ((((val_old - min_old) * (max_new - min_new))) / (max_old - min_old));
    
    return val_new;
};

typedef double (^Linearize)(double, double, double);
Linearize linearize = ^double(double range_min, double range_max, double value)
{
    double result = (value * (range_max - range_min)) + range_min;
    
    return result;
};

typedef NS_ENUM(NSUInteger, StereoChannelOutput) {
    StereoChannelOutputLeft,
    StereoChannelOutputRight,
    StereoChannelOutputMono,
    StereoChannelOutputUnspecified
};

typedef void (^PlayedToneCompletionBlock)(void); // passed to player node buffer scheduler by the buffer rendered completion block; called by the player node buffer scheduler after the schedule buffer plays; reruns the render buffer block
typedef void (^BufferRenderedCompletionBlock)(PlayedToneCompletionBlock _Nonnull); // called by buffer renderer after buffer samples are created; runs the player node buffer scheduler
typedef void (^BufferRenderer)(AVAudioFrameCount, double, double, StereoChannelOutput, float *, BufferRenderedCompletionBlock); // adds the sample data to the PCM buffer; calls the buffer rendered completion block when finisned
//typedef void(^RenderBuffer)(AVAudioPlayerNodeIndex, dispatch_queue_t __strong, dispatch_queue_t __strong, AVAudioPlayerNode * __strong, AVAudioPCMBuffer *, DurationTally *, BufferRenderer); // starts the process of creating a buffer, scheduling it and playing it, and recursively starting itself again while the player node passed to it isPlaying

- (AudioEngineStatus)play
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
        
        return AudioEngineStatusStopped;
    } else {
        
        if ([self setupEngine]) [self.audioEngine prepare];
        
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
        
        self.pcmBuffer     = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.audioFormat frameCapacity:self.audioFormat.sampleRate * 2.0 * self.audioFormat.channelCount];
        self.pcmBufferAux  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.audioFormat frameCapacity:self.audioFormat.sampleRate * 2.0 * self.audioFormat.channelCount];
        
        if ([self startEngine])
        {
            if (![self.playerNode isPlaying]) [self.playerNode play];
            if (![self.playerNodeAux isPlaying]) [self.playerNodeAux play];
            
            unsigned int seed    = (unsigned int)time(0);
            size_t buffer_size   = 256 * sizeof(char *);
            char * random_buffer = (char *)malloc(buffer_size);
            initstate(seed, random_buffer, buffer_size);
            srandomdev();
        
            
            typedef void (^PlayTones)(__weak typeof(AVAudioPlayerNode) *,
                                      __weak typeof(AVAudioPCMBuffer) *,
                                      __weak typeof(AVAudioFormat) *);
            
            // TO-DO: Define play_tones, then assign its value to a separate reference to copy it (to maintain separate values for otherwise shared __block variable references;
            //        copying play_tones only increases the reference count, so reference variables are shared
            //        (Source: https://www.cocoawithlove.com/2009/10/how-blocks-are-implemented-and.html)
            static PlayTones play_tones;
            play_tones =
            ^ (__weak typeof(AVAudioPlayerNode) * player_node,
               __weak typeof(AVAudioPCMBuffer) * pcm_buffer,
               __weak typeof(AVAudioFormat) * audio_format) {
                
                const double sample_rate = [audio_format sampleRate];
                
                const AVAudioChannelCount channel_count = audio_format.channelCount;
                const AVAudioFrameCount frame_count = sample_rate * 2.0;
                pcm_buffer.frameLength = frame_count;
                
                //                dispatch_queue_t samplerQueue = dispatch_queue_create("com.blogspot.demonicactivity.samplerQueue", DISPATCH_QUEUE_SERIAL);
                //                dispatch_block_t samplerBlock = dispatch_block_create(0, ^{
                ^ (AVAudioChannelCount channel_count, AVAudioFrameCount frame_count, double sample_rate, float * const _Nonnull * _Nullable float_channel_data) {
                    double divider = ^ double (long random, int n, int m) {
                        printf("random == %ld\n", random);
                        double result = random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n);
                        double scaled_result = scale(0.0, 1.0, result, MIN(m, n), MAX(m, n));
                        //                            double weighted_result = pow(scaled_result, 3.0);
                        double weighted_result = 4.0 * pow((scaled_result - 0.5), 2.0);
                        //                            double weighted_result = (-(1.0 - scaled_result) * log2(1.0 - scaled_result) - scaled_result * log2(scaled_result));
                        printf("result == %f\n", result);
                        printf("\tscaled_result == %f\n", scaled_result);
                        printf("\t\tweighted_result == %f\n", weighted_result);
                        double rescaled_result = scale(0.125, 0.875, weighted_result, 0.0, 1.0);
                        // TO-DO: Weighted result must be adjusted to account for 0.25 and 1.75 (actual) min-max divider duration
                        //        Weighted result should be greater than 0.125 and less than 0.875
                        printf("\t\trescaled_result == %f\n", rescaled_result);
                        return rescaled_result * frame_count;
                    } (random(), 11025, 77175);
                    printf("\t\t\tdivider == %f\n", divider);
                    for (int channel_index = 0; channel_index < channel_count; channel_index++)
                    {
                        double sin_phase = 0.0;
                        double sin_phase_dyad = 0.0;
                        double sin_phase_tremolo = 0.0;
                        double sin_phase_aux = 0.0;
                        double sin_phase_dyad_aux = 0.0;
                        double sin_phase_tremolo_aux = 0.0;
                        
                        double sin_increment = (signal_frequency(dyad) * (2.0 * M_PI)) / sample_rate;
                        double sin_increment_dyad = (signal_frequency(dyad) * (2.0 * M_PI)) / sample_rate;
                        double sin_increment_tremolo = (2.0 * (2.0 * M_PI)) / sample_rate;
                        double sin_increment_aux = (signal_frequency(dyad) * (2.0 * M_PI)) / sample_rate;
                        double sin_increment_aux_dyad = (signal_frequency(dyad) * (2.0 * M_PI)) / sample_rate;
                        double sin_increment_tremolo_aux = (4.0 * (2.0 * M_PI)) / sample_rate;
                        
                        
                        for (int buffer_index = 0; buffer_index < frame_count; buffer_index++) {
                            float_channel_data[channel_index][buffer_index] = (buffer_index > divider)
                            ? (sinf(sin_phase) + sinf(sin_phase_dyad)) * sinf(sin_phase_tremolo)
                            : (sinf(sin_phase_aux) + sinf(sin_phase_dyad_aux)) * sinf(sin_phase_tremolo_aux);
                            
                            sin_phase      += sin_increment;
                            sin_phase_dyad += sin_increment_dyad;
                            sin_phase_tremolo += sin_increment_tremolo;
                            sin_phase_aux  += sin_increment_aux;
                            sin_phase_dyad_aux  += sin_increment_aux_dyad;
                            sin_phase_tremolo_aux += sin_increment_tremolo_aux;
                            
                            //                                    if (sin_phase >= (2.0 * M_PI)) sin_phase -= (2.0 * M_PI);
                            //                                    if (sin_phase < 0.0) sin_phase += (2.0 * M_PI);
                        }
                    }
                } (channel_count, frame_count, sample_rate, pcm_buffer.floatChannelData);
                //                });
                //                dispatch_block_t playToneBlock = dispatch_block_create(0, ^{
                ^ (PlayedToneCompletionBlock played_tone) {
                    if ([player_node isPlaying])
                    {
                        [player_node prepareWithFrameCount:frame_count];
                        [player_node scheduleBuffer:pcm_buffer
                                             atTime:nil
                                            options:AVAudioPlayerNodeBufferInterruptsAtLoop
                             completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack
                                  completionHandler:^(AVAudioPlayerNodeCompletionCallbackType callbackType) {
                            if (callbackType == AVAudioPlayerNodeCompletionDataPlayedBack)
                                played_tone();
                        }];
                    }
                } (^ {
                    play_tones(player_node, pcm_buffer, audio_format);
                });
                //                });
                //                dispatch_block_notify(samplerBlock, dispatch_get_main_queue(), playToneBlock);
                //                dispatch_async(samplerQueue, samplerBlock);
            };
            
            __weak typeof(AVAudioPlayerNode) * w_playerNode = self.playerNode;
            __weak typeof(AVAudioPCMBuffer) * w_pcmBuffer = self.pcmBuffer;
            __weak typeof(AVAudioFormat) * w_audioFormat = self.audioFormat;
            
            play_tones(w_playerNode, w_pcmBuffer, w_audioFormat);
            
            return AudioEngineStatusPlaying;
        } else {
            return AudioEngineStatusError;
        }
    }
}

void report_memory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = TASK_BASIC_INFO_COUNT;
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
        NSLog(@"Memory in use (in MiB): %f", ((CGFloat)info.resident_size / 1048576));
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}

@end
