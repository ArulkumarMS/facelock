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
    std::vector<cv::Rect> _faces;
    std::vector<cv::Rect> _eyes;
    CGContextRef _contextRef;
}
@property (nonatomic, retain) CvVideoCamera* videoCamera;

//- (cv::CascadeClassifier*)loadClassifier: (NSString*) haar_file_path;

//- (BOOL) saveImage2:(UIImage*)img andName:(NSString *)imagname;

//=======
- (cv::CascadeClassifier*)loadClassifier: (NSString*) model_file_path;
//- (BOOL) saveMATImage: (cv::Mat) img andName:(NSString*) imagename;
//- (cv::Mat) loadImage2MAT: (NSString*) imagename;

@end
