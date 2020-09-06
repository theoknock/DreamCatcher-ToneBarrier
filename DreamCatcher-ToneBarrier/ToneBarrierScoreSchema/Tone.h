//
//  Tone.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/5/20.
//

#ifndef Tone_h
#define Tone_h

#include <stdio.h>

#include "Randomizer.h"

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

typedef enum HarmonicAlignment) {
    HarmonicAlignmentConsonance,
    HarmonicAlignmentDissonance,
    HarmonicAlignmentRandom
} harmonic_alignment;

typedef enum HarmonicAlignmentConsonantInterval {
    HarmonicAlignmentConsonanceIntervalUnison,
    HarmonicAlignmentConsonanceIntervalOctave,
    HarmonicAlignmentConsonanceIntervalMajorSixth,
    HarmonicAlignmentConsonanceIntervalPerfectFifth,
    HarmonicAlignmentConsonanceIntervalPerfectFourth,
    HarmonicAlignmentConsonanceIntervalMajorThird,
    HarmonicAlignmentConsonanceIntervalMinorThird,
    HarmonicAlignmentConsonanceIntervalRandom
} harmonic_alignment_consonant_interval;

typedef enum HarmonicAlignmentDissonantInterval {
    HarmonicIntervalDissonantMinorSecond,                       // C/C sharp
    HarmonicIntervalDissonantMajorSecond,                       // C/D
    HarmonicIntervalDissonantMinorSevenths,                     // C/B flat
    HarmonicIntervalDissonantMajor sevenths                     // C/B
} harmonic_alignment_dissonant_interval;

double (^harmonic_alignment_consonant_interval)(double, HarmonicAlignmentConsonantInterval))Interval
{
    return ^double(double frequency, HarmonicAlignmentConsonantInterval harmonic_alignment_consonant_interval)
    {
        double new_frequency = frequency * ^double(HarmonicAlignmentConsonantInterval harmonic_alignment_consonant_interval_) {
            double consonant_harmonic_interval_ratios[7] = {1.0, 2.0, 5.0/3.0, 4.0/3.0, 5.0/4.0, 6.0/5.0};
            
            return (harmonic_alignment_consonant_interval_ == 8)
            ? consonant_harmonic_interval_ratios[arc4random_uniform(7)]
            : consonant_harmonic_interval_ratios[harmonic_alignment_consonant_interval_];
        } (harmonic_alignment_consonant_interval);

        return new_frequency;
    };
};

double Harmonicity(double frequency, HarmonicInterval interval, HarmonicHarmony harmony)
{
    double new_frequency = frequency;
    switch (harmony) {
        case HarmonicHarmonyDissonance:
            new_frequency *= (1.1 + drand48());
            break;
            
        case HarmonicHarmonyConsonance:
            new_frequency = ToneBarrierGenerator.Interval(frequency, interval);
            break;
            
        case HarmonicHarmonyRandom:
            new_frequency = Harmonicity(frequency, interval, (HarmonicHarmony)arc4random_uniform(2));
            break;
            
        default:
            break;
    }
    
    return new_frequency;
}


struct Tone
{
    struct Samplers
    {
        __unsafe_unretained FrequencySampler sample_frequency;
        __unsafe_unretained FrequencySamplerModifier modify_frequency_sampler;
        __unsafe_unretained AmplitudeSampler sample_amplitude;
    } * samplers;
    
    struct Random * randomizer;
    
    enum HarmonicAlignment harmonic_alignment;
    enum ConsonantHarmonicInterval harmonic_interval;
    
};
typedef struct Tone Tone;

#endif /* Tone_h */
