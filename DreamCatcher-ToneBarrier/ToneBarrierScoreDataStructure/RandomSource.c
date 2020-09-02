//
//  RandomSource.c
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/29/20.
//

#include <assert.h>
#include <stdlib.h>

#include "RandomSource.h"

#include "new.h"
#include "Class.h"

struct RandomSource
{
    const void * class;    /* must be first */
    double * lower_bound;
    double * higher_bound;
    enum RandomNumberGeneratorFunc random_number_generator_func;
    __unsafe_unretained double (^random_number_generator)(double, double);
};

double (^random_number_generator_drand48)(double, double) = ^double(double lower_bound, double higher_bound)
{
    double random = drand48();
    double result = (random * (higher_bound - lower_bound)) + lower_bound;
    
    return result;
};

double (^random_number_generator_arc4random)(double, double) = ^double(double lower_bound, double higher_bound)
{
    double random = ((double)arc4random() / 0x100000000) ;
    double result = (random * (higher_bound - lower_bound)) + lower_bound;
    
    return result;
};

double (^_Nonnull(^ _Nonnull random_number_generator)(enum RandomNumberGeneratorFunc))(double, double) = ^(enum RandomNumberGeneratorFunc random_number_generator_func) {
    switch (random_number_generator_func) {
        case random_number_generator_func_drand48:
            return random_number_generator_drand48;
            break;
            
        case random_number_generator_func_arc4random:
            return random_number_generator_arc4random;
            break;
            
        default:
            return random_number_generator_drand48;
            break;
    }
};

static void * RandomSource_ctor(void * _self, enum RandomNumberGeneratorFunc random_number_generator_func, double * lower_bound, double * higher_bound)
{
    struct RandomSource * self = _self;
    self->lower_bound = lower_bound;
    self->higher_bound = higher_bound;
    self->random_number_generator_func = random_number_generator_func;
    self->random_number_generator = random_number_generator(self->random_number_generator_func);
    assert(self->lower_bound);
    assert(self->higher_bound);
    
    return self;
}

static void * RandomSource_dtor(void * _self)
{
    struct RandomSource * self = _self;

    (void)(free((void *)self->lower_bound)),  self->lower_bound  = 0;
    (void)(free((void *)self->higher_bound)), self->higher_bound = 0;
    
    return self;
}

static void * RandomSource_clone(const void * _self)
{
    const struct RandomSource * self = _self;

    return new(RandomSource, self->lower_bound, self->higher_bound);
}

static int RandomSource_differ(const void * _self, const void * _b)
{
    const struct RandomSource * self = _self;
    const struct RandomSource * b = _b;

    if (&self == &b)
    {
        return 0;
    } else {
        return 1;
    }
}

static const struct Class _RandomSource = {
    sizeof(struct RandomSource),
    RandomSource_ctor,  RandomSource_dtor,
    RandomSource_clone, RandomSource_differ
};

const void * RandomSource = &_RandomSource;
