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
    UIImage* testImage = [UIImage imageNamed:@"bg_horizon.jpg"];
    //[self saveImage2:testImage andName:@"b.jpg"];
    cv::Mat testImage2 = [UIImageCVMatConverter cvMatFromUIImage:testImage];
    UIImage* testImage3 = [UIImageCVMatConverter UIImageFromCVMat:testImage2];
    [self saveImage2:testImage3 andName: @"c.jpg"];
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

#pragma mark - Save Image to Sandbox/Documents

- (BOOL) saveImage:(cv::Mat)img andName:(NSString *)imagname{
    NSLog(@"W: %d, H: %d", img.cols, img.rows);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imagname]];
    UIImage* image = [UIImageCVMatConverter UIImageFromCVMat:img];
    // NSLog(@"UIImage: W: %d, H: %d", image.)
    BOOL result = [UIImageJPEGRepresentation(image, 1)writeToFile:filePath atomically:YES];
    
    if (result) {
        NSLog(@"Save Correctly...");
    }else{
        NSLog(@"Save Problem...");
    }
    
    return result;
}

- (BOOL) saveImage2:(UIImage*)image andName:(NSString *)imagname{
    //NSLog(@"W: %d, H: %d", img.cols, img.rows);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imagname]];
    //UIImage* image = [UIImageCVMatConverter UIImageFromCVMat:img];
    // NSLog(@"UIImage: W: %d, H: %d", image.)
    BOOL result = [UIImageJPEGRepresentation(image, 1)writeToFile:filePath atomically:YES];
    
    if (result) {
        NSLog(@"Save Correctly...");
    }else{
        NSLog(@"Save Problem...");
    }
    
    return result;
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
    //Do some openCV stuff with the image
    //NSLog(@"It calls processing Image function\n");
    _count++;
//    cv::Rect roit = cv::Rect(0,0,100,100);
//    cv::rectangle(image, roit, cv::Scalar(255, 0, 0), 1, 8);
    cv::Rect roi = cv::Rect(0.25*image.cols,0,image.cols/2,image.rows);
    cv::rectangle(image, roi, cv::Scalar(0, 255, 0), 1, 8);
    
    if (_count == 1) {
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if(orientation == UIDeviceOrientationLandscapeLeft)
        {
            //NSLog(@"Landscape Left...\n");
        }
        //NSLog(@"Detecting face...\n");
        cv::Mat image_roi = image(roi);
        _faceCascade->detectMultiScale(image_roi, _faces, 2, 3, 0, cv::Size(50,50));
        NSLog(@"Found %@ faces!\n", @(_faces.size()));
        for(int i =0; i<_faces.size(); i++){
            cv::rectangle(image_roi, _faces[i], cv::Scalar(0, 255, 255), 1, 8);
            NSString* imagename = @"a.jpg";
            
            
            cv::Mat image_eye_roi = image_roi(_faces[i]).clone();
            UIImage* saveimage = [UIImageCVMatConverter UIImageFromCVMat:image_eye_roi];
            [self saveImage2: saveimage andName: imagename];
            
            _eyeCascade->detectMultiScale(image_eye_roi, _eyes);
            NSLog(@"Found %@ eyes!\n", @(_eyes.size()));
            for (int j = 0; j<_eyes.size(); j++) {
                cv::Point eye_center( _eyes[j].x + _eyes[j].width/2, _eyes[j].y + _eyes[j].height/2 );
                int radius = cvRound((_eyes[j].width + _eyes[j].height)*0.25 );
                cv::circle(image_eye_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
                //cv::rectangle(image_eye_roi, _eyes[j], cv::Scalar(0, 0, 255), 1, 8);
            }
        }
        _count = 0; //Reset _count, (Ha Le)
        //});
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
