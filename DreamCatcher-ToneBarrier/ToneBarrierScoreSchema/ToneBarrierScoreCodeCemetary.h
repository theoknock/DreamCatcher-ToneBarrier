//#include <stdio.h>
//
//#include "new.h"
//#include "Object.h"
//#include "Set.h"
//
//
//int main()
//{
//    //    create a new Set object
//    void * s = new(Set);
//
//    //    add an object to the set
//    void * a = add(s, new(Object));
//
//    //    add an object to the set
//    void * b = add(s, new(Object));
//
//    //    create an individual instance of an object
//    void * c = new(Object);
//
//
//    if (contains(s, a) && contains(s, b))
//        puts("ok");
//
//    if (contains(s, c))
//        puts("contains?");
//
//    if (differ(a, add(s, a)))
//        puts("differ?");
//
//    if (contains(s, drop(s,a)))
//        puts("drop?");
//
//    delete(drop(s, b));
//    delete(drop(s, c));
//    
//    return 0;
//}
//
//// --
//
//
//
//#include <stdio.h>
//#include "String.h"
//#include "new.h"
//
//
//
//int main(void)
//{
//    void * a = new(String, "a"), *aa = clone(a);
//    void * b = new(String, "b");
//
//    printf("sizeOf(a) == %u\n", sizeOf(a));
//    if (differ(a,b))
//    {
//        puts("ok");
//    }
//    if (differ(a,aa))
//    {
//        puts("differ?");
//    }
//    if (a == aa)
//    {
//        puts("clone?");
//    }
//
//    delete(a), delete(aa), delete(b);
//    return 0;
//}
//
//
//

//
//  ToneBarrierScore.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

//#import <Foundation/Foundation.h>

//! Project version number for ToneBarrierScore.
//FOUNDATION_EXPORT double ToneBarrierScoreVersionNumber;

