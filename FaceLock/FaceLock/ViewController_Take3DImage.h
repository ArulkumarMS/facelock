//
//  ViewController_Take3DImage.h
//  FaceLock
//
//  Created by Yiwen Shi on 5/9/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//


#ifdef __cpluscplus
#import <opencv2/opencv.hpp>
#endif
#import <UIKit/UIKit.h>
#import <Structure/Structure.h>
#import "Utils.h"
#import "UIImageCVMatConverter.h"
#import "NSLogger.h"
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/objdetect/objdetect.hpp>
#import <opencv2/face.hpp>
#import <opencv2/face/facerec.hpp>

#import "FaceRecognition_3D.h"
#import "Setting_UserManagement.h"
#import "Threshold.h"

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import "Setting_ImageManagement.h"

@interface ViewController_Take3DImage : UIViewController<STSensorControllerDelegate>{
}
@property(nonatomic) NSString *FullName;
@end
