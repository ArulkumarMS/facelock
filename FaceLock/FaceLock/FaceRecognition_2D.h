//
//  FaceRecognition_2D.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/6/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/face.hpp>
#import <opencv2/face/facerec.hpp>


@interface FaceRecognition_2D : NSObject{
}

+ (BOOL)LBPHfileExist;
+ (void)saveFaceRecognizer: (cv::Ptr<cv::face::FaceRecognizer>) LBPHFR;
+ (void)loadFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR;
+ (void)trainFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR andUser:(NSString*) username andLabel: (int)label andTrainNum:(NSInteger)imageNum;

@end
