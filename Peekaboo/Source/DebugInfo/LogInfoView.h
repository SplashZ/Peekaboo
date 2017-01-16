//
//  LogInfoView.h
//  Peekaboo
//
//  Created by macintosh on 2017/1/13.
//  Copyright © 2017年 splashz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInfoView : UIView

@property (nonatomic, assign, readonly) BOOL isShow;

+ (instancetype)logInfoViewWithViewControler:(UIViewController *)viewController;
- (void)showWithCompletation:(void(^)(void))completation;
- (void)hideWithCompletation:(void(^)(void))completation;

@end
