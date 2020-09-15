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

#include <stdlib.h>

#import "ToneBarrierScorePlayer.h"

#include "Randomizer.h"
#include "Tone.h"



typedef uint32_t AVAudioPlayerNodeCount, AVAudioPlayerNodeIndex;

// Classification of structs:
// - some organize properties and methods that relate to software design and architecture (computer science, hardware considerations, best practices, provisions)
// - some organize methods and properties to affect or ensure tone barrier specifications
// - some organize methods and properties relating to the mathematics (statistics)
// - some organize methods and properties relating to the science (music and sound theory and practice)
// - some organize methods and properties relating to expediency (driven by external and personal concerns, urgency of demand)

typedef struct DurationTally
{
    double total;
    double tally;
    double(^next_duration)(double * tally, double * total);
} * DurationTally;

typedef struct FrequencyChord
{
    double ratios[4];
    int frequency_count;
    double frequencies[4];
} * FrequencyChord;

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



@interface ToneBarrierScorePlayer ()
{
    struct DurationTally * duration_tally[2];
    struct FrequencyChord * frequency_chord;
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
    if (self == [super init])
    {
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

typedef NS_ENUM(NSUInteger, StereoChannelOutput) {
    StereoChannelOutputLeft,
    StereoChannelOutputRight,
    StereoChannelOutputMono
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

- (BOOL)play
{
    //    void * tone = new(Tone, "ToneChannelR");
    
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
            
            dispatch_queue_t player_nodes_concurrent_queue = dispatch_queue_create_with_target("render_buffer_concurrent_queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
            dispatch_queue_t player_node_serial_queue = dispatch_queue_create("player_node_serial_queue", DISPATCH_QUEUE_SERIAL);
            dispatch_queue_t player_node_serial_queue_aux = dispatch_queue_create("player_node_serial_queue_aux", DISPATCH_QUEUE_SERIAL);
            
            unsigned int seed = (unsigned int)time(0);
            size_t buffer_size = 256 * sizeof(char *);
            char * random_buffer_duration      = (char *)malloc(buffer_size);
            char * random_buffer_frequency     = (char *)malloc(buffer_size);
            char * random_buffer_duration_aux  = (char *)malloc(buffer_size);
            char * random_buffer_frequency_aux = (char *)malloc(buffer_size);
            
            initstate(seed, , buffer_size);
            
            static void(^render_buffer[2])(dispatch_queue_t __strong, dispatch_queue_t __strong, AVAudioPlayerNode * __strong,  struct Randomizer *, struct Randomizer *, struct DurationTally *);
            for (int i = 0; i < 2; i++)
            {
                
                
                duration_tally[i] = (struct DurationTally *)malloc(sizeof(struct DurationTally *));
                duration_tally[i]->tally = 2.0;
                duration_tally[i]->total = 2.0;
                duration_tally[i]->next_duration = ^ double (double * tally, double *total) {
                    if (*tally == *total)
                    {
                        double duration_diff = 1.0; // < -- placeholder for duration_randomizer->generate_distributed_random(duration_randomizer);
                        *tally = *total - duration_diff;
                        
                        return duration_diff;
                    } else {
                        double duration_remainder = *tally;
                        *tally = *total;
                        
                        return duration_remainder;
                    }
                };
                
                frequency_chord = (struct FrequencyChord *)malloc(sizeof(struct FrequencyChord));
                //                frequency_chord->ratios[0] = 8.0;
                //                frequency_chord->ratios[0] = 10.0;
                //                frequency_chord->ratios[0] = 12.0;
                //                frequency_chord->ratios[0] = 15.0;
                
                render_buffer[i] = ^(dispatch_queue_t __strong concurrent_queue, dispatch_queue_t __strong serial_queue, AVAudioPlayerNode * __strong player_node, struct Randomizer * duration_randomizer, struct Randomizer * frequency_randomizer, struct DurationTally * tone_duration) {
                    ^(AVAudioPlayerNodeCount player_node_count, AVAudioSession * audio_session, AVAudioFormat * audio_format, BufferRenderedCompletionBlock buffer_rendered)
                    {
                        buffer_rendered(^ AVAudioPCMBuffer * (double distributed, double duration, void (^buffer_sample)(AVAudioFrameCount, double, double, StereoChannelOutput, float *)) {
                            double fundamental_frequency = distributed;//,er, * duration;
                            double harmonic_frequency = fundamental_frequency * (4.0/5.0);
                            if (harmonic_frequency < 500.0)
                            {
                                harmonic_frequency = fundamental_frequency;
                                fundamental_frequency = fundamental_frequency * (5.0/4.0);
                            }
                            printf("\nDUR:\t%f\tFREQ\t%f\tHARM:\t%f\n\n", duration, fundamental_frequency, harmonic_frequency);
                            
                            AVAudioFrameCount frameCount = ([audio_format sampleRate] * duration);
                            [player_node prepareWithFrameCount:frameCount];
                            AVAudioPCMBuffer *pcmBuffer  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audio_format frameCapacity:frameCount];
                            pcmBuffer.frameLength        = frameCount;
                            AVAudioChannelCount channel_count = audio_format.channelCount;
                            
                            
                            buffer_sample(frameCount,
                                          fundamental_frequency,
                                          harmonic_frequency,
                                          StereoChannelOutputLeft,
                                          pcmBuffer.floatChannelData[0]);
                            
                            buffer_sample(frameCount,
                                          harmonic_frequency,
                                          fundamental_frequency,
                                          StereoChannelOutputRight,
                                          (channel_count == 2) ? pcmBuffer.floatChannelData[1] : nil);
                            return pcmBuffer;
                        } (^ double (double random, uint32_t n, uint32_t m, double gamma) {
                            double result = pow(random, gamma);
                            result = (result * (m - n)) + n;
                            return result;
                        } (^ double () {
                            double random = drand48();
                            return random;
                        } (), 500, 2000, 2.0), ^ double (double * tally, double *total) {
                            if (*tally == *total)
                            {
                                double random = drand48();
                                double duration_diff = *total * random; // < -- placeholder for duration_randomizer->generate_distributed_random(duration_randomizer);
                                *tally = *total - duration_diff;
                                
                                return duration_diff;
                            } else {
                                double duration_remainder = *tally;
                                *tally = *total;
                                
                                return duration_remainder;
                            }
                        } (&tone_duration->tally, &tone_duration->total), (^(AVAudioFrameCount sample_count, double fundamental_frequency, double harmonic_frequency, StereoChannelOutput stereo_channel_output, float * samples) {
                            for (int index = 0; index < sample_count; index++)
                            if (samples) samples[index] =
                                ^ float (float xt, float frequency) { // pow(2.0 * pow(sinf(M_PI * time * trill), 2.0) * 0.5, 4.0); // (-(1 - xt) * log2(1 - xt) - xt * log2(xt));
                                    return (frequency < 600.0)
                                    ? sinf(M_PI * frequency * xt) * (^ float (void) {
                                        return sinf(M_PI * xt * ((((xt - 0.0) * (6.0 - 4.0)) / (1.0 - 0.0)))) * (^ float (AVAudioChannelCount channel_count, AVAudioPlayerNodeCount player_node_count) {
                                            return ((^ float (float output_volume) { return /*sinf(M_PI * xt) / (2.0 * output_volume)*/ (1.0/output_volume) / (player_node_count * channel_count); } ((audio_session.outputVolume == 0) ? 1.0 : audio_session.outputVolume)));
                                        } (audio_format.channelCount, player_node_count));
                                    } ())
                                    : cosf(M_PI * frequency * xt) * (^ float (void) {
                                        return sinf(M_PI * xt * ((((xt - 0.0) * (6.0 - 4.0)) / (1.0 - 0.0)))) * (^ float (AVAudioChannelCount channel_count, AVAudioPlayerNodeCount player_node_count) {
                                            return ((^ float (float output_volume) { return /*sinf(M_PI * xt) / (2.0 * output_volume)*/ (1.0/output_volume) / (player_node_count * channel_count); } ((audio_session.outputVolume == 0) ? 1.0 : audio_session.outputVolume)));
                                        } (audio_format.channelCount, player_node_count));
                                    } ());
                                } (^ float (float range_min, float range_max, float range_value) {
                                    return (range_value - range_min) / (range_max - range_min);
                                } (0.0, sample_count, index), fundamental_frequency);
                        })), ^{
                            dispatch_async(concurrent_queue, ^{
                                render_buffer[i](concurrent_queue, serial_queue, player_node, duration_randomizer, frequency_randomizer, tone_duration);
                            });
                        });
                    } ((AVAudioPlayerNodeCount)2, [AVAudioSession sharedInstance], self.audioFormat,
                       ^(AVAudioPCMBuffer * pcm_buffer, PlayedToneCompletionBlock played_tone) {
                        if ([player_node isPlaying])
                            [player_node scheduleBuffer:pcm_buffer atTime:nil options:AVAudioPlayerNodeBufferInterruptsAtLoop completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack completionHandler:
                             ^(AVAudioPlayerNodeCompletionCallbackType callbackType) {
                                if (callbackType == AVAudioPlayerNodeCompletionDataPlayedBack)
                                /*dispatch_sync(serial_queue, ^{ */played_tone();/* });*/
                            }];
                    });
                };
                
                dispatch_async(player_nodes_concurrent_queue, ^{
                    dispatch_sync((i == 0) ? player_node_serial_queue : player_node_serial_queue_aux, ^{
                        render_buffer[i](player_nodes_concurrent_queue,
                                         (i == 0) ? player_node_serial_queue : player_node_serial_queue_aux,
                                         (i == 0) ? self.playerNode : self.playerNodeAux,
                                         (i == 0) ? random_buffer_duration : random_buffer_duration_aux,
                                         (i == 0) ? random_buffer_frequency : random_buffer_frequency_aux,
                                         ^struct DurationTally * (struct DurationTally * tally){ return tally; }(self->duration_tally[i]));
                    });
                });
            }
            
            return TRUE;
            
        } else {
            return FALSE;
        }
    }
}

//    struct RandomSource * duration_random_source;
//    struct RandomSource * frequency_random_source;
//    duration_random_source = new(random_generator_drand48, 0.25, 1.75);
//    frequency_random_source = new(random_generator_drand48, 500.0, 2000.0);
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
