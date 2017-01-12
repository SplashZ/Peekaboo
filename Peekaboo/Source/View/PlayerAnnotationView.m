//
//  PlayerAnnotationView.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "PlayerAnnotationView.h"
#import "PlayerAnnotation.h"

@interface PlayerAnnotationView ()
@property (nonatomic, weak) PlayerAnnotation *annotation;
@property (nonatomic, assign) BOOL hasOverlay;
@end

@implementation PlayerAnnotationView

@synthesize annotation = _annotation;

- (void)removeRadiusOverlay
{
    for (id overlay in [self.mapView overlays]) {
        if ([overlay isKindOfClass:[MKCircle class]]) {
            MKCircle *circleOverlay = (MKCircle *)overlay;
            CLLocationCoordinate2D coord = circleOverlay.coordinate;
            
            if (coord.latitude == self.annotation.coordinate.latitude && coord.longitude == self.annotation.coordinate.longitude) {
                [self.mapView removeOverlay:overlay];
                self.hasOverlay = NO;
            }
        }
    }
}

- (void)updateRadiusOverlayAndAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.hasOverlay) {
        [self removeRadiusOverlay];
    }
    self.hasOverlay = YES;
    self.annotation.coordinate = coordinate;
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:self.annotation.coordinate radius:self.annotation.radius]];
}

@end
