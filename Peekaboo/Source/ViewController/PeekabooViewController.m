//
//  PeekabooViewController.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "PeekabooViewController.h"
#import "Player.h"
#import "PeekabooMap.h"
#import "PeekabooManager.h"
#import "PeekabooInfo.h"
#import "PeekabooAnnotation.h"
#import "PeekabooAnnotationView.h"
#import "PlayerAnnotation.h"
#import "LocationManager.h"
#import "TestInfo.h"

@interface PeekabooViewController () <LocationManagerDelegate>

@property (nonatomic, strong) PeekabooMap *mapView;
@property (nonatomic, strong) PeekabooManager *peekabooManger;
@property (nonatomic, strong) LocationManager *locationManager;
@property (nonatomic, assign) CLAuthorizationStatus authorizationStatus;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
///需要的时候可以取消监听对应的region
@property (nonatomic, strong) NSMutableDictionary<NSString *, CLCircularRegion *> *regionsDict;

@end

@implementation PeekabooViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self assignNavigationBar];
    [self assignDefaultValue];
    [TestInfo initPlayersProfiles];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //开始定位
    [self.locationManager startLocation];
    [self addNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.locationManager stopLocation];
}

- (void)assignDefaultValue
{
    _authorizationStatus = kCLAuthorizationStatusNotDetermined;
}

- (void)assignNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"information"] style:UIBarButtonItemStylePlain target:self action:@selector(popIntroduce)];
    self.title = @"Peekaboo";
}

- (void)showSubviewsWithStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusRestricted:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"该设备不支持定位" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            if (_tapGesture) {
                _tapGesture.enabled = NO;
            }
            
            [self.view addSubview:self.mapView];
            break;
        case kCLAuthorizationStatusDenied:
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"开启定位服务参与互动" message:@"请在”设置“-”隐私“-”定位服务“中开启" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:^{
                [self.view addGestureRecognizer:self.tapGesture];
                self.tapGesture.enabled = YES;
            }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - LocationManagerDelegate

- (void)locationManagerDidChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.authorizationStatus = status;
    [self showSubviewsWithStatus:status];
}

- (void)locationManagerDidRegionStateChanged:(CLRegionState)state
                                   forRegion:(CLRegion *)region
{
//    NSLog(@"----->latitude:%lf, longitude:%lf", region.center.latitude, region.center.longitude);
    
    PeekabooAnnotationView *annotationView = [self.mapView annotationViewWithAnnotationIdentifier:region.identifier];
    PeekabooAnnotation *annotation = annotationView.annotation;
    
    switch (state) {
        case CLRegionStateInside:
            annotation.canShowCallout = YES;
            annotationView.canShowCallout = YES;
            break;
        case CLRegionStateOutside:
            annotation.canShowCallout = NO;
            annotationView.canShowCallout = NO;
            break;
        case CLRegionStateUnknown:
            break;
        default:
            break;
    }
}

#pragma mark - notification

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationDidUpdated:) name:UserLocationDidUpdateNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)locationDidUpdated:(NSNotification *)notification
{
    //坑爹的天朝定位偏移
    MKUserLocation *userLocation = notification.object;
    CLLocationCoordinate2D userCoordinate = userLocation.coordinate;
    
    __weak typeof(self) weakSelf = self;
    
    [self.mapView showIndicator];
    [self.locationManager addGeocodingOperationWithCoordinate:userCoordinate completionHandler:^(NSString *locationInfo) {
        Player *player = [Player shareInstance];
        player.locationDesc = locationInfo;
        [weakSelf.mapView updateUserLocationWithTitle:[player name] subTitle:player.locationDesc];
        PlayerAnnotation *playerAnnotation = [PlayerAnnotation peekabooAnnotationWithCoordinate:userCoordinate radius:[TestInfo radius]];
        [weakSelf.mapView addAnnotation:playerAnnotation];
        [weakSelf.mapView hideIndicator];
    }];
    
    [self.peekabooManger collectionPeekaboosWithCoordinate:userCoordinate];
    [self.peekabooManger.peekabooInfos enumerateObjectsUsingBlock:^(PeekabooInfo * _Nonnull peekabooInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.mapView showIndicator];
        CLLocationCoordinate2D coordinate = (CLLocationCoordinate2D){peekabooInfo.latitude, peekabooInfo.longitude};
        [self.locationManager addGeocodingOperationWithCoordinate:coordinate completionHandler:^(NSString *locationInfo) {
            peekabooInfo.locationDesc = locationInfo;
            
            PeekabooAnnotation *peekabooAnnotation = [PeekabooAnnotation peekabooAnnotationWithPeekabooInfo:peekabooInfo];
            [weakSelf.mapView addAnnotation:peekabooAnnotation];
            CLCircularRegion *region = [weakSelf.locationManager startMonitorRegionWithCenter:peekabooAnnotation.coordinate radius:peekabooAnnotation.radius identifier:peekabooAnnotation.identifier];
            weakSelf.regionsDict[region.identifier] = region;
            [weakSelf.mapView hideIndicator];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //等到下一个loop获取annotationView
                if ([region containsCoordinate:userCoordinate]) {
                    MKAnnotationView *annotationView = [weakSelf.mapView annotationViewWithAnnotationIdentifier:region.identifier];
                    peekabooAnnotation.canShowCallout = YES;
                    annotationView.canShowCallout = YES;
                }
            });
        }];
    }];
    
    [self.locationManager startGeocoding];
    
    [self removeNotifications];
}

#pragma mark - touch event

- (void)tapOnView:(UITapGestureRecognizer *)tap
{
    [self showSubviewsWithStatus:self.authorizationStatus];
}

- (void)popIntroduce
{
    
}

#pragma mark - getter

- (PeekabooMap *)mapView
{
    if (!_mapView) {
        _mapView = [PeekabooMap mapViewWithFrame:self.view.frame];
    }
    return _mapView;
}

- (LocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [LocationManager locationManager];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (PeekabooManager *)peekabooManger
{
    if (!_peekabooManger) {
        _peekabooManger = [PeekabooManager peekabooManager];
    }
    return _peekabooManger;
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    }
    return _tapGesture;
}

- (NSMutableDictionary<NSString *, CLCircularRegion *> *)regionsDict
{
    if (!_regionsDict) {
        _regionsDict = [NSMutableDictionary dictionary];
    }
    return _regionsDict;
}

@end
