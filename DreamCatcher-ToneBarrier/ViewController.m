//
//  ViewController.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ToneBarrierScorePlayer.h"
#import "ToneBarrierScoreDispatchObjects.h"
#import "LogEvent.h"

@interface ViewController ()
{
    NSDictionary *_eventTextAttributes, *_operationTextAttributes, *_errorTextAttributes, *_successTextAttributes;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_source_set_event_handler(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source, ^{
        LogEntry log_entry = dispatch_get_context(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source);
        
        NSMutableAttributedString *log = [[NSMutableAttributedString alloc] initWithAttributedString:[self.logTextView attributedText]];
        NSDictionary<NSAttributedStringKey,id> * logEntryAttributes = logEntryAttributeStyle(log_entry->log_entry_attribute);
        NSAttributedString *entry = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", timeString(log_entry->entry_date)] attributes:logEntryAttributes];
        [log appendAttributedString:entry];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.logTextView setAttributedText:log];
        });
        
        free(log_entry), log_entry = 0;
        
    });
        
    dispatch_resume(ToneBarrierScoreDispatchObjects.sharedDispatchObjects.tone_barrier_dispatch_source);
}

/*
 __block NSMutableAttributedString *log = [[NSMutableAttributedString alloc] init];
 
 [logEntries enumerateObjectsUsingBlock:^(NSValue * _Nonnull logEntryValue, NSUInteger idx, BOOL * _Nonnull stop) {
     LogEntry log_entry;
     [logEntryValue getValue:&log_entry];
     NSDictionary<NSAttributedStringKey,id> * logEntryAttributes = logEntryAttributeStyle(log_entry->log_entry_attribute);
     NSAttributedString *time_s = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", timeString(log_entry->entry_date)] attributes:logEntryAttributes];
     [log appendAttributedString:time_s];
     printf("idx %lu\n", idx);
 }];
 
 
 
 //        NSDictionary<NSAttributedStringKey,id> * logEntryAttributes = logEntryAttributeStyle(log_entry->log_entry_attribute);
 //        NSMutableAttributedString *log = [[NSMutableAttributedString alloc] initWithAttributedString:[logView attributedText]];
 //        NSAttributedString *time_s = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", timeString(log_entry->entry_date)] attributes:logEntryAttributes];
 //        NSAttributedString *context_s = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:log_entry->context] attributes:logEntryAttributes];
 //        NSAttributedString *entry_s = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:log_entry->entry] attributes:logEntryAttributes];
 //        [log appendAttributedString:time_s];
 //        [log appendAttributedString:context_s];
 //        [log appendAttributedString:entry_s];
 [logView setAttributedText:log]; // To-Do: display every entry in logEntries
 */

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


- (IBAction)hidelogTextView:(UITapGestureRecognizer *)sender {
    [UIView animateWithDuration:1.0 animations:^{
        [self.logTextView setAlpha:(self.logTextView.alpha == 0.0) ? 1.0 : 0.0];
    }];
}

- (void)displayYHeightForFrameBoundsRect:(CGRect)rect withLabel:(NSString *)label
{
    NSLog(@"%@", [NSString stringWithFormat:@"y:\t%f\t\th:\t%f\t\t\ty:\t%f\t\th:\t%f\t\t(%@)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height, label]);
}

- (IBAction)playToneBarrierScore:(UIButton *)sender forEvent:(UIEvent *)event {
    BOOL isToneBarrierScorePlaying = [ToneBarrierScorePlayer.sharedPlayer play];
    [sender setImage:([ToneBarrierScorePlayer.sharedPlayer.audioEngine isRunning] && isToneBarrierScorePlaying) ? [UIImage systemImageNamed:@"stop"] : [UIImage systemImageNamed:@"play"] forState:UIControlStateNormal];
}

@end
