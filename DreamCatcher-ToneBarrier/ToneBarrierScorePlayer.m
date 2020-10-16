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
#include "Chords.h"

#define randomdouble()    (arc4random() / ((unsigned)RAND_MAX))
#define E_NUM 0.5772156649015328606065120900824024310421593359399235988057672348848677267776646709369470632917467495

typedef unsigned int AVAudioPlayerNodeCount, AVAudioPlayerNodeChannelIndex, AVAudioPlayerNodeDurationIndex;

// Classification of structs:
// - some organize properties and methods that relate to software design and architecture (computer science, hardware considerations, best practices, provisions)
// - some organize methods and properties to affect or ensure tone barrier specifications
// - some organize methods and properties relating to the mathematics (statistics)
// - some organize methods and properties relating to the science (music and sound theory and practice)
// - some organize methods and properties relating to expediency (driven by external and personal concerns, urgency of demand)
//typedef int (^next_ratio_index)(int * total, int * tally);
//next_ratio_index next_ratio = ^ int (int * total, int * tally) {
//    if (*tally == *total)
//    {
//        *tally = *total - *tally;
//        return *tally;
//    } else {
//        int diff = *total - *tally;
//        *tally = *tally + 1;
//        return diff;
//    }
//};

struct DurationTally
{
    double total;
    double tally;
    __unsafe_unretained double(^next_duration)(double * tally, double * total);
} * duration_tally;

// Pitch Set - Major Seventh
//                double majorSeventhFrequencyRatios[4]  = {8.0, 10.0, 12.0, 15.0};
//                double root_frequency = random_frequency->generate_distributed_random(random_frequency) / majorSeventhFrequencyRatios[0];
//                double frequencies[4] = {root_frequency * majorSeventhFrequencyRatios[0] * durations[0],
//                                         root_frequency * majorSeventhFrequencyRatios[1] * durations[1],
//                                         root_frequency * majorSeventhFrequencyRatios[2] * durations[2],
//                                         root_frequency * majorSeventhFrequencyRatios[3] * durations[3]};

//typedef enum HarmonicAlignment {
//    HarmonicAlignmentConsonant,
//    HarmonicAlignmentDissonant,
//    HarmonicAlignmentRandomize,
//} HarmonicAlignment;

//typedef NSUInteger HarmonicInterval;

//typedef typeof(HarmonicInterval) HarmonicIntervalConsonance;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantUnison = 0;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantOctave = 1;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantMajorSixth = 2;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantPerfectFifth = 3;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantPerfectFourth = 4;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantMajorThird = 5;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantMinorThird = 6;
//static HarmonicIntervalConsonance HarmonicIntervalConsonantRandomize = 7;
//
//typedef typeof(HarmonicInterval) HarmonicIntervalDissonance;
//static HarmonicIntervalConsonance HarmonicIntervalDissonantMinorSecond = 8;                    // C/C sharp
//static HarmonicIntervalDissonance HarmonicIntervalDissonantMajorSecond = 9;                       // C/D
//static HarmonicIntervalDissonance HarmonicIntervalDissonantMinorSevenths = 10;                    // C/B flat
//static HarmonicIntervalDissonance HarmonicIntervalDissonantMajorSevenths = 11;                     // C/B
//static HarmonicIntervalDissonance HarmonicIntervalDissonantRandomize = 12;

//typedef NSUInteger Harmonics;
//
//typedef NS_OPTIONS(Harmonics, HarmonicAlignment) {
//    HarmonicAlignmentConsonant = 1 << 0,
//    HarmonicAlignmentDissonant = 2 << 0,
//    HarmonicAlignmentRandom    = 3 << 0,
//};
//
//typedef NS_OPTIONS(Harmonics, HarmonicInterval) {
//    Unison = 1 << 0,
//    Octave = 1 << 1,
//    MajorSixth = 1 << 2,
//    PerfectFifth = 1 << 3,
//    PerfectFourth = 1 << 4,
//    MajorThird = 1 << 5,
//    MinorThird = 1 << 6,
//    Random = 1 << 7,
//    MinorSecond = 2 << 0,
//    MajorSecond = 2 << 1,
//    MinorSevenths = 2 << 2,
//    MajorSevenths = 2 << 3,
//    Random = 2 << 4
//};
//
//typedef enum Chord
//{
//    ChordRandomize,
//    ChordMonad,
//    ChordDyad,
//    ChordTriad,
//    ChordTetrad,
//    ChordPentad,
//    ChordHexad,
//    ChordHeptad
//} Chord;
//
//static double harmonic_alignment_ratios_consonant[7] = {1.0, 2.0, 5.0/3.0, 4.0/3.0, 5.0/4.0, 6.0/5.0};
//static double harmonic_alignment_ratios_dissonant[5] = {1.0, 2.0, 3.0, 4.0, 5.0};



