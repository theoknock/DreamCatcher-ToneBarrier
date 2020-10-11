//
//  ViewController.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ToneBarrierScorePlayer.h"
#import "LogViewDataSource.h"
#import "LogViewControllerAnimator.h"
#import "LogViewController.h"


#import <mach/mach.h>

@interface ViewController  () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) LogViewControllerAnimator *animator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAGradientLayer * gradient = [CAGradientLayer new];
    gradient.frame = self.logContainerView.bounds;
    [gradient setColors:@[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor]];
    self.logContainerView.layer.mask = gradient;
    
//    _animator = [[LogViewControllerAnimator alloc] init];
//
//    [self.logViewControllerTapGestureRecognizer setDelegate:self];
//    [self.view addGestureRecognizer:self.logViewControllerTapGestureRecognizer];
//
//    self.log_view_gesture_recognizer = [[LogViewGestureRecognizer alloc] init];
//    [self.log_view_gesture_recognizer setDelegate:self.log_view_gesture_recognizer];
//    dispatch_source_set_event_handler(self.log_view_gesture_recognizer.main_view_touch_recognizer_dispatch_source, ^{
//        struct MainViewTouchRecognizerLocationX * data = dispatch_get_context(self.log_view_gesture_recognizer.main_view_touch_recognizer_dispatch_source);
//        float alpha = (1.0 - (data->x / CGRectGetWidth(self.view.frame)));
//        printf("alpha = %f\n", alpha);
//
//        [self.blurView setAlpha:alpha];
//        [self.logView setAlpha:alpha];
//    });
//    dispatch_resume(self.log_view_gesture_recognizer.main_view_touch_recognizer_dispatch_source);
//    [self.view addGestureRecognizer:self.log_view_gesture_recognizer];
    
    dispatch_source_set_event_handler(LogViewDataSource.logData.log_view_dispatch_source, ^{
        [self.logView setAttributedText:[LogViewDataSource.logData logAttributedText]];
    });
    
    dispatch_resume(LogViewDataSource.logData.log_view_dispatch_source);
}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    BOOL isToneBarrierScorePlaying = [ToneBarrierScorePlayer.sharedPlayer play];
    [sender setImage:([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning] && isToneBarrierScorePlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        return TRUE;
    } else {
        return FALSE;
    }
}

- (IBAction)presentAction:(id)sender {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    LogViewController *detailVC = [[LogViewController alloc] init];
    detailVC.modalPresentationStyle = UIModalPresentationCustom;//设置展示样式,包含了modalTransitionStyle的自定义
//    secondVC.transitioningDelegate = self.transition;//此协议用于实现自定义UIPresentationController
    
    detailVC.transitioningDelegate = self;//此协议用于实现自定义UIPresentationController

    //2.  设置动画样式
    
//    secondVC.modalTransitionStyle = self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:detailVC animated:YES completion:^{
    }];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                            presentingController:(UIViewController *)presenting
                                                                                sourceController:(UIViewController *)source{
    _animator.presenting = YES;
    return _animator;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    
    _animator.presenting = NO;
    return _animator;
}


@end
