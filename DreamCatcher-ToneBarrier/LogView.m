//
//  LogView.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 9/21/20.
//

#import "LogView.h"

@implementation LogView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateLog:(nonnull NSAttributedString *)logAttributedText {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self setAttributedText:logAttributedText];
}

@end
