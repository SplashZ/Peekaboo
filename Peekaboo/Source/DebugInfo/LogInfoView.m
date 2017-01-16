//
//  LogInfoView.m
//  Peekaboo
//
//  Created by macintosh on 2017/1/13.
//  Copyright © 2017年 splashz. All rights reserved.
//

#import "LogInfoView.h"

@interface LogInfoView ()
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *clearBtn;
@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, assign) BOOL isShow;
@end

@implementation LogInfoView

- (void)didMoveToSuperview
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logDidUpdated:) name:LogDidUpdated object:nil];
}

- (void)removeFromSuperview
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

+ (instancetype)logInfoViewWithViewControler:(UIViewController *)viewController
{
    LogInfoView *logInfoView = [[LogInfoView alloc] initWithFrame:viewController.view.frame];
    logInfoView.viewController = viewController;
    logInfoView.transform = CGAffineTransformMakeTranslation(0, logInfoView.frame.size.height);
    logInfoView.isShow = NO;
    return logInfoView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        CGRect _frame = frame;
        _frame.origin.y = 64;
        _frame.size.height = frame.size.height - 64;
        
        self.textView.frame = _frame;
        
        [self addSubview:self.textView];
        self.textView.text = [TestInfo getLog];
    }
    return self;
}

#pragma mark - public

- (void)showWithCompletation:(void(^)(void))completation
{
    if (CGAffineTransformIsIdentity(self.transform)) {
        return;
    }
    
    [self.viewController.view addSubview:self];
    self.viewController.navigationItem.titleView = self.clearBtn;
    self.clearBtn.alpha = 0;
    
    [self.viewController.view addSubview:self];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
        self.clearBtn.alpha = 1;
    } completion:^(BOOL finished) {
        self.isShow = YES;
        if (completation) {
            completation();
        }
    }];
}

- (void)hideWithCompletation:(void(^)(void))completation
{
    if (!CGAffineTransformIsIdentity(self.transform)) { // hide
        return;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.clearBtn.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(0, self.frame.size.height);
    } completion:^(BOOL finished) {
        self.isShow = NO;
        self.viewController.navigationItem.titleView = nil;
        [self removeFromSuperview];
        if (completation) {
            completation();
        }
    }];
}

#pragma mark - touch events

- (void)clearBtnClicked:(UIButton *)btn
{
    [TestInfo clearLog];
}

#pragma mark - LogDidUpdated

- (void)logDidUpdated:(NSNotification *)notification
{
    NSString *logInfo = notification.object;
    self.textView.text = logInfo;
    NSLog(@"%p", logInfo);
}

#pragma mark - getter

- (UIButton *)clearBtn
{
    if (!_clearBtn) {
        _clearBtn = [[UIButton alloc] init];
        [_clearBtn setTitle:@"clear" forState:UIControlStateNormal];
        [_clearBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_clearBtn addTarget:self action:@selector(clearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_clearBtn sizeToFit];
    }
    return _clearBtn;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor blackColor];
        _textView.textColor = [UIColor whiteColor];
        _textView.editable = NO;
    }
    return _textView;
}

@end
