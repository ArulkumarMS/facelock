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
    _faceCascade = [self loadClassifier];
    //_context = [CIContext contextWithOptions:nil];
    //_faceDectector = [CIDetector detectorOfType:CIDetectorTypeFace context:_context options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    // Call OPENCV video camera
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:_colorImageView];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [_colorImageView setImage:[UIImage imageNamed:@"bg_horizon.jpg"]];
    [self.videoCamera start];
}

- (cv::CascadeClassifier*)loadClassifier{
    NSString* haar = [[NSBundle mainBundle]pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
    cv::CascadeClassifier* cascade = new cv::CascadeClassifier();
    cascade->load([haar UTF8String]);
    return cascade;
}

#pragma mark -Protocol CvVideoCameraDelegate
#ifdef __cplusplus

- (void) processImage:(cv::Mat &)image{
    //Do some openCV stuff with the image
    //NSLog(@"It calls processing Image function\n");
    _count++;
    if (0 == _count%30) {
        NSLog(@"Detecting face...\n");
        _faceCascade->detectMultiScale(image, _faces);
        if (_faces.size() > 0) {
            NSLog(@"Found a face!\n");
        }
        for(int i =0; i<_faces.size(); i++){
            CvRect rect = _faces[i];
            cv::rectangle(image, cv::Point(rect.x, rect.y), cv::Point(rect.x + rect.width, rect.y + rect.height), cv::Scalar(0, 255, 255), 5, 8);
        }
        _count = 0; //Reset _count, (Ha Le)
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
