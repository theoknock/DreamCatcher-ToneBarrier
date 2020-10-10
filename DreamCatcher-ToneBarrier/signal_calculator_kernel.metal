//
//  signal_calculator_kernel.metal
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#include <metal_stdlib>
#include <metal_math>
using namespace metal;

kernel void signal_calculation_kernel(device const float* signal_increment,
                       device float* channel_data,
                       uint index [[thread_position_in_grid]])
{
    channel_data[index] = sin(2.0); //sin(*signal_increment);
}

