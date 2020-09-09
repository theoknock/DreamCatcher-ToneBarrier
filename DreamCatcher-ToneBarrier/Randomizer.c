//
//  Randomizer.c
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/5/20.
//

#include "Randomizer.h"


#include "Score.h"
typedef double (^Percentage)(double, double, double);
Percentage percentage = ^double(double min, double max, double value)
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

struct RandomizerParameters * new_randomizer_parameters(double range_min,
                                                        double range_max,
                                                        double gamma_distribution)
{
    struct RandomizerParameters * parameters = malloc(sizeof(RandomizerParameters));
    parameters->range_min = range_min;
    parameters->range_max = range_max;
    parameters->gamma_distribution = gamma_distribution;
    
    assert(parameters);
    
    return parameters;
}

double (^generate_random_drand48)(double, double, double) = ^double(double range_min,
                                                                    double range_max,
                                                                    double gamma_distribution)
{
    double random = drand48();
    double result = pow(linearize(range_min, range_max, random), gamma_distribution);
    
    return result;
};

double (^generate_random_drand48_normalized_bounds)(double, double, double) = ^double(double range_min,
                                                                                      double range_max,
                                                                                      double gamma_distribution)
{
    double random = drand48();
    double result = pow(linearize(0.0, 1.0, random), gamma_distribution);
    
    return result;
};

double (^generate_random_arc4random)(double, double, double) = ^double(double range_min,
                                                                       double range_max,
                                                                       double gamma_distribution)
{
    double random = ((double)arc4random() / 0x100000000);
    double result = pow(linearize(range_min, range_max, random), gamma_distribution);
    
    return result;
};

double (^_Nonnull(^ _Nonnull set_random_generator)(enum RandomGenerator))(double, double, double) = ^(enum RandomGenerator random_generator) {
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
        default:
        {
            srand48(time(0));
            return generate_random_drand48;
            break;
        }
    }
};

struct RandomSource * new_random_source (enum RandomGenerator random_generator,
                                         double range_min,
                                         double range_max,
                                         double gamma_distribution)
{
    struct RandomSource * random_source = malloc(sizeof(struct RandomSource) + sizeof(struct RandomizerParameters));
    random_source->random_generator_parameters = new_randomizer_parameters(range_min,
                                                                           range_max,
                                                                           gamma_distribution);
    random_source->random_generator = random_generator;
    random_source->generate_random = set_random_generator(random_generator);
    
    assert(random_source);
    
    return random_source;
}

double (^random_distributor_gamma)(double, double, double, double) = ^(double random, double range_min, double range_max, double gamma_distribution)
{
    //    double random = random_source->generate_random(range_min, range_max);
    double scaled = scale(1.0, 0.0, random, range_min, range_max);
    double result = pow(scaled, gamma_distribution);
    result = linearize(range_min, range_max, result);
    
    
    
    return result;
};

double (^random_distributor_scurve)(double, double, double, double) = ^(double random, double range_min, double range_max, double gamma_distribution)
{
    //    double random = random_source->generate_random(range_min, range_max);
    // The inverse is not necessarily 1/gamma; but, is gamma * 1/frequency
    double scaled_x1 = pow(random, gamma_distribution);
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

struct RandomDistributor * new_random_distributor (enum RandomDistribution random_distribution,
                                                   double range_min,
                                                   double range_max,
                                                   double gamma_distribution)
{
    struct RandomDistributor * _random_distributor = malloc(sizeof(struct RandomDistributor) + sizeof(struct RandomizerParameters));
    _random_distributor->random_distribution = random_distribution;
    _random_distributor->random_distributor_parameters = new_randomizer_parameters(range_min,
                                                                                   range_max,
                                                                                   gamma_distribution);
    _random_distributor->distribute_random = set_random_distributor(random_distribution);
    
    assert(_random_distributor);
    
    return _random_distributor;
}


double (^ _Nonnull generate_distributed_random)(struct Randomizer *) = ^(struct Randomizer * randomizer) {
    double generated_random = randomizer->random_source->generate_random(randomizer->random_source->random_generator_parameters->range_min,
                                                                         randomizer->random_source->random_generator_parameters->range_max,
                                                                         randomizer->random_source->random_generator_parameters->gamma_distribution);
    randomizer->random_source->last_generator_value = generated_random;
    
    
    double distributed_random = randomizer->random_distributor->distribute_random(generated_random,
                                                                                  randomizer->random_distributor->random_distributor_parameters->range_min,
                                                                                  randomizer->random_distributor->random_distributor_parameters->range_max,
                                                                                  randomizer->random_distributor->random_distributor_parameters->gamma_distribution);
    randomizer->random_distributor->last_distributor_value = distributed_random;
    
    return distributed_random;
};









struct Randomizer * _Nonnull new_randomizer (enum RandomGenerator random_generator,
                                             double random_generator_range_min,
                                             double random_generator_range_max,
                                             double random_generator_gamma_distribution,
                                             enum RandomDistribution random_distribution,
                                             double random_distribution_range_min,
                                             double random_distribution_range_max,
                                             double random_distribution_gamma_distribution)
{
    struct Randomizer * random = malloc(sizeof(struct Randomizer) + sizeof(struct RandomSource) + sizeof(struct RandomDistributor));
    random->random_source = new_random_source(random_generator,
                                              random_generator_range_min,
                                              random_generator_range_max,
                                              random_generator_gamma_distribution);
    
    random->random_distributor = new_random_distributor(random_distribution,
                                                        random_distribution_range_min,
                                                        random_distribution_range_max,
                                                        random_distribution_gamma_distribution);
    
    random->generate_distributed_random = generate_distributed_random;
    
    assert(random);
    
    return random;
}
