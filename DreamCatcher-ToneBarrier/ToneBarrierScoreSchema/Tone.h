//
//  Tone.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/5/20.
//

#ifndef Tone_h
#define Tone_h

#include <stdio.h>

extern const void * Tone;

//#include <Random.h>
//
//typedef double (^FrequencySamplerModifier)(double, double frequency_sample);
//FrequencySamplerModifier modify_frequency_sample = ^(double time, double frequency_sample)
//{
//    return 0.0;
//};
//
//typedef double (^FrequencySampler)(double, double, FrequencySamplerModifier);
//FrequencySampler sample_frequency = ^(double time, double frequency, FrequencySamplerModifier modify_frequency_sample)
//{
//    double result = modify_frequency_sample(time, sinf(M_PI * time * frequency));
//    
//    return result;
//};
//
//typedef double (^AmplitudeSampler)(double, double);
//AmplitudeSampler sample_amplitude = ^(double time, double gain)
//{
//    double result = pow(sin(time * M_PI), gain);
//    
//    return result;
//};
//
struct Tone
{
    struct Samplers
    {
        __unsafe_unretained FrequencySampler sample_frequency;
        __unsafe_unretained FrequencySamplerModifier modify_frequency_sampler;
        __unsafe_unretained AmplitudeSampler sample_amplitude;
    } * samplers;
    
    struct Random * randomizer;
};
typedef struct Tone Tone;

#endif /* Tone_h */
