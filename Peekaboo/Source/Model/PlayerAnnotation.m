//
//  PlayerAnnotation.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "PlayerAnnotation.h"

@implementation PlayerAnnotation

+ (instancetype)peekabooAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
                                      radius:(CLLocationDistance)radius
{
    PlayerAnnotation *playerAnnotation = [PlayerAnnotation new];
    playerAnnotation.coordinate = coordinate;
    playerAnnotation.radius = radius;
    return playerAnnotation;
}

@end
