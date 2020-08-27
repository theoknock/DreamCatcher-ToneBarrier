//
//  ToneBarrierScorePlayer.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import "ToneBarrierScore.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GameKit/GameKit.h>

#import <objc/runtime.h>


typedef enum : NSUInteger {
    ChannelOutputStereoLeft,
    ChannelOutputStereoRight,
    ChannelOutputMono
} ChannelOutput;

typedef enum : NSUInteger {
    RandomSourceScalarTypeInt,
    RandomSourceScalarTypeFloat
} RandomSourceScalarType;

typedef enum : NSUInteger {
    RandomDistributionRangeLowerUpperBounds,
    RandomDistributionRangeMeanDeviation
} RandomDistributionRangeScalarType;

struct tone_barrier_score {
    char * title;
    struct audio_buffer {
        AVAudioFormat * __nonnull audio_format;
        double duration;
        AVAudioFrameCount frame_count;
        struct channel_list {
            AVAudioChannelCount channel_count;
            struct channel {
                ChannelOutput channel_output;
                AVAudioFramePosition starting_frame;
                AVAudioFrameCount frame_count;
                float * __nonnull samples;
                struct frequencies {
                    int frequencies_count;
                    double * __nonnull frequencies;
                    struct random_generator {
                        struct source {
                            GKMersenneTwisterRandomSource * random_source;
                            RandomSourceScalarType source_scalar_type;
                        } source;
                        struct distributor {
                            GKGaussianDistribution * gaussian_distributor;
                            RandomDistributionRangeScalarType range_scalar_type;
                            union distribution_range {
                                struct distribution_range_lower_upper_bounds {
                                    int lower_bounds, upper_bounds;
                                } distribution_range_lower_upper_bounds;
                                struct distribution_range_mean_deviation {
                                    float mean, deviation;
                                } distribution_range_mean_deviation;
                            } distribution_range;
                        } distributor;
                    } random_generator;
                } frequencies;
            } channel;
        } * __nonnull * channel_list;
    } audio_buffer;
} tone_barrier_score;

@interface ToneBarrierScore ()

@property (nonatomic, readonly) struct tone_barrier_score * (^tone_barrier_score_ptr)(struct tone_barrier_score *);


@property (nonatomic, readonly) struct tone_barrier_score * (^init_tone_barrier_score_ptr)(char *, struct audio_buffer *);
@property (nonatomic, readonly) struct audio_buffer * (^init_audio_buffer_ptr)(AVAudioFormat * __nonnull, double, AVAudioFrameCount, struct channel_list *);
@property (nonatomic, readonly) struct channel_list * (^init_channel_list_ptr)(AVAudioChannelCount, struct channel *);
@property (nonatomic, readonly) struct channel * (^init_channel_ptr)(ChannelOutput, AVAudioFramePosition, AVAudioFrameCount, float * __nonnull, struct frequencies *);
@property (nonatomic, readonly) struct frequencies * (^init_frequencies_ptr)(int, double * __nonnull, struct random_generator *);
@property (nonatomic, readonly) struct random_generator * (^init_random_generator_ptr)(struct source *, struct distributor *);
@property (nonatomic, readonly) struct source * (^init_source_ptr)(GKMersenneTwisterRandomSource *, RandomSourceScalarType);
@property (nonatomic, readonly) struct distributor * (^init_distributor_ptr)(GKGaussianDistribution *, RandomDistributionRangeScalarType, union distribution_range *);
@property (nonatomic, readonly) union distribution_range * (^init_distribution_range_ptr)(struct distribution_range_lower_upper_bounds *, struct distribution_range_mean_deviation *);
@property (nonatomic, readonly) struct distribution_range_lower_upper_bounds * (^init_distribution_range_lower_upper_bounds_ptr)(int lower_bounds, int upper_bounds);
@property (nonatomic, readonly) struct distribution_range_mean_deviation * (^init_distribution_range_mean_deviation_ptr)(float mean, float deviation);

