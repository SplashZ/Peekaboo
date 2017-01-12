//
//  TestInfo.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"

@class PeekabooInfo;

@interface TestInfo : NSObject

+ (void)initPlayersProfiles;
+ (NSArray<PeekabooInfo *> *)testInfoWithCurrentCoordinate:(CLLocationCoordinate2D)coordinate;
+ (NSString *)userTitle;
+ (double)radius;

@end
