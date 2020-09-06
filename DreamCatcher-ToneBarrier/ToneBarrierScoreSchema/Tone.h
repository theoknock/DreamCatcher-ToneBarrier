//
//  Tone.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/5/20.
//

#ifndef Tone_h
#define Tone_h

#include <stdio.h>
#include <stddef.h>

#include "Randomizer.h"

extern const void * Tone;

static double consonant_harmonic_interval_ratios[7] = {1.0, 2.0, 5.0/3.0, 4.0/3.0, 5.0/4.0, 6.0/5.0};
static double dissonant_harmonic_interval_ratios[5] = {1.0, 2.0, 3.0, 4.0, 5.0}; // TO-DO: Find the ratios for the notes in the comments for each dissonant harmonic interval

typedef struct FrequencySamplers
{
    FrequencySampler frequency_sampler;
    struct FrequencySamplerModifiers
    {
        int frequency_sampler_modifier_count;
        FrequencySamplerModifier * frequency_sampler_modifiers_arr[];
    } * frequency_sampler_modifiers;
} frequency_sampler_modifier;

typedef double (^FrequencySamplerModifier)(double, double frequency_sample, ...);
FrequencySamplerModifier modify_frequency_sample = ^(double time, double frequency_sample, ...)
{
    return 0.0;
};

typedef double (^FrequencySampler)(double, double, ...);
FrequencySampler sample_frequency = ^(double time, double frequency, ...)
{
    double result = modify_frequency_sample(time, sinf(M_PI * time * frequency));
    
    return result;
};

typedef double (^AmplitudeSampler)(double, double, ...);
AmplitudeSampler sample_amplitude = ^(double time, double gain, ...)
{
    double result = pow(sin(time * M_PI), gain);
    
    return result;
};

typedef enum HarmonicAlignment) {
    HarmonicAlignmentConsonant,
    HarmonicAlignmentDissonant,
    HarmonicAlignmentRandomize
} HarmonicAlignment;

typedef enum HarmonicInterval;

typedef enum typeof(HarmonicInterval) {
    HarmonicIntervalConsonantUnison,
    HarmonicIntervalConsonantOctave,
    HarmonicIntervalConsonantMajorSixth,
    HarmonicIntervalConsonantPerfectFifth,
    HarmonicIntervalConsonantPerfectFourth,
    HarmonicIntervalConsonantMajorThird,
    HarmonicIntervalConsonantMinorThird,
    HarmonicIntervalConsonantRandomize
} HarmonicIntervalConsonant;

typedef enum typeof(HarmonicInterval) {
    HarmonicIntervalDissonantMinorSecond,                       // C/C sharp
    HarmonicIntervalDissonantMajorSecond,                       // C/D
    HarmonicIntervalDissonantMinorSevenths,                     // C/B flat
    HarmonicIntervalDissonantMajorSevenths,                     // C/B
    HarmonicIntervalDissonantRandomize
} HarmonicIntervalDissonantInterval;

// TO-DO: Make this a typeof(FrequencySamplerModifier)
//        Change the FrequencySamplerModifier parameters to a variadic argument
double (^harmonize)(double, HarmonicAlignment, typeof(HarmonicInterval)))
{
    return ^double(double frequency, HarmonicAlignment harmonic_alignment, typeof(HarmonicInterval) harmonic_interval)
    {
        double harmonized_frequency = frequency * ^double(HarmonicAlignment harmonic_alignment_, typeof(HarmonicInterval) harmonic_interval_) {
            double * harmonic_alignment_intervals[2] = {consonant_harmonic_interval_ratios, dissonant_harmonic_interval_ratios};
            
            return (harmonic_alignment_   == HarmonicAlignmentConsonant)
            ? ((harmonic_interval_ == HarmonicIntervalConsonantRandomize) ? consonant_harmonic_interval_ratios[(HarmonicInterval)arc4random_uniform(7)] : consonant_harmonic_interval_ratios[harmonic_alignment_consonant_interval_]))
            : ((harmonic_interval_ == HarmonicIntervalDissonantRandomize) ? dissonant_harmonic_interval_ratios[(HarmonicInterval)arc4random_uniform(4)] : dissonant_harmonic_interval_ratios[harmonic_alignment_consonant_interval_]);
        } (harmonic_alignment, harmonic_interval);

        return harmonized_frequency;
    };
};

struct Tone
{
    struct Samplers
    {
        __unsafe_unretained FrequencySampler sample_frequency;
        __unsafe_unretained FrequencySamplerModifier * modify_frequency_sampler;
        __unsafe_unretained AmplitudeSampler sample_amplitude;
    } * samplers;
    
    struct Random * randomizer;
    
    enum HarmonicInterval harmonic_Interval;
    enum ConsonantHarmonicInterval harmonic_interval;
    
};
typedef struct Tone Tone;

#endif /* Tone_h */
