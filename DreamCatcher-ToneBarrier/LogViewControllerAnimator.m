//
//  LogViewControllerAnimator.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import "LogViewControllerAnimator.h"

@implementation LogViewControllerAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [transitionContext containerView].contentMode = UIViewContentModeCenter;
    // TO-DO: insert view transition animations
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^ {
        toViewController.view.alpha = 1;
        fromViewController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [transitionContext containerView].transform = CGAffineTransformMakeScale(0.9, 0.9);
        
    } completion:^(BOOL finished) {
        if (_presenting) {
            
            [[transitionContext containerView] addSubview:toViewController.view];
            [[transitionContext containerView] bringSubviewToFront:toViewController.view];
        }else{
            
            [transitionContext containerView].transform = CGAffineTransformIdentity;
        }
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (UIImage *)screenShortOnView:(UIView *)view{
    
    // define the size and grab a UIImage from it
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    return screengrab;
}

- (UIImage *)screenShorture{
    
//    // create graphics context with screen size
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    UIGraphicsBeginImageContext(screenRect.size);
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    [[UIColor blackColor] set];
//    CGContextFillRect(ctx, screenRect);
//    // grab reference to our window
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    // transfer content into our context
//    [window.layer renderInContext:ctx];
//    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
