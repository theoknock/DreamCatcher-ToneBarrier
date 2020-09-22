//
//  LogViewDataSource.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/20/20.
//

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdlib.h>
#include <assert.h>

#include "time.h"
#include "math.h"

#import <CoreMedia/CMTime.h>
#import <CoreMedia/CMSync.h>

#import <pthread.h> // for pthread_rwlock_init

#import "LogViewDataSource.h"

typedef struct LogEntry
{
    char datestamp[20];
    char timestamp[20];
    CMTime entry_date;
    LogEntryAttributeStyle log_entry_attribute_style;
    char * title;
    char * entry;
    __unsafe_unretained NSDictionary<NSAttributedStringKey,id> * _Nonnull (^attribute_style_for_log_entry)(void);
} * LogEntry;

@interface LogViewDataSource ()

@property LogEntry * logEntryBuffer;
@property NSUInteger logEntryCount;
@property NSUInteger logEntryBufferCapacity;

@property pthread_rwlock_t rwLock;

@end

@implementation LogViewDataSource



//- (void)textStyles
//{
//    NSMutableParagraphStyle *leftAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    leftAlignedParagraphStyle.alignment = NSTextAlignmentLeft;
//    _operationTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.87 green:0.5 blue:0.0 alpha:1.0],
//                                 NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium]};
//
//    NSMutableParagraphStyle *fullJustificationParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    fullJustificationParagraphStyle.alignment = NSTextAlignmentJustified;
//    _errorTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.91 green:0.28 blue:0.5 alpha:1.0],
//                             NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium]};
//
//    NSMutableParagraphStyle *rightAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    rightAlignedParagraphStyle.alignment = NSTextAlignmentRight;
//    _eventTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.54 blue:0.87 alpha:1.0],
//                             NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
//                             NSParagraphStyleAttributeName: rightAlignedParagraphStyle};
//
//    NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
//    centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
//    _successTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.87 blue:0.19 alpha:1.0],
//                               NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
//                               NSParagraphStyleAttributeName: rightAlignedParagraphStyle};
//}

NSDictionary<NSAttributedStringKey,id> * _Nonnull (^(^set_log_entry_attribute_style_block)(LogEntryAttributeStyle))(void) =
^ (LogEntryAttributeStyle logEntryAttributeStyle) {
    switch (logEntryAttributeStyle) {
        case LogEntryAttributeStyleOperation:
            return ^ NSDictionary * (void) {
                NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
                centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
                return @{NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.87 blue:0.19 alpha:1.0],
                                           NSFontAttributeName: [UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
                                           NSParagraphStyleAttributeName: centerAlignedParagraphStyle};
            };
            break;
            
        case LogEntryAttributeStyleEvent:
            return ^ NSDictionary * (void) {
                NSMutableParagraphStyle *leftAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
                leftAlignedParagraphStyle.alignment = NSTextAlignmentLeft;
                return @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.87 green:0.5 blue:0.0 alpha:1.0],
                         NSFontAttributeName:[UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
                         NSParagraphStyleAttributeName:leftAlignedParagraphStyle};
            };
            break;
            
        default:
            return ^ NSDictionary * (void) {
                NSMutableParagraphStyle *leftAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
                leftAlignedParagraphStyle.alignment = NSTextAlignmentLeft;
                return @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.87 green:0.5 blue:0.0 alpha:1.0],
                         NSFontAttributeName:[UIFont systemFontOfSize:11.0 weight:UIFontWeightMedium],
                         NSParagraphStyleAttributeName:leftAlignedParagraphStyle};
            };
            break;
    }
};

static LogViewDataSource * logData = NULL;
+ (nonnull LogViewDataSource *)logData
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^{
        if (!logData)
        {
            logData = [[self alloc] init];
        }
    });
    
    return logData;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _logEntryBufferCapacity = 1000;
        _logEntryBuffer = malloc(sizeof(struct LogEntry) * self.logEntryBufferCapacity);
        
        pthread_rwlock_init(&_rwLock, NULL);
        
        self.log_view_dispatch_queue  = dispatch_queue_create_with_target("Log View Dispatch Queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
        self.log_view_dispatch_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, self.log_view_dispatch_queue);
        
    }
    return self;
}

