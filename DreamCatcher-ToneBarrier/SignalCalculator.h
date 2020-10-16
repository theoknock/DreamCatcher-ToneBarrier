//
//  SignalCalculator.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>


NS_ASSUME_NONNULL_BEGIN

@interface SignalCalculator : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (void)prepareBuffer:(float * const _Nonnull * _Nullable)buffer size:(const unsigned int)bufferSize;
- (void)sendComputeCommand;

@end

NS_ASSUME_NONNULL_END
