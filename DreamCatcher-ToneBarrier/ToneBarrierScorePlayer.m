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

struct FrequencyScale
{
    double root_frequency;
    int total;
    int tally;
    double ratios[4];
    //    int (^next_ratio)(int * total, int * tally);
} * frequency_scale;

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

typedef double * (^FrequencyModulator)(double, int, ...);
static FrequencyModulator harmonize_frequency = //enum HarmonicAlignment, enum typeof(HarmonicInterval)));
^ double * (double root_frequency, int argument_count, ... /*enum HarmonicAlignment harmonic_alignment, enum typeof(HarmonicInterval) harmonic_interval*/)
{
    va_list ap;
    double * harmonic_pitch;
    int harmonic_pitch_ratio_count;
    va_start (ap, argument_count);
    harmonic_pitch = va_arg (ap, double *);
    harmonic_pitch_ratio_count = va_arg (ap, int);
    va_end (ap);
    
    double ratio_1[4] = {8.0, 10.0, 12.0, 15.0};
    double * majorSeventhFrequencyRatios = &ratio_1[0];
    
    //    for (int i = 0; i < (harmonic_pitch_ratio_count); i++)
    //        harmonized_frequency[i] = (harmonic_alignment == HarmonicAlignmentConsonant) ? harmonic_alignment_ratios_consonant[i] : harmonic_alignment_ratios_dissonant[i];
    double ratios_values[4] = {0.0, 1.0, 2.0, 3.0};
    double *ratios = malloc(sizeof(double) * 4);
    ratios = ratios_values;
    
    return ratios;
};

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
        //        dispatch_source_set_event_handler(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source, ^{
        //            struct ContextData * data = dispatch_get_context(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source);
        //            printf("x = %f", data->x);
        //        });
        //
        //        dispatch_resume(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source);
        //
        //        struct ContextData *context_data = malloc(sizeof(struct ContextData));
        //        context_data->x = 2.0;
        //        dispatch_set_context(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source, context_data);
        //        dispatch_source_merge_data(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source, 1);
        
        [self setupEngine];
        self.commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        
        MPRemoteCommandHandlerStatus (^remoteCommandHandler)(MPRemoteCommandEvent * _Nonnull) = ^ MPRemoteCommandHandlerStatus (MPRemoteCommandEvent * _Nonnull event) {
            if ([self play])
            {
                [self nowPlayingInfo];
                return MPRemoteCommandHandlerStatusSuccess;
            } else {
                return MPRemoteCommandHandlerStatusCommandFailed;
            }
        };
        
        [self.commandCenter.playCommand addTargetWithHandler:remoteCommandHandler];
        [self.commandCenter.stopCommand addTargetWithHandler:remoteCommandHandler];
        [self.commandCenter.pauseCommand addTargetWithHandler:remoteCommandHandler];
    }
    
    return self;
}

- (void)nowPlayingInfo
{
    // Define Now Playing Info
    NSMutableDictionary<NSString *, id> * nowPlayingInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    [nowPlayingInfo setObject:@"ToneBarrier" forKey:MPMediaItemPropertyTitle];
    
    UIImage * image = [UIImage systemImageNamed:@"waveform.path"];
    CGSize imageBounds = CGSizeMake(180.0, 180.0);
    
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:imageBounds requestHandler:^UIImage * _Nonnull(CGSize size) {
        return image;
    }];
    
    [nowPlayingInfo setObject:(MPMediaItemArtwork *)artwork forKey:MPMediaItemPropertyArtwork];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:(NSDictionary *)nowPlayingInfo];
}


