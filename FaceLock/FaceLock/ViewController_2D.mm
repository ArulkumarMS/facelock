//
//  ViewController_2D.m
//  FaceLock
//
//  Created by Alan Xu on 3/19/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_2D.h"


@interface ViewController_2D (){
    
}

@end

@implementation ViewController_2D

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize counting variables
    _count = 0;
    _imagename_count = 0;
    logger = [[NSLogger alloc] init];

    // Load face detector and eye detector models
    _faceCascade = [Utils loadClassifier:@"haarcascade_frontalface_alt2"];
    _eyeCascade = [Utils loadClassifier:@"haarcascade_eye"];
    _lefteyeCascade = [Utils loadClassifier:@"haarcascade_lefteye_2splits"];
    _righteyeCascade = [Utils loadClassifier:@"haarcascade_righteye_2splits"];
    
    // Load threshold
    threshold2D = [[Threshold Load2DThresholdFile] doubleValue];
    NSLog(@"Threshold 2D: %.4f",threshold2D);
    // Load username
    UserName = [Setting_UserManagement LoadUserFile];
    // Load face recognition model
    _LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer();
//    _LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer(2,16,16,16,threshold2D);
    if (![FaceRecognition_2D LBPHfileExist]){
            [FaceRecognition_2D loadDefaultFaceRecognizer:_LBPHFaceRecognizer];
    } else {

        [FaceRecognition_2D loadFaceRecognizer:_LBPHFaceRecognizer];
    }

    // Setup camera view
    CGRect colorFrame = self.view.frame;
    _colorImageView = [[UIImageView alloc]initWithFrame:colorFrame];
    _colorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_colorImageView];
    // Call OPENCV video camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_colorImageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.videoCamera start];

    UserName = [Setting_UserManagement LoadUserFile];
    _LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer();
    if (UserName.count == 0) {
        [FaceRecognition_2D loadDefaultFaceRecognizer:_LBPHFaceRecognizer];
    } else
    {
        for(int i=0;i<=[UserName count]-1;i++){
            [FaceRecognition_2D trainFaceRecognizer:_LBPHFaceRecognizer andUser:UserName[i] andLabel:i andTrainNum:50];
        }
    }
    threshold2D=[[Threshold Load2DThresholdFile] doubleValue];
    NSLog(@"threshold is %f",threshold2D);
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.videoCamera stop];
}

#pragma mark -Protocol CvVideoCameraDelegate
#ifdef __cplusplus