@property (nonatomic, readonly) struct tone_barrier_score * (^score_tone_barrier)(struct tone_barrier_score * (^)(char *,
                                struct audio_buffer * (^)(AVAudioFormat * __nonnull, double, AVAudioFrameCount,
                                struct channel_list * (^)(AVAudioChannelCount,
                                struct channel * (^)(ChannelOutput, AVAudioFramePosition, AVAudioFrameCount, float * __nonnull,
                                struct frequencies * (^)(int, double * __nonnull,
                                struct random_generator * (^)(struct source * (^)(GKMersenneTwisterRandomSource *, RandomSourceScalarType),
                                struct distributor * (^)(GKGaussianDistribution *, RandomDistributionRangeScalarType,
                                union distribution_range * (^)(struct distribution_range_lower_upper_bounds * (^)(int lower_bounds, int upper_bounds), struct distribution_range_mean_deviation * (^)(float mean, float deviation))))))))));


@end

//static struct audio_buffer * __nonnull (^init_buffer)(AVAudioFormat * ) = ^struct audio_buffer * __nonnull (AVAudioFormat * __nullable audio_format)
//{
//    struct channel_list * channels = malloc(sizeof(struct channel_list));
//    channels->audio_format                = audio_format;
//    channels->frame_capacity              = frame_capacity;
//    channels->channel_count               = channel_count;
//    channels->duration                    = duration;
//    channels->flag                        = flag;
//
//    for (int i = 0; i < 2; i++)
//    {
//        channels->channels[i] = channels[i];
//    }
//
//    return stereo_channel_list;
//};

@implementation ToneBarrierScore
                                                                                                                                                                                                                                                                     
static ToneBarrierScore * player = NULL;
+ (ToneBarrierScore * _Nonnull )player
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
        if (!player)
        {
            player = [[self alloc] init];
        }
    });
    
    return player;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
    }
    
    return self;
}

// EXAMPLE
typedef struct keyval{
    char *key;
    void *value;
} keyval;

keyval *keyval_new(char *key, void *value);
keyval *keyval_copy(keyval const *in);
void keyval_free(keyval *in);
int keyval_matches(keyval const *in, char const *key);

extern void *dictionary_not_found;

typedef struct dictionary{
   keyval **pairs;
   int length;
} dictionary;

dictionary *dictionary_new (void);
dictionary *dictionary_copy(dictionary *in);
void dictionary_free(dictionary *in);
void dictionary_add(dictionary *in, char *key, void *value);
void *dictionary_find(dictionary const *in, char const *key);

//

// TO-DO: Compare tone_barrier_score struct members that are pointers
//        to the same in the dict and keyval structs,
//        as well as the pointers as passed to and received by (and returned by) functions

- (struct tone_barrier_score *(^)(struct tone_barrier_score *(^)(char *, struct audio_buffer *(^)(AVAudioFormat * _Nonnull, double, AVAudioFrameCount, struct channel_list *(^)(AVAudioChannelCount, struct channel *(^)(ChannelOutput, AVAudioFramePosition, AVAudioFrameCount, float * _Nonnull, struct frequencies *(^)(int, double * _Nonnull, struct random_generator *(^)(struct source *(^)(GKMersenneTwisterRandomSource *, RandomSourceScalarType), struct distributor *(^)(GKGaussianDistribution *, RandomDistributionRangeScalarType, union distribution_range *(^)(struct distribution_range_lower_upper_bounds *(^)(int, int), struct distribution_range_mean_deviation *(^)(float, float)))))))))))score_tone_barrier
{
    return ^struct tone_barrier_score *(struct tone_barrier_score *(^tone_barrier_score)(char * title,
                                                                                         struct audio_buffer *(^audio_buffer)(AVAudioFormat * _Nonnull audio_format,
                                                                                                                              double duration,
                                                                                                                              AVAudioFrameCount frame_count,
                                                                                                                              struct channel_list *(^channel_list)(AVAudioChannelCount channel_count,
                                                                                                                                                                   struct channel *(^channel)(ChannelOutput channeL_output,
                                                                                                                                                                                              AVAudioFramePosition frame_position,
                                                                                                                                                                                              AVAudioFrameCount frame_count,
                                                                                                                                                                                              float * _Nonnull samples,
                                                                                                                                                                                              struct frequencies *(^frequencies)(int frequency_count,
                                                                                                                                                                                                                                 double * _Nonnull frequencies,
                                                                                                                                                                                                                                 struct random_generator *(^random_generator)(struct source *(^)(GKMersenneTwisterRandomSource *random_source,
                                                                                                                                                                                                                                                                                                 RandomSourceScalarType random_source_scalar_type),
                                                                                                                                                                                                                                                                              struct distributor *(^)(GKGaussianDistribution *random_distribution,
                                                                                                                                                                                                                                                                                                      RandomDistributionRangeScalarType random_distribution_range_scalar_type,
                                                                                                                                                                                                                                                                                                      union distribution_range *(^)(struct distribution_range_lower_upper_bounds *(^)(int, int),
                                                                                                                                                                                                                                                                                                                                    struct distribution_range_mean_deviation *(^)(float, float))))))))))
    {
        struct tone_barrier_score * score = malloc(sizeof(struct tone_barrier_score));
        * score = * tone_barrier_score(nil, nil);
        return score;
    };
}

