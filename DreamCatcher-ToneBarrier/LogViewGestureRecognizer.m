//
//  LogViewGestureRecognizer.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import "LogViewGestureRecognizer.h"
#import "LogViewDataSource.h"

@implementation LogViewGestureRecognizer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    // get location (must be within 21 (?) points of right or left edge to be "recognized" as a swipe intended to display/hide the log view)
    // send location to the dispatch_source context
//    dispatch_source_merge_data(self.main_view_touch_recognizer_dispatch_source, 1);
    struct MainViewTouchRecognizerLocationX *main_view_touch_recognizer_location_x_context_data = malloc(sizeof(struct MainViewTouchRecognizerLocationX));
    UITouch *touch = [[event allTouches] anyObject];
    main_view_touch_recognizer_location_x_context_data->x = [touch preciseLocationInView:touch.view].x;
    dispatch_set_context(LogViewDataSource.logData.main_view_touch_recognizer_dispatch_source, main_view_touch_recognizer_location_x_context_data);
    dispatch_source_merge_data(LogViewDataSource.logData.main_view_touch_recognizer_dispatch_source, 1);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return FALSE;
//        NSLog(@"Touch view == %@", [touch.view description]);
    } else {
        return TRUE;
    }
}

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    for (UITouch *touch in touches)
//    {
//        if (self.state == UIGestureRecognizerStateBegan)
//        {
//            struct MainViewTouchRecognizerLocationX *main_view_touch_recognizer_location_x_context_data = malloc(sizeof(struct MainViewTouchRecognizerLocationX));
//            main_view_touch_recognizer_location_x_context_data->x = [touch preciseLocationInView:touch.view].x;
//            dispatch_set_context(LogViewDataSource.logData.main_view_touch_recognizer_dispatch_source, main_view_touch_recognizer_location_x_context_data);
//            dispatch_source_merge_data(LogViewDataSource.logData.main_view_touch_recognizer_dispatch_source, 1);
//        }
//    }
//}

@end
