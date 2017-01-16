//
//  BaseViewController.m
//  Peekaboo
//
//  Created by macintosh on 2017/1/13.
//  Copyright © 2017年 splashz. All rights reserved.
//

#import "BaseViewController.h"
#import "LogInfoView.h"

@interface BaseViewController ()
@property (nonatomic, strong) LogInfoView *logView;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _barStyle = self.preferredStatusBarStyle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"information"] style:UIBarButtonItemStylePlain target:self action:@selector(popLogInfo)];
    self.title = @"Do whatever you want";
}

#pragma mark - status bar

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.barStyle;
}

#pragma mark - touch events

- (void)popLogInfo
{
    if (!self.logView.isShow) {
        [self.logView showWithCompletation:^{
            self.barStyle = UIStatusBarStyleLightContent;
        }];
    } else {
        self.barStyle = UIBarStyleDefault;
        [self.logView hideWithCompletation:nil];
    }
}

#pragma mark - getter

- (LogInfoView *)logView
{
    if (!_logView) {
        _logView = [LogInfoView logInfoViewWithViewControler:self];
    }
    return _logView;
}

#pragma mark - setter

- (void)setBarStyle:(UIStatusBarStyle)barStyle
{
    if (_barStyle == barStyle) {
        return;
    }
    
    _barStyle = barStyle;
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