- (struct tone_barrier_score *(^)(char **, struct audio_buffer *))init_tone_barrier_score_ptr
{
    return ^ struct tone_barrier_score *(char ** title, struct audio_buffer * buffer)
    {
        struct tone_barrier_score * score = malloc(sizeof(struct tone_barrier_score));
//        strcpy(score->title, *title);
        score->title = * title;
        score->audio_buffer = * buffer;
        
        return score;
    };
};


- (struct mersenne_twister_random_source * (^)(MersenneTwisterRandomSourceValueScalarType))init_mersenne_twister_random_source
{
    return ^struct mersenne_twister_random_source * (MersenneTwisterRandomSourceValueScalarType random_number_scalar_type)
    {
        struct mersenne_twister_random_source * random_source = malloc(sizeof(struct mersenne_twister_random_source));
        
        return random_source;
    };
}

- (union distributor_parameters * (^)(void *))init_distributor_parameters
{
    return ^union distributor_parameters * (void * ranges)
    {
        union distributor_parameters * distribution_range;
        switch (
            };
}

- (struct gaussian_distributor * (^)(GaussianDistributorRangeValuesScalarType, void *))init_gaussian_distributor
{
    return ^struct gaussian_distributor * (GaussianDistributorRangeValuesScalarType distributor_range_values_scalar_type, void * distribution_range_values)
    {
        struct gaussian_distributor * random_distributor = malloc(sizeof(struct gaussian_distributor));
        union  distribution_range * ran
        switch (distributor_range_values_scalar_type) {
            case GaussianDistributorRangeValuesScalarTypeLowerUpperBounds:
            {
                gaussian_distributor->distribution = (int *)distribution_range_values;
                gaussian_distributor->distribution = [[GKGaussianDistribution alloc] initWithRandomSource:<#(nonnull id<GKRandom>)#> lowestValue:<#(NSInteger)#> highestValue:<#(NSInteger)#>]
                break;
            }
            case GaussianDistributorRangeValuesScalarTypeMeanDeviation:
            {
                random_distributor->mean_deviation = (float *)distribution_range_values;
                break;
            }
            default:
                break;
        }
        
        return random_distributor;
    };
}

- (struct channel_frequencies * (^)(void))init_channel_frequencies
{
    return ^struct channel_frequencies * (void)
    {
        struct channel_frequencies * ch_frequencies = malloc(sizeof(struct channel_frequencies));
        
        return ch_frequencies;
    };
}

- (struct channel * (^)(void))init_channel
{
    return ^struct channel * (void)
    {
        struct channel * ch = malloc(sizeof(struct channel));
        
        return ch;
    };
}

- (struct channel_list * (^)(void))init_channel_list
{
    return ^struct channel_list * (void)
    {
        struct channel_list * channels = malloc(sizeof(struct channel_list));
        
        return channels;
    };
}


- (struct audio_buffer * (^)(void))init_audio_buffer
{
    return ^struct audio_buffer * (void)
    {
        struct audio_buffer * buffer = malloc(sizeof(struct audio_buffer));
        
        return buffer;
    };
}

//ToneGenerator *tg = [ToneGenerator sharedGenerator];
//double root_frequency = 440.0 * duration;
//double frequencies_params[] = {root_frequency, root_frequency * (5.0/4.0)};
//struct channel_frequencies * channel_frequencies_left     = tg.frequencies(2, frequencies_params, nil);
//struct channel_frequencies * channel_frequencies_right    = tg.frequencies(2, frequencies_params, nil);
//struct channel_frequencies * channel_frequencies_array[2] = {channel_frequencies_left, channel_frequencies_right};
//
//struct stereo_channel_struct *stereo_channel = tg.stereo_channel(StereoChannelOutputLeft,
//                                                                 channel_frequencies_array[StereoChannelOutputLeft],
//                                                                 (AVAudioFramePosition)(0),
//                                                                 pcmBuffer.frameLength,
//                                                                 pcmBuffer.floatChannelData[StereoChannelOutputLeft],
//                                                                 nil);

//- (struct channel_frequencies * (^)(int, double *, __unsafe_unretained id))frequencies
//{
//   return ^struct channel_frequencies * (int frequencies_array_length,
//                                       double * frequencies_array,
//                                       __unsafe_unretained id flag)
//    {
//        struct channel_frequencies * frequencies = malloc(sizeof(struct channel_frequencies));
//        frequencies->frequencies_array_length = frequencies_array_length;
//        frequencies->frequencies_array = malloc(sizeof(double) * frequencies_array_length);
//        for (int i = 0; i < frequencies_array_length; i++)
//        {
//            frequencies->frequencies_array[i] = frequencies_array[i];
//        }
//        frequencies->flag = flag;
//
//        return frequencies;
//    };
//}
//
//- (struct stereo_channel_struct * (^)(struct channel_frequencies *, __unsafe_unretained id))stereo_channels
//{
//    return ^struct stereo_channel_struct * (struct channel_frequencies * stereo_channels_frequencies, __unsafe_unretained id flag)
//    {
//        struct stereo_channel_struct * stereo_channels = malloc(sizeof(struct stereo_channel_struct) + (sizeof(frequencies) * 2));
//        stereo_channels->stereo_channels_frequencies = malloc(sizeof(struct channel_frequencies) * 2);
//        for (int i = 0; i < 2; i++)
//        {
//            stereo_channels->stereo_channels_frequencies[i] = stereo_channels_frequencies[i];
//        }
//
//        stereo_channels->flag = flag;
//
//        return stereo_channels;
//    };
//}
//
//- (struct stereo_channel_list * (^)(AVAudioFormat *, AVAudioFrameCount, AVAudioChannelCount, double, struct stereo_channel_struct * [2], __unsafe_unretained id))channel_list
//{
//    return ^struct stereo_channel_list * (AVAudioFormat * audio_format,
//                                          AVAudioFrameCount frame_capacity,
//                                          AVAudioChannelCount channel_count,
//                                          double duration,
//                                          struct stereo_channel_struct * stereo_channels[2],
//                                          __unsafe_unretained id flag)
//    {
//        struct stereo_channel_list * stereo_channel_list = malloc(sizeof(struct stereo_channel_list));
//        stereo_channel_list->audio_format                = audio_format;
//        stereo_channel_list->frame_capacity              = frame_capacity;
//        stereo_channel_list->channel_count               = channel_count;
//        stereo_channel_list->duration                    = duration;
//        stereo_channel_list->flag                        = flag;
//
//        for (int i = 0; i < 2; i++)
//        {
//            stereo_channel_list->stereo_channels[i] = stereo_channels[i];
//        }
//
//        return stereo_channel_list;
//    };
//}



// TO-DO: A stereo_channel_list init block, which takes a stereo_channel_struct init block, which takes a channel_frequencies init block
//struct stereo_channel_struct * (^init_stereo_channel_struct)(void) = ^void(void)

//struct stereo_channel_list * (^init_stereo_channel_list)(struct stereo_channel_struct * (^)(struct channel_frequencies * (^)(void))) = ^struct stereo_channel_list * (struct stereo_channel_struct * (^init_stereo_channel_struct)(struct channel_frequencies * (^init_channel_frequencies)(void)))
//{
//    struct stereo_channel_list * stereo_channel_list = malloc(sizeof(struct stereo_channel_list));
//
//    init_stereo_channel_struct(^struct channel_frequencies * {
//        return nil;
//    });
//
//    return (struct stereo_channel_list * )stereo_channel_list;
//};

- (void)test1:(int)a1 test2:(int)a2
{
    int(^(^myNestedBlock)(void))(void);
    //
    typedef int(^IntBlock)(void);
    IntBlock(^nestedBlock)(void);
    
    ^(int d1, int(^c2)(void))
    {
        return c2;
    } (^(int c1)
       {
        return c1;
    } (^(int b1)
       {
        return b1;
    } (a1)),
       ^(int b2)
       {
        return ^{
            return b2;
        };
    } (a2));
    
    // TO-DO: Nested block literals that return blocks that return blocks and so on...
}


//struct stereo_channel_struct
//{
//    StereoChannelOutput stereo_channel_output;
//    struct channel_frequencies * stereo_channels_frequencies;
//    AVAudioFramePosition index_start;
//    AVAudioFrameCount samples_count;
//    float * __nullable samples;
//    __unsafe_unretained id flag;
//};
//


//- (struct stereo_channel_list * (^)(struct stereo_channel_struct *, __unsafe_unretained id))stereo_channels
//{
//    return ^struct stereo_channel_list * (struct stereo_channel_struct * stereo_channels_frequencies, __unsafe_unretained id flag)
//    {
//        struct stereo_channel_list * stereo_channels = malloc(sizeof(struct stereo_channel_list) + (sizeof(frequencies) * 2));
//        stereo_channels->stereo_channels_frequencies = malloc(sizeof(struct channel_frequencies) * 2);
//        for (int i = 0; i < 2; i++)
//        {
//            stereo_channels->stereo_channels_frequencies[i] = stereo_channels_frequencies[i];
//        }
//
//        stereo_channels->flag = flag;
//
//        return stereo_channels;
//    };
//}

static ToneBarrierGenerator *sharedGenerator = NULL;
+ (nonnull ToneBarrierGenerator *)sharedGenerator
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
        if (!sharedGenerator)
        {
            sharedGenerator = [[self alloc] init];
        }
    });
    
    return sharedGenerator;
}