#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMSync.h>

@interface ToneBarrierScorePlayer ()
{
    //    struct DurationTally * duration_tally;
    //    struct FrequencyScale * frequency_scale;
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
            struct AudioEngineCommand * audio_engine_command = dispatch_get_context(self.audio_engine_command_dispatch_source);
            if (audio_engine_command->command == AudioEngineCommandStop)
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
                    
                    //            struct AudioStreamBasicDescription {
                    //                mSampleRate       = 44100.0;
                    //                mFormatID         = kAudioFormatLinearPCM;
                    //                mFormatFlags      = kAudioFormatFlagsAudioUnitCanonical;
                    //                mBitsPerChannel   = 8 * sizeof (AudioUnitSampleType);                    // 32 bits
                    //                mChannelsPerFrame = 2;
                    //                mBytesPerFrame    = mChannelsPerFrame * sizeof (AudioUnitSampleType);    // 8 bytes
                    //                mFramesPerPacket  = 1;
                    //                mBytesPerPacket   = mFramesPerPacket * mBytesPerFrame;     // 8 bytes
                    //                mReserved         = 0;
                    //            };
                    
                    unsigned int seed    = (unsigned int)time(0);
                    size_t buffer_size   = 256 * sizeof(char *);
                    char * random_buffer = (char *)malloc(buffer_size);
                    initstate(seed, random_buffer, buffer_size);
                    srandomdev();
                    
                    chord_frequency_ratios = (struct ChordFrequencyRatio *)malloc(sizeof(struct ChordFrequencyRatio));
                    
                    typedef void (^PlayTones)(__weak typeof(AVAudioPlayerNode) *,
                                              __weak typeof(AVAudioPCMBuffer) *,
                                              __weak typeof(AVAudioFormat) *);
                    
                    static PlayTones play_tones;
                    play_tones =
                    ^ (__weak typeof(AVAudioPlayerNode) * player_node,
                       __weak typeof(AVAudioPCMBuffer) * pcm_buffer,
                       __weak typeof(AVAudioFormat) * audio_format) {
                        
                        struct AudioEngineStatus *audio_engine_status = malloc(sizeof(struct AudioEngineStatus));
                        audio_engine_status->status = AudioEngineStatusPlaying;
                        dispatch_set_context(self.audio_engine_status_dispatch_source, audio_engine_status);
                        dispatch_source_merge_data(self.audio_engine_status_dispatch_source, 1);
                        
                        const double sample_rate = [audio_format sampleRate];
                        
                        const AVAudioChannelCount channel_count = audio_format.channelCount;
                        const AVAudioFrameCount frame_count = sample_rate * 2.0;
                        pcm_buffer.frameLength = frame_count;
                        
                        dispatch_queue_t samplerQueue = dispatch_queue_create("com.blogspot.demonicactivity.samplerQueue", DISPATCH_QUEUE_SERIAL);
                        dispatch_block_t samplerBlock = dispatch_block_create(0, ^{
                            
                            ^ (AVAudioChannelCount channel_count, AVAudioFrameCount frame_count, double sample_rate, float * const _Nonnull * _Nullable float_channel_data) {
                                
                                for (int channel_index = 0; channel_index < 1; channel_index++)
                                {
                                    double sin_phase = 0.0;
                                    double sin_increment = (440.0 * (2.0 * M_PI)) / sample_rate;
                                    double sin_increment_aux = (880.0 * (2.0 * M_PI)) / sample_rate;
                                    
                                    double divider = ^ long (long random, int n, int m) {
                                        long result = random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n);
                                        return result;
                                    } (random(), 11025, 77175);
                                    if (float_channel_data[channel_index])
                                        for (int buffer_index = 0; buffer_index < frame_count; buffer_index++) {
                                            if (float_channel_data) float_channel_data[channel_index][buffer_index] = sinf(sin_phase);
                                            sin_phase += (buffer_index > 11025) ? sin_increment : sin_increment_aux;
                                            if (sin_phase >= (2.0 * M_PI)) sin_phase -= (2.0 * M_PI);
                                            if (sin_phase < 0.0) sin_phase += (2.0 * M_PI);
                                            
                                        }
                                }
                                
                            } (channel_count, frame_count, sample_rate, pcm_buffer.floatChannelData);
                        });
                        dispatch_block_t playToneBlock = dispatch_block_create(0, ^{
                            ^ (PlayedToneCompletionBlock played_tone) {
                                if ([player_node isPlaying])
                                {
                                    //                            report_memory();
                                    
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
                                // TO-DO: Add else block to change play button to stop (to accurately reflect whether a tone barrier is playing)
                                else {
                                    struct AudioEngineStatus *audio_engine_status = malloc(sizeof(struct AudioEngineStatus));
                                    audio_engine_status->status = AudioEngineStatusStopped;
                                    dispatch_set_context(self.audio_engine_status_dispatch_source, audio_engine_status);
                                    dispatch_source_merge_data(self.audio_engine_status_dispatch_source, 1);
                                }
                            } (^ {
                                play_tones(player_node, pcm_buffer, audio_format);
                            });
                        });
                        dispatch_block_notify(samplerBlock, dispatch_get_main_queue(), playToneBlock);
                        dispatch_async(samplerQueue, samplerBlock);
                    };
                    
