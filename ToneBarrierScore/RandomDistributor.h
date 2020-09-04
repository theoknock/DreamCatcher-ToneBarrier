//
//  RandomDistributor.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

#ifndef RandomDistributor_h
#define RandomDistributor_h

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "RandomSource.h"

extern const void * RandomDistributor;

enum random_distributor_func
{
    random_generator_func_gaussian,
    random_generator_func_linear,
    random_generator_func_gamma
};

typedef struct RandomDistributor
{
    struct RandomSource * random_source;
    enum random_distributor_func distributor;
    double mean;
    double deviation;
    double lower_bound;
    double higher_bound;
    double (^distribute_random)(struct RandomDistributor *);
} random_distributor;

struct RandomDistributor * new_random_distributor (enum random_distributor_func distributor,
                                                   double mean,
                                                   double deviation,
                                                   double lower_bound,
                                                   double higher_bound,
                                                   double (^distribute_random)(struct RandomSource *));

#endif /* RandomDistributor_h */
