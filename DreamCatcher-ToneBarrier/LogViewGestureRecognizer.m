//
//  LogViewGestureRecognizer.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import "LogViewGestureRecognizer.h"
#import "LogViewDataSource.h"

@implementation LogViewGestureRecognizer
{
    BOOL isTracking;
}

- (instancetype)init
{
    if (self == [super init])
    {
        self.main_view_touch_recognizer_dispatch_queue  = dispatch_queue_create_with_target("Main View Touch Recognizer Dispatch Queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
        self.main_view_touch_recognizer_dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, self.main_view_touch_recognizer_dispatch_queue);
    }
    
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    isTracking = FALSE;
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat touch_location_x = [touch preciseLocationInView:touch.view].x;
    isTracking = (touch_location_x > (CGRectGetMaxX(touch.view.frame) - 42));
    NSLog(@"Touch location x %f %@ %f%@", touch_location_x, (isTracking) ? @">" : @"<", (CGRectGetMaxX(touch.view.frame) - 42), (isTracking) ? @"\n\nTRACKING" : @"");
    if (isTracking)
    {
        struct MainViewTouchRecognizerLocationX * main_view_touch_recognizer_location_x_context_data = malloc(sizeof(struct MainViewTouchRecognizerLocationX));
        main_view_touch_recognizer_location_x_context_data->x = touch_location_x;
        dispatch_set_context(self.main_view_touch_recognizer_dispatch_source, main_view_touch_recognizer_location_x_context_data);
        dispatch_source_merge_data(self.main_view_touch_recognizer_dispatch_source, 1);
    } else {
        
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat touch_location_x = [touch preciseLocationInView:touch.view].x;
    if (touch_location_x < (CGRectGetMaxX(touch.view.frame) - 42) &&
        touch.phase != 0 && isTracking)
    {
        //        NSLog(@"Phase == %ld\t\t%@", (long)touch.phase, (isTracking) ? @"TRACKING" : @"UNTRACKED");
        struct MainViewTouchRecognizerLocationX * main_view_touch_recognizer_location_x_context_data = malloc(sizeof(struct MainViewTouchRecognizerLocationX));
        main_view_touch_recognizer_location_x_context_data->x = touch_location_x;
        dispatch_set_context(self.main_view_touch_recognizer_dispatch_source, main_view_touch_recognizer_location_x_context_data);
        dispatch_source_merge_data(self.main_view_touch_recognizer_dispatch_source, 1);
    }
}

//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [[event allTouches] anyObject];
////    NSLog(@"Phase == %ld\t\t%@", (long)touch.phase, (isTracking) ? @"TRACKING" : @"UNTRACKED");
//    CGFloat touch_location_x = [touch preciseLocationInView:touch.view].x;
//    struct MainViewTouchRecognizerLocationX * main_view_touch_recognizer_location_x_context_data = malloc(sizeof(struct MainViewTouchRecognizerLocationX));
//    main_view_touch_recognizer_location_x_context_data->x = (touch_location_x <= (CGRectGetMinX(touch.view.frame) + 42)) ? touch_location_x : CGRectGetWidth(touch.view.frame);
//    dispatch_set_context(LogViewDataSource.logData.main_view_touch_recognizer_dispatch_source, main_view_touch_recognizer_location_x_context_data);
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return FALSE;
    } else {
        return TRUE;
    }
}

@end
