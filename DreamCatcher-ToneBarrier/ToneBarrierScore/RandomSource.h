//
//  RandomSource.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/2/20.
//

#ifndef RandomSource_h
#define RandomSource_h

#include <stdarg.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

extern const void * RandomSource;

enum RandomGenerator
{
    random_generator_drand48,
    random_generator_arc4random
};

typedef struct RandomSource
{
//    const void * pointer_to_parent_struct;
    
    enum RandomGenerator random_generator;
    double lower_bound;
    double higher_bound;
    double (^generate_random)(struct RandomSource *);
} random_source;

struct RandomSource * new (enum RandomGenerator random_generator,
                   double lower_bound,
                   double higher_bound);


#endif /* RandomSource_h */
