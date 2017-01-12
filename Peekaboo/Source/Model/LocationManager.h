//
//  LocationManager.h
//  PresentMap
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2016年 splashz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol LocationManagerDelegate <NSObject>

@optional
///授权状态改变
- (void)locationManagerDidChangeAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)locationManagerDidRegionStateChanged:(CLRegionState)state
                                   forRegion:(CLRegion *)region;

@end


@interface LocationManager : NSObject

@property (nonatomic, weak) id<LocationManagerDelegate> delegate;

+ (instancetype)locationManager;

///计算两点之间的距离
+ (NSString *)distanceFromOrigin:(CLLocationCoordinate2D)origin
                   toDestination:(CLLocationCoordinate2D)destination;

///开始定位
- (void)startLocation;
///停止定位
- (void)stopLocation;
///添加反地理编码操作
- (void)addGeocodingOperationWithCoordinate:(CLLocationCoordinate2D)coordinate
                        completionHandler:(void (^)(NSString *locationInfo))completionHandler;
///开始批量反地理编码操作
- (void)startGeocoding;
///监听指定区域
- (CLCircularRegion *)startMonitorRegionWithCenter:(CLLocationCoordinate2D)center
                                            radius:(CLLocationDistance)radius
                                        identifier:(NSString *)identifier;
///取消监听指定区域
- (void)stopMonitorRegion:(CLCircularRegion *)region;

@end
