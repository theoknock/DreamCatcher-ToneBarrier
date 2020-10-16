//
//  LogViewGestureRecognizer.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


NS_ASSUME_NONNULL_BEGIN

typedef struct LogViewGestureRecognizerLocationX
{
    float x;
} LogViewGestureRecognizerLocationX;

@interface LogViewGestureRecognizer : UIGestureRecognizer <UIGestureRecognizerDelegate>

@property (strong, nonatomic) dispatch_queue_t   log_view_gesture_recognizer_dispatch_queue;
@property (strong, nonatomic) dispatch_source_t  log_view_gesture_recognizer_dispatch_source;


@end

NS_ASSUME_NONNULL_END
