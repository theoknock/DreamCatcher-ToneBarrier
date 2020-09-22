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

@interface ViewController : UIViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UITextView *logView;


@end

