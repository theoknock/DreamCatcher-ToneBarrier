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

@end
