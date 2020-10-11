//
//  LogViewGestureRecognizer.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


NS_ASSUME_NONNULL_BEGIN

typedef struct MainViewTouchRecognizerLocationX
{
    float x;
} MainViewTouchRecognizerLocationX;

@interface LogViewGestureRecognizer : UIGestureRecognizer <UIGestureRecognizerDelegate>

@property (strong, nonatomic) dispatch_queue_t   main_view_touch_recognizer_dispatch_queue;
@property (strong, nonatomic) dispatch_source_t  main_view_touch_recognizer_dispatch_source;


@end

NS_ASSUME_NONNULL_END
