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
#import "UIImageCVMatConverter.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface ViewController_2D : UIViewController <CvVideoCameraDelegate>{
    UIImageView *_colorImageView;
    CvVideoCamera* _videoCamera;
    int _count;
    //CIDetector *_faceDectector;
    //CIContext *_context;
    //NSArray *_features;
    cv::CascadeClassifier *_faceCascade;
    std::vector<cv::Rect> _faces;
    CGContextRef _contextRef;
}
@property (nonatomic, retain) CvVideoCamera* videoCamera;

- (cv::CascadeClassifier*)loadClassifier;

@end
