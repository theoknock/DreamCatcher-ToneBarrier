//
//  AppDelegate.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 8/26/20.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMSync.h>

#define AppServices ((AppDelegate *)[[UIApplication sharedApplication] delegate])

typedef NS_ENUM(NSUInteger, LogTextAttributes) {
    LogTextAttributes_Error,
    LogTextAttributes_Success,
    LogTextAttributes_Operation,
    LogTextAttributes_Event
};

typedef CMTime(^CurrentTime)(void);
typedef void(^LogEvent)(NSString *context, NSString *entry, LogTextAttributes logTextAttributes, dispatch_block_t block);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) dispatch_queue_t loggerQueue;
@property (strong, nonatomic) dispatch_queue_t taskQueue;
@property (copy, nonatomic) LogEvent logEvent;
@property (copy, nonatomic) CurrentTime currentTime;

@end
