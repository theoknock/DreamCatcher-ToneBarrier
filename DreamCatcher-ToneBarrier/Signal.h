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

typedef struct Harmony
{
    __unsafe_unretained double (^harmonize)(int min_key,
                                            int max_key,
                                            double * root_frequency,
                                            unsigned int * ratio_index, // the next ratio to return
                                            unsigned int * ratio_count, // the modulus for ratio_index
                                            double ** ratio_array);
    unsigned int ratio_index;
    unsigned int ratio_count;
    Ratio * ratio_array;
} harmony;

typedef struct Note
{
    double sine_phase;
    double phase_increment;
    __unsafe_unretained double (^sample)(double * sine_phase,
                                         double * phase_increment);
} note;

typedef struct Chord
{
    __unsafe_unretained double (^mix_notes)(double root,
                                            struct Harmony * harmonic_ratio,
                                            unsigned int note_count,
                                            struct Note * note_array,
                                            struct Amplitude * amplitude);
    double root;
    struct Amplitude * amplitude;
    struct Harmony * harmonic_ratio;
    unsigned int note_count;
    struct Note * note_array;
} chord;

typedef struct Signal
{
    __unsafe_unretained double (^mix_chords)(unsigned int chord_count,
                                             struct Chord * chord_array,
                                             struct Amplitude * amplitude);
    struct Amplitude * amplitude;
    unsigned int chord_count;
    struct Chord * chord_array;
} signal;

#endif /* Signal_h */
