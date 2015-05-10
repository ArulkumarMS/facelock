//
//  ViewController_AddUser.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/10/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/face.hpp>
#import <opencv2/face/facerec.hpp>
#import "TableViewController_AddUser.h"
#import "Setting_UserManagement.h"
#import "ViewController_Take2DImage.h"
#import "ViewController_Take3DImage.h"
#import "FaceRecognition_2D.h"


@interface ViewController_AddUser : UIViewController{
    NSString *fullname;
    cv::Ptr<cv::face::FaceRecognizer> _LBPHFaceRecognizer;
}
@property (weak, nonatomic) IBOutlet UITextField *TFFirstName;
@property (weak, nonatomic) IBOutlet UITextField *TFLastName;
@property (weak, nonatomic) IBOutlet UILabel *LBNotification;
@end