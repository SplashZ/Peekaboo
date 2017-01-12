//
//  PeekabooMap.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "PeekabooMap.h"
#import "PeekabooAnnotation.h"
#import "PlayerAnnotation.h"
#import "PeekabooAnnotationView.h"
#import "PlayerAnnotationView.h"
#import "LocationManager.h"

#import <objc/runtime.h>

NSString *UserLocationDidUpdateNotification = @"UserLocationDidUpdateNotification";

@interface PeekabooMap () <MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIButton *mapTypeBtn;
@property (nonatomic, strong) UIButton *scanRangeBtn;
@property (nonatomic, strong) UIButton *gifRangeBtn;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, weak) PlayerAnnotation *playerAnnotation;
@property (nonatomic, strong) NSMutableDictionary<NSString *, PeekabooAnnotation *> *annotationsDict;

@property (nonatomic, assign) NSInteger identifierNum;
@property (nonatomic, assign) NSInteger typeCount;
@property (nonatomic, assign) int activityCount;
@property (nonatomic, assign) BOOL peekabooRange;
@property (nonatomic, assign) BOOL scanRange;
@end

@implementation PeekabooMap

#pragma mark - life cycle

- (void)dealloc
{
    //下面的做法是参照stackoverflow，但是经我测试做了和没做一样，可能是之后版本有改进吧。
    //http://stackoverflow.com/questions/26463125/memory-leak-in-mapkit-ios8?rq=1
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode  = MKUserTrackingModeNone;
    [self.mapView.layer removeAllAnimations];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

+ (instancetype)mapViewWithFrame:(CGRect)frame
{
    PeekabooMap *mapView = [[PeekabooMap alloc] initWithFrame:frame];
    return mapView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self assignSubviews];
        [self assignDefaultValue];
    }
    return self;
}

- (void)assignSubviews
{
    self.mapView.frame = self.frame;
    CGFloat h = 64.f;
    self.toolBar.frame = CGRectMake(self.frame.size.width - h, self.frame.size.height - h, h, h);
    CGFloat w = 38.f;
    self.mapTypeBtn.frame = CGRectMake(CGRectGetMidX(self.toolBar.frame) - w * 0.5, CGRectGetMinY(self.toolBar.frame) - w, w, w);
    self.gifRangeBtn.frame = CGRectMake(CGRectGetMinX(self.mapTypeBtn.frame), CGRectGetMinY(self.mapTypeBtn.frame) - w - 10, w, w);
    self.scanRangeBtn.frame = CGRectMake(CGRectGetMinX(self.mapTypeBtn.frame), CGRectGetMinY(self.gifRangeBtn.frame) - w - 10, w, w);
    self.indicatorView.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
    
    [self addSubview:self.mapView];
    [self addSubview:self.toolBar];
    [self addSubview:self.mapTypeBtn];
    [self addSubview:self.gifRangeBtn];
    [self addSubview:self.scanRangeBtn];
    [self addSubview:self.indicatorView];
    
    MKUserTrackingBarButtonItem *trackBtn = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    UIBarButtonItem *space1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *space2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolBar.items = @[space1, trackBtn, space2];
}

- (void)assignDefaultValue
{
    _typeCount = 0;
    _activityCount = 0;
    _peekabooRange = NO;
    _scanRange = NO;
    _identifierNum = 1000;
}

#pragma mark - public

- (void)updateUserLocationWithTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    self.mapView.userLocation.title = title;
    self.mapView.userLocation.subtitle = subTitle;
    self.mapView.showsUserLocation = YES;
}

- (void)addAnnotation:(id <MKAnnotation>)annotation
{
    [self.mapView addAnnotation:annotation];
    
    if ([annotation isKindOfClass:[PlayerAnnotation class]]) {
        self.playerAnnotation = annotation;
    } else if ([annotation isKindOfClass:[PeekabooAnnotation class]]) {
        PeekabooAnnotation *gifAnnotation = (PeekabooAnnotation *)annotation;
        if (!gifAnnotation.identifier.length) {
            self.identifierNum ++;
            gifAnnotation.identifier = [NSString stringWithFormat:@"PeekabooAnnotationIdentifier%@", @(self.identifierNum)];
        }
        self.annotationsDict[gifAnnotation.identifier] = gifAnnotation;
    }
}

- (PeekabooAnnotationView *)annotationViewWithAnnotationIdentifier:(NSString *)identifier
{
    id annotation = self.annotationsDict[identifier];
    return (PeekabooAnnotationView *)[self.mapView viewForAnnotation:annotation];
}

