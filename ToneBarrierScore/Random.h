//
//  Randomizer.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

// defines the properties, functions and substructs members of the Randomizer struct
// allocates memory for the Randomizer struct, its members and its substructs and...
// ...initializes its values
// provides accessor functions for setting/getting values of its members (where applicable)s

#ifndef Randomizer_h
#define Randomizer_h

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

extern const void * Random;

typedef struct Random
{
    struct RandomSource
    {
        enum RandomGenerator
        {
            random_generator_drand48,
            random_generator_arc4random
        } random_generator;
        double (^generate_random)(double, double);
    } * random_source;
    
    struct RandomDistributor
    {
        enum RandomDistribution
        {
            random_distribution_gamma,
            random_distribution_scurve
        } random_distribution;
        double gamma; // gamma >= 1 x10 <==> gamma < 1 x.10
        double (^distribute_random)(double, double, double);
    } * random_distributor;
    double range_min;
    double range_max;
    double (^random)(double (^)(double, double), double (^)(double (^)(double, double), double, double, double), double, double, double);
} randomizer;

struct Random * new_random (enum RandomGenerator random_generator,
                            enum RandomDistribution random_distribution,
                            double range_min,
                            double range_max,
                            double gamma);

#endif /* Randomizer_h */
