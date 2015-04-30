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
+ (cv::Mat) normalizeFace:(cv::Mat)img andFaceSize:(cv::Point)face_size;
+ (cv::Mat) normalizeFace: (cv::Mat) img andEyeLeft: (cv::Point) leftEye andEyeRight:(cv::Point) rightEye andFaceSize: (cv::Point) face_size andHistEqual: (BOOL) doLeftandRightSeparately;
+ (void) equalizeLeftAndRightHalves: (cv::Mat&) faceImg;

+ (cv::CascadeClassifier*)loadClassifier: (NSString*) model_file_path;
@end