                    __weak typeof(AVAudioPlayerNode) * w_playerNode = self.playerNode;
                    __weak typeof(AVAudioPCMBuffer) * w_pcmBuffer = self.pcmBuffer;
                    __weak typeof(AVAudioFormat) * w_audioFormat = self.audioFormat;
                    
                    play_tones(w_playerNode, w_pcmBuffer, w_audioFormat);
                }
            }
        });
        
        dispatch_resume(self.audio_engine_command_dispatch_source);
        
        [self playingInfo];
        
        self.commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        
        MPRemoteCommandHandlerStatus (^remoteCommandHandler)(MPRemoteCommandEvent * _Nonnull) = ^ MPRemoteCommandHandlerStatus (MPRemoteCommandEvent * _Nonnull event) {
           if ([[event command] isEqual:self.commandCenter.playCommand])
           {
               struct AudioEngineCommand *audio_engine_command = malloc(sizeof(struct AudioEngineCommand));
               audio_engine_command->command = AudioEngineCommandPlay;
               dispatch_set_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, audio_engine_command);
               dispatch_source_merge_data(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, 1);
           } else if ([[event command] isEqual:self.commandCenter.stopCommand])
            {
                struct AudioEngineCommand *audio_engine_command = malloc(sizeof(struct AudioEngineCommand));
                audio_engine_command->command = AudioEngineCommandStop;
                dispatch_set_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, audio_engine_command);
                dispatch_source_merge_data(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, 1);
            } else if ([[event command] isEqual:self.commandCenter.pauseCommand])
            {
                struct AudioEngineCommand *audio_engine_command = malloc(sizeof(struct AudioEngineCommand));
                audio_engine_command->command = AudioEngineCommandStop;
                dispatch_set_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, audio_engine_command);
                dispatch_source_merge_data(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, 1);
            }
            
//            if ([self play])
//            {
//                [self nowPlayingInfo];
                return MPRemoteCommandHandlerStatusSuccess;
