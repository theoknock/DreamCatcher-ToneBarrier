//
//  LogViewDataSource.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/20/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, LogEntryAttributeStyle) {
    LogEntryAttributeStyleError,     // Any error
    LogEntryAttributeStyleSuccess,   // A successful @try
    LogEntryAttributeStyleFailure,   // A @catch
    LogEntryAttributeStyleOperation, // A declaration of a series of methods or a @finally
    LogEntryAttributeStyleTransient, // An entry replaceable by subsequent transients, erased by next non-transient event
    LogEntryAttributeStyleEvent      // A notification, user input or completion block/callback
};

typedef struct MainViewTouchRecognizerLocationX
{
    float x;
} MainViewTouchRecognizerLocationX;

@interface LogViewDataSource : NSObject

+ (nonnull LogViewDataSource *)logData;

- (void)addLogEntryWithTitle:(NSString *)title entry:(NSString *)entry attributeStyle:(LogEntryAttributeStyle)style;
- (NSAttributedString *)logAttributedText;

@property (strong, nonatomic) dispatch_queue_t log_view_dispatch_queue;
@property (strong, nonatomic) dispatch_source_t log_view_dispatch_source;

@property (strong, nonatomic) dispatch_queue_t   main_view_touch_recognizer_dispatch_queue;
@property (strong, nonatomic) dispatch_source_t  main_view_touch_recognizer_dispatch_source;


@end

NS_ASSUME_NONNULL_END