#pragma mark - praviate

- (void)updateOverlayerOfPlayer:(BOOL)isUpdate
{
    PlayerAnnotationView *annotationView = (PlayerAnnotationView *)[self.mapView viewForAnnotation:self.playerAnnotation];
    
    if (isUpdate) {
        [annotationView updateRadiusOverlayAndAnnotationWithCoordinate:self.mapView.userLocation.coordinate];
    } else {
        [annotationView removeRadiusOverlay];
    }
}

- (void)constraintSpanRegionWithMapView:(MKMapView *)mapView
{
    //    latitudeDelta:0.118848-longitudeDelta:0.080327
    //    latitudeDelta:0.026287-longitudeDelta:0.017767
    //    latitudeDelta:0.001035-longitudeDelta:0.000699
    //    NSLog(@"latitude:%lf-longitude:%lf, latitudeDelta:%lf-longitudeDelta:%lf", mapView.region.center.latitude, mapView.region.center.longitude, mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    MKCoordinateSpan span = mapView.region.span;
    BOOL isExceed = NO;
    
    if (span.latitudeDelta > 0.118848) {
        span.latitudeDelta = 0.118500;
        isExceed = YES;
    }
    
    if (span.longitudeDelta > 0.080327) {
        span.longitudeDelta = 0.08;
        isExceed = YES;
    }
    
    if (isExceed) {
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = span;
        [self.mapView setRegion:region animated:NO];
    }
}

- (void)showIndicator
{
    if (_activityCount > 0) {
        _activityCount ++;
        return;
    }
    
    [self.indicatorView startAnimating];
}

- (void)hideIndicator
{
    if (_activityCount > 0) {
        _activityCount --;
        return;
    }
    
    [self.indicatorView stopAnimating];
}

#pragma mark - touch event

- (void)mapTypeSwitch
{
    self.typeCount ++;
    self.mapView.mapType = self.typeCount % MKMapTypeHybridFlyover;
}

- (void)gifRangeToggle:(UIButton *)btn
{
    btn.selected = !btn.isSelected;
    self.peekabooRange = btn.isSelected;
    
    [self.mapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[PeekabooAnnotation class]]) {
            return;
        }
        
        PeekabooAnnotationView *annotationView = (PeekabooAnnotationView *)[self.mapView viewForAnnotation:obj];
        
        if (self.peekabooRange) {
            [annotationView updateRadiusOverlay];
        } else {
            [annotationView removeRadiusOverlay];
        }
    }];
}

- (void)scanRangeToggle:(UIButton *)btn
{
    btn.selected = !btn.isSelected;
    self.scanRange = btn.isSelected;
    
    [self updateOverlayerOfPlayer:self.scanRange];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (userLocation.coordinate.latitude == 0 && userLocation.coordinate.longitude == 0) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UserLocationDidUpdateNotification object:userLocation];
    
    if (!self.scanRange) {
        return;
    }
    
    [self updateOverlayerOfPlayer:YES];
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    [self showIndicator];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    [self hideIndicator];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    [self hideIndicator];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self constraintSpanRegionWithMapView:mapView];
    
    //防止内存暴增导致crash，有点作用，不过还是无法阻止内存的暴增
    [mapView removeFromSuperview];
    [self insertSubview:mapView belowSubview:self.toolBar];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSString *identifier = [NSString stringWithFormat:@"%@Identifer", [[annotation class] description]];
    if([annotation isKindOfClass:[PeekabooAnnotation class]]) {
        PeekabooAnnotation *gifAnnotation = (PeekabooAnnotation *)annotation;
        PeekabooAnnotationView *annotationView = (PeekabooAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier: identifier];
        
        if (!annotationView) {
            annotationView = [[PeekabooAnnotationView alloc] initWithAnnotation:gifAnnotation reuseIdentifier:identifier];
            annotationView.mapView = mapView;
            annotationView.CalloutDidClick = ^{
                //TODO: CalloutDidClick
            };
        }
        
        annotationView.annotation = gifAnnotation;
        
        return annotationView;
    } else if ([annotation isKindOfClass:[PlayerAnnotation class]]) {
        PlayerAnnotation *playerAnnotation = (PlayerAnnotation *)annotation;
        PlayerAnnotationView *annotationView = (PlayerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!annotationView) {
            annotationView = [[PlayerAnnotationView alloc] initWithAnnotation:playerAnnotation reuseIdentifier:identifier];
            annotationView.mapView = mapView;
        }
        
        annotationView.annotation = playerAnnotation;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view isKindOfClass:[PeekabooAnnotationView class]]) {
        PeekabooAnnotationView *annotationView = (PeekabooAnnotationView *)view;
        PeekabooAnnotation *annotation = annotationView.annotation;
        NSMutableString *desc = [NSMutableString stringWithString:@"🌐距离"];
        NSString *distanceStr = [LocationManager distanceFromOrigin:mapView.userLocation.coordinate toDestination:annotationView.annotation.coordinate];
        [desc appendString:annotation.locationDesc];
        [desc appendString:@"还有"];
        [desc appendString:distanceStr];
        annotation.subtitle = desc;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    for (MKAnnotationView *view in views) {
        if(![view isKindOfClass:[PeekabooAnnotationView class]]) {
            continue;
        }

        view.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:0.3 animations:^{
            view.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                view.transform = CGAffineTransformIdentity;
            }];
        }];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    BOOL isPlayerOverlay = overlay.coordinate.latitude == self.playerAnnotation.coordinate.latitude && overlay.coordinate.longitude == self.playerAnnotation.coordinate.longitude;
    
    if(self.peekabooRange
       && [overlay isKindOfClass:[MKCircle class]]
       && !isPlayerOverlay) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.lineWidth = 1;
        circleView.strokeColor = [UIColor cyanColor];
        circleView.fillColor = [circleView.strokeColor colorWithAlphaComponent:0.1];
