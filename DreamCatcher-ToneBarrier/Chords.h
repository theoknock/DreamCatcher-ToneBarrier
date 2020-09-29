//
//  Chords.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/25/20.
//

#ifndef Chords_h
#define Chords_h

#include <Accelerate/Accelerate.h>

static float ratio[4][4] = {
    {1.f,   25.f / 20.f,    30.f / 20.f,    36.f / 20.f},
    {1.f,   25.f / 20.f,    30.f / 20.f,    36.f / 20.f},
    {1.f,   12.f / 10.f,    15.f / 10.f,    18.f / 10.f},
    {1.f,   10.f /  8.f,    12.f /  8.f,    15.f /  8.f}
};

struct ChordFrequencyRatio
{
    enum : unsigned int {
        ChordFrequencyRatioDefault,
        ChordFrequencyRatioSeventh,
        ChordFrequencyRatioMinorSeventh,
        ChordFrequencyRatioMajorSeventh
    } chord;
    
    struct
    {
        unsigned int chord : 2;
        unsigned int ratio : 2;
    } indices;
    
    double root;
} * chord_frequency_ratios;

//chord_frequency_ratios = (struct ChordFrequencyRatio *)malloc(sizeof(struct ChordFrequencyRatio));

#endif /* Chords_h */
