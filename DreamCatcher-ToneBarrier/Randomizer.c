//
//  Randomizer.c
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/5/20.
/

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "time.h"
#include "math.h"

#include "New.h"
#include "New.r"

#include "Randomizer.h"


struct Randomizer
{
    const void * class;
    
    struct RandomGeneratorParameters * _Nonnull random_generator_parameters;
    
    RandomGenerator generate_distributed_random;
};

typedef double (^Percentage)(double, double, double);
Percentage percentage = ^double(double min, double max, double value)
{
    double result = (value - min) / (max - min);
    
    return result;
};

// TO-DO: Cut normalized time into three segments, each corresponding to attack, sustain and release;
//        Distribute time in proportion to the relative duration of each segment;
//        Use the lowest and highest values in each segment to normalize the values from the amplitude envelope function
//        Calculate the weighted sum of the three sinusoids to create a amplitude sinusoid that conforms to [what you wanted for the attack, sustain and release]

// TO-DO: To rescale a sine curve period into a 0 to 1 frame,
//  use 0 to 1/frequency as the new minimum and new maximum, respectively


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

//typedef void (^RandomizerParametersCompletion)(RandomSource generate_random, double random, double median, double mode);
//RandomizerParametersCompletion randomizer_parameters_completion
//void (^RandomizerParameters)(^(RandomSource generate_random, double random, double median, double mode);
                             //    double range_min          = random_generator_parameters -> range_min;
                             //    double range_max          = random_generator_parameters -> range_max;
                             //    double mean               = random_generator_parameters -> mean;
                             //    double standard_deviation = random_generator_parameters -> standard_deviation;
                             //    double random = random_generator_parameters -> generate_random(range_min, range_max, mean, standard_deviation);
                             //
                             //    double distributed_random = random_generator_parameters -> distribute_random(random_generator_parameters -> generate_random(range_min, range_max, mean, standard_deviation),
                             //                                                                                 double
                                 
                             //    double scaled = scale(1.0, 0.0, random, range_min, range_max);
                             //    double result = pow(scaled, gamma_distribution);
                             //    result = linearize(range_min, range_max, result);

//RandomGenerator generate_distributed_random;


double (^ _Nonnull generate_distributed_random)(double (^)(double, double, double, double, double, double, double),
                                                double(^)(RandomSource),
                                                struct RandomGeneratorParameters * _Nonnull) =
^ double (^ double (double random,
                    double range_min,
                    double range_max,
                    double mean,
                    double standard_deviation,
                    double median,
                    double mode) { }, ^ double (RandomSource) { }, struct RandomGeneratorParameters * _Nonnull random_generator_parameters)
{
    
};


^(RandomGeneratorParameters * _Nonnull random_generator_parameters)
{
    ^(RandomSource generate_random, double random, double median, double mode) {
        
    } (random_generator_parameters -> random_source_parameters -> generate_random,
       random_generator_parameters -> random_source_parameters -> range_min,
       random_generator_parameters -> random_source_parameters -> range_max;
       random_generator_parameters -> random_source_parameters -> mean;
       random_generator_parameters -> random_source_parameters -> standard_deviation);

    
    
    
    return 1.0;
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



static void * Randomizer_ctor (void * _self, va_list * app)
{
    struct Randomizer * self = _self;
    
    const enum RandomGeneratorFunction random_generator_function = va_arg(* app, enum RandomGeneratorFunction);
    double range_min = va_arg(* app, double);
    double range_max = va_arg(* app, double);
    double mean = va_arg(* app, double);
    double median = va_arg(* app, double);
    double mode = va_arg(* app, double);
    double standard_deviation = va_arg(* app, double);
    
    self -> random_generator_parameters = malloc(sizeof(struct RandomizerParameters));
    self -> random_generator_parameters -> random_generator_function = random_generator_function;
    self -> random_generator_parameters -> range_min = range_min;
    self -> random_generator_parameters -> range_max = range_max;
    self -> random_generator_parameters -> mean = mean;
    self -> random_generator_parameters -> median = median;
    self -> random_generator_parameters -> mode = mode;
    self -> random_generator_parameters -> standard_deviation = standard_deviation;
    
    _random_distributor->distribute_random = set_random_distributor(random_distribution);
    
    
    double abs_diff = fabs(random_generator_parameters -> range_min - random_generator_parameters -> range_max);
    assert((random_generator_parameters -> mean < abs_diff) &&
           (random_generator_parameters -> median < abs_diff) &&
           (random_generator_parameters -> mode < abs_diff));
    
    
    
    return self;
}

static void *Randomizer_dtor (void * _self)
{
    struct Randomizer * self = _self;
    free(self -> random_generator_parameters), self -> random_generator_parameters = 0;
    
    return self;
}

static void * Randomizer_clone (const void * _self)
{    const struct Randomizer * self = _self;

    return new(Randomizer, self -> tempo);
}

static int Randomizer_differ (const void * _self, const void * _b)
{
    const struct Randomizer * self = _self;
    const struct Randomizer * b = _b;

    if (Randomizer == b)
        return 0;
    if (! b || b -> class != Randomizer)
        return 1;
    
    return strcmp(self -> title, b -> title);
}

static const struct Class _Randomizer =
{
    sizeof(struct Randomizer),
    Randomizer_ctor, Randomizer_dtor,
    Randomizer_clone, Randomizer_differ
};

const void * Randomizer = & _Randomizer;







//    random_generator_parameters->seed = seed;
    // 68-95-99.7 Rule
//    size_t size = ^ size_t(double range_width, int random_count) {  };
//    random_generator_parameters->size =
//
//    random_generator_parameters->size
//    random_generator_parameters->state = malloc(size);
//

double (^generate_random_drand48)(double, double, double) = ^double(double range_min,
                                                                    double range_max,
                                                                    double gamma_distribution)
{
    double random = rand_r(time(0));//  drand48();
    

    double result = pow(linearize(range_min, range_max, random), gamma_distribution);
    
    return result;
};

double (^generate_random_3(double, double, double) = ^double(double range_min,
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

double (^_Nonnull(^ _Nonnull set_random_generator)(enum Randomizer))(double, double, double) = ^(enum Randomizer random_generator) {
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

struct RandomSource * new_random_source (enum Randomizer random_generator,
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
