//
//  RandomSource.c
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/2/20.
//

#include "RandomSource.h"
#include "time.h"

double (^generate_random_drand48)(struct RandomSource *) = ^double(struct RandomSource * random_source)
{
    double random = drand48();
    double result = (random * (random_source->higher_bound - random_source->lower_bound)) + random_source->lower_bound;
    
    return result;
};

double (^generate_random_arc4random)(struct RandomSource *) = ^double(struct RandomSource * random_source)
{
    double random = ((double)arc4random() / 0x100000000) ;
    double result = (random * (random_source->higher_bound - random_source->lower_bound)) + random_source->lower_bound;
    
    return result;
};

//double (^generate_random_drand48)(double, double) = ^double(double lower_bound, double higher_bound)
//{
//    double random = drand48();
//    double result = (random * (higher_bound - lower_bound)) + lower_bound;
//
//    return result;
//};

//double (^generate_random_arc4random)(double, double) = ^double(double lower_bound, double higher_bound)
//{
//    double random = ((double)arc4random() / 0x100000000) ;
//    double result = (random * (higher_bound - lower_bound)) + lower_bound;
//
//    return result;
//};

double (^_Nonnull(^ _Nonnull set_random_generator)(enum RandomGenerator))(struct RandomSource *) = ^(enum RandomGenerator random_generator) {
    switch (random_generator) {
        case random_generator_drand48:
        {
            srand48(time(0));
            return generate_random_drand48;
            break;
        }
        case random_generator_arc4random:
            return generate_random_arc4random;
            break;
            
        default:
        {
            srand48(time(0));
            return generate_random_drand48;
            break;
        }
    }
};

struct RandomSource * new (enum RandomGenerator random_generator,
                           double lower_bound,
                           double higher_bound)
{
    struct RandomSource * _random_source = malloc(sizeof(struct RandomSource));
    _random_source->lower_bound = lower_bound;
    _random_source->higher_bound = higher_bound;
    _random_source->random_generator = random_generator;
    _random_source->generate_random = set_random_generator(random_generator);
    
    assert(_random_source);
//    assert(_random_source->lower_bound);
//    assert(_random_source->higher_bound);
//    assert(_random_source->random_generator);
//    assert(_random_source->generate_random);
    
    return _random_source;
}
