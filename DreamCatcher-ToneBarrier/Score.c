//
//  Score.c
//  DreamCatcher-ToneBarrier
//
//  Created by James Bush on 9/11/20.
//

#include <assert.h>
#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "math.h"


#include "New.h"
#include "New.r"

#include "String.h"

#include "Score.h"

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
typedef struct Aleatory Aleatory;


struct Score
{
    const void * class;
    char * title;
    struct Tempo
    {
        int session_period;                 // 8 hours
        int event_frequency;                // 3 minutes
        double event_duration;              // 30 seconds
        double tone_pair_duration;          // 2 seconds
    } * _Nonnull tempo;
    
    struct Aleatory
    {
        __unsafe_unretained double (^mix_chords)(unsigned int chord_count,
                                                 struct Chord * chord_array[],
                                                 struct Amplitude * amplitude,
                                                 double sample_rate);
        struct Amplitude * amplitude;
            struct Tone
            {
                double duration_min;
                double duration_max;
                double (^duration_split)(unsigned int frame_count,
                                         long random,
                                         unsigned int duration_min,
                                         unsigned int duration_max);
            } * _Nonnull tone;
            
            unsigned int chord_count;
            struct Chord
            {
                struct Amplitude * amplitude;

                __unsafe_unretained double (^mix_notes)(double sample_rate,
                                                        double * root,
                                                        struct Harmony * harmony,
                                                        unsigned int note_count,
                                                        struct Note * note_array,
                                                        struct Amplitude * amplitude);
                double root;
                struct Harmony
                {
                    unsigned int ratio_index : 2;
                    __unsafe_unretained double (^harmonize_note)(int min_key,
                                                                 int max_key,
                                                                 double * root_frequency,
                                                                 unsigned int ratio_index, // the next ratio to return
                                                                 unsigned int ratio_count, // the modulus for ratio_index
                                                                 double * ratio_array);
                    double ratio_count;
                    Ratio * ratio_array;
                } * _Nonnull harmony;
                
                unsigned int note_count;
                struct Note
                {
                    struct Amplitude * amplitude;
                    double frequency;
                    double sine_phase;
                    double phase_increment;
                    __unsafe_unretained double (^ _Nonnull cycle)(double sample_rate,
                                                                  double frequency,
                                                                  double * _Nonnull sine_phase,
                                                                  double * _Nonnull phase_increment);
                    __unsafe_unretained double (^ _Nonnull sample)(double * _Nonnull sine_phase,
                                                                   double * _Nonnull phase_increment);
                } * _Nonnull note_array[];
                
            } * _Nonnull chord_array[];
        
    } * _Nonnull aleatory;
};


double (^Harmonize)(struct Chord *, int, int) = ^ double (struct Chord * chord, int min_key, int max_key) {
                    if (chord->harmony->ratio_index == 0)
                    {
                        chord->root = ^ double (double * frequency, long random) {
                            *frequency = pow(1.059463094f, random) * 440.0;// binexp(1.059463094f, random) * 440.0;
                            return *frequency;
                        } (&chord->root, ^ long (long random, int n, int m) {
                            long result = random % abs(fmin(m, n) - fmax(m, n)) + fmin(m, n);
                            return result;
                        } (random(), min_key, max_key));
                    }
    
    //    //            printf("%d\t\t%f\t\t%f\t\t%f\n", dyad->ratio_index, dyad->root_frequency, ratio[dyad->ratio_index], dyad->root_frequency * ratio[dyad->ratio_index]);
    //
    //                double frequency = chord->root * chord->harmony->ratio_array[chord->harmony->ratio_index];
    //
    //    chord->harmony->ratio_index++;\
    //
    //                return frequency;
    return 1.0;
};

