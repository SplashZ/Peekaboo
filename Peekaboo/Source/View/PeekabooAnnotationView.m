//
//  PeekabooAnnotationView.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "PeekabooAnnotationView.h"
#import "PeekabooAnnotation.h"

@interface PeekabooAnnotationView ()

@property (nonatomic, weak) PeekabooAnnotation *annotation;
@property (nonatomic, assign) BOOL isUpdated;

@end

@implementation PeekabooAnnotationView

@synthesize annotation = _annotation;

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.canShowCallout = NO;
        _mapView = nil;
        _isUpdated = NO;
        _showOverlay = YES;
        _annotation = (PeekabooAnnotation *)annotation;
        self.image = _annotation.profile;
    }
    return self;
}

- (void)removeRadiusOverlay
{
    for (id overlay in [self.mapView overlays]) {
        if ([overlay isKindOfClass:[MKCircle class]]) {
            MKCircle *circleOverlay = (MKCircle *)overlay;
            CLLocationCoordinate2D coord = circleOverlay.coordinate;
            
            if (coord.latitude == self.annotation.coordinate.latitude && coord.longitude == self.annotation.coordinate.longitude) {
                [self.mapView removeOverlay:overlay];
            }
        }
    }
}

- (void)updateRadiusOverlay
{
    if (!self.showOverlay) {
        return;
    }
    
    if (self.isUpdated) {
        [self removeRadiusOverlay];
    }
    self.isUpdated = YES;
    [self.mapView addOverlay:[MKCircle circleWithCenterCoordinate:self.annotation.coordinate radius:self.annotation.radius]];
}

- (void)addCalloutContainer
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0., 0., 44., 44.)];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.leftCalloutAccessoryView = btn;
}

- (void)setCalloutImage:(UIImage *)calloutImage
{
    if (!self.leftCalloutAccessoryView) {
        [self addCalloutContainer];
        
    }
    
    UIButton *btn = (UIButton *)self.leftCalloutAccessoryView;
    [btn setBackgroundImage:calloutImage forState:UIControlStateNormal];
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    if (annotation
        && [annotation isKindOfClass:[PeekabooAnnotation class]]
        && self.annotation != annotation) {
        _annotation = annotation;
        self.canShowCallout = _annotation.canShowCallout;
        self.calloutImage = _annotation.accessoryImage;
        self.image = _annotation.profile;
    }
}

- (void)btnClicked:(UIButton *)btn
{
    if (_CalloutDidClick) {
        _CalloutDidClick();
    }
}

@end