//! Project version string for ToneBarrierScore.
//FOUNDATION_EXPORT const unsigned char ToneBarrierScoreVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ToneBarrierScore/PublicHeader.h>
//#include "Randomizer.h"
//
//typedef enum : NSUInteger {
//    RandomSourceScalarTypeInt,
//    RandomSourceScalarTypeFloat
//} RandomSourceScalarType;
//
//typedef enum : NSUInteger {
//    RandomDistributionRangeLowerUpperBounds,
//    RandomDistributionRangeMeanDeviation
//} RandomDistributionRangeScalarType;
//
//union DistributionRange
//{
//    int * distribution_range_lower_upper_bounds;
//    float * distribution_range_mean_deviation;
//};
//typedef union DistributionRange DistributionRange;
//
//struct RandomDistributor
//{
//    GKGaussianDistribution * distributor;
//    RandomDistributionRangeScalarType range_scalar_type;
//    DistributionRange range_parameters;
//};
//typedef struct RandomDistributor RandomDistributor;
//
//struct RandomSource
//{
//    GKMersenneTwisterRandomSource * source;
//    RandomSourceScalarType source_scalar_type;
//};
//typedef struct RandomSource RandomSource;
//
//struct Randomizer
//{
//    RandomSource random_source;
//    RandomDistributor random_distributor;
//};
//typedef struct Randomizer Randomizer;
//
//
//// ---------
//
////StereoChannelList * (^createStereoChannelList)(AVAudioFrameCount, AVAudioChannelCount, float * const *) = ^StereoChannelList * (AVAudioFrameCount frame_capacity,
////                                                                                                                                                 AVAudioChannelCount channel_count,
////                                                                                                                                                 float * const * channel_samples)
////{
////    StereoChannelList * stereoChannelList = (StereoChannelList *)malloc(sizeof(StereoChannelList) + (2 * sizeof(StereoChannel)));
////    stereoChannelList->channel_count = channel_count;
////    for (StereoChannelOutput channel = 0; channel < channel_count; channel++)
////    {
////        StereoChannel * stereoChannel = (StereoChannel *)malloc(sizeof(StereoChannel));
////        stereoChannel->stereo_channel_output = (StereoChannelOutput)channel;
////        stereoChannel->samples = channel_samples[channel];
////
////        Frequencies * frequencies = (Frequencies *)malloc(sizeof(Frequencies) + sizeof(float));
////        int frequency_count = 2;
////        float * frequencies_arr = malloc(frequency_count * sizeof(float));
////        for (int i = 0; i < frequency_count; i++)
////        {
////            frequencies_arr[i] = 440 * (i * (5.0/4.0));
////        }
////        frequencies->frequencies = frequencies_arr;
////        stereoChannel->frequencies = *frequencies;
////
////        stereoChannelList->channels[channel] = stereoChannel;
////    }
////
////    return stereoChannelList;
////};
//
////+ (StereoChannelList *)audioBufferListWithNumberOfFrames:(UInt32)frames
////                                      numberOfChannels:(UInt32)channels
////                                           interleaved:(BOOL)interleaved
////{
////    unsigned nBuffers;
////    unsigned bufferSize;
////    unsigned channelsPerBuffer;
////    if (interleaved)
////    {
////        nBuffers = 1;
////        bufferSize = sizeof(float) * frames * channels;
////        channelsPerBuffer = channels;
////    }
////    else
////    {
////        nBuffers = channels;
////        bufferSize = sizeof(float) * frames;
////        channelsPerBuffer = 1;
////    }
////
////    AudioBufferList *audioBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * (channels-1));
////    audioBufferList->mNumberBuffers = nBuffers;
////    for(unsigned i = 0; i < nBuffers; i++)
////    {
////        audioBufferList->mBuffers[i].mNumberChannels = channelsPerBuffer;
////        audioBufferList->mBuffers[i].mDataByteSize = bufferSize;
////        audioBufferList->mBuffers[i].mData = calloc(bufferSize, 1);
////    }
////    return audioBufferList;
////}
//
//
//// Modify for Frequencies struct initializer
////static OSStatus recordingCallback(void *inRefCon,
////                                  AudioUnitRenderActionFlags *ioActionFlags,
////                                  const AudioTimeStamp *inTimeStamp,
////                                  UInt32 inBusNumber,
////                                  UInt32 inNumberFrames,
////                                  AudioBufferList *ioData) {
////
////    // the data gets rendered here
////    AudioBuffer buffer;
////
////    // a variable where we check the status
////    OSStatus status;
////
////    /**
////     This is the reference to the object who owns the callback.
////     */
////    AudioProcessor *audioProcessor = (AudioProcessor*) inRefCon;
////
////    /**
////     on this point we define the number of channels, which is mono
////     for the iphone. the number of frames is usally 512 or 1024.
////     */
////    buffer.mDataByteSize = inNumberFrames * 2; // sample size
////    buffer.mNumberChannels = 1; // one channel
////    buffer.mData = malloc( inNumberFrames * 2 ); // buffer size
////
////    // we put our buffer into a bufferlist array for rendering
////    AudioBufferList bufferList;
////    bufferList.mNumberBuffers = 1;
////    bufferList.mBuffers[0] = buffer;
////
////    // render input and check for error
////    status = AudioUnitRender([audioProcessor audioUnit], ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
////    [audioProcessor hasError:status:__FILE__:__LINE__];
////
////    // process the bufferlist in the audio processor
////    [audioProcessor processBuffer:&bufferList];
////
////    // clean up the buffer
////    free(bufferList.mBuffers[0].mData);
////
////    return noErr;
////}
//
//
////static void(^initStereoChannel)(void * inRefCon, float * samples, AVAudioFrameCount samples_count, StereoChannelList * stereoChannelData)
////{
////    NSObject * refCon = (__bridge NSObject *) inRefCon;
////
////    // iterate over incoming stream an copy to output stream
////    for (int i = 0; i < stereoChannelData->channel_count; i++) {
////        StereoChannel channel = stereoChannelData->channels[i];
////        channel.samples_count = samples_count;
////        channel.samples       = samples;
////    }
////    return noErr;
////}
//
//
////@property (nonatomic, readonly) ToneBarrierScore * (^tone_barrier_score_standard)(char *, PlayerNode * __nonnull *);
////@property (nonatomic, readonly) PlayerNode * (^player_nodes)(NSUInteger, PCMBuffer);
////@property (nonatomic, readonly) PCMBuffer * (^pcm_buffer)(AVAudioFormat * __nonnull, double, AVAudioFrameCount, ChannelList);
//
////typedef AVAudioPCMBuffer * (^SampleBuffer)(AVAudioFormat *, double, AVAudioSession *);
////static SampleBuffer buffer_samples = ^AVAudioPCMBuffer * (AVAudioFormat * audio_format, double duration, AVAudioSession * audio_session)
////{
////    double duration = 0.25;
////    AVAudioFrameCount frameCount = ([audio_format sampleRate] * duration);
////    AVAudioPCMBuffer *pcmBuffer  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audio_format frameCapacity:frameCount];
////    pcmBuffer.frameLength        = frameCount;
////
////    double tone_split = randomize(0.0, 1.0, 1.0);
////    double device_volume = pow(audio_session.outputVolume, 3.0);
////
////    //        calculateChannelData(pcmBuffer.frameLength,
////    //                             frequencies_struct_left,
////    //                             tone_split,
////    //                             device_volume,
////    //                             pcmBuffer.floatChannelData[0]);
////    //
////    //        calculateChannelData(pcmBuffer.frameLength,
////    //                             frequencies_struct_right,
////    //                             tone_split,
////    //                             device_volume,
////    //                             ([audioFormat channelCount] == 2) ? pcmBuffer.floatChannelData[1] : nil);
////
////    return pcmBuffer;
////};
//
////typedef void (^BufferRenderer)(AVAudioSession * _Nonnull, AVAudioFormat * _Nonnull, SampleBuffer buffer_samples, BufferRenderedCompletionBlock);
////BufferRenderer render_buffer = ^(AVAudioSession * audioSession, AVAudioFormat * audioFormat, BufferRenderedCompletionBlock bufferRenderedCompletionBlock
////{
////
////    static void (^audioBufferCreatedCompletionBlock)(void);
////    static void (^tonePlayedCompletionBlock)(void) = ^(void) {
////        bufferRenderedCompletionBlock();
////    };
////    bufferRenderedCompletionBlock = ^void(void)
////    {
////        createAudioBufferCompletionBlock(calculateBufferData(), ^{
////            tonePlayedCompletionBlock();
////        });
////    };
////    audioBufferCreatedCompletionBlock();
////};
//
////struct Buffer
////{
////    double duration;
////    AVAudioFrameCount frame_count;
////    ChannelList channel_list;
////    __unsafe_unretained SampleBuffer buffer_samples;
////    __unsafe_unretained BufferRenderer render_buffer;
////};
////typedef struct Buffer Buffer;
//
////struct PlayerNode
////{
////    AVAudioSession * audio_session;
////    AVAudioFormat * audio_format;
////    AVAudioPlayerNode * __nonnull player_node;
////    Buffer * __nonnull sample_buffer;
////};
////typedef struct PlayerNode PlayerNode;
//
////typedef void (^BufferScheduler)(PlayerNode *, BufferConsumedCompletionBlock);
////BufferScheduler schedule_buffer = ^(PlayerNode * player_node, ^(AVAudioPCMBuffer * _Nonnull, BufferConsumedCompletionBlock buffer_consumed)
////{
////
////)};
//       
//
////void * (^new)(const void *, const size_t *) = ^ void * (const void * node, const size_t *)
////{
////
////};
////static const size_t _PlayerNode = sizeof(struct PlayerNode);
////
////const void *  = & _Set;
////
////void * new (const void * type, ...)
////{
////    const size_t size = * (const size_t *) type;
////    void * p = calloc(1, size);
////    assert(p); return p;
////}
////
////struct ToneBarrierScore
////{
////    char * title;
////    int player_node_count;
////    PlayerNode * __nonnull * playerNodes;
////    __unsafe_unretained BufferScheduler schedule_buffer;
////    __unsafe_unretained BufferRenderedCompletionBlock buffer_rendered;
////};
////typedef struct ToneBarrierScore ToneBarrierScore;
//
////typedef void (^BufferConsumedCompletionBlock)(void);
////typedef void (^ConsumeBufferBlock)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull, BufferConsumedCompletionBlock);
////typedef void (^BufferRenderedCompletionBlock)(ConsumeBufferBlock);
////typedef void (^RenderBufferBlock)(AVAudioSession * _Nonnull, AVAudioFormat * _Nonnull, BufferRenderedCompletionBlock);
//
////@property (copy, nonatomic, readwrite) BufferConsumedCompletionBlock bufferConsumed;
////@property (copy, nonatomic, readwrite)  void (^ _Nonnull (^ _Nonnull buffer_consumed)(void))(AVAudioSession * _Nonnull, AVAudioFormat * _Nonnull /*, BufferRenderedCompletionBlock*/);
////@property (copy, nonatomic, readwrite) ConsumeBufferBlock consumeBuffer;
////@property (copy, nonatomic, readwrite) BufferRenderedCompletionBlock bufferRendered;
////@property (copy, nonatomic, readwrite) RenderBufferBlock renderBuffer;
//
//
//
//#import "ToneBarrierScorePlayer.h"
//
//#import <AVFoundation/AVFoundation.h>
//#import <MediaPlayer/MediaPlayer.h>
//#import <GameKit/GameKit.h>
//
//#import <objc/runtime.h>
// 
//typedef double (^Normalize)(double, double, double);
//Normalize normalize = ^double(double min, double max, double value)
//{
//    double result = (value - min) / (max - min);
//    
//    return result;
//};
//
//typedef double (^Scale)(double, double, double, double, double);
//Scale scale = ^double(double min_new, double max_new, double val_old, double min_old, double max_old)
//{
//    double val_new = min_new + ((((val_old - min_old) * (max_new - min_new))) / (max_old - min_old));
//    
//    return val_new;
//};
//
//typedef double (^RandomSource)(double, double);
//RandomSource random_source_drand48 = ^double(double lower_bound, double higher_bound)
//{
//    double random = drand48();
//    double result = (random * (higher_bound - lower_bound)) + lower_bound;
//    
//    return result;
//};
//
//typedef double (^RandomDistributor)(RandomSource random_source, double, double, double, double);
//RandomDistributor random_distributor_gaussian_mean_variance = ^double(RandomSource random_source, double lower_bound, double upper_bound, double mean, double variance)
//{
//    double result        = exp(-(pow((random_source(lower_bound, upper_bound) - mean), 2.0) / variance));
//    double scaled_result = scale(0.0, 1.0, result, lower_bound, upper_bound);
//    
//    return scaled_result;
//};
//
//RandomDistributor random_distributor_gaussian_mean_standard_deviation = ^double(RandomSource random_source, double lower_bound, double upper_bound, double mean, double standard_deviation)
//{
//    double result        = sqrt(1 / (2 * M_PI * standard_deviation)) * exp(-(1 / (2 * standard_deviation)) * (random_source(lower_bound, upper_bound) - mean) * 2);
//    double scaled_result = scale(0.0, 1.0, result, lower_bound, upper_bound);
//    
//    return scaled_result;
//};
//
//typedef double (^TimeSampler)(double, double);
//TimeSampler sample_time = ^(double index, double sample_count)
//{
//    double result = index / sample_count;
//    
//    return result;
//};
//
//// make recursive (exits when time >= 1)
//typedef double (^FrequencySampler)((double(^)(double, double)), double, double);
//FrequencySampler sample_frequency = ^(^double(double index, double sample_count), double time, double frequency)
//{
//    double result = sinf(M_PI * 2.0 * time * frequency);
//    
//    return result;
//};
//
//typedef double (^AmplitudeSampler)(double, double);
//AmplitudeSampler sample_amplitude = ^(double time, double gain)
//{
//    double result = pow(sin(time * M_PI), gain);
//    
//    return result;
//};
//
//struct Amplitude
//{
//    double audio_output_volume;
//    __unsafe_unretained AmplitudeSampler amplitude_sampler;
//};
//typedef struct Amplitude Amplitude;
//
//struct Randomizer
//{
//    double lower_bounds;
//    double upper_bounds;
//    double mean;
//    double deviation;
//    __unsafe_unretained RandomSource random_source;
//    __unsafe_unretained RandomDistributor random_distributor;
//};
//typedef struct Randomizer Randomizer;
//
//struct Frequencies
//{
//    int frequencies_count;
//    double * __nonnull frequencies;
//    Randomizer randomizer;
//    __unsafe_unretained FrequencySampler frequency_sampler;
//};
//typedef struct Frequencies Frequencies;
//
//struct Tone
//{
//    Frequencies * frequencies;
//    Amplitude * amplitude;
//};
//typedef struct Tone Tone;
//
//enum ChannelAudioOutput
//{
//    ChannelAudioOutputStereoLeft,
//    ChannelAudioOutputStereoRight,
//    ChannelAudioOutputMono
//};
//
//struct Channel
//{
//    enum ChannelAudioOutput channel_audio_output;
//    AVAudioFramePosition starting_frame;
//    AVAudioFrameCount frame_count;
//    float * __nonnull samples;
//    Tone * tone;
//};
//typedef struct Channel Channel;
//
//struct ChannelList
//{
//    AVAudioChannelCount channel_count;
//    Channel * channels;
//};
//typedef struct ChannelList ChannelList;