// TO-DO: Add scaling and ring modulation blocks
double (^mix_chords_sinusoids_sum)(unsigned int, struct Chord * [], struct Amplitude *, double) = ^(unsigned int chord_count, struct Chord * chord_array[], struct Amplitude * amplitude, double sample_rate)
{
    for (unsigned int chord = 0; chord < chord_count; chord++)
    {
        for (unsigned int note = 0; note < chord_array[chord]->note_count; note++)
        {
            chord_array[chord]->note_array[note]->sine_phase = 0.0;
            chord_array[chord]->note_array[note]->phase_increment = chord_array[chord]->harmony->harmonize_note(-8, 24, &chord_array[chord]->root, chord_array[chord]->harmony->ratio_index, chord_array[chord]->harmony->ratio_count, &chord_array[chord]->harmony->ratio_array[chord_array[chord]->harmony->ratio_index]) * (2.0 * M_PI) / sample_rate;

        }

//        double ds = self->duration_split(frame_count, random(), 11025, 77175);
//        double amplitude_step = 1.0 / frame_count;
//        double amplitude = 0.0;
//
//        for (int buffer_index = 0; buffer_index < frame_count; buffer_index++) {
//            double damped_sine_wave = pow(E_NUM, -1.0 * amplitude) * (cosf(2.0 * M_PI * amplitude));
//            float_channel_data[channel_index][buffer_index] = damped_sine_wave * ((buffer_index > ds)
//            ? (sinf(sin_phase) + sinf(sin_phase_dyad) + sinf(sin_phase_bass) + sinf(sin_phase_dyad_bass)) * (1.0 * sinf(sin_phase_tremolo))
//            : amplitude * (sinf(sin_phase_aux) + sinf(sin_phase_dyad_aux) + sinf(sin_phase_aux_bass) + sinf(sin_phase_dyad_aux_bass)) * (1.0 * sinf(sin_phase_tremolo_aux)));
//
//            sin_phase += sin_increment;
//            sin_phase_dyad += sin_increment_dyad;
//            sin_phase_tremolo += sin_increment_tremolo;
//            sin_phase_aux += sin_increment_aux;
//            sin_phase_dyad_aux += sin_increment_aux_dyad;
//            sin_phase_tremolo_aux += sin_increment_tremolo_aux;
//
//            sin_phase_bass += sin_increment_bass;
//            sin_phase_dyad_bass += sin_increment_dyad_bass;
//            sin_phase_tremolo_bass += sin_increment_tremolo_bass;
//            sin_phase_aux_bass += sin_increment_aux_bass;
//            sin_phase_dyad_aux_bass += sin_increment_aux_dyad_bass;
//            sin_phase_tremolo_aux_bass += sin_increment_tremolo_aux_bass;
//
//            amplitude += amplitude_step;
//        }
    }
    return 1.0;
};


double (^_Nonnull(^ _Nonnull set_mix_chords)(void))(unsigned int, struct Chord * [], struct Amplitude *, double) = ^(void) {
    return mix_chords_sinusoids_sum;
};

static void * Score_ctor (void * _self, va_list * app)
{
    struct Score * self = _self;
    const char * title = va_arg(* app, const char *);
    self -> title = malloc(strlen(title) + 1);
    strcpy(self -> title, title);
    assert(self -> title);
    
    int session_period = va_arg(* app, int);
    int event_frequency = va_arg(* app, int);
    double event_duration = va_arg(* app, double);
    int tone_pair_duration = va_arg(* app, int);
    
    struct Tempo * tempo = malloc(sizeof(struct Tempo));
    tempo -> tone_pair_duration = tone_pair_duration;
    tempo -> event_duration = event_duration;
    tempo -> event_frequency = event_frequency;
    tempo -> session_period = session_period;
    
    assert((tempo -> tone_pair_duration == 2)   &&
           (tempo -> event_duration      = 30)  &&
           (tempo -> event_frequency     = 120) &&
           (tempo -> session_period      = 28800));
    
    self -> tempo = tempo;
    
    struct Aleatory * aleatory = malloc(sizeof(struct Aleatory));
    
    
    return self;
}

static void *Score_dtor (void * _self)
{
    struct Score * self = _self;
//    free(self -> title), self -> title = 0;
    delete(self -> title);
    free(self->tempo), self->tempo = 0;
    
    return self;
}

static void * Score_clone (const void * _self)
{    const struct Score * self = _self;

    return new(Score, self -> tempo);
}

static int Score_differ (const void * _self, const void * _b)
{
    const struct Score * self = _self;
    const struct Score * b = _b;

    if (Score == b)
        return 0;
    if (! b || b -> class != Score)
        return 1;
    
    return strcmp(self -> title, b -> title);
}

static size_t Score_sizeof (const void * _self)
{
    const struct Score * self = _self;
    
    return sizeof(self);
}


static const struct Class _Score =
{
    sizeof(struct Score),
    Score_ctor, Score_dtor,
    Score_clone, Score_differ,
    Score_sizeof
};

const void * Score = & _Score;