#pragma clang diagnostic pop
        return circleView;		
    }
    
    if (self.scanRange
        && [overlay isKindOfClass:[MKCircle class]]
        && isPlayerOverlay) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.lineWidth = 1;
        circleView.strokeColor = [UIColor blueColor];
        circleView.fillColor = [circleView.strokeColor colorWithAlphaComponent:0.1];
#pragma clang diagnostic pop
        return circleView;
    }
    
    return nil;
}

#pragma mark - getter

- (MKMapView *)mapView
{
    if (!_mapView) {
        //MKMapView 每次加载后都会增加40m左右，并且这40m无法释放，有点坑
        //http://stackoverflow.com/questions/26463125/memory-leak-in-mapkit-ios8
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        _mapView.mapType = MKMapTypeStandard;
        _mapView.zoomEnabled = YES;
        _mapView.scrollEnabled = YES;
        _mapView.rotateEnabled = YES;
        _mapView.pitchEnabled = NO;
        _mapView.showsCompass = YES;
        _mapView.showsScale = YES;
        _mapView.showsBuildings = YES;
        _mapView.showsTraffic = YES;
        _mapView.showsUserLocation = NO;
        _mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        
        //去掉左右下角的标识
        for (UIView *view in _mapView.subviews) {
            if ([view isKindOfClass:NSClassFromString(@"MKAttributionLabel")]) {
                [view removeFromSuperview];
            }
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
    }
    return _mapView;
}

- (UIToolbar *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIToolbar alloc] init];
        [_toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [_toolBar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    }
    return _toolBar;
}

- (UIButton *)mapTypeBtn
{
    if (!_mapTypeBtn) {
        _mapTypeBtn = [[UIButton alloc] init];
        [_mapTypeBtn setBackgroundImage:[UIImage imageNamed:@"maptype"] forState:UIControlStateNormal];
        [_mapTypeBtn addTarget:self action:@selector(mapTypeSwitch) forControlEvents:UIControlEventTouchUpInside];
    }
    return _mapTypeBtn;
}

- (UIButton *)gifRangeBtn
{
    if (!_gifRangeBtn) {
        _gifRangeBtn = [[UIButton alloc] init];
        [_gifRangeBtn setBackgroundImage:[UIImage imageNamed:@"range"] forState:UIControlStateNormal];
        [_gifRangeBtn addTarget:self action:@selector(gifRangeToggle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _gifRangeBtn;
}

- (UIButton *)scanRangeBtn
{
    if (!_scanRangeBtn) {
        _scanRangeBtn = [[UIButton alloc] init];
        [_scanRangeBtn setBackgroundImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        [_scanRangeBtn addTarget:self action:@selector(scanRangeToggle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scanRangeBtn;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.color = [UIColor grayColor];
    }
    return _indicatorView;
}

- (NSMutableDictionary<NSString *, PeekabooAnnotation *> *)annotationsDict
{
    if (!_annotationsDict) {
        _annotationsDict = [NSMutableDictionary dictionary];
    }
    return _annotationsDict;
}

@end

