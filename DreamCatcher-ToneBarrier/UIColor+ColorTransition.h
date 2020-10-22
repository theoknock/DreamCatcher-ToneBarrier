//
//  UIColor+ColorTransition.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/22/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (ColorTransition)

+ (UIColor *)interpolateRGBColorFrom:(UIColor *)start to:(UIColor *)end withFraction:(float)f;
+ (UIColor *)interpolateHSVColorFrom:(UIColor *)start to:(UIColor *)end withFraction:(float)f;

@end

NS_ASSUME_NONNULL_END
