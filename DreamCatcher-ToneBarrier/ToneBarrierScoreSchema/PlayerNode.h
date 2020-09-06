//
//  PlayerNode.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/5/20.
//

#ifndef PlayerNode_h
#define PlayerNode_h


#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

//extern const void * _Nonnull PlayerNode;
//
//// Passes the requisite block parameter to RenderBuffer, which returns a reference to the AVAudioPlayerNode that consumed the buffer
//// Called during the AVAudioPlayerNodeCompletionDataPlayedBack completion handler
//typedef void (^BufferConsumed)(
//                               void (^RenderBuffer)(AVAudioPlayerNode * _Nonnull));
//
//typedef void (^ConsumeBuffer)(AVAudioPlayerNode * _Nonnull,
//                              void (^)(AVAudioPlayerNode * _Nonnull)));
//
//typedef void (^BufferRendered)(void (^)(AVAudioPCMBuffer * _Nonnull,
//                                   void (^)(AVAudioPlayerNode * _Nonnull,
//                                            void (^)(AVAudioPlayerNode * _Nonnull)));
//                          
//typedef void (^BufferRenderer)(AVAudioFormat * _Nonnull, AVAudioSession * _Nonnull,
//                          void (^)(AVAudioPCMBuffer * _Nonnull,
//                                   void (^)(AVAudioPlayerNode * _Nonnull)));
//                          
//typedef void (^RenderBuffer)(AVAudioPlayerNode * _Nonnull),
//                               void (^BufferRenderer)(AVAudioFormat * _Nonnull, AVAudioSession * _Nonnull,
//                                                    void (^BufferRendered)(AVAudioPCMBuffer * _Nonnull,
//                                                             void (^ConsumeBuffer)(AVAudioPlayerNode * _Nonnull, AVAudioPCMBuffer * _Nonnull,
//                                                                      void (^BufferConsumed)(AVAudioPlayerNode * _Nonnull)))));
//
//typedef struct PlayerNode
//{
//    AVAudioSession * audio_session;
//    AVAudioFormat * audio_format;
//    AVAudioPlayerNode * __nonnull player_node;
//    
//    struct Buffer
//    {
//        double duration;
//        AVAudioFrameCount frame_count;
//        ChannelList channel_list;
//        __unsafe_unretained SampleBuffer buffer_samples;
//        __unsafe_unretained BufferRenderer render_buffer;
//    } Buffer * __nonnull sample_buffer;
//    
//} player_node;
//
//struct Random * new_random (enum RandomGenerator random_generator,
//                            enum RandomDistribution random_distribution,
//                            double range_min,
//                            double range_max,
//                            double gamma);
//
//double (GenerateDistributedRandom)(struct Random *);
//
//
//typedef struct PlayerNode PlayerNode;

#endif /* PlayerNode_h */

//struct Buffer
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
