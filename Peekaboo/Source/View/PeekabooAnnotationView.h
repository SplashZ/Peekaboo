//
//  PeekabooAnnotationView.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PeekabooAnnotationView : MKAnnotationView

@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, strong) UIImage *calloutImage;
@property (nonatomic, assign) BOOL showOverlay;
@property (nonatomic, copy) void(^CalloutDidClick)(void);

- (void)removeRadiusOverlay;
- (void)updateRadiusOverlay;

@end
