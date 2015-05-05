//
//  Setting_ImageManagement.h
//  FaceLock
//
//  Created by Yiwen Shi on 5/3/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Setting_ImageManagement : NSObject{
}

+ (BOOL)ImageExist:(NSString*)ImageName;
+ (UIImage*)loadImage:(NSString*)ImageName;
+ (void)removeImage:(NSString *)ImageName andTrainNum:(NSInteger)imageNum;
+ (void)removeOneImage:(NSString *)ImageName;

@end