double Normalize(double a, double b)
{
    return (double)(a / b);
}

#define max_frequency      1500.0
#define min_frequency       100.0
#define max_trill_interval    4.0
#define min_trill_interval    2.0
#define duration_interval     5.0
#define duration_maximum      2.0


// Elements of an effective tone:
// High-pitched
// Modulating amplitude
// Alternating channel output
// Loud
// Non-natural (no spatialization)
//
// Elements of an effective score:
// Random frequencies
// Random duration
// Random tonality

// To-Do: Multiply the frequency by a random number between 1.01 and 1.1)

typedef NS_ENUM(NSUInteger, TonalHarmony) {
    TonalHarmonyConsonance,
    TonalHarmonyDissonance,
    TonalHarmonyRandom
};

typedef NS_ENUM(NSUInteger, TonalInterval) {
    TonalIntervalUnison,
    TonalIntervalOctave,
    TonalIntervalMajorSixth,
    TonalIntervalPerfectFifth,
    TonalIntervalPerfectFourth,
    TonalIntervalMajorThird,
    TonalIntervalMinorThird,
    TonalIntervalRandom
};

typedef NS_ENUM(NSUInteger, TonalEnvelope) {
    TonalEnvelopeAverageSustain,
    TonalEnvelopeLongSustain,
    TonalEnvelopeShortSustain
};

