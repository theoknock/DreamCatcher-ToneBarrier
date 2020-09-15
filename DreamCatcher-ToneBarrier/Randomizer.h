//
//  Randomizer.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/5/20.
//
//  This is (or will be) a base class for Frequency and Duration randomizers. It provides all the functionality inherent to both; it is flexible enough to serve as a foundation for any type of random generator and distributor
//  Classification of structs:
//  - some organize properties and methods that relate to implementation of any of the methods and properties below, i.e., software design and architecture (computer science, hardware considerations, best practices, provisions)
//  - some organize methods and properties to affect or ensure tone barrier specification and the data from which it is derived
//  - some organize methods and properties relating to the mathematics (statistics)
//  - some organize methods and properties relating to the science (music and sound theory and practice)
//  - some organize methods and properties relating to expediency (driven by external and personal concerns, urgency of demand)
//
//  Together, these all match the intended usage of the methods ; properties,
//
//  The Randomizer struct organizes the properties and methods relating to the following:
//  - Tone barrier specifications:
//       - Trigger instinctual listening
//       - Distract pitch-prediction, pitch-projection
//  - Tone barrier specification data suggests:
//       - Random durations and frequencies trigger instinctual listening
//       - Certain ranges of durations and frequencies are more effective than others
//       - Some ranges are universally effective (fixed distribution and probability: should not change), others are circumstantial (dynamic distribution: should be adaptable, editable, setable)
//  - Mathematics (statistics):
//       - Randoms should be generated within a given range on a parameterized distribution curve (values should be random within a non-random range)
//   - Implementation:
//       - The base random value should lie between the range of values possible for generating the sample (when possible)
//           - For smaller ranges (per unit value or cumulative value or for non-integer range values): generate a double between 0 and 1 (drand48) and multiply it by the difference between the upper and lower range bounds, and then add the minimum range bound to the product
//           - For larger ranges: generate an integer between 0 and the difference between the bounds (arc4random_uniform), and then add the minimun range bound to the product
//       - All randoms should be distributed normally, binomially, etc.
//       - The distribution range parameters should be based on the type of sample derived from it
//       - The random number and/or the distributed value returned should within the range specified UNLESS the random number is to be distributed along a non-standard curve
//
//  Usage:
//      - Generate a random duration within a fixed range for:
//          - two pairs of tones
//              - Fixed:
//                  - tones are played in two (to form a pair), playing collectively for a total of two seconds
//                  - each tone should play for a minimum of 0.25 seconds (leaving a maximum of 0.75)
//              - Dynamic:
//                  - the characteristics of a pair of tones relates to the duration of their respective sustain (short-long, long-short or even)
//                  - in the case of even: a normal distribution with the mean centered directly in the middle of the range should be used, narrowed tightly
//                  - in the case of short-long: a normal distribution with the mean centered one standard deviation greater than the minimum range value (or one standard deviation less than the maximum range value for long-short), narrowed bny the midpoint and the nearest range bound
//          - three-minute measures
//              - 

#ifndef Randomizer_h
#define Randomizer_h

#include <stdio.h>

extern const void * _Nonnull Randomizer;

typedef enum RandomSourceFunction
{
    random_generator_rand_r,
    random_generator_rand_r_boolean
} RandomSourceFunction;

typedef struct RandomGeneratorParameters RandomParameters;
typedef struct RandomSourceParameters RandomSourceParameters;
typedef struct RandomFunctionParameters RandomFunctionParameters;
typedef struct RandomDistributorParameters RandomDistributorParameters;

typedef double (^ _Nonnull RandomSource)(struct RandomFunctionParameters random_function_parameters);

typedef double (^ _Nonnull RandomDistributor)(double random,
                                              double range_min,
                                              double range_max,
                                              double mean,
                                              double standard_deviation,
                                              double median,
                                              double mode);

typedef struct RandomGeneratorParameters
{
    struct RandomSourceParameters
    {
        RandomSource generate_random;
        RandomSourceFunction random_source_function;
    } * _Nonnull random_source_parameters;
    
    struct RandomFunctionParameters
    {
        const unsigned seed;
        char * _Nullable state;
        size_t size;
    } * _Nonnull random_function_parameters;
    
    struct RandomDistributorParameters
    {
        RandomDistributor distribute_random;
        double range_min;
        double range_max;
        double standard_deviation;
        double median;
        double mean;
        double mode;
        
    } * _Nonnull random_distributor_parameters;
    
} * _Nonnull random_generator_parameters;

typedef double (^ _Nonnull RandomGenerator)(struct RandomGeneratorParameters * _Nonnull random_generator_parameters);

#endif /* Randomizer_h */
