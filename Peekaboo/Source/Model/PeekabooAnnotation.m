//
//  PeekabooAnnotation.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "PeekabooAnnotation.h"
#import "PeekabooInfo.h"
#import "TestInfo.h"

@interface PeekabooAnnotation ()
@end


@implementation PeekabooAnnotation

+ (instancetype)peekabooAnnotationWithPeekabooInfo:(PeekabooInfo *)peekabooInfo
{
    PeekabooAnnotation *annotation = [PeekabooAnnotation new];
    annotation.coordinate = (CLLocationCoordinate2D){peekabooInfo.latitude, peekabooInfo.longitude};
    //The value of `title` should be greater than 0, or the callout wouldn't appear
    annotation.title = @"距离太远了，走近一点才能找到哦🎵";
    annotation.locationDesc = peekabooInfo.locationDesc;
    annotation.radius = [TestInfo radius];
    annotation.accessoryImage = peekabooInfo.profile;
    annotation.profile = peekabooInfo.profile;
    annotation.canShowCallout = NO;

    return annotation;
}

@end
