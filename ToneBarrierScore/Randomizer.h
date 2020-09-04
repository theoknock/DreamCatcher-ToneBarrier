//
//  Randomizer.h
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

// defines the properties, functions and substructs members of the Randomizer struct
// allocates memory for the Randomizer struct, its members and its substructs and...
// ...initializes its values
// provides accessor functions for setting/getting values of its members (where applicable)s

#ifndef Randomizer_h
#define Randomizer_h

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "RandomSource.h"
#include "RandomDistributor.h"

extern const void * Randomizer;

typedef struct Randomizer
{
    struct RandomDistributor * distributor;
    double (^math_operation_block)(double, double);
} randomizer;

struct Randomizer * new_randomizer (struct RandomSource *,
                         struct RandomDistributor *);

#endif /* Randomizer_h */