double Tonality(double frequency, TonalInterval interval, TonalHarmony harmony)
{
    double new_frequency = frequency;
    switch (harmony) {
        case TonalHarmonyDissonance:
            new_frequency *= (1.1 + drand48());
            break;
            
        case TonalHarmonyConsonance:
            new_frequency = ToneBarrierGenerator.Interval(frequency, interval);
            break;
            
        case TonalHarmonyRandom:
            new_frequency = Tonality(frequency, interval, (TonalHarmony)arc4random_uniform(2));
            break;
            
        default:
            break;
    }
    
    return new_frequency;
}

double Envelope(double x, TonalEnvelope envelope)
{
    double x_envelope = 1.0;
    switch (envelope) {
        case TonalEnvelopeAverageSustain:
            x_envelope = sinf(x * M_PI) * (sinf((2 * x * M_PI) / 2));
            break;
            
        case TonalEnvelopeLongSustain:
            x_envelope = sinf(x * M_PI) * -sinf(
                                                ((Envelope(x, TonalEnvelopeAverageSustain) - (2.0 * Envelope(x, TonalEnvelopeAverageSustain)))) / 2.0)
            * (M_PI / 2.0) * 2.0;
            break;
            
        case TonalEnvelopeShortSustain:
            x_envelope = sinf(x * M_PI) * -sinf(
                                                ((Envelope(x, TonalEnvelopeAverageSustain) - (-2.0 * Envelope(x, TonalEnvelopeAverageSustain)))) / 2.0)
            * (M_PI / 2.0) * 2.0;
            break;
            
        default:
            break;
    }
    
    return x_envelope;
}

typedef NS_ENUM(NSUInteger, Trill) {
    TonalTrillUnsigned,
    TonalTrillInverse
};

