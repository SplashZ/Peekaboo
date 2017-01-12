//
//  PlayerAnnotationView.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PlayerAnnotationView : MKAnnotationView

@property (nonatomic, weak) MKMapView *mapView;

- (void)removeRadiusOverlay;
- (void)updateRadiusOverlayAndAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
