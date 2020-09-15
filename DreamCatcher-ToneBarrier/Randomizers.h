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

// Randomizer blocks look like this
/*
 ^ double (double random, double n, double m, double gamma) { return random / RAND_MAX; } (random(), 0.25, 1.75, 1.0));
 */

// Frequency randomizer (chooses a musical note from A440)
/*
 ^ double (double random) {
     double result = pow(2.0, (random) / 12.0) * 440.0;
     return result;
 } (^ double (double random,  double n, double m, double gamma) {
     // ignore gamma for now
     // -57.0, 50.0
     double result = ((random / RAND_MAX) * (m - n)) + n;
     return ceil(result);
 } (random(), -57.0, 50.0, 1.0))
 */

// Duration randomizer
/*
 ^ double (double * tally, double *total, double random) {
     if (*tally == *total)
     {
         double duration_diff = random;//random() / RAND_MAX; // < -- placeholder for duration_randomizer->generate_distributed_random(duration_randomizer);
         *tally = *total - duration_diff;
         
         return duration_diff;
     } else {
         double duration_remainder = *tally;
         *tally = *total;
         
         return duration_remainder;
     }
 } (&tone_duration->tally, &tone_duration->total, ^ double (double random, double n, double m, double gamma) { return random / RAND_MAX; } (random(), 0.25, 1.75, 1.0)
 */

#endif /* Randomizers_h */