//            } else {
//                return MPRemoteCommandHandlerStatusCommandFailed;
//            }
        };
        
        [self.commandCenter.playCommand addTargetWithHandler:remoteCommandHandler];
        [self.commandCenter.stopCommand addTargetWithHandler:remoteCommandHandler];
        [self.commandCenter.pauseCommand addTargetWithHandler:remoteCommandHandler];
        
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
    
    [self.nowPlayingInfo setObject:@"ToneBarrier" forKey:MPMediaItemPropertyTitle];
    
    UIImage * image = [UIImage systemImageNamed:@"waveform.path"];
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
        [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioEngine started"]
                                                  entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
                                         attributeStyle:LogEntryAttributeStyleSuccess];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error)
        {
            [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioSession category could not be set"]
                                                      entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
                                             attributeStyle:LogEntryAttributeStyleError];
            return FALSE;
        } else {
            [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioSession configured"]
                                                      entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
                                             attributeStyle:LogEntryAttributeStyleSuccess];
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (error)
            {
                [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioSession could not be activated"]
                                                          entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
                                                 attributeStyle:LogEntryAttributeStyleError];
                return FALSE;
            } else {
                [LogViewDataSource.logData addLogEntryWithTitle:[NSString stringWithFormat:@"AudioSession activated"]
                                                          entry:[NSString stringWithFormat:@"%@", (error) ? error.description : @"---"]
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

//typedef double (^FrequencySample)(double, double, ...);
// TO-DO: Cut normalized time into three segments, each corresponding to attack, sustain and release;
//        Distribute time in proportion to the relative duration of each segment;
//        Use the lowest and highest values in each segment to normalize the values from the amplitude envelope function
//        Calculate the weighted sum of the three sinusoids to create a amplitude sinusoid that conforms to [what you wanted for the attack, sustain and release]

// TO-DO: To rescale a sine curve period into a 0 to 1 frame,
//  use 0 to 1/frequency as the new minimum and new maximum, respectively
typedef double (^FrequencySample)(double time, double frequency);//, int argument_count, ...);// , double trill_min, double trill_max, double trill_gamma);
FrequencySample sample_frequency_vibrato = ^(double time, double frequency)//, int argument_count, ...)
{
    //    va_list ap;
    //    double gamma, trill_min, trill_max;
    //    va_start(ap, argument_count);
    //
    //    gamma = va_arg (ap, double);
    //    trill_min = va_arg (ap, double);
    //    trill_max = va_arg (ap, double);
    
    //    va_end (ap);
    
    double result = sinf(2.0 * M_PI * time * frequency);/*^double(double time_, double trill_max_, double trill_min_, double gamma_)
                                                         {
                                                         return ((trill_max_ - trill_min_) * pow(time_, gamma_)) + trill_min_;
                                                         } (frequency, trill_min, trill_max, gamma));/* * ^double(double time, double trill) {
                                                         return sinf(M_PI * time * trill);
                                                         } (time, trill);*/
    return result;
};

//FrequencySampleModifier harmonize_frequency_sample = ^{
//    return ^double(double frequency_sample, int argument_count, ...) {
//        va_list ap;
//        enum HarmonicAlignment harmonic_alignment, typeof(HarmonicInterval) harmonic_interval;
//        va_start (ap, argument_count);
//
//        va_arg (ap, enum HarmonicAlignment);
//        va_arg (ap, typeof(HarmonicInterval) harmonic_interval);
//
//        va_end (ap);
//
//        double harmonized_frequency = frequency * ^double(HarmonicAlignment harmonic_alignment_, typeof(HarmonicInterval) harmonic_interval_) {
//            double * harmonic_alignment_intervals[2] = {consonant_harmonic_interval_ratios, dissonant_harmonic_interval_ratios};
//
//            return (harmonic_alignment_   == HarmonicAlignmentConsonant)
//            ? ((harmonic_interval_ == HarmonicIntervalConsonantRandomize) ? consonant_harmonic_interval_ratios[(HarmonicInterval)arc4random_uniform(7)] : consonant_harmonic_interval_ratios[harmonic_alignment_consonant_interval_]))
//            : ((harmonic_interval_ == HarmonicIntervalDissonantRandomize) ? dissonant_harmonic_interval_ratios[(HarmonicInterval)arc4random_uniform(4)] : dissonant_harmonic_interval_ratios[harmonic_alignment_consonant_interval_]);
//        } (harmonic_alignment, harmonic_interval);
//
//        return harmonized_frequency;
//    };
//};

// TO-DO: Modify the amplitude to account for any changes in the mean
//        See https://en.wikipedia.org/wiki/Least_squares
typedef double (^AmplitudeSample)(double, double);//, int, ...);//double, double, StereoChannelOutput);
AmplitudeSample sample_amplitude_tremolo = ^(double time, double gain)//, int argument_count, ...) // double tremolo, double gamma, StereoChannelOutput stereo_channel_output)
{
    // ERROR: tremolo equation should be: (frequency * amplitude) * tremolo
    //        NOT: frequency * (amplitude * tremolo)
    //    va_list ap;
    //    double tremolo, gamma;
    //    int stereo_channel_output;
    //    va_start(ap, argument_count);
    //
    //    tremolo = va_arg (ap, double);
    //    gamma = va_arg (ap, double);
    //
    //    va_end (ap);
    //
    double result = ^double(double time_, double gain_)
    {
        return sinf(M_PI * time) * gain;//pow(sinf(time_ * M_PI), (stereo_channel_output_) ? 10.0 : 0.1);
    } (time, gain); //(sinf(M_PI  * time * tremolo) * sinf(M_PI_PI * time) / 2.0);// * sinf((M_PI * time * tremolo)));//sinf((M_PI_PI * time * tremolo) / 2) * (time * gain);
    //    result = result * ^double(double gamma_, double time_)
    //    {
    //        double a = pow(time_, gamma_);
    //        double b = 1.0 - a;
    //        double c = a * b;
    ////        c = (stereo_channel_output_ == StereoChannelOutputRight)
    ////        ? 1.0 - c : c;
    //
    //        return c;
    //    } (gamma, time);
    //    result *= gain;
    
    return result;
};

typedef NS_ENUM(NSUInteger, StereoChannelOutput) {
    StereoChannelOutputLeft,
    StereoChannelOutputRight,
    StereoChannelOutputMono,
    StereoChannelOutputUnspecified
};

typedef NSUInteger AVAudioPlayerNodeIndex;
typedef struct DurationTally DurationTally;

typedef void (^PlayedToneCompletionBlock)(void); // passed to player node buffer scheduler by the buffer rendered completion block; called by the player node buffer scheduler after the schedule buffer plays; reruns the render buffer block
typedef void (^BufferRenderedCompletionBlock)(PlayedToneCompletionBlock _Nonnull); // called by buffer renderer after buffer samples are created; runs the player node buffer scheduler
typedef void (^BufferRenderer)(AVAudioFrameCount, double, double, StereoChannelOutput, float *, BufferRenderedCompletionBlock); // adds the sample data to the PCM buffer; calls the buffer rendered completion block when finisned
typedef void(^RenderBuffer)(AVAudioPlayerNodeIndex, dispatch_queue_t __strong, dispatch_queue_t __strong, AVAudioPlayerNode * __strong, AVAudioPCMBuffer *, DurationTally *, BufferRenderer); // starts the process of creating a buffer, scheduling it and playing it, and recursively starting itself again while the player node passed to it isPlaying


// TO-DO: Embed in source event handler (?)
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
        
        struct AudioEngineStatus *audio_engine_status = malloc(sizeof(struct AudioEngineStatus));
        audio_engine_status->status = AudioEngineStatusStopped;
        dispatch_set_context(self.audio_engine_status_dispatch_source, audio_engine_status);
        dispatch_source_merge_data(self.audio_engine_status_dispatch_source, 1);
        
        return FALSE;
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
            
            struct AudioEngineStatus *audio_engine_status = malloc(sizeof(struct AudioEngineStatus));
            audio_engine_status->status = AudioEngineStatusPlaying;
            dispatch_set_context(self.audio_engine_status_dispatch_source, audio_engine_status);
            dispatch_source_merge_data(self.audio_engine_status_dispatch_source, 1);
            
            //            struct AudioStreamBasicDescription {
            //                mSampleRate       = 44100.0;
            //                mFormatID         = kAudioFormatLinearPCM;
            //                mFormatFlags      = kAudioFormatFlagsAudioUnitCanonical;
            //                mBitsPerChannel   = 8 * sizeof (AudioUnitSampleType);                    // 32 bits
            //                mChannelsPerFrame = 2;
            //                mBytesPerFrame    = mChannelsPerFrame * sizeof (AudioUnitSampleType);    // 8 bytes
            //                mFramesPerPacket  = 1;
            //                mBytesPerPacket   = mFramesPerPacket * mBytesPerFrame;     // 8 bytes
            //                mReserved         = 0;
            //            };
            
            unsigned int seed    = (unsigned int)time(0);
            size_t buffer_size   = 256 * sizeof(char *);
            char * random_buffer = (char *)malloc(buffer_size);
            initstate(seed, random_buffer, buffer_size);
            srandomdev();
            
            chord_frequency_ratios = (struct ChordFrequencyRatio *)malloc(sizeof(struct ChordFrequencyRatio));
            
            typedef void (^PlayTones)(__weak typeof(AVAudioPlayerNode) *,
                                      __weak typeof(AVAudioPCMBuffer) *,
                                      __weak typeof(AVAudioFormat) *);
            
            static PlayTones play_tones;
            play_tones =
            ^ (__weak typeof(AVAudioPlayerNode) * player_node,
               __weak typeof(AVAudioPCMBuffer) * pcm_buffer,
               __weak typeof(AVAudioFormat) * audio_format) {
                
                const double sample_rate = [audio_format sampleRate];
                
                const AVAudioChannelCount channel_count = audio_format.channelCount;
                const AVAudioFrameCount frame_count = sample_rate * 2.0;
                pcm_buffer.frameLength = frame_count;
                
                dispatch_queue_t samplerQueue = dispatch_queue_create("com.blogspot.demonicactivity.samplerQueue", DISPATCH_QUEUE_SERIAL);
                dispatch_block_t samplerBlock = dispatch_block_create(0, ^{
                    
                    ^ (AVAudioChannelCount channel_count, AVAudioFrameCount frame_count, double sample_rate, float * const _Nonnull * _Nullable float_channel_data) {
                        
                        for (int channel_index = 0; channel_index < 1; channel_index++)
                        {
                            double sin_phase = 0.0;
                            double sin_increment = (440.0 * (2.0 * M_PI)) / sample_rate;
                            double sin_increment_aux = (880.0 * (2.0 * M_PI)) / sample_rate;
                            
                            double divider = ^ long (long random, int n, int m) {
                                long result = random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n);
                                return result;
                            } (random(), 11025, 77175);
                            if (float_channel_data[channel_index])
                                for (int buffer_index = 0; buffer_index < frame_count; buffer_index++) {
                                    if (float_channel_data) float_channel_data[channel_index][buffer_index] = sinf(sin_phase);
                                    sin_phase += (buffer_index > 11025) ? sin_increment : sin_increment_aux;
                                    if (sin_phase >= (2.0 * M_PI)) sin_phase -= (2.0 * M_PI);
                                    if (sin_phase < 0.0) sin_phase += (2.0 * M_PI);
                                    
                                }
                        }
                        
                    } (channel_count, frame_count, sample_rate, pcm_buffer.floatChannelData);
                });
                dispatch_block_t playToneBlock = dispatch_block_create(0, ^{
                    ^ (PlayedToneCompletionBlock played_tone) {
                        if ([player_node isPlaying])
                        {
                            //                            report_memory();
                            
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
                });
                dispatch_block_notify(samplerBlock, dispatch_get_main_queue(), playToneBlock);
                dispatch_async(samplerQueue, samplerBlock);
            };
            //            play_tones =
            //            ^ (__weak typeof(AVAudioPlayerNode) * player_node,
            //               __weak typeof(AVAudioPCMBuffer) * pcm_buffer,
            //               __weak typeof(AVAudioFormat) * audio_format) {
            //
            //                const double sample_rate = [audio_format sampleRate];
            //
            //                const AVAudioChannelCount channel_count = audio_format.channelCount;
            //                const AVAudioFrameCount frame_count = sample_rate * 2.0;
            //                pcm_buffer.frameLength = frame_count;
            //
            //                const double PI_2 = 2.0 * M_PI;
            //                const double phase_increment = PI_2 / frame_count;
            //                const double (^phase_validator)(double) = ^ double (double phase) {
            //                    if (phase >= PI_2) phase -= PI_2;
            //                    if (phase < 0.0)   phase += PI_2;
            //
            //                    return phase;
            //                };
            //
            //                dispatch_queue_t samplerQueue = dispatch_queue_create("com.blogspot.demonicactivity.samplerQueue", DISPATCH_QUEUE_SERIAL);
            //                dispatch_block_t samplerBlock = dispatch_block_create(0, ^{
            //
            //                    ^ (AVAudioChannelCount channel_count, AVAudioFrameCount frame_count, double sample_rate, float * const _Nonnull * _Nullable float_channel_data) {
            //                        for (int channel_index = 0; channel_index < channel_count; channel_index++)
            //                        {
            //                            double signal_frequency = (^ double (double fundamental_frequency, double frequency_ratio) {
            //                                return (fundamental_frequency * frequency_ratio);
            //                            } ((chord_frequency_ratios->indices.ratio == 0 || chord_frequency_ratios->indices.ratio == 2)
            //                               ? ^ double (double * root_frequency, long random) {
            //                                *root_frequency = pow(1.059463094f, random) * 440.0;
            //                                return *root_frequency;
            //                            } (&chord_frequency_ratios->root, ^ long (long random, int n, int m) {
            //                                long result = random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n);
            //                                return result;
            //                            } (random(), -8, 24))
            //                               : chord_frequency_ratios->root,
            //                               ratio[1][chord_frequency_ratios->indices.ratio]));
            ////                            if (chord_frequency_ratios->indices.ratio == 0) chord_frequency_ratios->indices.chord++;
            //
            //                            double divider = ^ double (long random, int n, int m) {
            //                                double result = (random % abs(MIN(m, n) - MAX(m, n)) + MIN(m, n)) * .01;
            //                                return result;
            //                            } (random(), 25, 175);
            //
            //                            printf("divider == %f\n", divider);
            //
            //                            double signal_phase = 0.0;
            //                            double signal_increment = signal_frequency * phase_increment;
            //                            double signal_increment_aux = signal_frequency * (5.0/4.0) /*ratio[1][chord_frequency_ratios->indices.ratio])*/ * phase_increment;
            //
            //                            double amplitude_frequency = 1.0;
            //                            double amplitude_phase = 0.0;
            //                            double amplitude_increment = (amplitude_frequency) * phase_increment;
            //
            //                            double tremolo_min, tremolo_max;
            //                            tremolo_min = (chord_frequency_ratios->indices.ratio == 0 || chord_frequency_ratios->indices.ratio == 2) ? 4.0 : 6.0;
            //                            tremolo_max = (chord_frequency_ratios->indices.ratio == 0 || chord_frequency_ratios->indices.ratio == 2) ? 6.0 : 4.0;
            //                            double tremolo_frequency   = scale(tremolo_min, tremolo_max, chord_frequency_ratios->root, 277.1826317, 1396.912916);
            //
            //                            double tremolo_phase = 0.0;
            //                            double tremolo_increment = (tremolo_frequency) * phase_increment;
            //
            //                            if (float_channel_data[channel_index])
            //                                for (int buffer_index = 0; buffer_index < frame_count; buffer_index++) {
            //                                    float_channel_data[channel_index][buffer_index] = /*sinf(tremolo_phase) **/ sinf(amplitude_phase) * sinf(signal_phase);
            //                                    signal_phase += ^ double (double time) { return (time < divider) ? signal_increment : signal_increment_aux; } (scale(0.0, 1.0, buffer_index, 0, frame_count));
            //
            //                                    phase_validator(signal_phase);
            //                                    amplitude_phase += amplitude_increment;
            //                                    phase_validator(amplitude_phase);
            //                                    tremolo_phase += ^ double (double time) { return time * tremolo_increment; } (scale(MIN(tremolo_min, tremolo_frequency), MIN(tremolo_max, tremolo_frequency), buffer_index, 0, frame_count));
            //                                    phase_validator(tremolo_phase);
            //                                }
            //                            chord_frequency_ratios->indices.ratio++;
            //                        }
            //
            //                    } (channel_count, frame_count, sample_rate, pcm_buffer.floatChannelData);
            //                });
            //                dispatch_block_t playToneBlock = dispatch_block_create(0, ^{
            //                    ^ (PlayedToneCompletionBlock played_tone) {
            //                        if ([player_node isPlaying])
            //                        {
            ////                            report_memory();
            //
            //                            [player_node prepareWithFrameCount:frame_count];
            //                            [player_node scheduleBuffer:pcm_buffer
            //                                                 atTime:nil
            //                                                options:AVAudioPlayerNodeBufferInterruptsAtLoop
            //                                 completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack
            //                                      completionHandler:^(AVAudioPlayerNodeCompletionCallbackType callbackType) {
            //                                if (callbackType == AVAudioPlayerNodeCompletionDataPlayedBack)
            //                                    played_tone();
            //                            }];
            //                        }
            //                    } (^ {
            //                        play_tones(player_node, pcm_buffer, audio_format);
            //                    });
            //                });
            //                dispatch_block_notify(samplerBlock, dispatch_get_main_queue(), playToneBlock);
            //                dispatch_async(samplerQueue, samplerBlock);
            //            };
            
            __weak typeof(AVAudioPlayerNode) * w_playerNode = self.playerNode;
            __weak typeof(AVAudioPCMBuffer) * w_pcmBuffer = self.pcmBuffer;
            __weak typeof(AVAudioFormat) * w_audioFormat = self.audioFormat;
            
            play_tones(w_playerNode, w_pcmBuffer, w_audioFormat);
            
            return TRUE;
            
        } else {
            return FALSE;
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

void add_arrays(const float signal_increment,
                float* channel_data,
                int index)
{
    channel_data[index] = sin(signal_increment);
}


@end