+ (double(^)(double, double))Frequency
{
    return ^double(double time, double frequency)
    {
        return pow(sinf(M_PI * time * frequency), 2.0);
    };
}

+ (double(^)(double))TrillInterval
{
    return ^double(double frequency)
    {
        return ((frequency / (max_frequency - min_frequency) * (max_trill_interval - min_trill_interval)) + min_trill_interval);
    };
}

+ (double(^)(double, double))Trill
{
    return ^double(double time, double trill)
    {
        return pow(2.0 * pow(sinf(M_PI * time * trill), 2.0) * 0.5, 4.0);
    };
}

+ (double(^)(double, double))TrillInverse
{
    return ^double(double time, double trill)
    {
        return pow(-(2.0 * pow(sinf(M_PI * time * trill), 2.0) * 0.5) + 1.0, 4.0);
    };
}

+ (double(^)(double))Amplitude
{
    return ^double(double time)
    {
        return pow(sinf(time * M_PI), 3.0) * 0.5;
    };
}

+ (double(^)(double, TonalInterval))Interval
{
    return ^double(double frequency, TonalInterval interval)
    {
        double new_frequency = frequency;
        switch (interval)
        {
            case TonalIntervalUnison:
                new_frequency *= 1.0;
                break;
                
            case TonalIntervalOctave:
                new_frequency *= 2.0;
                break;
                
            case TonalIntervalMajorSixth:
                new_frequency *= 5.0/3.0;
                break;
                
            case TonalIntervalPerfectFifth:
                new_frequency *= 4.0/3.0;
                break;
                
            case TonalIntervalMajorThird:
                new_frequency *= 5.0/4.0;
                break;
                
            case TonalIntervalMinorThird:
                new_frequency *= 6.0/5.0;
                break;
                
            case TonalIntervalRandom:
                new_frequency = ToneBarrierGenerator.Interval(frequency, (TonalInterval)arc4random_uniform(7));
                
            default:
                break;
        }
        
        return new_frequency;
    };
};

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
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
        NSLog(@"AudioEngine started");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error)
        {
            NSLog(@"%@", [error description]);
            return FALSE;
        } else {
            NSLog(@"AudioSession configured");
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            if (error)
            {
                NSLog(@"%@", [error description]);
                return FALSE;
            } else {
                NSLog(@"AudioSession active");
                return TRUE;
            }
        }
    } else {
        NSLog(@"AudioEngine did not start: %@", [error description]);
        return FALSE;
    }
}

double (^standardize)(double, double, double, double, double) = ^double(double value, double min, double max, double new_min, double new_max)
{
    double standardized_value = (new_max - new_min) * (value - min) / (max - min) + new_min;
    
    return standardized_value;
};

double (^normalize)(double, double, double, double, double) = ^double(double min_new, double max_new, double val_old, double min_old, double max_old)
{
    double val_new = min_new + ((((val_old - min_old) * (max_new - min_new))) / (max_old - min_old));
    
    return val_new;
};

double(^randomize)(double, double, double) = ^double(double min, double max, double weight)
{
    double random = drand48();
    double weighted_random = pow(random, weight);
    double frequency = (weighted_random * (max - min)) + min;
    
    return frequency;
};


double sincf(double x)
{
    double sincf_x = sin(x * M_PI) / (x * M_PI);
    
    return sincf_x;
}

double (^frequency_sin)(double, double) =  ^(double time, double frequency)
{
    double freq_sin = sinf(M_PI * 2.0 * time * frequency);
    
    return freq_sin;
};

double (^envelope_lfo)(double, double) = ^(double time, double slope)
{
    double env_lfo = pow(sin(time * M_PI), slope);
    
    return env_lfo;
};

typedef struct frequencies_array_struct
{
    int length;
    double * frequencies_array;             // Frequencies.frequencies = malloc(Frequencies.frequency_count * sizeof(double));
} Frequencies;

static Frequencies * (^frequencies)(int length, double * frequencies_array);



void (^initFrequenciesArray)(Frequencies * , int, double, double) = ^ void (Frequencies * channel_frequencies, int frequency_count, double root_frequency, double duration)
{
    channel_frequencies = (Frequencies *)malloc(sizeof(Frequencies));
    channel_frequencies->length = frequency_count;
    channel_frequencies->frequencies_array = (double *)calloc(frequency_count, sizeof(double));
    
    double harmonic_increment = root_frequency - (root_frequency * (5.0/4.0));
    for (int i = 0; i < frequency_count; i++)
    {
        channel_frequencies->frequencies_array[i] = (root_frequency + (i * harmonic_increment)) * duration;
    }
};



