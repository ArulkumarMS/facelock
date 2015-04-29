//
//  ViewController_Take2DImage.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/21/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_Take2DImage.h"

@interface ViewController_Take2DImage (){
}

@end

@implementation ViewController_Take2DImage

- (void)viewDidLoad {
    [super viewDidLoad];
    _count = 0;
    _imagename_count = 0;
    CGRect colorFrame = self.view.frame;
    _colorImageView = [[UIImageView alloc]initWithFrame:colorFrame];
    _colorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_colorImageView];
    // Create face detector
    _faceCascade = [Utils loadClassifier:@"haarcascade_frontalface_alt2"];
    _eyeCascade = [Utils loadClassifier:@"haarcascade_eye_tree_eyeglasses"];
    //_context = [CIContext contextWithOptions:nil];
    //_faceDectector = [CIDetector detectorOfType:CIDetectorTypeFace context:_context options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    // Call OPENCV video camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_colorImageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    
    //if run FaceLock in the ios device first time, uncommend following part.
    BOOL flag_fr_initial = [UserDefaultsHelper getBoolForKey: Str_FR_Initial];
    if (flag_fr_initial){
        cv::Ptr<cv::face::FaceRecognizer> ini_LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer();
        [FaceRecognition_2D saveFaceRecognizer:ini_LBPHFaceRecognizer];
        [UserDefaultsHelper setBoolForKey:true andKey:Str_FR_Initial];
    }
    
    _LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer();
    [FaceRecognition_2D loadFaceRecognizer:_LBPHFaceRecognizer];
    NSLog(@"FULL NAME IS: %@", self.FullName);

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    [_colorImageView setImage:[UIImage imageNamed:@"bg_horizon.jpg"]];
    [self.videoCamera start];
}

- (void)viewDidDisappear:(BOOL)animated{
    //[super viewDidDisappear:<#animated#>];
    [self.videoCamera stop];
}

#pragma mark -Protocol CvVideoCameraDelegate
#ifdef __cplusplus

- (void) processImage:(cv::Mat &)image{
    _count++;
    cv::Rect roi = cv::Rect(0.25*image.cols,0,image.cols/2,image.rows);
    cv::rectangle(image, roi, cv::Scalar(0, 255, 0), 1, 8);
    cv::Mat image_roi = image(roi);
    //    _faceCascade->detectMultiScale(image_roi, _faces, 2, 3, 0, cv::Size(50,50));
    //    if (_faces.size() > 0) {
    //        NSLog(@"Found %@ faces!\n", @(_faces.size()));
    //    }
    
    // Detection and Recognition every roundly 10 frames
    if (_count == 1) {
        __block cv::Mat image_roi_clone = image_roi.clone();
        //cv::cvtColor(image_roi_clone, image_roi_clone, CV_BGRA2RGB);
        dispatch_queue_t face_recognition_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(face_recognition_queue, ^{
            // Perform long running process
            _faceCascade->detectMultiScale(image_roi_clone, _faces, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(200,200), cv::Size(image.cols, image.cols));
            if (_faces.size() > 0) {
                NSLog(@"Found %@ faces!\n", @(_faces.size()));
                //[self.navigationController popViewControllerAnimated:YES];
            }
            for(int i =0; i <_faces.size(); i++){
                cv::Mat image_face_roi = image_roi_clone(_faces[i]);
                _eyes.clear();
                _eyeCascade->detectMultiScale(image_face_roi, _eyes);
                
                if (_eyes.size() > 0) {
                    NSLog(@"Found %@ eyes!\n", @(_eyes.size()));
                }
                
                if (_eyes.size() == 2) {
                    cv::Point eye_one( _eyes[0].x + _eyes[0].width/2, _eyes[0].y + _eyes[0].height/2 );
                    cv::Point eye_two( _eyes[1].x + _eyes[1].width/2, _eyes[1].y + _eyes[1].height/2 );
                    cv::Point face_size(70,70);
                    cv::Mat normalFaceImg;
                    if (eye_one.x <= eye_two.x) {
                        normalFaceImg = [Utils normalizeFace:image_roi(_faces[i]).clone()
                                                  andEyeLeft: eye_one
                                                 andEyeRight: eye_two
                                                 andFaceSize: face_size
                                                andHistEqual:true];
                    } else {
                        normalFaceImg = [Utils normalizeFace:image_roi(_faces[i]).clone()
                                                  andEyeLeft: eye_two
                                                 andEyeRight: eye_one
                                                 andFaceSize: face_size
                                                andHistEqual:true];
                    }

                    NSString* imagename = [NSString stringWithFormat:@"%@%d.jpg", self.FullName,_imagename_count];
                    NSLog(@"IMAGE FILE NAME IS %@", imagename);
                    [Utils saveMATImage:normalFaceImg andName:imagename];
                    NSString *imagecount = [NSString stringWithFormat: @"Have Taken %@ Image",[@(_imagename_count) stringValue]];
                    [[NSNumber numberWithInt:_imagename_count] stringValue];
                    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
                    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:imagecount];
                    [utterance setRate:0.1f];
                    [synthesizer speakUtterance:utterance];
                    _imagename_count++;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                
            });
            _count = 0; //Reset _count
        });
    }
    
    // Draw face and eyes boundaries
    for(int i =0; i<_faces.size(); i++){
        cv::rectangle(image_roi, _faces[i], cv::Scalar(0, 255, 255), 1, 8);
        cv::Mat image_face_roi = image_roi(_faces[i]);
        for (int j = 0; j<_eyes.size(); j++) {
            cv::Point eye_center( _eyes[j].x + _eyes[j].width/2, _eyes[j].y + _eyes[j].height/2 );
            //NSLog(@"%d %d %d %d %d", _count, i, j, eye_center.x, eye_center.y);
            int radius = cvRound((_eyes[j].width + _eyes[j].height)*0.25 );
            cv::circle(image_face_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
        }
    }
    
    
    
    /*
     NSString* filePath = [[NSBundle mainBundle] pathForResource:@"yiwen10" ofType:@"JPG" ];
     UIImage* resImage = [UIImage imageWithContentsOfFile:filePath];
     cv::Mat newimg=[UIImageCVMatConverter cvMatGrayFromUIImage:resImage];
     int label;
     double predicted_confidence;
     _LBPHFaceRecognizer->predict(newimg,label,predicted_confidence);
     //[_colorImageView setImage:resImage  ];
     NSLog(@"Found %d,with confidence %f \n", label,predicted_confidence);
     if(predicted_confidence>20){//need to update after experiment.
     NSLog(@"Sorry, you can not enter the door.\n");
     AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
     AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Sorry, you can not enter the door."];
     [utterance setRate:0.1f];
     [synthesizer speakUtterance:utterance];
     }
     else{
     NSLog(@"Welcome Back.\n");
     AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
     AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Welcome back."];
     [utterance setRate:0.1f];
     [synthesizer speakUtterance:utterance];
     }
     
     */
}

#endif


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
