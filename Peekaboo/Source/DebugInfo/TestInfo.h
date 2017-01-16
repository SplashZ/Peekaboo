//
//  TestInfo.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"

#define TestLog(fmt, ...) ([TestInfo setLog:[NSString stringWithFormat:(fmt), ##__VA_ARGS__]], NSLog(fmt, ##__VA_ARGS__))

@class PeekabooInfo;

FOUNDATION_EXTERN NSString *LogDidUpdated;

@interface TestInfo : NSObject

+ (void)initPlayersProfiles;
+ (NSArray<PeekabooInfo *> *)testInfoWithCurrentCoordinate:(CLLocationCoordinate2D)coordinate;
+ (NSString *)userTitle;
+ (double)radius;

+ (void)setLog:(NSString *)log;
+ (NSString *)getLog;

+ (void)clearLog;

@end
