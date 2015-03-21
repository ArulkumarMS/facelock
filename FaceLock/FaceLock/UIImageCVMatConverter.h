//
//  UIImageCVMatConverter.h
//  FaceLock
//
//  Created by Alan Xu on 3/20/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/imgproc.hpp>

@interface UIImageCVMatConverter : NSObject{

}

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat withUIImage:(UIImage*)image;
+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;
+ (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageFrontCamera:(UIImage *)image;
+ (UIImage *)scaleAndRotateImageBackCamera:(UIImage *)image;
@end
