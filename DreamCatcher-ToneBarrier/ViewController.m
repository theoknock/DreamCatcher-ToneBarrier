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
#import "UIColor+ColorTransition.h"

#import <mach/mach.h>

#define BLUE_HUE_NORM 240.0 / 360.0
#define RED_HUE_NORM  0.0

@interface ViewController ()
{
    CGFloat color_transition_step;
}

@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.waveformImageView setTintColor:[UIColor colorWithHue:BLUE_HUE_NORM saturation:1.0 brightness:1.0 alpha:1.0]];
    
    CAGradientLayer * gradient = [CAGradientLayer new];
    gradient.frame = self.logContainerView.bounds;
    [gradient setColors:@[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor]];
    self.logContainerView.layer.mask = gradient;

    dispatch_source_set_event_handler(LogViewDataSource.logData.log_view_dispatch_source, ^{
        [self.logView setAttributedText:[LogViewDataSource.logData logAttributedText]];
    });
    dispatch_resume(LogViewDataSource.logData.log_view_dispatch_source);
    
    dispatch_source_set_event_handler(ToneBarrierScorePlayer.sharedPlayer.audio_engine_status_dispatch_source, ^{
        NSLog(@"%s", __PRETTY_FUNCTION__);
        AudioEngineStatus status = (AudioEngineStatus)dispatch_get_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_status_dispatch_source);
        [self.playButton setImage:^ UIImage * (AudioEngineStatus status)
         {
            switch (status) {
                case AudioEngineStatusPlaying:
                    return [UIImage systemImageNamed:@"stop"];
                    break;
                    
                case AudioEngineStatusStopped:
                    return [UIImage systemImageNamed:@"play"];
                    break;
                    
                case AudioEngineStatusError:
                    return [UIImage systemImageNamed:@"play.slash"];
                    break;
                    
                default:
                    return [UIImage systemImageNamed:@"play.slash"];
                    break;
            }
        } (status) forState:UIControlStateNormal];
    });
    dispatch_resume(ToneBarrierScorePlayer.sharedPlayer.audio_engine_status_dispatch_source);
}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    AudioEngineCommand command = ([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning]) ? AudioEngineCommandStop : AudioEngineCommandPlay;
    dispatch_set_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, (void *)command);
    dispatch_source_merge_data(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, 1);
}

- (void)shimmerWaveFormTint
{
    CGFloat hue, saturation, brightness, alpha;
    BOOL didGetHSBColor = [[self.waveformImageView tintColor] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    if (didGetHSBColor)
    {
        [self.waveformImageView setTintColor:[UIColor colorWithHue:(hue + (1.0 / [self.displayLink duration])) saturation:saturation brightness:brightness alpha:alpha]];
    }
//    // TO-DO: Cycle the transition (don't just loop it linearly)
//    dispatch_async(dispatch_get_main_queue(), ^{
//        // Get the current wave form symbol tint hue value
//        // increment or decrement by 1.0 / display refresh rate [CADisplayLink duration]
//        // (depends on whether current hue value is greater than or equal to red hue value or less than or equal to blue hue value)
//        [self.waveformImageView setTintColor:[UIColor interpolateHSVColorFrom:self.blue to:self.red withFraction:[self.displayLink duration]]];
//    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.displayLink) {
        [self.displayLink invalidate];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(shimmerWaveFormTint)];
    [self.displayLink setPreferredFramesPerSecond:15];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

@end
