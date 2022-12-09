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
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMSync.h>

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

#define randomFloat32()    (arc4random() / ((unsigned)RAND_MAX))
#define E_NUM 0.5772156649015328606065120900824024310421593359399235988057672348848677267776646709369470632917467495

static Float32 ratio[4] = {1.f,   12.f / 10.f,    15.f / 10.f,    18.f / 10.f};
typedef struct Chord
{
     Float32 root_frequency;
     unsigned int ratio_index : 2;
} chord;
typedef Float32 (^FrequencyGenerator)(struct Chord *, int, int);

typedef struct Sine
{
     Float32 phase_start;
     Float32 phase_increment;
} sine;

@interface ToneBarrierScorePlayer ()
{
     Float32 (^duration_split)(AVAudioFrameCount, long, int, int);
     __block struct Chord * soprano_dyad;
     __block struct Chord * bass_dyad;
     
     Float32 (^sample)(Float32 sample_rate, Float32 * phase_start, Float32 * phase_increment);
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

static void (^configure_lock_screen_control)(MPNowPlayingInfoCenter * nowPlayingInfoCenter, MPRemoteCommandCenter  * remoteCommandCenter) = ^ (MPNowPlayingInfoCenter * nowPlayingInfoCenter, MPRemoteCommandCenter  * remoteCommandCenter) {
     
     NSMutableDictionary<NSString *, id> * nowPlayingInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
     [nowPlayingInfo setObject:@"ToneBarrier" forKey:MPMediaItemPropertyTitle];
     [nowPlayingInfo setObject:(NSString *)@"James Alan Bush" forKey:MPMediaItemPropertyArtist];
     [nowPlayingInfo setObject:(NSString *)@"The Life of a Demoniac" forKey:MPMediaItemPropertyAlbumTitle];
     
     static UIImage * image;
     MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:(image = [UIImage imageNamed:@"AppIcon-Wave-Regular-M-2"])];
     [nowPlayingInfo setObject:(MPMediaItemArtwork *)artwork forKey:MPMediaItemPropertyArtwork];
     
     [(nowPlayingInfoCenter = [MPNowPlayingInfoCenter defaultCenter]) setNowPlayingInfo:(NSDictionary<NSString *,id> * _Nullable)nowPlayingInfo];
     
     MPRemoteCommandHandlerStatus (^remoteCommandHandler)(MPRemoteCommandEvent * _Nonnull) = ^ MPRemoteCommandHandlerStatus (MPRemoteCommandEvent * _Nonnull event) {
          AudioEngineCommand command;
          if ([[event command] isEqual:remoteCommandCenter.playCommand])
          {
               command = AudioEngineCommandPlay;
               [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"MPRemoteCommandCenter MPRemoteCommandEvent playCommand"]
                                                         entry:[NSString stringWithFormat:@"%@", event.description]
                                                attributeStyle:LogEntryAttributeStyleEvent];
          } else if ([[event command] isEqual:remoteCommandCenter.stopCommand]) {
               [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"MPRemoteCommandCenter MPRemoteCommandEvent stopCommand"]
                                                         entry:[NSString stringWithFormat:@"%@", event.description]
                                                attributeStyle:LogEntryAttributeStyleEvent];
               command = AudioEngineCommandStop;
          } else {
               [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"MPRemoteCommandCenter MPRemoteCommandEvent [command?]"]
                                                         entry:[NSString stringWithFormat:@"%@", event.description]
                                                attributeStyle:LogEntryAttributeStyleTransient];
               command = AudioEngineCommandStop;
          }
          
          dispatch_set_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, (void *)command);
          dispatch_source_merge_data(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, 1);
          
          return MPRemoteCommandHandlerStatusSuccess;
     };
     
     [remoteCommandCenter.playCommand addTargetWithHandler:remoteCommandHandler];
     [remoteCommandCenter.stopCommand addTargetWithHandler:remoteCommandHandler];
     [remoteCommandCenter.pauseCommand addTargetWithHandler:remoteCommandHandler];
     
     [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
};

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
          
