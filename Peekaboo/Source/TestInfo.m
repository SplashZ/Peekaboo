//
//  TestInfo.m
//  Peekaboo
//
//  Created by splashz on 2017/1/11.
//  Copyright © 2017 splashz. All rights reserved.
//

#import "TestInfo.h"
#import "PeekabooInfo.h"


@implementation TestInfo

static int latitudeDelta = 5000;
static int longitudeDelta = 3000;
static double radius = 300;
static NSArray * profiles = nil;

+ (void)initPlayersProfiles
{
    if (profiles) return;
    
    NSMutableArray *emojis = [NSMutableArray array];
    NSMutableArray *images = [NSMutableArray array];
    
    NSString *emojiStr = @"👶👦👧👨👩👱‍♀️👱👶🏿👴👵👲👳‍♀️👳👮‍♀️👮👷‍♀️👷💂‍♀️💂🕵️‍♀️🕵️🎅👸👼🙆‍♂️💆🏿🙎🏽🙎🏼‍♂️💆🏾‍♂️";
    NSRange range;
    for(int i=0; i<emojiStr.length; i+=range.length){
        range = [emojiStr rangeOfComposedCharacterSequenceAtIndex:i];
        [emojis addObject:[emojiStr substringWithRange:NSMakeRange(i, range.length)]];
    }
    
    [emojis enumerateObjectsUsingBlock:^(NSString  *_Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(32, 32), NO, [UIScreen mainScreen].scale);
        [str drawInRect:CGRectMake(0, 0, 32, 32) withAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:27]}];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        [images addObject:image];
        UIGraphicsEndImageContext();
    }];
    
    profiles = [images copy];
}

+ (NSArray<PeekabooInfo *> *)testInfoWithCurrentCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSMutableArray *arr = [NSMutableArray array];
    
    if (!profiles) {
        return arr;
    }
    
    for (int i = 0; i < profiles.count; i++) {
        PeekabooInfo *peekabooInfo = [PeekabooInfo new];
        
        uint32_t rand1 = arc4random_uniform(latitudeDelta);
        uint32_t rand2 = arc4random_uniform(longitudeDelta);
        
        peekabooInfo.latitude = rand1 % 2 ? -((double)rand1) / 1000000 : ((double)rand1) / 1000000;
        peekabooInfo.longitude = rand2 % 2 ? -((double)rand2) / 1000000 : ((double)rand2) / 1000000;
        
        peekabooInfo.latitude += coordinate.latitude;
        peekabooInfo.longitude += coordinate.longitude;
        
        peekabooInfo.radius = [self radius];
        
        peekabooInfo.profile = profiles[i];
        
        [arr addObject:peekabooInfo];
    }
    
    return arr;
}

+ (NSString *)userTitle
{
    return @"Mr. Zhi";
}

+ (double)radius
{
    return radius;
}


@end
