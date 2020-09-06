//
//  Tone.c
//  DreamCatcher-ToneBarrier
//
//  Created by James Bush on 9/6/20.
//

#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "Tone.h"

#include "new.h"
#include "Class.h"

struct Tone {
    const void * class;    /* must be first */
    char * text;
};

static void * Tone_ctor (void * _self, va_list * app)
{    struct Tone * self = _self;
    const char * text = va_arg(* app, const char *);

    self -> text = malloc(strlen(text) + 1);
    assert(self -> text);
    strcpy(self -> text, text);
    return self;
}

static void * Tone_dtor (void * _self)
{    struct Tone * self = _self;

    free(self -> text), self -> text = 0;
    return self;
}

static void * Tone_clone (const void * _self)
{    const struct Tone * self = _self;

    return new(Tone, self -> text);
}

static int Tone_differ (const void * _self, const void * _b)
{    const struct Tone * self = _self;
    const struct Tone * b = _b;

    if (self == b)
        return 0;
    if (! b || b -> class != Tone)
        return 1;
    return strcmp(self -> text, b -> text);
}

static const struct Class _Tone = {
    sizeof(struct Tone),
    Tone_ctor, Tone_dtor,
    Tone_clone, Tone_differ
};

const void * Tone = & _Tone;
