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
        struct AudioEngineStatus * audio_engine_status = dispatch_get_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_status_dispatch_source);
        [self.playButton setImage:(audio_engine_status->status == AudioEngineStatusPlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
    });
    dispatch_resume(ToneBarrierScorePlayer.sharedPlayer.audio_engine_status_dispatch_source);
}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    struct AudioEngineCommand *audio_engine_command = malloc(sizeof(struct AudioEngineCommand));
    audio_engine_command->command = ([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning]) ? AudioEngineCommandStop : AudioEngineCommandPlay;
    dispatch_set_context(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, audio_engine_command);
    dispatch_source_merge_data(ToneBarrierScorePlayer.sharedPlayer.audio_engine_command_dispatch_source, 1);
//    BOOL isPlaying = [ToneBarrierScorePlayer.sharedPlayer play];
//    [sender setImage:(isPlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
}

@end
