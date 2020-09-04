//
//  Randomizer.c
//  ToneBarrierScore
//
//  Created by Xcode Developer on 9/2/20.
//

#include "Randomizer.h"

struct Randomizer * new_randomizer (struct RandomSource * source,
                         struct RandomDistributor * distributor)
{
    struct Randomizer * randomizer = malloc(sizeof(struct Randomizer) +
                                            sizeof(struct RandomSource) +
                                            sizeof(struct RandomDistributor));
    
    assert(randomizer);
    
    return randomizer;
}
