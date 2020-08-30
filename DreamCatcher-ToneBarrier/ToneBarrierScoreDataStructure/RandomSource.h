//
//  RandomSource.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/29/20.
//

#ifndef RandomSource_h
#define RandomSource_h

#include <stdio.h>

extern const void * RandomSource;

enum RandomNumberGeneratorFunc
{
    random_number_generator_func_drand48,
    random_number_generator_func_arc4random
};

double (^generate_random_number)(double, double);

#endif /* RandomSource_h */
