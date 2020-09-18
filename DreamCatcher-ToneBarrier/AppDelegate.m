//
//  AppDelegate.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

CMTime(^currentTime)(void) = ^ CMTime (void) {
    return CMClockGetTime(CMClockGetHostTimeClock());
};


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _loggerQueue = dispatch_queue_create_with_target("Logger queue", DISPATCH_QUEUE_SERIAL, dispatch_get_main_queue());
    _taskQueue = dispatch_queue_create_with_target("Task queue", DISPATCH_QUEUE_SERIAL, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    AppServices.logEvent([NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__], @"Initializing network service...", LogTextAttributes_Operation, ^() {
        
    });
    
    return YES;
}

#pragma mark - Log


- (LogEvent)logEvent
{
    return ^(NSString *context, NSString *entry, LogTextAttributes logTextAttributes, dispatch_block_t block) {
        dispatch_async(dispatch_get_main_queue(), block);
        
        dispatch_async(self->_loggerQueue, ^{
            [((ViewController *)self.window.rootViewController.childViewControllers.firstObject) log:context entry:entry time:currentTime() textAttributes:(NSUInteger)logTextAttributes];
        });
        BOOL wasHidden = ([[(ViewController *)(self.window.rootViewController.childViewControllers.firstObject) logTextView] alpha] < 1.0) ? TRUE : FALSE;
        if (wasHidden)
        {
            [UIView animateWithDuration:0.1 animations:^{
                [[(ViewController *)(self.window.rootViewController.childViewControllers.firstObject) logTextView] setAlpha:1.0];
            } completion:^(BOOL finished) {
//                if (wasHidden)
                    [UIView animateWithDuration:0.1 delay:3.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [[(ViewController *)(self.window.rootViewController.childViewControllers.firstObject) logTextView] setAlpha:0.0];
                    } completion:^(BOOL finished) {
                        // save and/or transmit user log here
                    }];
            }];
        }
    };
}



#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
