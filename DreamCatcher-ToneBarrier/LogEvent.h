//
//  LogEvent.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/18/20.
//

#ifndef LogEvent_h
#define LogEvent_h

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "time.h"
#include "math.h"

#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMSync.h>

typedef NS_ENUM(NSUInteger, LogEntryAttribute) {
    LogEntryAttributeError,     // Any error
    LogEntryAttributeSuccess,   // A successful @try
    LogEntryAttributeFailure,   // A @catch
    LogEntryAttributeOperation, // A declaration of a series of methods or a @finally
    LogEntryAttributeTransient, // An entry replaceable by subsequent transients, erased by next non-transient event
    LogEntryAttributeEvent      // A notification, user input or completion block/callback
};

typedef struct LogEntry
{
    CMTime entry_date;
    LogEntryAttribute log_entry_attribute;
    char * _Nonnull context;
    char * _Nonnull entry;
} * LogEntry;

typedef CMTime(^CurrentCMTime)(void);
static CurrentCMTime _Nonnull current_cmtime = ^ CMTime (void) {
    printf("%s\n", __PRETTY_FUNCTION__);
    
    return CMClockGetTime(CMClockGetHostTimeClock());
};

typedef NSString * _Nonnull (^StringFromTime)(CMTime);
static StringFromTime _Nonnull timeString = ^ NSString * (CMTime cm_time) {
    printf("%s\n", __PRETTY_FUNCTION__);
    
    NSString *stringFromCMTime;
    float seconds = round(CMTimeGetSeconds(cm_time));
    int hh = (int)floorf(seconds / 3600.0f);
    int mm = (int)floorf((seconds - hh * 3600.0f) / 60.0f);
    int ss = (((int)seconds) % 60);
    if (hh > 0)
    {
        stringFromCMTime = [NSString stringWithFormat:@"%02d:%02d:%02d", hh, mm, ss];
    }
    else
    {
        stringFromCMTime = [NSString stringWithFormat:@"%02d:%02d", mm, ss];
    }
    return stringFromCMTime;
};

typedef NSDictionary<NSAttributedStringKey,id> * _Nonnull (^LogEntryAttributeStyle)(LogEntryAttribute);
static LogEntryAttributeStyle _Nonnull logEntryAttributeStyle = ^ NSDictionary<NSAttributedStringKey,id> * (LogEntryAttribute logEntryAttribute)
{
    printf("%s\n", __PRETTY_FUNCTION__);
    
    NSDictionary<NSAttributedStringKey,id> *logEntryAttributeStyle;
    switch (logEntryAttribute) {
        case LogEntryAttributeOperation:
            logEntryAttributeStyle = ^ NSDictionary * (void) {
                NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
                centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
                return @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.87 blue:0.19 alpha:1.0],
                                                                NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
                                                                NSParagraphStyleAttributeName:centerAlignedParagraphStyle};
            }();
            break;
            
        default:
            logEntryAttributeStyle = ^ NSDictionary * (void) {
                NSMutableParagraphStyle *leftAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
                leftAlignedParagraphStyle.alignment = NSTextAlignmentLeft;
                return @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.87 green:0.5 blue:0.0 alpha:1.0],
                                                                NSFontAttributeName:[UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
                                                                NSParagraphStyleAttributeName:leftAlignedParagraphStyle};
            }();
            break;
    }

    return logEntryAttributeStyle;
};


//static dispatch_queue_t _Nonnull loggerQueue;
//static dispatch_queue_t _Nonnull taskQueue;

//typedef void (^LogEventCompletionBlock)(NSValue * _Nonnull , NSMutableOrderedSet<NSValue *> *_Nonnull, UITextView * _Nonnull);
//static LogEventCompletionBlock _Nonnull logEventCompletionBlock = ^(NSValue * logEventValue, NSMutableOrderedSet<NSValue *> * logEntries, UITextView * _Nonnull logView)
//{
//    printf("%s\n", __PRETTY_FUNCTION__);
//    
////    dispatch_async(loggerQueue, ^{
//        // To-Do: either add new value and replace transient values (at end) or add new transient and leave transient values
//        [logEntries addObject:logEventValue];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            LogEntry log_entry;
//            [logEventValue getValue:&log_entry];
//            
//            NSDictionary<NSAttributedStringKey,id> * logEntryAttributes = logEntryAttributeStyle(log_entry->log_entry_attribute);
//            NSMutableAttributedString *log = [[NSMutableAttributedString alloc] initWithAttributedString:[logView attributedText]];
//            NSAttributedString *time_s = [[NSAttributedString alloc] initWithString:timeString(log_entry->entry_date) attributes:logEntryAttributes];
//            NSAttributedString *context_s = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:log_entry->context] attributes:logEntryAttributes];
//            NSAttributedString *entry_s = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:log_entry->entry] attributes:logEntryAttributes];
//            [log appendAttributedString:time_s];
//            [log appendAttributedString:context_s];
//            [log appendAttributedString:entry_s];
//            [logView setAttributedText:log]; // To-Do: display every entry in logEntries
//        });
////    });
//};

typedef void (^LogEvent)(NSMutableOrderedSet<NSValue *> *_Nonnull, UITextView * _Nonnull, char * _Nonnull, char * _Nonnull, LogEntryAttribute);
static LogEvent _Nonnull logEvent = ^ void (NSMutableOrderedSet<NSValue *> * logEntries, UITextView * _Nonnull logView, char * context, char * entry, LogEntryAttribute logEntryAttribute) {
    printf("%s\n", __PRETTY_FUNCTION__);
    
    LogEntry log_entry = calloc(1, sizeof(CMTime) + sizeof(NSUInteger));
    log_entry->entry_date = current_cmtime();
//    log_entry->context = strdup("context");
//    log_entry->entry = strdup(entry);
    log_entry->log_entry_attribute = logEntryAttribute;

    NSValue *logEntryValue = [NSValue valueWithBytes:&log_entry objCType:@encode(LogEntry)];
    [logEntries addObject:logEntryValue];
    free(log_entry), log_entry = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        LogEntry log_entry;
        [logEntryValue getValue:&log_entry];
        
        NSDictionary<NSAttributedStringKey,id> * logEntryAttributes = logEntryAttributeStyle(log_entry->log_entry_attribute);
        NSMutableAttributedString *log = [[NSMutableAttributedString alloc] initWithAttributedString:[logView attributedText]];
        NSAttributedString *time_s = [[NSAttributedString alloc] initWithString:timeString(log_entry->entry_date) attributes:logEntryAttributes];
//        NSAttributedString *context_s = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:log_entry->context] attributes:logEntryAttributes];
//        NSAttributedString *entry_s = [[NSAttributedString alloc] initWithString:[NSString stringWithUTF8String:log_entry->entry] attributes:logEntryAttributes];
        [log appendAttributedString:time_s];
//        [log appendAttributedString:context_s];
//        [log appendAttributedString:entry_s];
        [logView setAttributedText:log]; // To-Do: display every entry in logEntries
    });
    
};

#endif /* LogEvent_h */
