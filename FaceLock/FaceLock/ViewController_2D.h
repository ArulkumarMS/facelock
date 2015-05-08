//
//  ViewController_2D.h
//  FaceLock
//
//  Created by Alan Xu on 3/19/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#ifdef __cpluscplus
#import <opencv2/opencv.hpp>
#endif
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/face.hpp>
#import <opencv2/face/facerec.hpp>
#import "UIImageCVMatConverter.h"
#import "Utils.h"
#import "NSLogger.h"
#import "FaceRecognition_2D.h"
#import "Setting_UserManagement.h"
#import "Threshold.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>


@interface ViewController_2D : UIViewController <CvVideoCameraDelegate>{
    UIImageView *_colorImageView;
    CvVideoCamera* _videoCamera;
    int _count;
    int _imagename_count;
    NSLogger* logger;
    cv::CascadeClassifier *_faceCascade;
    cv::CascadeClassifier *_eyeCascade;
    cv::CascadeClassifier *_lefteyeCascade;
    cv::CascadeClassifier *_righteyeCascade;
    std::vector<cv::Rect> _mfaces;
    std::vector<cv::Rect> _meyes;
    CGContextRef _contextRef;
    cv::Ptr<cv::face::FaceRecognizer> _LBPHFaceRecognizer;
    NSString *user;
    NSMutableArray *UserName;
    double threshold2D;
}
@property (nonatomic, retain) CvVideoCamera* videoCamera;



@end
