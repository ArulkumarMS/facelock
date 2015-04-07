//
//  Utils.h
//  FaceLock
//
//  Created by Alan Xu on 4/3/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import "UIImageCVMatConverter.h"

@interface Utils : NSObject{
}

+ (BOOL) saveMATImage: (cv::Mat) img andName:(NSString*) imagname;
+ (cv::Mat) loadImage2MAT: (NSString*) imagename;
+ (cv::Mat) normalizeFace: (cv::Mat) img andEyeLeft: (cv::Mat) eye_left andEyeRight:(cv::Mat) eye_right andOffset:(cv::Mat) offset andDstsize: (cv::Mat) dest_size;
+ (cv::Mat) ScaleRotateTranslate: (cv::Mat&)image andEyeLeft:(cv::Mat) eye_Left andRotation: (double) angle andScale:(double) scale;
+ (void) equalizeLeftAndRightHalves: (cv::Mat&) faceImg;

+ (cv::CascadeClassifier*)loadClassifier: (NSString*) model_file_path;
@end
