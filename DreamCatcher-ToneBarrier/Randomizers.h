//
//  Randomizers.h
//  DreamCatcher-ToneBarrier
//
//  Created by James Bush on 9/10/20.
//

#ifndef Randomizers_h
#define Randomizers_h

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "time.h"
#include "math.h"

#include "Randomizer.h"

extern const void * _Nonnull Randomizers;

typedef struct PlayerNodes
{
    struct random_data * buf;
} PlayerNodes;

struct Randomizers
{
    int randomizer_count;
    struct Randomizer * randomizers;
};


#endif /* Randomizers_h */