//StereoChannelList * (^createStereoChannelList)(AVAudioFrameCount, AVAudioChannelCount, float * const *) = ^StereoChannelList * (AVAudioFrameCount frame_capacity,
//                                                                                                                                                 AVAudioChannelCount channel_count,
//                                                                                                                                                 float * const * channel_samples)
//{
//    StereoChannelList * stereoChannelList = (StereoChannelList *)malloc(sizeof(StereoChannelList) + (2 * sizeof(StereoChannel)));
//    stereoChannelList->channel_count = channel_count;
//    for (StereoChannelOutput channel = 0; channel < channel_count; channel++)
//    {
//        StereoChannel * stereoChannel = (StereoChannel *)malloc(sizeof(StereoChannel));
//        stereoChannel->stereo_channel_output = (StereoChannelOutput)channel;
//        stereoChannel->samples = channel_samples[channel];
//
//        Frequencies * frequencies = (Frequencies *)malloc(sizeof(Frequencies) + sizeof(float));
//        int frequency_count = 2;
//        float * frequencies_arr = malloc(frequency_count * sizeof(float));
//        for (int i = 0; i < frequency_count; i++)
//        {
//            frequencies_arr[i] = 440 * (i * (5.0/4.0));
//        }
//        frequencies->frequencies = frequencies_arr;
//        stereoChannel->frequencies = *frequencies;
//
//        stereoChannelList->channels[channel] = stereoChannel;
//    }
//
//    return stereoChannelList;
//};

//+ (StereoChannelList *)audioBufferListWithNumberOfFrames:(UInt32)frames
//                                      numberOfChannels:(UInt32)channels
//                                           interleaved:(BOOL)interleaved
//{
//    unsigned nBuffers;
//    unsigned bufferSize;
//    unsigned channelsPerBuffer;
//    if (interleaved)
//    {
//        nBuffers = 1;
//        bufferSize = sizeof(float) * frames * channels;
//        channelsPerBuffer = channels;
//    }
//    else
//    {
//        nBuffers = channels;
//        bufferSize = sizeof(float) * frames;
//        channelsPerBuffer = 1;
//    }
//
//    AudioBufferList *audioBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer) * (channels-1));
//    audioBufferList->mNumberBuffers = nBuffers;
//    for(unsigned i = 0; i < nBuffers; i++)
//    {
//        audioBufferList->mBuffers[i].mNumberChannels = channelsPerBuffer;
//        audioBufferList->mBuffers[i].mDataByteSize = bufferSize;
//        audioBufferList->mBuffers[i].mData = calloc(bufferSize, 1);
//    }
//    return audioBufferList;
//}


// Modify for Frequencies struct initializer
//static OSStatus recordingCallback(void *inRefCon,
//                                  AudioUnitRenderActionFlags *ioActionFlags,
//                                  const AudioTimeStamp *inTimeStamp,
//                                  UInt32 inBusNumber,
//                                  UInt32 inNumberFrames,
//                                  AudioBufferList *ioData) {
//
//    // the data gets rendered here
//    AudioBuffer buffer;
//
//    // a variable where we check the status
//    OSStatus status;
//
//    /**
//     This is the reference to the object who owns the callback.
//     */
//    AudioProcessor *audioProcessor = (AudioProcessor*) inRefCon;
//
//    /**
//     on this point we define the number of channels, which is mono
//     for the iphone. the number of frames is usally 512 or 1024.
//     */
//    buffer.mDataByteSize = inNumberFrames * 2; // sample size
//    buffer.mNumberChannels = 1; // one channel
//    buffer.mData = malloc( inNumberFrames * 2 ); // buffer size
//
//    // we put our buffer into a bufferlist array for rendering
//    AudioBufferList bufferList;
//    bufferList.mNumberBuffers = 1;
//    bufferList.mBuffers[0] = buffer;
//
//    // render input and check for error
//    status = AudioUnitRender([audioProcessor audioUnit], ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
//    [audioProcessor hasError:status:__FILE__:__LINE__];
//
//    // process the bufferlist in the audio processor
//    [audioProcessor processBuffer:&bufferList];
//
//    // clean up the buffer
//    free(bufferList.mBuffers[0].mData);
//
//    return noErr;
//}


