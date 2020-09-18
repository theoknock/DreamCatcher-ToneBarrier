//
//  ViewController.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ToneBarrierScorePlayer.h"

@interface ViewController ()
{
    NSDictionary *_eventTextAttributes, *_operationTextAttributes, *_errorTextAttributes, *_successTextAttributes;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self textStyles];
}

- (void)textStyles
{
    NSMutableParagraphStyle *leftAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    leftAlignedParagraphStyle.alignment = NSTextAlignmentLeft;
    _operationTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.87 green:0.5 blue:0.0 alpha:1.0],
                        NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium]};
    
    NSMutableParagraphStyle *fullJustificationParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    fullJustificationParagraphStyle.alignment = NSTextAlignmentJustified;
    _errorTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.91 green:0.28 blue:0.5 alpha:1.0],
                                 NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium]};
    
    NSMutableParagraphStyle *rightAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    rightAlignedParagraphStyle.alignment = NSTextAlignmentRight;
    _eventTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.54 blue:0.87 alpha:1.0],
                                    NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
                                    NSParagraphStyleAttributeName: rightAlignedParagraphStyle};
    
    NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
    _successTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.87 blue:0.19 alpha:1.0],
                                NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
                                NSParagraphStyleAttributeName: rightAlignedParagraphStyle};
    }

static NSString *stringFromCMTime(CMTime time)
{
    NSString *stringFromCMTime;
    float seconds = round(CMTimeGetSeconds(time));
    int hh = (int)floorf(seconds / 3600.0f);
    int mm = (int)floorf((seconds - hh * 3600.0f) / 60.0f);
    int ss = (((int)seconds) % 60);
    if (hh > 0)
    {
        stringFromCMTime = [NSString stringWithFormat:@"%02d:%02d:%02d", hh, mm, ss];
    }
    else
    {
        stringFromCMTime = [NSString stringWithFormat:@"%02d:%02d", mm, ss];
    }
    return stringFromCMTime;
}

- (void)log:(NSString *)context entry:(NSString *)entry time:(CMTime)time textAttributes:(NSUInteger)logTextAttributes
{
    NSDictionary *attributes;
    switch (logTextAttributes) {
        case LogTextAttributes_Event:
            attributes = _eventTextAttributes;
            break;
        case LogTextAttributes_Operation:
            attributes = _operationTextAttributes;
            break;
        case LogTextAttributes_Success:
            attributes = _successTextAttributes;
            break;
        case LogTextAttributes_Error:
            attributes = _errorTextAttributes;
            break;
        default:
            attributes = _errorTextAttributes;
            break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self displayYHeightForFrameBoundsRect:CGRectMake(self.logTextView.frame.origin.y, self.logTextView.frame.size.height, self.logTextView.bounds.origin.y, self.logTextView.bounds.size.height)
//         withLabel:@"START"];
        NSMutableAttributedString *log = [[NSMutableAttributedString alloc] initWithAttributedString:[self.logTextView attributedText]];
        NSAttributedString *time_s = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n%@", stringFromCMTime(time)] attributes:attributes];
        NSAttributedString *context_s = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", context] attributes:attributes];
        NSAttributedString *entry_s = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", entry] attributes:attributes];
        [log appendAttributedString:time_s];
        [log appendAttributedString:context_s];
        [log appendAttributedString:entry_s];
        [self.logTextView setAttributedText:log];
        
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
    });
}


- (IBAction)hidelogTextView:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:1.0 animations:^{
        [[(ViewController *)(AppServices.window.rootViewController.childViewControllers.firstObject) logTextView]
         setAlpha:([(ViewController *)(AppServices.window.rootViewController.childViewControllers.firstObject) logTextView].alpha == 0.0) ? 1.0 : 0.0];
    }];
}

- (void)displayYHeightForFrameBoundsRect:(CGRect)rect withLabel:(NSString *)label
{
    NSLog(@"%@", [NSString stringWithFormat:@"y:\t%f\t\th:\t%f\t\t\ty:\t%f\t\th:\t%f\t\t(%@)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, label]);
}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    BOOL isToneBarrierScorePlaying = [ToneBarrierScorePlayer.sharedPlayer playWithUpdateFrequencyDurationBlock:^(NSString * _Nonnull frequencyDurationLabelText, NSUInteger labelCollectionIndex) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AppServices.logEvent([NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__],
                                 frequencyDurationLabelText, LogTextAttributes_Error, ^() {
                                       
                   });
            [(UILabel *)[(NSArray<UILabel *> *)self.frequencyDurationLabelOutletCollection objectAtIndex:labelCollectionIndex] setText:frequencyDurationLabelText];
        });
    }];
    [sender setImage:([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning] && isToneBarrierScorePlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
}

@end
