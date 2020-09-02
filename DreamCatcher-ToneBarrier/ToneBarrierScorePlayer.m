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

//#include "new.h"
//#include "Class.h"
#include "RandomSource.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GameKit/GameKit.h>
#import <objc/runtime.h>

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

typedef double (^FrequencySample)(double, double);
FrequencySample sample_frequency = ^(double time, double frequency)
{
    double result = sinf(M_PI * 2.0 * time * frequency);
    
    return result;
};

typedef double (^AmplitudeSample)(double, double);
AmplitudeSample sample_amplitude = ^(double time, double gain)
{
    double result = pow(sinf(time * M_PI), gain);
    
    return result;
};

@interface ToneBarrierScorePlayer ()
{
    struct RandomSource * duration_random_source;
    struct RandomSource * frequency_random_source;
}

@end

@implementation ToneBarrierScorePlayer

static ToneBarrierScorePlayer * sharedPlayer = NULL;
+ (nonnull ToneBarrierScorePlayer *)sharedPlayer;
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
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
        duration_random_source  = new(random_generator_drand48, 0.25, 1.75);
        frequency_random_source = new(random_generator_drand48, 400.0, 2000.0);
        
        [self setupEngine];
    }
    
    return self;
}

- (void)setupEngine
{
    self.audioEngine = [[AVAudioEngine alloc] init];
    
    self.mainNode = self.audioEngine.mainMixerNode;
    
    double sampleRate = [self.mainNode outputFormatForBus:0].sampleRate;
    AVAudioChannelCount channelCount = [self.mainNode outputFormatForBus:0].channelCount;
    self.audioFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:sampleRate channels:channelCount];
}

- (BOOL)startEngine
{
    __autoreleasing NSError *error = nil;
    if ([self.audioEngine startAndReturnError:&error])
    {
        NSLog(@"1/3. AudioEngine started");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error)
        {
            NSLog(@"1/3. AudioSession category could not be set: %@", [error description]);
            return FALSE;
        } else {
            NSLog(@"2/3. AudioSession configured");
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (error)
            {
                NSLog(@"2/3. AudioSession could not be activated: %@", [error description]);
                return FALSE;
            } else {
                NSLog(@"3/3. AudioSession activated");
                return TRUE;
            }
        }
    } else {
        NSLog(@"1/3. AudioEngine could not be started: %@", [error description]);
        return FALSE;
    }
}




typedef void (^PlayedToneCompletionBlock)(void);
typedef void (^BufferRenderedCompletionBlock)(AVAudioPlayerNode * _Nonnull player_node, AVAudioPCMBuffer * _Nonnull buffer, PlayedToneCompletionBlock _Nonnull playedToneCompletionBlock);
typedef void (^RenderBuffer)(AVAudioPlayerNode *, AVAudioSession *, AVAudioFormat *, BufferRenderedCompletionBlock);

- (BOOL)play
{
    if ([self.audioEngine isRunning])
    {
        [self.playerNode pause];
        
        [self.audioEngine pause];
        
        [self.audioEngine detachNode:self.playerNode];
        self.playerNode = nil;
        
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
        
        self.mixerNode = [[AVAudioMixerNode alloc] init];
        
        self.reverb = [[AVAudioUnitReverb alloc] init];
        [self.reverb loadFactoryPreset:AVAudioUnitReverbPresetLargeChamber];
        [self.reverb setWetDryMix:50.0];
        
        [self.audioEngine attachNode:self.reverb];
        [self.audioEngine attachNode:self.playerNode];
        [self.audioEngine attachNode:self.mixerNode];
        
        [self.audioEngine connect:self.playerNode     to:self.mixerNode  format:self.audioFormat];
        [self.audioEngine connect:self.mixerNode      to:self.reverb      format:self.audioFormat];
        [self.audioEngine connect:self.reverb         to:self.mainNode    format:self.audioFormat];
        
        if ([self startEngine])
        {
            if (![self.playerNode isPlaying])
            {
                [self.playerNode play];
            }
            
            static void(^render_buffer)(void);
            // plays tone
            render_buffer = ^{
                // creates tone
                ^(AVAudioPlayerNode * player_node, AVAudioSession * audio_session, AVAudioFormat * audio_format, BufferRenderedCompletionBlock buffer_rendered)
                {   // returns buffer            // creates buffer
                    buffer_rendered(player_node, ^AVAudioPCMBuffer * (void (^buffer_sample)(AVAudioFrameCount, double, double, double, float *, AVAudioChannelCount))
                                    {
                        double duration = duration_random_source->generate_random(duration_random_source);
                        AVAudioFrameCount frameCount = ([audio_format sampleRate] * duration);
                        AVAudioPCMBuffer *pcmBuffer  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audio_format frameCapacity:frameCount];
                        pcmBuffer.frameLength        = frameCount;
                        
                        AVAudioChannelCount channel_count = audio_format.channelCount;
                        double root_freq = frequency_random_source->generate_random(frequency_random_source) /** duration*/;
                        double harmonic_freq = root_freq * (5.0/4.0);
                        NSLog(@"  dur:  %fs\tfreq(s):  %f\t%f", duration, root_freq, harmonic_freq);
                        double device_volume = pow(audio_session.outputVolume, 3.0);
                        
                        buffer_sample(pcmBuffer.frameLength,
                                      root_freq,
                                      duration,
                                      device_volume,
                                      pcmBuffer.floatChannelData[0],
                                      channel_count);
                        
                        buffer_sample(pcmBuffer.frameLength,
                                      harmonic_freq,
                                      duration,
                                      device_volume,
                                      (channel_count == 2) ? pcmBuffer.floatChannelData[1] : nil,
                                      channel_count);
                        
                        return pcmBuffer;
                        // buffer_sample executable
                    }(^(AVAudioFrameCount sampleCount, double frequency, double duration, double output_volume, float * samples, AVAudioChannelCount channel_count)
                      {
                        NSLog(@"  dur:  %fs\tfreq:  %f\tvol:  %f", duration, frequency, output_volume);
                        
                        //        for (AVAudioChannelCount channel = 0; channel < channel_count; channel++)
                        //        {
                        for (int index = 0; index < sampleCount; index++)
                        {
                            double normalized_time = normalize(0.0, 1.0, index);
                            double sine_frequency = sample_frequency(normalized_time, frequency);
                            double sample = sine_frequency * sample_amplitude(normalized_time, output_volume);
                            
                            if (samples) samples[index] = sample;
                            //                if (samples[channel]) samples[channel][index] = sample;
                        }
                        // PlayedToneCompletionBlock executable
                    }), ^(void) {
                        render_buffer();
                    });
                    // render_buffer parameters                // BufferRenderedCompletionBlock executable
                } (self.playerNode, [AVAudioSession sharedInstance], self.audioFormat, ^(AVAudioPlayerNode * player_node, AVAudioPCMBuffer * pcm_buffer, PlayedToneCompletionBlock played_tone) {
                    [player_node scheduleBuffer:pcm_buffer atTime:nil options:AVAudioPlayerNodeBufferInterruptsAtLoop completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack completionHandler:^(AVAudioPlayerNodeCompletionCallbackType callbackType) {
                        played_tone();
                    }];
                });
            };
            
            render_buffer();
            
            return TRUE;
            
        } else {
            return FALSE;
        }
    }
}

@end
