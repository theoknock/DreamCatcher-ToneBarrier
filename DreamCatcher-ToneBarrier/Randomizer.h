//
//  Randomizer.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/5/20.
//

#ifndef Randomizer_h
#define Randomizer_h

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "time.h"
#include "math.h"


extern const void * _Nonnull Randomizer;

typedef struct RandomizerParameters
{
    double range_min;
    double range_max;
    double gamma_distribution;
} RandomizerParameters;

struct Randomizer
{
    struct RandomSource
    {
        enum RandomGenerator
        {
            random_generator_drand48,
            random_generator_arc4random,
        } random_generator;
    
        struct RandomizerParameters * _Nonnull random_generator_parameters;
        
        double (^ _Nonnull generate_random)(double, double, double);
    } * _Nonnull random_source;
    
    struct RandomDistributor
    {
        enum RandomDistribution
        {
            random_distribution_gamma,
            random_distribution_scurve
        } random_distribution;
        
        struct RandomizerParameters * _Nonnull random_distributor_parameters;
        
        double (^ _Nonnull distribute_random)(double, double, double, double);
    } * _Nonnull random_distributor;
    
    double (^ _Nonnull generate_distributed_random)(struct Randomizer * _Nonnull);
};

struct Randomizer * _Nonnull new_randomizer (enum RandomGenerator random_generator,
                                             double random_generator_range_min,
                                             double random_generator_range_max,
                                             double random_generator_gamma_distribution,
                                             enum RandomDistribution random_distribution,
                                             double random_distribution_range_min,
                                             double random_distribution_range_max,
                                             double random_distribution_gamma_distribution);


#endif /* Randomizer_h */
