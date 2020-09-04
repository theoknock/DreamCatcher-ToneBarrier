////
////  ToneBarrierScore.h
////  DreamCatcher-ToneBarrier
////
////  Created by Xcode Developer on 9/2/20.
////
//// The Tone Barier Score architectre is comprised of three major parts:
////  . The structs that define the elements of the tone barrier score data structure
//// 2. The fumnctions that create the structs in memory and return a pointer to them
//// 3. THe fumnctions that act on the valiues of the eleemts im thej data strructrure
////
//// A struct deefntuons and its initializers go in one file, as fo thrir setters amnd getters and galidfates fuimnctionwe
//
//#import <Foundation/Foundation.h>
//#import <AVFoundation/AVFoundation.h>
//#import <GameKit/GameKit.h>
//
//NS_ASSUME_NONNULL_BEGIN
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
//struct Random
//{
//    RandomSource random_source;
//    RandomDistributor random_distributor;
//};
//typedef struct Random Random;
//
//struct Buffer
//{
//    double duration;
//    AVAudioFrameCount frame_count;
//    ChannelList channel_list;
//    __unsafe_unretained SampleBuffer buffer_samples;
//    __unsafe_unretained BufferRenderer render_buffer;
//};
//typedef struct Buffer Buffer;
//
//struct PlayerNode
//{
//    AVAudioSession * audio_session;
//    AVAudioFormat * audio_format;
//    AVAudioPlayerNode * __nonnull player_node;
//    Buffer * __nonnull sample_buffer;
//};
//typedef struct PlayerNode PlayerNode;
//
//
//struct ToneBarrierScore
//{
//    char * title;
//    int player_node_count;
//    PlayerNode * __nonnull * playerNodes;
//    __unsafe_unretained BufferScheduler schedule_buffer;
//    __unsafe_unretained BufferRenderedCompletionBlock buffer_rendered;
//};
//typedef struct ToneBarrierScore ToneBarrierScore;
//
//
//@interface ToneBarrierScore : NSObject
//
//@end
//
//NS_ASSUME_NONNULL_END
//
