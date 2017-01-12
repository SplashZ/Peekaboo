//
//  PeekabooAnnotation.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <MapKit/MapKit.h>

@class PeekabooInfo;

@interface PeekabooAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *locationDesc;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) UIImage *profile;
@property (nonatomic, copy) UIImage *accessoryImage;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) BOOL canShowCallout;

+ (instancetype)peekabooAnnotationWithPeekabooInfo:(PeekabooInfo *)peekabooInfo;

@end
