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
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [_colorImageView setImage:[UIImage imageNamed:@"bg_horizon.jpg"]];
    [self.videoCamera start];
}


- (void)saveFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR{
    //    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"LBPHmodel" ofType:@"xml" ];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPHmodel.xml"];
    const cv::String filename=([LBPHfilePath UTF8String]);
    LBPHFR->save(filename);
}

- (void)loadFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPHmodel.xml"];
    const cv::String filename=([LBPHfilePath UTF8String]);
    //cv::Ptr<cv::face::FaceRecognizer> LBPHFR=cv::face::createLBPHFaceRecognizer();
    LBPHFR->load(filename);
}

- (void)trainFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR andUser:(NSString*) username andLabel: (int)label andTrainNum:(NSInteger)imageNum{
    
    std::vector<cv::Mat> Images;
    std::vector<int> Lables;
    
    for(int i=1; i<=imageNum; i++){
        //NSString *path = [[NSBundle mainBundle] pathForResource:@"pattern" ofType:@"bmp"];
        //const char * cpath = [path cStringUsingEncoding:NSUTF8StringEncoding];
        //cv::Mat img_object = cv::imread( cpath, CV_LOAD_IMAGE_GRAYSCALE );
        
        NSString *filename = [NSString stringWithFormat: @"%@%@",
                              username, [@(i) stringValue]];
        NSLog(@"%@",filename);
        NSString* filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"JPG" ];
        const char * cpath = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
        cv::Mat cvImage = cv::imread( cpath, CV_LOAD_IMAGE_GRAYSCALE );
        
        if(cvImage.data )                              // Check for invalid input
        {
            NSLog(@"!!!");
            Images.push_back(cvImage);Lables.push_back(label);
        }
    }
    LBPHFR->update(Images, Lables);
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
            _faceCascade->detectMultiScale(image_roi_clone, _faces, 2, 3, 0, cv::Size(50,50));
            if (_faces.size() > 0) {
                NSLog(@"Found %@ faces!\n", @(_faces.size()));
            }
            for(int i =0; i <_faces.size(); i++){
                NSString* imagename = [NSString stringWithFormat:@"faces_%.4d.jpg", _imagename_count];
                _imagename_count++;
                cv::Mat face_image=image_roi_clone(_faces[i]).clone();
                cv::cvtColor(image_roi_clone(_faces[i]), face_image, CV_BGRA2RGB);
                [Utils saveMATImage:face_image andName:imagename];
                cv::Mat image_face_roi = image_roi_clone(_faces[i]);
                _eyes.clear();
                _eyeCascade->detectMultiScale(image_face_roi, _eyes);
                if (_eyes.size() > 0) {
                    NSLog(@"Found %@ eyes!\n", @(_eyes.size()));
                }
                
                if (2 == _eyes.size()) {
                    cv::Mat eyeLeft = (cv::Mat_<double>(1,2)<< _eyes[0].x + _eyes[0].width/2, _eyes[0].y + _eyes[0].height/2);
                    cv::Mat eyeRight = (cv::Mat_<double>(1,2)<< _eyes[1].x + _eyes[1].width/2, _eyes[1].y + _eyes[1].height/2);
                    cv::Mat offset =  (cv::Mat_<double>(1,2)<< 0.2, 0.2);
                    cv::Mat dst_sz = (cv::Mat_<double>(1,2)<< 70, 70);
                    cv::Mat normalFaceImg = [Utils normalizeFace:image_roi(_faces[i]) andEyeLeft: eyeLeft andEyeRight: eyeRight andOffset: offset andDstsize: dst_sz];
                    [Utils saveMATImage:normalFaceImg andName:@"NormalFace.jpg"];
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
            int radius = cvRound((_eyes[j].width + _eyes[j].height)*0.25 );
            cv::circle(image_face_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
        }
        NSString *imagename = [NSString stringWithFormat:@"%d.jpg", _imagename_count];
        cv::Mat image_eye_roi = image_roi(_faces[i]).clone();
        [Utils saveMATImage: image_eye_roi andName: imagename];
        
        _eyeCascade->detectMultiScale(image_eye_roi, _eyes);
        NSLog(@"Found %@ eyes!\n", @(_eyes.size()));
        for (int j = 0; j<_eyes.size(); j++) {
            cv::Point eye_center( _eyes[j].x + _eyes[j].width/2, _eyes[j].y + _eyes[j].height/2 );
            int radius = cvRound((_eyes[j].width + _eyes[j].height)*0.25 );
            cv::circle(image_eye_roi, eye_center, radius, cv::Scalar( 255, 0, 255 ), 1, 8);
        }

    }
    
    _LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer();
    //cv::Ptr<cv::face::FaceRecognizer>_LBPHFaceRecognizer1=cv::face::createLBPHFaceRecognizer();
    //    [self saveFaceRecognizer:_LBPHFaceRecognizer];
    //    [self loadFaceRecognizer:_LBPHFaceRecognizer];
    //[self trainFaceRecognizer:_LBPHFaceRecognizer andUser:@"xiang" andLabel:1 andTrainNum:9];
    //[self trainFaceRecognizer:_LBPHFaceRecognizer andUser:@"ha" andLabel:2 andTrainNum:9];
    //[self saveFaceRecognizer:_LBPHFaceRecognizer];
    [self loadFaceRecognizer:_LBPHFaceRecognizer];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"yiwen2" ofType:@"JPG" ];
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
