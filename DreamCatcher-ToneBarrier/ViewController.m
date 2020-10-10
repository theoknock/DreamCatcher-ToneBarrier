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

#import <mach/mach.h>


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    CAGradientLayer * gradient = [CAGradientLayer new];
    gradient.frame = self.logContainerView.bounds;
    [gradient setColors:@[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor]];
    self.logContainerView.layer.mask = gradient;
    
    self.log_view_gesture_recognizer = [[LogViewGestureRecognizer alloc] init];
    [self.log_view_gesture_recognizer setDelegate:self.log_view_gesture_recognizer];
    dispatch_source_set_event_handler(LogViewDataSource.logData.main_view_touch_recognizer_dispatch_source, ^{
        struct MainViewTouchRecognizerLocationX * data = dispatch_get_context(LogViewDataSource.logData.main_view_touch_recognizer_dispatch_source);
        float alpha = (1.0 - (data->x / CGRectGetWidth(self.view.frame)));
        printf("alpha = %f\n", alpha);
        
        [self.blurView setAlpha:alpha];
        [self.logView setAlpha:alpha];
    });
    [self.view addGestureRecognizer:self.log_view_gesture_recognizer];
    
    dispatch_source_set_event_handler(LogViewDataSource.logData.log_view_dispatch_source, ^{
        [self.logView setAttributedText:[LogViewDataSource.logData logAttributedText]];
    });
    
    dispatch_resume(LogViewDataSource.logData.log_view_dispatch_source);
}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    BOOL isToneBarrierScorePlaying = [ToneBarrierScorePlayer.sharedPlayer play];
    [sender setImage:([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning] && isToneBarrierScorePlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
}

- (IBAction)showLogView:(UIScreenEdgePanGestureRecognizer *)sender {
    float alpha = (1.0 - ([sender locationInView:self.view].x / CGRectGetWidth(self.view.frame)));
    [self.blurView setAlpha:alpha];
    [self.logView setAlpha:alpha * 0.5];
}

@end