- (void)dealloc
{
    [self readLogEntriesWithBlockAndWait:^(LogEntry *logEntryArray, NSUInteger logEntryCount) {
        for (NSUInteger logEntryIndex = 0; logEntryIndex < logEntryCount; logEntryIndex++)
        {
            (void)(free(logEntryArray[logEntryIndex]->title)), logEntryArray[logEntryIndex]->title = 0;
            (void)(free(logEntryArray[logEntryIndex]->entry)), logEntryArray[logEntryIndex]->entry = 0;
        }
    }];
    
    free(_logEntryBuffer);
    pthread_rwlock_destroy(&_rwLock);
}

- (NSAttributedString *)logAttributedText
{
    __block NSMutableAttributedString * log = [[NSMutableAttributedString alloc] init];
    [self readLogEntriesWithBlockAndWait:^(LogEntry *logEntryArray, NSUInteger logEntryCount) {
        for (NSUInteger logEntryIndex = 0; logEntryIndex < logEntryCount; logEntryIndex++)
        {
            NSDictionary<NSAttributedStringKey,id> * attributeStyleForLogEntry = logEntryArray[logEntryIndex]->attribute_style_for_log_entry();
//            NSAttributedString * entry_date = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", cmTimeString(logEntryArray[logEntryIndex]->entry_date)] attributes:attributeStyleForLogEntry];
            NSAttributedString * datestamp = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [NSString stringWithUTF8String:logEntryArray[logEntryIndex]->datestamp]] attributes:attributeStyleForLogEntry];
            NSAttributedString * timestamp = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [NSString stringWithUTF8String:logEntryArray[logEntryIndex]->timestamp]] attributes:attributeStyleForLogEntry];
            NSAttributedString * title     = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [NSString stringWithUTF8String:logEntryArray[logEntryIndex]->title]] attributes:attributeStyleForLogEntry];
            NSAttributedString * entry     = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [NSString stringWithUTF8String:logEntryArray[logEntryIndex]->entry]] attributes:attributeStyleForLogEntry];
            
//            [log appendAttributedString:entry_date];
            [log appendAttributedString:datestamp];
            [log appendAttributedString:timestamp];
            [log appendAttributedString:title];
            [log appendAttributedString:entry];
        }
    }];
    
    return log;
}

- (void)readLogEntriesWithBlockAndWait:(void (^)(LogEntry *logEntryArray, NSUInteger logEntryCount))block
{
    pthread_rwlock_wrlock(&_rwLock);
    block(self.logEntryBuffer, self.logEntryCount);
    pthread_rwlock_unlock(&_rwLock);
}

- (void)addLogEntryWithTitle:(NSString *)title entry:(NSString *)entry attributeStyle:(LogEntryAttributeStyle)style
{
    pthread_rwlock_wrlock(&_rwLock);
    
    if (self.logEntryBufferCapacity == self.logEntryCount)
    {
        _logEntryBufferCapacity *= 2;
        _logEntryBuffer = realloc(self.logEntryBuffer, sizeof(struct LogEntry) * self.logEntryBufferCapacity);
    }
    
    struct LogEntry * logEntry = malloc(sizeof(struct LogEntry));
    
    time_t time_val;
    struct tm * tm_info;
    
    time_val = time(NULL);
    tm_info = localtime(&time_val);
    
    strftime(logEntry->datestamp, 20, "%F (%a)", tm_info);
    strftime(logEntry->timestamp, 20, "%H:%M:%S", tm_info);
    
//    logEntry->entry_date = current_cmtime();
    logEntry->log_entry_attribute_style = style;
    logEntry->title = (char *)malloc(strlen((char *)[title UTF8String]));
    strcpy(logEntry->title, (char *)[title UTF8String]);
    logEntry->entry = (char *)malloc(strlen((char *)[entry UTF8String]));
    strcpy(logEntry->entry, (char *)[entry UTF8String]);
    logEntry->attribute_style_for_log_entry = set_log_entry_attribute_style_block(logEntry->log_entry_attribute_style);
    
    // TO-DO: Get the style of the last entry
    //        If 'transient' free it...
    //        and replace it with the new log entry
    //        (do not increment count)
    self.logEntryBuffer[self.logEntryCount] = logEntry;
    _logEntryCount++;
    
    pthread_rwlock_unlock(&_rwLock);
    
    //    dispatch_set_context(self.log_view_dispatch_source, self.logEntryBuffer);
    dispatch_source_merge_data(self.log_view_dispatch_source, 1);
}

@end
