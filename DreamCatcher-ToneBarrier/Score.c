//
//  Score.c
//  DreamCatcher-ToneBarrier
//
//  Created by James Bush on 9/11/20.
//

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "New.h"
#include "New.r"

#include "String.h"

#include "Score.h"


struct Score
{
    const void * class;
    char * title;
    struct Tempo
    {
        int session_period;     // 8 hours
        int event_frequency;    // 3 minutes
        double event_duration;  // 30 seconds
        int tone_pair;          // 2 seconds
    } * _Nonnull tempo;
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
    int tone_pair = va_arg(* app, int);
    
    struct Tempo * tempo = malloc(sizeof(struct Tempo));
    tempo -> tone_pair = tone_pair;
    tempo -> event_duration = event_duration;
    tempo -> event_frequency = event_frequency;
    tempo -> session_period = session_period;
    
    assert((tempo -> tone_pair      == 2)   &&
           (tempo -> event_duration  = 30)  &&
           (tempo -> event_frequency = 120) &&
           (tempo -> session_period  = 28800));
    
    self -> tempo = tempo;
    
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
