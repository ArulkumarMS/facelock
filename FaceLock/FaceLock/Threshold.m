//
//  Threshold.m
//  FaceLock
//
//  Created by Yiwen Shi on 5/4/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "Threshold.h"

static double Threshold2D = 0; // static means it is only accessible from the current file
static double Threshold3D = 0;

@implementation Threshold

+ (double)getThreshold_2D {
    return Threshold2D;
}
+ (void)setThreshold_2D:(double)newThreshold2D {
    Threshold2D = newThreshold2D;
}

+ (double)getThreshold_3D {
    return Threshold3D;
}
+ (void)setThreshold_3D:(double)newThreshold3D {
    Threshold3D = newThreshold3D;
}
@end