//          [self playingInfo];
          
          self.commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
          configure_lock_screen_control(_nowPlayingInfo, _commandCenter);
          
          
          duration_split = ^ Float32 (AVAudioFrameCount frame_count, long random, int n, int m) {
               Float32 result = random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n);
               Float32 scaled_result = scale(0.0, 1.0, result, MIN(m, n), MAX(m, n));
               Float32 weighted_result = 4.0 * pow((scaled_result - 0.5), 2.0);
               Float32 rescaled_result = scale(0.125, 0.875, weighted_result, 0.0, 1.0);
               return rescaled_result * frame_count;
          };
          
          soprano_dyad = (struct Chord *)malloc(sizeof(struct Chord));
          bass_dyad    = (struct Chord *)malloc(sizeof(struct Chord));
          
          //        sample = ^ Float32 (Float32 * phase_start, Float32 * phase_increment) {
          //
          //        };
          
          //        signal_frequency = ^ Float32 (struct Chord * dyad, int min_key, int max_key) {
          //            if (dyad->ratio_index == 0)
          //            {
          //                dyad->root_frequency = ^ Float32 (Float32 * root_frequency, long random) {
          //                    *root_frequency = pow(1.059463094f, random) * 440.0;
          //                    return *root_frequency;
          //                } (&dyad->root_frequency, ^ long (long random, int n, int m) {
          //                    long result = random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n);
          //                    return result;
          //                } (random(), min_key, max_key));
          //            }
          //
          ////            printf("%d\t\t%f\t\t%f\t\t%f\n", dyad->ratio_index, dyad->root_frequency, ratio[dyad->ratio_index], dyad->root_frequency * ratio[dyad->ratio_index]);
          //
          //            Float32 frequency = dyad->root_frequency * ratio[dyad->ratio_index];
          //
          //            dyad->ratio_index++;
          //
          //            return frequency;
          //        };
          
          
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
     const Float32 sampleRate = [self.mainNode outputFormatForBus:0].sampleRate;
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

typedef Float32 (^Normalize)(Float32, Float32, Float32);
Normalize normalize = ^Float32(Float32 min, Float32 max, Float32 value)
{
     Float32 result = (value - min) / (max - min);
     
     return result;
};

typedef Float32 (^Scale)(Float32, Float32, Float32, Float32, Float32);
Scale scale = ^Float32(Float32 min_new, Float32 max_new, Float32 val_old, Float32 min_old, Float32 max_old)
{
     Float32 val_new = min_new + ((((val_old - min_old) * (max_new - min_new))) / (max_old - min_old));
     
     return val_new;
};

