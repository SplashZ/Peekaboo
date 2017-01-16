//
//  Player.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "Player.h"

@implementation Player

+ (instancetype)shareInstance
{
    static Player *player;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        player = [Player new];
        player.name = [TestInfo userTitle];
    });
    
    return player;
}

@end
