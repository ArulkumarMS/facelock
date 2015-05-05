//
//  Threshold.h
//  FaceLock
//
//  Created by Yiwen Shi on 5/4/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Threshold : NSObject

+ (BOOL)Threshold2dfileExist;
+ (NSString *) Load2DThresholdFile;
+ (void) init2DThresholdFile;
+ (void) Save2DThresholdFile:(NSString *)Threshold2D;
+ (BOOL)Threshold3dfileExist;
+ (NSString *) Load3DThresholdFile;
+ (void) init3DThresholdFile;
+ (void) Save3DThresholdFile:(NSString *)Threshold3D;
@end