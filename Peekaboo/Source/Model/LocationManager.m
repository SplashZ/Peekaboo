//
//  LocationManager.m
//  PresentMap
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2016年 splashz. All rights reserved.
//

#import "LocationManager.h"
#import <UIKit/UIKit.h>

@interface ReverseLocationInfo : NSObject
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) void(^completionHandler)(NSString *locationInfo);

+ (instancetype)reverseLocationInfoWithCoordinate:(CLLocationCoordinate2D)coordinate completionHandler:(void (^)(NSString *locationInfo))completionHandler;

@end

@implementation ReverseLocationInfo

+ (instancetype)reverseLocationInfoWithCoordinate:(CLLocationCoordinate2D)coordinate completionHandler:(void (^)(NSString *locationInfo))completionHandler
{
    ReverseLocationInfo *info = [ReverseLocationInfo new];
    info.coordinate = coordinate;
    info.completionHandler = completionHandler;
    return info;
}

@end

@interface LocationManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;

@property (nonatomic, assign) NSTimeInterval retryInterval;
@property (nonatomic, assign) CLAuthorizationStatus authorizationStatus;

@property (nonatomic, assign) BOOL canRetry;
@property (nonatomic, assign) BOOL isUpdating;

@property (nonatomic, strong) NSMutableArray<ReverseLocationInfo *> *reverLocationInfos;

@end

@implementation LocationManager

#pragma mark - life cycly

+ (instancetype)locationManager
{
    LocationManager *locationManager = [LocationManager new];
    [locationManager defualtAssign];
    
    return locationManager;
}

- (void)defualtAssign
{
    _canRetry = YES;
    _retryInterval = 5;
    _isUpdating = NO;
}

#pragma mark - public

+ (NSString *)distanceFromOrigin:(CLLocationCoordinate2D)origin
                   toDestination:(CLLocationCoordinate2D)destination
{
    CLLocation *orig = [[CLLocation alloc] initWithLatitude:origin.latitude  longitude:origin.longitude];
    CLLocation* dest = [[CLLocation alloc] initWithLatitude:destination.latitude  longitude:destination.longitude];
    
    CLLocationDistance distance = [orig distanceFromLocation:dest];
    
    NSString *str = nil;
    if (distance >= 1000) {
        str = [NSString stringWithFormat:@"%.2fkm", distance / 1000];
    } else if (distance < 1000 && distance >= 0 ) {
        str = [NSString stringWithFormat:@"%.2fm", distance];
    } else {
        str = @"0m";
    }
    return str;
}

- (void)startLocation
{
    if (!self.isUpdating) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)stopLocation
{
    if (self.isUpdating) {
        [self.locationManager stopUpdatingLocation];
    }
}

///这里之所以这么处理是因为反地理编码的方法是异步的
///同时一个设备只能开启一个反地理编码的操作
///如果短时间内开启多个操作，编码系统只会处理正在处理的操作，而这个时间添加的操作会被忽略。
- (void)addGeocodingOperationWithCoordinate:(CLLocationCoordinate2D)coordinate
                          completionHandler:(void (^)(NSString *locationInfo))completionHandler
{
    ReverseLocationInfo *reverseLocationInfo = [ReverseLocationInfo reverseLocationInfoWithCoordinate:coordinate completionHandler:completionHandler];
    [self.reverLocationInfos addObject:reverseLocationInfo];
}

- (void)startGeocoding
{
    if (self.reverLocationInfos.count > 0) {
        ReverseLocationInfo *reverseLocationInfo = [self.reverLocationInfos firstObject];
        [self.reverLocationInfos removeObjectAtIndex:0];
        [self handleGeocodingOperationWithCoordinate:reverseLocationInfo];
    }
}

- (void)handleGeocodingOperationWithCoordinate:(ReverseLocationInfo *)reverseLocationInfo
{
    NSMutableString *locationInfo = [NSMutableString string];
    CLLocationCoordinate2D coordinate = reverseLocationInfo.coordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        void(^nextHandler)(NSString *locationInfo) = ^(NSString *locationInfo) {
             nil;
            reverseLocationInfo.completionHandler(locationInfo);
            [self startGeocoding];
        };
        
        if (error) {
            [locationInfo appendString:[NSString stringWithFormat:@"%@", error.localizedDescription]];
            nextHandler(locationInfo);
            return;
        }
        
        if (!placemarks.count) {
            [locationInfo appendString:@"这是哪，我都不知道"];
            nextHandler(locationInfo);
            return;
        }
        
        for (CLPlacemark *placemark in placemarks) {
            if (placemark.name) {
                [locationInfo appendString:placemark.name];
            }
        }
        nextHandler(locationInfo);
    }];
}

- (CLCircularRegion *)startMonitorRegionWithCenter:(CLLocationCoordinate2D)center
                                            radius:(CLLocationDistance)radius
                                        identifier:(NSString *)identifier
{
    if (![CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        return nil;
    }
    
    if (!self.isUpdating) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startLocation) object:nil];
        [self startLocation];
    }
    
    if (radius > self.locationManager.maximumRegionMonitoringDistance) {
        radius = self.locationManager.maximumRegionMonitoringDistance;
    }
    
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center
                                                                 radius:radius
                                                             identifier:identifier];
 
    [self.locationManager startMonitoringForRegion:region];
    
    return region;
}

- (void)stopMonitorRegion:(CLCircularRegion *)region
{
    [self.locationManager stopMonitoringForRegion:region];
}

#pragma mark - private


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    self.isUpdating = NO;
    if (_canRetry) {
        [self performSelector:@selector(startLocation) withObject:nil afterDelay:self.retryInterval];
    }
}

//天朝坑爹的定位偏移
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    self.isUpdating = YES;
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManagerDidRegionStateChanged:forRegion:)]) {
        [self.delegate locationManagerDidRegionStateChanged:state forRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationManagerDidChangeAuthorizationStatus:)]) {
        [self.delegate locationManagerDidChangeAuthorizationStatus:status];
    }
}

#pragma mark - getter

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.activityType = CLActivityTypeFitness;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
            NSDictionary *bundleInfo = [NSBundle mainBundle].infoDictionary;
            id whenInUse = bundleInfo[@"NSLocationWhenInUseUsageDescription"];
            if (whenInUse) {
                [_locationManager requestWhenInUseAuthorization];
            } else {
                NSLog(@"Location service is not authorization!");
            }
        }
    }
    return _locationManager;
}

- (CLGeocoder *)geoCoder
{
    if (!_geoCoder) {
        _geoCoder = [CLGeocoder new];
    }
    return _geoCoder;
}

- (NSMutableArray<ReverseLocationInfo *> *)reverLocationInfos
{
    if (!_reverLocationInfos) {
        _reverLocationInfos = [NSMutableArray array];
    }
    return _reverLocationInfos;
}

@end