typedef Float32 (^Linearize)(Float32, Float32, Float32);
Linearize linearize = ^Float32(Float32 range_min, Float32 range_max, Float32 value)
{
     Float32 result = (value * (range_max - range_min)) + range_min;
     
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
typedef void (^BufferRenderer)(AVAudioFrameCount, Float32, Float32, StereoChannelOutput, Float32 *, BufferRenderedCompletionBlock); // adds the sample data to the PCM buffer; calls the buffer rendered completion block when finisned
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
          
          [self.audioEngine connect:self.playerNode     to:self.mixerNode  format:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0]];
          [self.audioEngine connect:self.playerNodeAux  to:self.mixerNode  format:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0]];
          [self.audioEngine connect:self.mixerNode      to:self.reverb     format:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0]];
          [self.audioEngine connect:self.reverb         to:self.audioEngine.mainMixerNode   format:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0]];
          
          self.pcmBuffer     = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0] frameCapacity:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0].sampleRate * [self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0].channelCount];
          self.pcmBuffer.frameLength = self.pcmBuffer.frameCapacity;
          self.pcmBufferAux  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0] frameCapacity:[self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0].sampleRate * [self.audioEngine.mainMixerNode outputFormatForBus:(AVAudioNodeBus)0].channelCount];
          self.pcmBufferAux.frameLength = self.pcmBufferAux.frameCapacity;
          
          if ([self startEngine])
          {
               if (![self.playerNode isPlaying]) [self.playerNode play];
               if (![self.playerNodeAux isPlaying]) [self.playerNodeAux play];
               
               unsigned int seed    = (unsigned int)clock();
               size_t buffer_size   = 32 * sizeof(char *);
               char * random_buffer = (char *)malloc(buffer_size);
               initstate(seed, random_buffer, buffer_size);
               srandomdev();
               
               typedef void (^PlayTones)(__weak typeof(AVAudioPlayerNode) *,
                                         __weak typeof(AVAudioPCMBuffer) *,
                                         __weak typeof(AVAudioFormat) *,
                                         __weak typeof(FrequencyGenerator) frequency_generator);
               
               // TO-DO: Define play_tones, then assign its value to a separate reference to copy it (to maintain separate values for otherwise shared __block variable references;
               //        copying play_tones only increases the reference count, so reference variables are shared
               //        (Source: https://www.cocoawithlove.com/2009/10/how-blocks-are-implemented-and.html)
               static PlayTones play_tones;
               play_tones =
               ^ (__weak typeof(AVAudioPlayerNode) * player_node,
                  __weak typeof(AVAudioPCMBuffer) * pcm_buffer,
                  __weak typeof(AVAudioFormat) * audio_format,
                  __weak typeof(FrequencyGenerator) frequency_generator)
               {
                    __block Float32 sin_phase = 0.0;
                    __block Float32 sin_phase_dyad = 0.0;
                    __block Float32 sin_phase_tremolo = 0.0;
                    __block Float32 amplitude = 0.0;
                    ^ (AVAudioChannelCount channel_count, AVAudioFrameCount frame_count, Float32 sample_rate, Float32 * const _Nonnull * _Nullable Float32_channel_data) {
                         
                         for (int channel_index = 0; channel_index < channel_count; channel_index++) {
                              volatile int ds = self->duration_split(frame_count, random(), 11025, 77175);
                              Float32 amplitude_increment = 1.0 / ds;
                              Float32 amplitude_increment_aux = 1.0 / (frame_count - ds);
                              Float32 sin_increment = (frequency_generator(self->soprano_dyad, -8, 24) * (2.0 * M_PI)) / ds;
                              Float32 sin_increment_aux = (frequency_generator(self->soprano_dyad, -8, 24) * (2.0 * M_PI)) / (frame_count - ds);
                              Float32 sin_increment_dyad = (frequency_generator(self->soprano_dyad, -8, 24) * (2.0 * M_PI)) / ds;
                              Float32 sin_increment_dyad_aux = (frequency_generator(self->soprano_dyad, -8, 24) * (2.0 * M_PI)) / (frame_count - ds);
                              Float32 sin_increment_tremolo = 2.f * M_PI * (1.f / ds); //((frame_count/(frame_count - ds)) * (2.0 * M_PI)) / ds;
                              Float32 sin_increment_tremolo_aux = 2.f * M_PI * (1.f / (frame_count - ds)); // ((frame_count/ds) * (2.0 * M_PI)) / (frame_count - ds);
                              
                              //                         typedef Float32 * Float32_channel_data_ref[(ds)];
                              //                         typeof(Float32_channel_data_ref) Float32_channel_data_;
                              //                         typedef Float32 * Float32_channel_data_aux_ref[frame_count - ds];
                              //                         typeof(Float32_channel_data_aux_ref) Float32_channel_data_aux;
                              //                         vDSP_vramp(&sin_phase, &sin_increment, Float32_channel_data_, 1, ds);
                              //                         vDSP_vramp(&sin_phase_aux, &sin_increment_aux, Float32_channel_data_aux, 1, frame_count - ds);
                              //                         vDSP_vtmerg(Float32_channel_data_, 1, Float32_channel_data_aux, 1, Float32_channel_data[channel_index], 1, 10);
                         
                              for (int buffer_index = 0; buffer_index < frame_count; buffer_index++) {
                                   Float32 a = (Float32)sinf(amplitude * 2.0 * M_PI); //sinf(sin_phase);
                                   Float32 b = (Float32)sinf(2.f * M_PI * (sin_phase_tremolo * sin_phase_tremolo) * 3.f); //sinf(sin_phase_dyad);
                                   Float32 c = a + ((buffer_index / frame_count) * (b - a)); //(2.f * (sinf(a + b) * cosf(a - b))) / 2.f;
                                   Float32 d = (sinf(sin_phase) + (0.5 * (sinf(sin_phase_dyad) - sinf(sin_phase))));
                                   Float32_channel_data[channel_index][buffer_index] = c * d;
                                   
//                                   if (buffer_index < ds) +=z;
//                                   can be expressed as:
//
//                                   y += z & -(2-x >> sizeof(unsigned)*CHAR_BIT-1);
                                   sin_phase += (buffer_index < ds) ? sin_increment : sin_increment_aux;
                                   sin_phase_dyad += (buffer_index < ds) ? sin_increment_dyad : sin_increment_dyad_aux;
                                   sin_phase_tremolo += (buffer_index < ds) ? sin_increment_tremolo : sin_increment_tremolo_aux;
                                   amplitude += (buffer_index < ds) ? amplitude_increment : amplitude_increment_aux;
                              }
                         }
                         
                         //                        for (buffer_index = 0; buffer_index < ds; buffer_index++) {
                         //                            Float32 damped_sine_wave = (Float32)sinf(amplitude * 2.0 * M_PI); // (expf(-amplitude) * (cosf(2.0 * M_PI * amplitude))); //
                         //                            Float32_channel_data[channel_index][buffer_index] = (Float32)(damped_sine_wave * (sinf(sin_phase) + sinf(sin_phase_dyad)) * (0.5 * sinf(sin_phase_tremolo)));
                         //
                         //                            sin_phase += sin_increment;
                         //                            sin_phase_dyad += sin_increment_dyad;
                         //                            sin_phase_tremolo += sin_increment_tremolo;
                         //                            amplitude += amplitude_step;
                         //                        }
                         //
                         //                        for (; buffer_index < frame_count; buffer_index++) {
                         //                            Float32 damped_sine_wave = (Float32)sinf(amplitude_aux * 2.0 * M_PI); // (expf(-amplitude) * (cosf(2.0 * M_PI * amplitude))); //
                         //                            Float32_channel_data[channel_index][buffer_index] = (Float32)(damped_sine_wave * ((sinf(sin_phase_aux) + sinf(sin_phase_dyad_aux)) * (0.5 * sinf(sin_phase_tremolo_aux))));
                         //
                         //                            sin_phase_aux += sin_increment_aux;
                         //                            sin_phase_dyad_aux += sin_increment_dyad_aux;
                         //                            sin_phase_tremolo_aux += sin_increment_tremolo_aux;
                         //                            amplitude_aux += amplitude_step_aux;
                         //                        }
                         //                        typeof(Float32_channel_data[0]) hamm_window = malloc(sizeof(Float32) * 44100);
                         //                        vDSP_hamm_window(hamm_window, frame_count, 1);
                         //                        vDSP_vmul(Float32_channel_data[channel_index], 1, hamm_window, 1, Float32_channel_data[channel_index], 1, frame_count);
                         //                    }
                    } (audio_format.channelCount, pcm_buffer.frameCapacity, audio_format.sampleRate, pcm_buffer.floatChannelData);
                    ^ (PlayedToneCompletionBlock played_tone) {
                         if ([player_node isPlaying])
                         {
                              [player_node prepareWithFrameCount:pcm_buffer.frameCapacity];
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
                         play_tones(player_node, pcm_buffer, audio_format, frequency_generator);
                    });
               };
               
               __weak typeof(AVAudioPlayerNode) * w_playerNode = self.playerNode;
               __weak typeof(AVAudioPCMBuffer) * w_pcmBuffer = self.pcmBuffer;
               __weak typeof(AVAudioFormat) * w_audioFormat = self.audioFormat;
               
               play_tones(w_playerNode, w_pcmBuffer, w_audioFormat, ^ Float32 (struct Chord * dyad, int min_key, int max_key) {
                    if (dyad->ratio_index == 0)
                    {
                         dyad->root_frequency = ^ Float32 (Float32 * root_frequency, Float32 random) {
                              *root_frequency = (Float32)pow(2.f, (Float32)(random / 12.f)) * 440.0;
                              return *root_frequency;
                         } (&dyad->root_frequency, ^ Float32 (long random, int n, int m) {
                              Float32 result = (Float32)(random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n));
                              return result;
                         } (random(), min_key, max_key));
                    }
                    
                    //            printf("%d\t\t%f\t\t%f\t\t%f\n", dyad->ratio_index, dyad->root_frequency, ratio[dyad->ratio_index], dyad->root_frequency * ratio[dyad->ratio_index]);
                    
                    Float32 frequency = dyad->root_frequency * ratio[dyad->ratio_index];
                    
                    dyad->ratio_index++;
                    
                    return (Float32)frequency;
               });
               
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
