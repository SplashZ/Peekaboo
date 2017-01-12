//
//  PeekabooManager.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class PeekabooInfo, LocationManager, CLCircularRegion;

@interface PeekabooManager : NSObject

@property (nonatomic, strong) NSArray<PeekabooInfo *> *peekabooInfos;

+ (instancetype)peekabooManager;

- (void)addTipRegion:(CLCircularRegion *)region;
- (void)removeTipRegion:(CLCircularRegion *)region;

- (void)collectionPeekaboosWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
