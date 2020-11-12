//
//  ADSR.c
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 11/11/20.
//

#include "ADSR.h"

#include <assert.h>
#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "math.h"

struct ASDR
{
    double a;
    double d;
    double s;
    double r;
    
    double a_peak;
    double d_peak;
    
    double a_time;
    double d_time;
    double s_time;
    double r_time;
    
    // slope = (target_amplitude - initial amplitude)/(target_time - initial_time)
};


