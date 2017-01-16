//
//  PeekabooMap.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <MapKit/MapKit.h>

FOUNDATION_EXTERN NSString *UserLocationDidUpdateNotification;

@class MKMapView, PeekabooMap, PeekabooAnnotationView, PeekabooAnnotation;

@protocol PeekabooMapDelegate <NSObject>

- (void)peekabooMap:(PeekabooMap *)peekabooMap didLeftCalloutClicked:(PeekabooAnnotation *)annotation;

@end

@interface PeekabooMap : UIView

@property (nonatomic, weak) id<PeekabooMapDelegate> delegate;

+ (instancetype)mapViewWithFrame:(CGRect)frame;
- (void)updateUserLocationWithTitle:(NSString *)title subTitle:(NSString *)subTitle;
- (PeekabooAnnotationView *)annotationViewWithAnnotationIdentifier:(NSString *)identifier;
- (void)addAnnotation:(id <MKAnnotation>)annotation;
- (void)showIndicator;
- (void)hideIndicator;
@end
