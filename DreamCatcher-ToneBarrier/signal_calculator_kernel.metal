//
//  signal_calculator_kernel.metal
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#include <metal_stdlib>
#include <metal_math>
using namespace metal;

kernel void signal_calculation_kernel(device const float * frequency,
                                      device const float * sample_rate,
                                      device float * channel_data,
                                      uint index [[thread_position_in_grid]])
{
    float time = (float)index / *sample_rate;
    channel_data[index] = sin(*frequency * M_PI_F * time);
}

