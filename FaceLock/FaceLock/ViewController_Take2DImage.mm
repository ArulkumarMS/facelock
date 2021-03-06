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
    _imagename_count = 1;
    logger = [[NSLogger alloc] init];
    CGRect colorFrame = self.view.frame;
    _colorImageView = [[UIImageView alloc]initWithFrame:colorFrame];
    _colorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_colorImageView];
    // Create face detector
    _faceCascade = [Utils loadClassifier:@"haarcascade_frontalface_alt2"];
    _eyeCascade = [Utils loadClassifier:@"haarcascade_eye"];
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
}

- (void)viewDidDisappear:(BOOL)animated{
    //    [super viewDidDisappear:<#animated#>];
    [self.videoCamera stop];
}

#pragma mark -Protocol CvVideoCameraDelegate
#ifdef __cplusplus

- (void) processImage:(cv::Mat &)image{
    _count++;
    // Draw a detection boundary
    cv::Rect roi = cv::Rect(0.25*image.cols,0,image.cols/2,image.rows);
    cv::rectangle(image, roi, cv::Scalar(0, 255, 0), 1, 8);
    cv::Mat image_roi = image(roi);
    
    
    /*// Face Detection using LBP features, faster but unstable
     _faceCascade->detectMultiScale(image_roi, _mfaces, 2, 3, 0, cv::Size(50,50));
     if (_mfaces.size() > 0) {
     NSLog(@"Found %@ faces!\n", @(_mfaces.size()));
     }
     */
    
    // Detection and Recognition every roundly 10 frames
    if (_count == 1) {
        // Since we will run this part in another thread, we need to clone a copy of detection region
        __block cv::Mat image_roi_clone = image_roi.clone();
        //cv::cvtColor(image_roi_clone, image_roi_clone, CV_BGRA2RGB);
        
        // Run face detection, eye detection and face recognition in a thread (using global thread pool)
        dispatch_queue_t face_recognition_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(face_recognition_queue, ^{
            // Detect face using Haar features
            std::vector<cv::Rect> _faces;
            std::vector<cv::Rect> _eyes;
            _faceCascade->detectMultiScale(image_roi_clone, _faces, 1.1, 1, 0|CV_HAAR_SCALE_IMAGE, cv::Size(200,200), cv::Size(image.cols, image.cols));
            if (_faces.size() > 0) {
                //                NSLog(@"Found %@ faces!\n", @(_faces.size()));
            }
            for(int i =0; i <_faces.size(); i++){
                
                if (_imagename_count<=50) {
                
                    cv::Mat face_image = image_roi_clone(_faces[i]).clone();
                    // Get face region
                    cv::Mat image_face_roi = image_roi_clone(_faces[i]);
                    // Eye detection
                    _eyeCascade->detectMultiScale(image_face_roi, _eyes,1.1, 3, 0|CV_HAAR_SCALE_IMAGE);
                    //                _eyeCascade->detectMultiScale(image_face_roi, _eyes);
                
                    if (_eyes.size() > 0) {
                        //                    NSLog(@"Found %@ eyes!\n", @(_eyes.size()));
                    }
                
                    if (_eyes.size() == 2) {
                    // Face Alignment
                        cv::Point eye_one( _eyes[0].x + _eyes[0].width/2, _eyes[0].y + _eyes[0].height/2 );
                        cv::Point eye_two( _eyes[1].x + _eyes[1].width/2, _eyes[1].y + _eyes[1].height/2 );
                        cv::Point face_size(200,200);
                        cv::Mat normalFaceImg;
                        if (eye_one.x <= eye_two.x) {
                            normalFaceImg = [Utils normalizeFace:image_face_roi.clone()
                                                  andEyeLeft: eye_one
                                                 andEyeRight: eye_two
                                                 andFaceSize: face_size
                                                andHistEqual: true];
                        } else {
                            normalFaceImg = [Utils normalizeFace:image_face_roi.clone()
                                                  andEyeLeft: eye_two
                                                 andEyeRight: eye_one
                                                 andFaceSize: face_size
                                                andHistEqual: true];
                        }
                    
                        NSString *imagename = [NSString stringWithFormat:@"%@2D%d.jpg", self.FullName, _imagename_count];
                        [Utils saveMATImage:normalFaceImg andName:imagename];
                        _imagename_count++;
                    }
                }
                else{
                    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
                    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Already taken fifty images, please go back."];
                    [utterance setRate:0.1f];
                    [synthesizer speakUtterance:utterance];
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
        cv::rectangle(image_roi, _mfaces[0], cv::Scalar(0, 255, 255), 1, 8);
        cv::Mat image_face_roi = image_roi(_mfaces[0]);
        for (int j = 0; j<_meyes.size(); j++) {
            cv::Point eye_center( _meyes[j].x + _meyes[j].width/2, _meyes[j].y + _meyes[j].height/2 );
            int radius = cvRound((_meyes[j].width + _meyes[j].height)*0.25 );
            cv::circle(image_face_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
        }
    }
}

#endif


/*
 - (void)startColorCamera {
 BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:(UIImagePickerControllerCameraDeviceFront)];
 if (!isCamera) {
 NSLog(@"Front Camera unvailuable! Pls Check!");
 return;
 }
 
 UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
 imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
 imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
 //imagePicker.delegate =;
 imagePicker.allowsEditing = YES;
 [self presentViewController:imagePicker animated:YES completion:^{}];
 }*/

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
