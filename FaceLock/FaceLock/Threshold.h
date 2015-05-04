//
//  Threshold.h
//  FaceLock
//
//  Created by Yiwen Shi on 5/4/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Threshold : NSObject
+ (double)getThreshold_2D;
+ (void)setThreshold_2D:(double)newThreshold2D;
+ (double)getThreshold_3D;
+ (void)setThreshold_3D:(double)newThreshold3D;
@end