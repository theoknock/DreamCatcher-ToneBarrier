//
//  Signal.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/21/20.
//

#ifndef Signal_h
#define Signal_h

#include <stdio.h>

typedef struct Amplitude
{
    double lof;
    double step;
    __unsafe_unretained double (^envelope)(double lof,
                                           double step);
} amplitude;

typedef double Ratio;

typedef struct Harmony Harmony;
typedef struct Note Note;
typedef struct Chord Chord;
typedef struct Sample Sample;

typedef struct Sample
{
    __unsafe_unretained double (^mix_chords)(unsigned int chord_count,
                                             struct Chord * chord_array,
                                             struct Amplitude * amplitude);
    struct Amplitude * amplitude;
    
    unsigned int chord_count;
    struct Chord
    {
        __unsafe_unretained double (^mix_notes)(double root,
                                                struct Harmony * harmonic_ratio,
                                                unsigned int note_count,
                                                struct Note * note_array,
                                                struct Amplitude * amplitude);
        double root;
        struct Amplitude * amplitude;
        struct Harmony
        {
            unsigned int ratio_index : 2;
            __unsafe_unretained double (^harmonize)(int min_key,
                                                    int max_key,
                                                    double * root_frequency,
                                                    unsigned int * ratio_index, // the next ratio to return
                                                    unsigned int * ratio_count, // the modulus for ratio_index
                                                    double ** ratio_array);
            Ratio * ratio_array;
        } * _Nonnull harmony;

        unsigned int note_count;
        struct Note
        {
            double sine_phase;
            double phase_increment;
            __unsafe_unretained double (^ _Nonnull cycle)(double sample_rate,
                                                double frequency,
                                                double * _Nonnull sine_phase,
                                                double * _Nonnull phase_increment);
            __unsafe_unretained double (^ _Nonnull sample)(double * _Nonnull sine_phase,
                                                 double * _Nonnull phase_increment);
        } * _Nonnull note_array;

    } * _Nonnull chord;
    
} * sample;

#endif /* Signal_h */
