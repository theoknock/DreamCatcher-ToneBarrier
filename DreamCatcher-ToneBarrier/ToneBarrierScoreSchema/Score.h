//
//  Score.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/5/20.
//

#ifndef Score_h
#define Score_h

#include <stdio.h>

#include "Randomizer.h"

#define M_PI_PI M_PI * 2.0


extern const void * _Nonnull Score;



typedef struct Score
{
    char * title;
    struct Randomizer * randomizer;
    
} score;

struct Score * new_score (char * title,
                          struct Randomizer * randomizer);

#endif /* Score_h */
