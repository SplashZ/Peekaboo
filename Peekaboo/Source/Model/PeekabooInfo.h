//
//  PeekabooInfo.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeekabooInfo : NSObject

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double radius;
@property (nonatomic, strong) UIImage *profile;
@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) NSString *locationDesc;

@end
