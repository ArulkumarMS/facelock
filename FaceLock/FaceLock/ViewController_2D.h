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
#import "UserDefaultsHelper.h"
#import "Constants.h"
#import "Setting_UserManagement.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

@interface ViewController_2D : UIViewController <CvVideoCameraDelegate>{
    UIImageView *_colorImageView;
    CvVideoCamera* _videoCamera;
    int _count;
    int _imagename_count;
    //CIDetector *_faceDectector;
    //CIContext *_context;
    //NSArray *_features;
    cv::CascadeClassifier *_faceCascade;
    cv::CascadeClassifier *_eyeCascade;
    std::vector<cv::Rect> _mfaces;
    std::vector<cv::Rect> _meyes;
    CGContextRef _contextRef;
    cv::Ptr<cv::face::FaceRecognizer> _LBPHFaceRecognizer;
    NSString *user;
    NSLogger* logger;
    NSMutableArray *UserName;
}
@property (nonatomic, retain) CvVideoCamera* videoCamera;



@end
