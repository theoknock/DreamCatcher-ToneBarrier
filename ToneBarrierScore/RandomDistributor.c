//
//  RandomDistributor.c
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

#include "RandomDistributor.h"
#include "time.h"

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

double (^random_distributor_gamma)(double, struct RandomDistributor *) = ^(double random, struct RandomDistributor * random_distributor)
{
    double result = pow(random, random_distributor->gamma);
    result = scale(random_distributor->lower_bound, random_distributor->upper_bound, result, 0.0, 1.0);
    
    return result;
};

double (^random_distributor_scurve)(double, struct RandomDistributor *) = ^(double random, struct RandomDistributor * random_distributor)
{
    double result = (pow(random, random_distributor->gamma) + pow(random, (1.0 / random_distributor->gamma))) / 2.0;
    result = scale(random_distributor->lower_bound, random_distributor->upper_bound, result, 0.0, 1.0);
    
    return result;
};

double (^_Nonnull(^ _Nonnull set_random_distribution)(enum RandomDistribution))(double random, struct RandomDistributor *) = ^(enum RandomDistribution random_distribution) {
    switch (random_distribution) {
        case random_distribution_gamma:
            return random_distributor_gamma;
            break;
            
        case random_distribution_scurve:
            return random_distributor_scurve;
            break;
            
        default:
            return random_distributor_gamma;
            break;
    }
};


struct RandomDistributor * new_random_distributor (enum RandomDistribution random_distribution,
                                double gamma,
                                double lower_bound,
                                double upper_bound)
{
    struct RandomDistributor * _random_distributor = malloc(sizeof(struct RandomDistributor));
    _random_distributor->random_distribution = random_distribution;
    _random_distributor->gamma = gamma;
    _random_distributor->lower_bound = lower_bound;
    _random_distributor->upper_bound = upper_bound;
    _random_distributor->distribute_random = set_random_distribution(random_distribution);
    
    assert(_random_distributor);
    
    return _random_distributor;
}
