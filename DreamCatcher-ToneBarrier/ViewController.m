//
//  ViewController.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import "ViewController.h"
#import "ToneBarrierScorePlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    BOOL isToneBarrierScorePlaying = [ToneBarrierScorePlayer.sharedPlayer playWithUpdateFrequencyDurationBlock:^(NSString * _Nonnull frequencyDurationLabelText, NSUInteger labelCollectionIndex) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UILabel *)[(NSArray<UILabel *> *)self.frequencyDurationLabelOutletCollection objectAtIndex:labelCollectionIndex] setText:frequencyDurationLabelText];
        });
    }];
    [sender setImage:([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning] && isToneBarrierScorePlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
}

@end