//static void(^initStereoChannel)(void * inRefCon, float * samples, AVAudioFrameCount samples_count, StereoChannelList * stereoChannelData)
//{
//    NSObject * refCon = (__bridge NSObject *) inRefCon;
//
//    // iterate over incoming stream an copy to output stream
//    for (int i = 0; i < stereoChannelData->channel_count; i++) {
//        StereoChannel channel = stereoChannelData->channels[i];
//        channel.samples_count = samples_count;
//        channel.samples       = samples;
//    }
//    return noErr;
//}

//void (^calculateChannelData)(AVAudioFrameCount, double, double, double, float *) = ^(AVAudioFrameCount sampleCount, double frequency, double duration, double outputVolume, float * samples)

typedef void (^ToneCompletionBlock)(void);
typedef void (^BufferCompletionBlock)(AVAudioPCMBuffer * _Nonnull buffer, ToneCompletionBlock _Nonnull toneCompletionBlock);
typedef void (^Tone)(struct audio_buffer * __nullable buffer_data, BufferCompletionBlock bufferCompletionBlock);


void (^calculateChannelData)(AVAudioFrameCount, struct channel_frequencies *, double, double, float *) = ^(AVAudioFrameCount sampleCount, struct channel_frequencies * frequencies, double duration, double outputVolume, float * samples)
{
    for (int index = 0; index < sampleCount; index++)
    {
        double normalized_time = normalize(0.0, 1.0, index, 0.0, sampleCount);
        double frequency_sum   = 0.0;
        for (int i = 0; i < frequencies->frequencies_count; i++)
        {
            frequency_sum += sinf(2.0 * M_PI * normalized_time * frequencies->frequencies[i]);
        }
        double sample = frequency_sum * envelope_lfo(normalized_time, outputVolume);
        
        
        if (samples) samples[index] = sample;
    }
};

static void(^createAudioBuffer)(AVAudioSession *, AVAudioFormat *, CreateAudioBufferCompletionBlock) = ^(AVAudioSession * audioSession, AVAudioFormat * audioFormat, CreateAudioBufferCompletionBlock createAudioBufferCompletionBlock)
{
    static AVAudioPCMBuffer * (^calculateBufferData)(void);
    calculateBufferData = ^AVAudioPCMBuffer *(void)
    {
        double duration = 0.25;
        AVAudioFrameCount frameCount = ([audioFormat sampleRate] * duration);
        AVAudioPCMBuffer *pcmBuffer  = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFormat frameCapacity:frameCount];
        pcmBuffer.frameLength        = frameCount;
        
        //        double tone_split = randomize(0.0, 1.0, 1.0);
        //        double device_volume = pow(audioSession.outputVolume, 3.0);
        
        //        calculateChannelData(pcmBuffer.frameLength,
        //                             channel_frequencies_left,
        //                             tone_split,
        //                             device_volume,
        //                             pcmBuffer.floatChannelData[0]);
        //
        //        calculateChannelData(pcmBuffer.frameLength,
        //                             channel_frequencies_right,
        
        
        return pcmBuffer;
    };
    
    static void (^audioBufferCreatedCompletionBlock)(void);
    static void (^tonePlayedCompletionBlock)(void) = ^(void) {
        audioBufferCreatedCompletionBlock();
    };
    audioBufferCreatedCompletionBlock = ^void(void)
    {
        createAudioBufferCompletionBlock(calculateBufferData(), ^{
            tonePlayedCompletionBlock();
        });
    };
    audioBufferCreatedCompletionBlock();
};

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
            if (![self.playerNode isPlaying]) [self.playerNode play];
            
            createAudioBuffer([AVAudioSession sharedInstance], [self.playerNode outputFormatForBus:0], ^(AVAudioPCMBuffer * audio_buffer, PlayedToneCompletionBlock playedToneCompletionBlock) {
                [self.playerNode scheduleBuffer:audio_buffer atTime:nil options:AVAudioPlayerNodeBufferInterruptsAtLoop completionCallbackType:AVAudioPlayerNodeCompletionDataPlayedBack completionHandler:^(AVAudioPlayerNodeCompletionCallbackType callbackType) {
                    if (callbackType == AVAudioPlayerNodeCompletionDataPlayedBack)
                    {
                        playedToneCompletionBlock();
                    }
                }];
            });
            
            return TRUE;
        }
    }
    
    return FALSE;
}

@end
