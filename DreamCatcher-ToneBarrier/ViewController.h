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

#import "ToneBarrierScorePlayer.h"
#import "LogViewGestureRecognizer.h"

@interface ViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIView *logContainerView;
@property (weak, nonatomic) IBOutlet UITextView *logView;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

@property (strong, nonatomic) LogViewGestureRecognizer *log_view_gesture_recognizer;


@end

