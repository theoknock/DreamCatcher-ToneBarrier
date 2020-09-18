//
//  ViewController.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ToneBarrierScorePlayer.h"

@interface ViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *node1ChannelLLabel;
@property (weak, nonatomic) IBOutlet UILabel *node1ChannelRLabel;
@property (weak, nonatomic) IBOutlet UILabel *node2ChannelLLabel;
@property (weak, nonatomic) IBOutlet UILabel *node2ChannelRLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *frequencyDurationLabelOutletCollection;

@property (strong, nonatomic) IBOutlet UITextView *logTextView;
- (void)log:(NSString *)context entry:(NSString *)entry time:(CMTime)time textAttributes:(NSUInteger)logTextAttributes;


@end

