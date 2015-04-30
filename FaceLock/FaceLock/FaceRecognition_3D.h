//
//  FaceRecognition_3D.h
//  FaceLock
//
//  Created by Ha Le on 4/30/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/face.hpp>
#import <opencv2/face/facerec.hpp>


@interface FaceRecognition_3D : NSObject{
}

+ (BOOL)doesModelFileExist;
+ (void)saveFaceRecognizer: (cv::Ptr<cv::face::FaceRecognizer>) faceRecognizer;
+ (void)loadFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) faceRecognizer;
+ (void)trainFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) faceRecognizer andUser:(NSString*) username andLabel: (int)label andTrainNum:(NSInteger)imageNum;

@end
