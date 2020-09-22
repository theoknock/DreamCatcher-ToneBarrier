//
//  LogView.h
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/21/20.
//

#import <UIKit/UIKit.h>

#import "LogViewDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface LogView : UITextView <LogViewDataSourceDelegate>

@end

NS_ASSUME_NONNULL_END
