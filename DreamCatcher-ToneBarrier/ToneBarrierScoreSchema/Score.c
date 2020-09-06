//
//  Score.c
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/5/20.
//

#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "Score.h"


struct Score * new_score (char * title,
                          struct Randomizer * randomizer)
{
    struct Score * score = malloc(sizeof(struct Score));
    
    score->title = malloc(strlen(title) + 1);
    assert(score->title);
    strcpy(score->title, title);
    
    assert(score);
    
    return score;
}
