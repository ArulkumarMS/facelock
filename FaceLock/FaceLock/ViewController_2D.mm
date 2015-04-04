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
    _count = 0;
    _imagename_count = 0;
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

- (BOOL) saveMATImage:(cv::Mat)img andName:(NSString *)imagename{
//    NSLog(@"W: %d, H: %d", img.cols, img.rows);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imagename]];
    UIImage* image = [UIImageCVMatConverter UIImageFromCVMat:img];
//    NSLog(@"UIImage: W: %d, H: %d", image.)
    BOOL result = [UIImageJPEGRepresentation(image, 1)writeToFile:filePath atomically:YES];
    
//    if (result) {
//        NSLog(@"Image saved");
//    }
    
    return result;
}

- (cv::Mat) loadImage2MAT:(NSString *)imagename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *img_path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imagename]];
    NSData *img_data = [NSData dataWithContentsOfFile:img_path];
    UIImage *uiimage = [UIImage imageWithData:img_data];
    cv::Mat cvimage = [UIImageCVMatConverter cvMatFromUIImage:uiimage];
    return cvimage;
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
    cv::Mat image_roi = image(roi);
    // Detection and Recognition every roundly 10 frames
    if (_count == 1) {
        __block cv::Mat image_roi_clone = image_roi.clone();
        //cv::cvtColor(image_roi_clone, image_roi_clone, CV_BGRA2RGB);
        dispatch_queue_t face_recognition_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(face_recognition_queue, ^{
            // Perform long running process
//            NSString* imagename = [NSString stringWithFormat:@"roi_%.4d.jpg", _imagename_count];
//            _imagename_count++;
//            [self saveMATImage:image_roi_clone andName:imagename];
//            NSLog(@"Detecting face...\n");
            _faceCascade->detectMultiScale(image_roi_clone, _faces, 2, 3, 0, cv::Size(50,50));
            if (_faces.size() > 0) {
                NSLog(@"Found %@ faces!\n", @(_faces.size()));
            }
            for(int i =0; i <_faces.size(); i++){
                NSString* imagename = [NSString stringWithFormat:@"faces_%.4d.jpg", _imagename_count];
                _imagename_count++;
                cv::Mat face_image=image_roi_clone(_faces[i]).clone();
                cv::cvtColor(image_roi_clone(_faces[i]), face_image, CV_BGRA2RGB);
                [self saveMATImage:face_image andName:imagename];
                cv::Mat image_face_roi = image_roi_clone(_faces[i]);
                _eyes.clear();
                _eyeCascade->detectMultiScale(image_face_roi, _eyes);
                if (_eyes.size() > 0) {
                    NSLog(@"Found %@ eyes!\n", @(_eyes.size()));
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
            NSLog(@"%d %d %d %d %d", _count, i, j, eye_center.x, eye_center.y);
//            int radius = cvRound((_eyes[j].width + _eyes[j].height)*0.25 );
//            cv::circle(image_face_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
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
