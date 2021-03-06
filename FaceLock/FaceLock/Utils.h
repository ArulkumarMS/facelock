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
+ (BOOL) saveUIImage:(UIImage*)image andName:(NSString *)imagename;
+ (BOOL) saveMATImage: (cv::Mat) img andName:(NSString*) imagename;
+ (cv::Mat) loadImage2MAT: (NSString*) imagename;
+ (void) saveMAT: (cv::Mat) cvMat andName:(NSString*) imagename  andKey:(NSString*) keyname;
+ (cv::CascadeClassifier*)loadClassifier: (NSString*) model_file_path;
+ (cv::Mat) normalizeFace:(cv::Mat)img andFaceSize:(cv::Point)face_size andNoise:(cv::Point)nose;
+ (cv::Mat) normalizeFace: (cv::Mat) img andEyeLeft: (cv::Point) leftEye andEyeRight:(cv::Point) rightEye andFaceSize: (cv::Point) face_size andHistEqual: (BOOL) doLeftandRightSeparately;
+ (void) equalizeLeftAndRightHalves: (cv::Mat&) faceImg;
@end
