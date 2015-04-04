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
    // Do any additional setup after loading the view.
    _count = 0;
    CGRect colorFrame = self.view.frame;
    _colorImageView = [[UIImageView alloc]initWithFrame:colorFrame];
    _colorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_colorImageView];
    // Create face detector
    _faceCascade = [self loadClassifier:@"haarcascade_frontalface_alt2"];
    _eyeCascade = [self loadClassifier:@"haarcascade_eye_tree_eyeglasses"];
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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [_colorImageView setImage:[UIImage imageNamed:@"bg_horizon.jpg"]];
    [self.videoCamera start];
}

- (cv::CascadeClassifier*)loadClassifier: (NSString*) haar_file_path{
    NSString* haar = [[NSBundle mainBundle]pathForResource:haar_file_path ofType:@"xml"];
    cv::CascadeClassifier* cascade = new cv::CascadeClassifier();
    cascade->load([haar UTF8String]);
    return cascade;
}

#pragma mark -Protocol CvVideoCameraDelegate
#ifdef __cplusplus

- (void) processImage:(cv::Mat &)image{
    _count++;
    cv::Rect roi = cv::Rect(0.25*image.cols,0,image.cols/2,image.rows);
    cv::rectangle(image, roi, cv::Scalar(0, 255, 0), 1, 8);
    cv::Mat image_roi = image(roi).clone();
    if (_count == 30) {
        // dispatch_queue_t face_recognition_queue = dispatch_queue_create("Face Recognition Queue",NULL);
        dispatch_queue_t face_recognition_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(face_recognition_queue, ^{
            // Perform long running process
            NSLog(@"Detecting face...\n");
            _faceCascade->detectMultiScale(image_roi, _faces, 2, 3, 0, cv::Size(50,50));
            NSLog(@"Found %@ faces!\n", @(_faces.size()));
            for(int i =0; i<_faces.size(); i++){
                //cv::rectangle(image_roi, _faces[i], cv::Scalar(0, 255, 255), 1, 8);
                
                cv::Mat image_eye_roi = image_roi(_faces[i]);
                _eyeCascade->detectMultiScale(image_eye_roi, _eyes);
                NSLog(@"Found %@ eyes!\n", @(_eyes.size()));
//                for (int j = 0; j<_eyes.size(); j++) {
//                    cv::Point eye_center( _eyes[j].x + _eyes[j].width/2, _eyes[j].y + _eyes[j].height/2 );
//                    int radius = cvRound((_eyes[j].width + _eyes[j].height)*0.25 );
//                    cv::circle(image_eye_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
//                    cv::rectangle(image_eye_roi, _eyes[j], cv::Scalar(0, 0, 255), 1, 8);
//                }
                
            }
            _count = 0; //Reset _count

            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                
            });
        });
        
        // Continue doing other stuff on the 
        // main thread while process is running.
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
