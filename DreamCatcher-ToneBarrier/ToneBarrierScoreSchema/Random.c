//
//  Randomizer.c
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

#include "Random.h"
#include "time.h"
#include "math.h"

typedef double (^Percentage)(double, double, double);
Percentage percentage = ^double(double min, double max, double value)
{
    double result = (value - min) / (max - min);
    
    return result;
};

typedef double (^Normalize)(double, double, double);
Normalize normalize = ^double(double min, double max, double value)
{
    double result = (value - min) / (max - min);
    
    return result;
};

typedef double (^Scale)(double, double, double, double, double);
Scale scale = ^double(double min_new, double max_new, double val_old, double min_old, double max_old)
{
    double val_new = min_new + ((((val_old - min_old) * (max_new - min_new))) / (max_old - min_old));
    
    return val_new;
};

typedef double (^Linearize)(double, double, double);
Linearize linearize = ^double(double range_min, double range_max, double value)
{
    double result = (value * (range_max - range_min)) + range_min;
    
    return result;
};

double (^generate_random_drand48)(double, double) = ^double(double range_min, double range_max)
{
    double random = drand48();
    double result = linearize(range_min, range_max, random);
    
    return result;
};

double (^generate_random_drand48_normalized_bounds)(double, double) = ^double(double range_min, double range_max)
{
    double random = drand48();
    double result = linearize(0.0, 1.0, random);
    
    return result;
};

double (^generate_random_arc4random)(double, double) = ^double(double range_min, double range_max)
{
    double result = linearize(range_min, range_max, ((double)arc4random() / 0x100000000));
    
    return result;
};

double (^_Nonnull(^ _Nonnull set_random_generator)(enum RandomGenerator))(double, double) = ^(enum RandomGenerator random_generator) {
    switch (random_generator) {
        case random_generator_drand48:
        {
            srand48(time(0));
            return generate_random_drand48;
            break;
        }
        case random_generator_arc4random:
        {
            return generate_random_arc4random;
            break;
        }
//        case random_generator_drand48_normalized_bounds:
//        {
//            srand48(time(0));
//            return generate_random_drand48_normalized_bounds;
//            break;
//        }
        
            
        default:
        {
            srand48(time(0));
            return generate_random_drand48;
            break;
        }
    }
};

struct RandomSource * new_random_source (enum RandomGenerator random_generator)
{
    struct RandomSource * random_source = malloc(sizeof(struct RandomSource));
    random_source->random_generator = random_generator;
    random_source->generate_random = set_random_generator(random_generator);
    
    assert(random_source);
    
    return random_source;
}

double (^random_distributor_gamma)(double, double, double, double) = ^(double random, double gamma, double range_min, double range_max)
{
//    double random = random_source->generate_random(range_min, range_max);
    double scaled = scale(1.0, 0.0, random, range_min, range_max);
    double result = pow(scaled, gamma);
    result = linearize(range_min, range_max, result);
    
    
    
    return result;
};

double (^random_distributor_scurve)(double, double, double, double) = ^(double random, double gamma, double range_min, double range_max)
{
//    double random = random_source->generate_random(range_min, range_max);
    
    double scaled_x1 = pow(random, gamma);
    double scaled_x2 = linearize(1.0, 0.0, scaled_x1);
    double result = (scaled_x1 + scaled_x2) / 2.0;
//    double scaled_func_x = pow(scaled, gamma);
//    double result = (1.0 - scaled_func_x)) / 2.0;
    result = scale(range_min, range_max, result, 1.0, 0.0);

    
    return result;
};

double (^_Nonnull(^ _Nonnull set_random_distributor)(enum RandomDistribution))(double, double, double, double) = ^(enum RandomDistribution random_distribution) {
    switch (random_distribution) {
        case random_distribution_gamma:
        {
            return random_distributor_gamma;
            break;
        }
        case random_distribution_scurve:
            return random_distributor_scurve;
            break;
            
        default:
        {
            return random_distributor_gamma;
            break;
        }
    }
};

struct RandomDistributor * new_random_distributor (enum RandomDistribution random_distribution, double gamma)
{
    struct RandomDistributor * _random_distributor = malloc(sizeof(struct RandomDistributor));
    _random_distributor->random_distribution = random_distribution;
    _random_distributor->gamma = gamma;
    _random_distributor->distribute_random = set_random_distributor(random_distribution);
    
    assert(_random_distributor);
    
    return _random_distributor;
}


double (^ _Nonnull generate_distributed_random)(struct Random *) = ^(struct Random * randomizer) {
    double result = randomizer->random_distributor->distribute_random(randomizer->random_source->generate_random(randomizer->range_min, randomizer->range_max),
                                                                         randomizer->random_distributor->gamma, randomizer->range_min, randomizer->range_max);

    return result;
};



struct Random * new_random (enum RandomGenerator random_generator,
                            enum RandomDistribution random_distribution,
                            double range_min,
                            double range_max,
                            double gamma)
{
    struct Random * random = malloc(sizeof(struct Random) + sizeof(struct RandomSource) + sizeof(struct RandomDistributor));
    random->random_source = new_random_source(random_generator);
    random->random_distributor = new_random_distributor(random_distribution, gamma);
    random->generate_distributed_random = generate_distributed_random;
    random->range_min = range_min;
    random->range_max = range_max;
    
    assert(random);
    
    return random;
}

//double (GenerateDistributedRandom)(struct Random *randomizer)
//{
//    return randomizer->random_distributor->random_source->generate_random(randomizer->range_min, randomizer->range_max);
////    generate_distributed_random(randomizer);
//};
