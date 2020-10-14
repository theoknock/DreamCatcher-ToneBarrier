//
//  LogViewController.m
//  DreamCatcher-ToneBarrier
//
//  Created by Xcode Developer on 10/10/20.
//

#import "LogViewController.h"
#import "LogViewDataSource.h"

@interface LogViewController ()
{
    UITextView *logView;
}

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    logView = [[UITextView alloc] initWithFrame:self.view.frame];
    [logView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:logView];
    
    dispatch_source_set_event_handler(LogViewDataSource.logData.log_view_dispatch_source, ^{
        [logView setAttributedText:[LogViewDataSource.logData logAttributedText]];
    });
    
    dispatch_resume(LogViewDataSource.logData.log_view_dispatch_source);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller. (what object?)
}
*/

@end
