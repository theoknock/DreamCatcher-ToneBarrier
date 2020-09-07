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

typedef double (^FrequencySampleModifier)(double, ...);
FrequencySampleModifier modify_frequency_sample = ^(double frequency_sample, ...)
{
    return frequency_sample;
};

typedef double (^FrequencySampler)(double, double, ...);
FrequencySampler sample_frequency = ^(double time, double frequency, ...)
{
    double frequency_sample = sinf(M_PI * time * frequency);
    
    return frequency_sample;
};

typedef struct Samplers
{
    typedef struct FrequencySamplers
    {
        FrequencySampler frequency_sampler;
        struct FrequencySampleModifiers
        {
            int frequency_sample_modifier_count;
            FrequencySampleModifier * frequency_sample_modifiers_arr[];
        } * frequency_sample_modifiers;
        
    } frequency_samplers;
    
    typedef double (^AmplitudeSampler)(double, double, ...);
    AmplitudeSampler sample_amplitude = ^(double time, double gain, ...)
    {
        double result = pow(sin(time * M_PI), gain);
        
        return result;
    };

    typedef struct AmplitudeSamplers
    {
        AmplitudeSampler amplitude_sampler;
        struct AmplitudeSampleModifiers
        {
            int amplitude_sample_modifier_count;
            AmplitudeSampleModifier * amplitude_sample_modifiers_arr[];
        } * amplitude_sample_modifiers;
        
    } amplitude_samplers;
} Samplers;

// FrequencySampleModifiers

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
} HarmonicIntervalConsonance;

typedef enum typeof(HarmonicInterval) {
    HarmonicIntervalDissonantMinorSecond,                       // C/C sharp
    HarmonicIntervalDissonantMajorSecond,                       // C/D
    HarmonicIntervalDissonantMinorSevenths,                     // C/B flat
    HarmonicIntervalDissonantMajorSevenths,                     // C/B
    HarmonicIntervalDissonantRandomize
} HarmonicIntervalDissonance;

// TO-DO: Make this a typeof(FrequencySamplerModifier)
//        Change the FrequencySamplerModifier parameters to a variadic argument
static typeof(FrequencySampleModifier) * double (^harmonize_frequency)(double frequency_sample, enum HarmonicAlignment, enum typeof(HarmonicInterval)));
FrequencySampleModifier harmonize_frequency = ^{
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

// AmplitudeSampleModifiers

// Tremolo effect : amplitude_sample * sinf((M_PI * time * tremolo))

// Pan: amplitude_sample * * ^double(double gamma_, double time_, StereoChannelOutput stereo_channel_output_)
//{
//    double a = pow(time_, gamma_);
//    double b = 1.0 - a;
//    double c = a * b;
//    c = (stereo_channel_output_ == StereoChannelOutputRight)
//    ? 1.0 - c : c;
//
//    return c;
//} (gamma, time, stereo_channel_output);

// TO-DO: Process variadic arguments
//        Iterate through chain of sample modifiers
//        Create a type definition for any block that returns a double to the root frequency calculation
//        ...and apply it to the random generator and distributor blocks (call it the
FrequencySource type)

struct Tone
{
    // Procesing chain for the frequency variable of audio sample equation (the sine of frequency * amplitude, pi-normalized)
    struct Random * randomizer; //  --> root frequency
    /* --> root frequency --> */ struct Samplers * samplers;
    
    enum HarmonicInterval harmonic_Interval;
    enum ConsonantHarmonicInterval harmonic_interval;
    
};
typedef struct Tone Tone;

#endif /* Tone_h */
