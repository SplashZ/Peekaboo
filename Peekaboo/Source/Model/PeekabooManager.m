//
//  PeekabooManager.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "PeekabooManager.h"
#import "PeekabooInfo.h"


@interface PeekabooManager ()
@property (nonatomic, strong) NSMutableArray *tipRegions;
@end

@implementation PeekabooManager

+ (instancetype)peekabooManager
{
    PeekabooManager *peekabooManager = [[PeekabooManager alloc] init];
    return peekabooManager;
}

#pragma mark - public

- (void)collectionPeekaboosWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.peekabooInfos = [TestInfo testInfoWithCurrentCoordinate:coordinate];
}

- (void)addTipRegion:(CLCircularRegion *)region
{
    [self.tipRegions addObject:region];
}

- (void)removeTipRegion:(CLCircularRegion *)region
{
    [self.tipRegions removeObject:region];
}

#pragma mark - getter

- (NSMutableArray *)tipRegions
{
    if (!_tipRegions) {
        _tipRegions = [NSMutableArray array];
    }
    return _tipRegions;
}

@end
