//
//  RandomDistributor.c
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

#include "RandomDistributor.h"
#include "time.h"
//
//double (^generate_random_drand48)(struct RandomSource *) = ^double(struct RandomSource * random_source)
//{
//    double random = drand48();
//    double result = (random * (random_source->higher_bound - random_source->lower_bound)) + random_source->lower_bound;
//    
//    return result;
//};
//
//double (^generate_random_arc4random)(struct RandomSource *) = ^double(struct RandomSource * random_source)
//{
//    double random = ((double)arc4random() / 0x100000000) ;
//    double result = (random * (random_source->higher_bound - random_source->lower_bound)) + random_source->lower_bound;
//    
//    return result;
//};
//
////double (^generate_random_drand48)(double, double) = ^double(double lower_bound, double higher_bound)
////{
////    double random = drand48();
////    double result = (random * (higher_bound - lower_bound)) + lower_bound;
////
////    return result;
////};
//
////double (^generate_random_arc4random)(double, double) = ^double(double lower_bound, double higher_bound)
////{
////    double random = ((double)arc4random() / 0x100000000) ;
////    double result = (random * (higher_bound - lower_bound)) + lower_bound;
////
////    return result;
////};
//
//double (^_Nonnull(^ _Nonnull set_random_generator)(enum RandomGenerator))(struct RandomSource *) = ^(enum RandomGenerator random_generator) {
//    switch (random_generator) {
//        case random_generator_drand48:
//        {
//            srand48(time(0));
//            return generate_random_drand48;
//            break;
//        }
//        case random_generator_arc4random:
//            return generate_random_arc4random;
//            break;
//            
//        default:
//        {
//            srand48(time(0));
//            return generate_random_drand48;
//            break;
//        }
//    }
//};
//
//double (^random_distributor_gaussian_mean_variance)(struct RandomDistributor *) = ^double(struct RandomDistributor *)
//{
//    double result        = exp(-(pow((random_source(lower_bound, upper_bound) - mean), 2.0) / variance));
//    double scaled_result = scale(0.0, 1.0, result, lower_bound, upper_bound);
//
//    return scaled_result;
//};
//
//RandomDistributor random_distributor_gaussian_mean_standard_deviation = ^double(RandomSource random_source, double lower_bound, double upper_bound, double mean, double standard_deviation)
//{
//    double result        = sqrt(1 / (2 * M_PI * standard_deviation)) * exp(-(1 / (2 * standard_deviation)) * (random_source(lower_bound, upper_bound) - mean) * 2);
//    double scaled_result = scale(0.0, 1.0, result, lower_bound, upper_bound);
//
//    return scaled_result;
//};