- (BOOL)setupEngine
{
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
typedef struct FrequencyScale FrequencyScale;

typedef void (^PlayedToneCompletionBlock)(void); // passed to player node buffer scheduler by the buffer rendered completion block; called by the player node buffer scheduler after the schedule buffer plays; reruns the render buffer block
typedef void (^BufferRenderedCompletionBlock)(PlayedToneCompletionBlock _Nonnull); // called by buffer renderer after buffer samples are created; runs the player node buffer scheduler
typedef void (^BufferRenderer)(AVAudioFrameCount, double, double, StereoChannelOutput, float *, BufferRenderedCompletionBlock); // adds the sample data to the PCM buffer; calls the buffer rendered completion block when finisned
typedef void(^RenderBuffer)(AVAudioPlayerNodeIndex, dispatch_queue_t __strong, dispatch_queue_t __strong, AVAudioPlayerNode * __strong, AVAudioPCMBuffer *, DurationTally *, FrequencyScale *, BufferRenderer); // starts the process of creating a buffer, scheduling it and playing it, and recursively starting itself again while the player node passed to it isPlaying

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
            
            frequency_scale = (FrequencyScale *)malloc(sizeof(FrequencyScale));
            frequency_scale->root_frequency = 440.0;
            frequency_scale->ratios[0] = 1.0;
            frequency_scale->ratios[1] = 10.0 / 8.0;
            frequency_scale->ratios[2] = 12.0 / 8.0;
            frequency_scale->ratios[3] = 15.0 / 8.0;
            
            struct counter_struct
            {
                __block AVAudioPlayerNodeChannelIndex player_node_channel_index : 2;
            };
            __block struct counter_struct cs = { .player_node_channel_index = 0 };
            
            const double PI_2 = 2.0 * M_PI;
            
            typedef void (^PlayTones)(__weak typeof(AVAudioPlayerNode) *,
                                      __weak typeof(AVAudioPCMBuffer) *,
                                      __weak typeof(AVAudioFormat) *);
            
            static PlayTones play_tones;
            play_tones =
            ^ (__weak typeof(AVAudioPlayerNode) * player_node,
               __weak typeof(AVAudioPCMBuffer) * pcm_buffer,
               __weak typeof(AVAudioFormat) * audio_format) {
                
                double sample_rate = [audio_format sampleRate];
                AVAudioChannelCount channel_count = audio_format.channelCount;
                AVAudioFrameCount frame_count = sample_rate * 2.0;
                pcm_buffer.frameLength        = frame_count;
                
                dispatch_queue_t samplerQueue = dispatch_queue_create("com.blogspot.demonicactivity.samplerQueue", DISPATCH_QUEUE_SERIAL);
                dispatch_block_t samplerBlock = dispatch_block_create(0, ^{
                    
                    ^ (AVAudioChannelCount channel_count, AVAudioFrameCount frame_count, double sample_rate, float * const _Nonnull * _Nullable float_channel_data) {
                        double sin_phase = 0.0;
                        
                        for (int channel_index = 0; channel_index < channel_count; channel_index++)
                        {
                            double sin_increment = (^ double (double fundamental_frequency, double fundamental_ratio, double frequency_ratio) {
                                return (fundamental_frequency * frequency_ratio);
                            } ((cs.player_node_channel_index == 0) ? ^ double (double * root_frequency, double random) {
                                *root_frequency = pow(1.059463094, (int)random) * 440.0;
                                return *root_frequency;
                            } (&frequency_scale->root_frequency, ^ double (double random, double n, double m, double gamma) {
                                // ignore gamma for now
                                // -57.0, 50.0
                                double result = scale(n, m, random, -pow(2, 32), pow(2, 32));
                                return result;
                            } (arc4random(), -8.0, 24.0, 1.0)) : frequency_scale->root_frequency, frequency_scale->ratios[0],
                               frequency_scale->ratios[cs.player_node_channel_index]) * PI_2) / sample_rate;
                            
                            cs.player_node_channel_index++;
                                                    
                            double val;
                            double curfreq = scale(0.5, 4.0, frequency_scale->root_frequency, 277.1826317, 1396.912916);
                            double curphase = (cs.player_node_channel_index == 0 || cs.player_node_channel_index == 2) ? 0.0 : M_PI_2;
                            double incr = (PI_2 / sample_rate) * curfreq;

                            if (float_channel_data[channel_index])
                                for (int buffer_index = 0; buffer_index < frame_count; buffer_index++) {
                                    val = (2.0 * (curphase * (1.0 / PI_2) )) - 1.0;
                                    if (val < 0.0) val = -val;
                                    val = 2.0 * (val - 0.5);
                                    curphase += incr;
                                    if (curphase >= PI_2) curphase -= PI_2;
                                    if (curphase < 0.0)   curphase += PI_2;
                                    
                                    float_channel_data[channel_index][buffer_index] = val * sinf(sin_phase);
                                    sin_phase += sin_increment;
                                    if (sin_phase >= PI_2) sin_phase -= PI_2;
                                    if (sin_phase < 0.0)   sin_phase += PI_2;
                                }
                        }
                    } (channel_count, frame_count, sample_rate, pcm_buffer.floatChannelData);
                });
                dispatch_block_t playToneBlock = dispatch_block_create(0, ^{
                    
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
                });
                dispatch_block_notify(samplerBlock, dispatch_get_main_queue(), playToneBlock);
                dispatch_async(samplerQueue, samplerBlock);
            };
            
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


@end
