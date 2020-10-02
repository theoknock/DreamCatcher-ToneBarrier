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
}

#pragma mark - Log

    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self displayYHeightForFrameBoundsRect:CGRectMake(self.logTextView.frame.origin.y, self.logTextView.frame.size.height, self.logTextView.bounds.origin.y, self.logTextView.bounds.size.height)
    //         withLabel:@"START"];
    //        CGRect rect = [self.logTextView firstRectForRange:[self.logTextView textRangeFromPosition:self.logTextView.beginningOfDocument toPosition:self.logTextView.endOfDocument]];
    //        [self displayYHeightForFrameBoundsRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height) withLabel:@"First rect for range"];
    //        CGFloat heightDifference = rect.size.height - self.logTextView.bounds.size.height;
    //        NSLog(@"heightDifference\t%f", heightDifference);
    //        CGRect visibleRect = CGRectMake(rect.origin.x, rect.origin.y + heightDifference, rect.size.width, rect.size.height);
    ////        [self displayYHeightForFrameBoundsRect:CGRectMake(visibleRect.origin.x, visibleRect.origin.y, visibleRect.size.width, visibleRect.size.height) withLabel:@"Visible rect"];
    //        if (heightDifference > 0)
    //        {
    //            CGRect newRect = CGRectMake(0, heightDifference, visibleRect.size.width, self.logTextView.bounds.size.height);
    //            [self.logTextView scrollRectToVisible:newRect animated:TRUE];
    ////            NSLog(@"New rect\tx: %f, y: %f, w: %f, h: %f\n\n", newRect.origin.x, newRect.origin.y, newRect.size.width, newRect.size.height);
    //        }
    ////        [self displayYHeightForFrameBoundsRect:CGRectMake(self.logTextView.frame.origin.y, self.logTextView.frame.size.height, self.logTextView.bounds.origin.y, self.logTextView.bounds.size.height) withLabel:@"END\n\n"];
    //    });


//- (IBAction)hidelogTextView:(UITapGestureRecognizer *)sender {
//    [UIView animateWithDuration:1.0 animations:^{
//        [self.logTextView setAlpha:(self.logTextView.alpha == 0.0) ? 1.0 : 0.0];
//    }];
//}

//- (void)displayYHeightForFrameBoundsRect:(CGRect)rect withLabel:(NSString *)label
//{
//    NSLog(@"%@", [NSString stringWithFormat:@"y:\t%f\t\th:\t%f\t\t\ty:\t%f\t\th:\t%f\t\t(%@)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, label]);
//}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    BOOL isToneBarrierScorePlaying = [ToneBarrierScorePlayer.sharedPlayer play];
    [sender setImage:([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning] && isToneBarrierScorePlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
}

@end
