//
//  ViewController.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMSync.h>
#import <Foundation/Foundation.h>

#import "LogEvent.h"
#import "ToneBarrierScorePlayer.h"

@interface ViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) IBOutlet UITextView *logTextView;


@end

