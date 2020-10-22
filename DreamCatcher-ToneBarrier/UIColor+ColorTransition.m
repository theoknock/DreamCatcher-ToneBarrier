//
//  UIColor+ColorTransition.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/22/20.
//

#import "UIColor+ColorTransition.h"

@implementation UIColor (ColorTransition)

+ (UIColor *)interpolateRGBColorFrom:(UIColor *)start to:(UIColor *)end withFraction:(float)f {

    f = MAX(0, f);
    f = MIN(1, f);

    const CGFloat *c1 = CGColorGetComponents(start.CGColor);
    const CGFloat *c2 = CGColorGetComponents(end.CGColor);

    CGFloat r = c1[0] + (c2[0] - c1[0]) * f;
    CGFloat g = c1[1] + (c2[1] - c1[1]) * f;
    CGFloat b = c1[2] + (c2[2] - c1[2]) * f;
    CGFloat a = c1[3] + (c2[3] - c1[3]) * f;

    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)interpolateHSVColorFrom:(UIColor *)start to:(UIColor *)end withFraction:(float)f {

    f = MAX(0, f);
    f = MIN(1, f);

    CGFloat h1,s1,v1,a1;
    [start getHue:&h1 saturation:&s1 brightness:&v1 alpha:&a1];

    CGFloat h2,s2,v2,a2;
    [end getHue:&h2 saturation:&s2 brightness:&v2 alpha:&a2];

    CGFloat h = h1 + (h2 - h1) * f;
    CGFloat s = s1 + (s2 - s1) * f;
    CGFloat v = v1 + (v2 - v1) * f;
    CGFloat a = a1 + (a2 - a1) * f;

    return [UIColor colorWithHue:h saturation:s brightness:v alpha:a];
}

@end
