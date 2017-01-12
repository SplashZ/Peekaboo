//
//  PlayerAnnotation.h
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PlayerAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) CLLocationDistance radius;

+ (instancetype)peekabooAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate
                                      radius:(CLLocationDistance)radius;

@end