- (void) processImage:(cv::Mat &)image{
    _count++;
    // Draw a detection boundary
//    cv::Rect roi = cv::Rect(0.25*image.cols,0,image.cols/2,image.rows);
//    cv::rectangle(image, roi, cv::Scalar(0, 255, 0), 1, 8);
//    cv::Mat image_roi = image(roi);

    // Detection and Recognition every roundly 10 frames
    if (_count == 1) {
        // Since we will run this part in another thread, we need to clone a copy of detection region
        __block cv::Mat image_roi_clone = image.clone();
        // Run face detection, eye detection and face recognition in a thread (using global thread pool)
        dispatch_queue_t face_recognition_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(face_recognition_queue, ^{
            // Detect face using Haar features
            std::vector<cv::Rect> _faces;
            std::vector<cv::Rect> _eyes;
            _faceCascade->detectMultiScale(image_roi_clone, _faces, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(200,200), cv::Size(image.cols, image.cols));
            for(int i =0; i <_faces.size(); i++){
                _imagename_count++;
                NSString* imagename = [NSString stringWithFormat:@"face_%.4d.jpg", _imagename_count];
                cv::Mat face_image = image_roi_clone(_faces[i]).clone();
                [Utils saveMATImage:face_image andName:imagename];
                
                // Get face region
                cv::Mat image_face_roi = image_roi_clone(_faces[i]);
                // Eye detection
                cv::Point leftEyeCenter, rightEyeCenter;
                cv::Rect leftROI = cv::Rect(0, 0, image_face_roi.cols/2, image_face_roi.rows/2);
                cv::Rect rightROI = cv::Rect(image_face_roi.cols/2, 0, image_face_roi.cols/2, image_face_roi.rows/2);
                bool foundEyes = false;
                
                _eyeCascade->detectMultiScale(image_face_roi, _eyes,1.1, 3, 0|CV_HAAR_SCALE_IMAGE);

                if (_eyes.size() == 2) {
                    foundEyes = true;
                    cv::Point eye_one( _eyes[0].x + _eyes[0].width/2, _eyes[0].y + _eyes[0].height/2 );
                    cv::Point eye_two( _eyes[1].x + _eyes[1].width/2, _eyes[1].y + _eyes[1].height/2 );
                    if (eye_one.x <= eye_two.x) {
                        leftEyeCenter = eye_one;
                        rightEyeCenter = eye_two;
                    } else {
                        leftEyeCenter = eye_two;
                        rightEyeCenter = eye_one;
                    }
                } else {
                    _lefteyeCascade->detectMultiScale(image_face_roi(leftROI), _eyes,1.1, 3, 0|CV_HAAR_SCALE_IMAGE);
                    if (_eyes.size() == 1) {
                        cv::Rect leftEyeRect = _eyes[0];
                        leftEyeCenter = cv::Point( _eyes[0].x + _eyes[0].width/2, _eyes[0].y + _eyes[0].height/2 );
                        _righteyeCascade->detectMultiScale(image_face_roi(rightROI), _eyes,1.1, 3, 0|CV_HAAR_SCALE_IMAGE);
                        if (_eyes.size() == 1) {
                            foundEyes = true;
                            rightEyeCenter = cv::Point( rightROI.x + _eyes[0].x + _eyes[0].width/2, _eyes[0].y + _eyes[0].height/2 );
                            _eyes.push_back(leftEyeRect);
                        }
                    }
                }
                
                if (foundEyes) {
                    // Face Alignment
                    cv::Point face_size(200,200);
                    cv::Mat normalFaceImg;
                    normalFaceImg = [Utils normalizeFace:image_face_roi.clone()
                                              andEyeLeft: leftEyeCenter
                                             andEyeRight: rightEyeCenter
                                             andFaceSize: face_size
                                            andHistEqual: true];
                    
                    imagename = [NSString stringWithFormat:@"aligned_face_%.4d.jpg", _imagename_count];
                    [Utils saveMATImage:normalFaceImg andName:imagename];
                    
                    
                    //Face recognition
                    int label;
                    double predicted_confidence;
                    _LBPHFaceRecognizer->predict(normalFaceImg, label, predicted_confidence);
                    NSString* event = [NSString stringWithFormat:@"Label: %d Confidence: %.4f",label, predicted_confidence];
                    [logger log:event];
                    NSLog(@"Label: %d Confidence %.4f\n", label, predicted_confidence);
                    if(label >= 0 && label < UserName.count && predicted_confidence < threshold2D){
                        NSString* welcome=[NSString stringWithFormat:@"Welcome back, %@", UserName[label]];
                        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
                        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:welcome];
                        [utterance setRate:0.1f];
                        [synthesizer speakUtterance:utterance];
                    }
//                    else{
//                        NSLog(@"Sorry, you can not enter the door.\n");
//                        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
//                        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Sorry, you can not enter the door."];
//                        [utterance setRate:0.1f];
//                        [synthesizer speakUtterance:utterance];
//                    }
                    
                }
                
            }
            
            // Update the face and eye locations to the UI thread
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                _mfaces = _faces;
                _meyes = _eyes;
                
            });
            _count = 0; //Reset _count
        });
    }

    // Draw face and eye boundaries
    if ((_mfaces.size() == 1) && (_meyes.size() <= 2)){
        cv::rectangle(image, _mfaces[0], cv::Scalar(0, 255, 255), 1, 8);
        cv::Mat image_face_roi = image(_mfaces[0]);
        for (int j = 0; j<_meyes.size(); j++) {
            cv::Point eye_center( _meyes[j].x + _meyes[j].width/2, _meyes[j].y + _meyes[j].height/2 );
            int radius = cvRound((_meyes[j].width + _meyes[j].height)*0.25 );
            cv::circle(image_face_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
        }
    }
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
