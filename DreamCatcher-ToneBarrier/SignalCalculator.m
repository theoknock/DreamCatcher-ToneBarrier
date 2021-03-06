//
//  SignalCalculator.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import "SignalCalculator.h"

// The number of floats in each array, and the size of the arrays in bytes.
const unsigned int arrayLength =  1 << 24;
const unsigned int bufferSize  = arrayLength * sizeof(float);

@implementation SignalCalculator
{
    id<MTLDevice> _mDevice;

    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _mAddFunctionPSO;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;

    // Buffer to hold data.
    id<MTLBuffer> _mBuffer_channel_data;
}

- (instancetype) initWithDevice: (id<MTLDevice>) device
{
    self = [super init];
    if (self)
    {
        _mDevice = device;

        NSError* error = nil;

        // Load the shader files with a .metal file extension in the project

        id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
        if (defaultLibrary == nil)
        {
            NSLog(@"Default library not found.");
            return nil;
        }

        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"signal_calculation_kernel"];
        if (addFunction == nil)
        {
            NSLog(@"signal_calculation_kernel not found");
            return nil;
        }

        // Create a compute pipeline state object.
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
        if (_mAddFunctionPSO == nil)
        {
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to created pipeline state object, error %@.", error);
            return nil;
        }

        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil)
        {
            NSLog(@"Failed to find the command queue.");
            return nil;
        }
    }

    return self;
}

- (void)prepareBuffer:(float * const _Nonnull * _Nullable)buffer size:(const unsigned int)bufferSize
{
    _mBuffer_channel_data = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
}

- (void) sendComputeCommand
{
    // Create a command buffer to hold commands.
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    assert(commandBuffer != nil);

    // Start a compute pass.
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);

    [self encodeAddCommand:computeEncoder];

    // End the compute pass.
    [computeEncoder endEncoding];

    // Execute the command.
    [commandBuffer commit];

    // Normally, you want to do other work in your app while the GPU is running,
    // but in this example, the code simply blocks until the calculation is complete.
    [commandBuffer waitUntilCompleted];

    [self verifyResults];
}

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder {

    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
//    [computeEncoder set]
//    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
//    [computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
//    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];
    
    [computeEncoder setBuffer:_mBuffer_channel_data offset:0 atIndex:1];

    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);

    // Calculate a threadgroup size.
    NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if (threadGroupSize > arrayLength)
    {
        threadGroupSize = arrayLength;
    }
    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);

    // Encode the compute command.
    [computeEncoder dispatchThreads:gridSize
              threadsPerThreadgroup:threadgroupSize];
}

- (void) generateRandomFloatData: (id<MTLBuffer>) buffer
{
    float* dataPtr = buffer.contents;

    for (unsigned long index = 0; index < arrayLength; index++)
    {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}
- (void) verifyResults
{
//    float* signal_increment = _mBufferA.contents;
    float * channel_data = _mBuffer_channel_data.contents;
//    float* result = _mBufferResult.contents;

//    for (unsigned long index = 0; index < arrayLength; index++)
//    {
//        if (result[index] != (a[index] + b[index]))
//        {
//            printf("Compute ERROR: index=%lu result=%g vs %g=a+b\n",
//                   index, result[index], a[index] + b[index]);
//            assert(result[index] == (a[index] + b[index]));
//        }
//    }
    printf("signal_increment\t==\t%f\n", *channel_data);
}

@end
