//
//  ViewController_3D.m
//  FaceLock
//
//  Created by Alan Xu on 4/16/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_3D.h"

struct AppStatus
{
    NSString* const pleaseConnectSensorMessage = @"Please connect Structure Sensor.";
    NSString* const pleaseChargeSensorMessage = @"Please charge Structure Sensor.";
    NSString* const needColorCameraAccessMessage = @"This app requires camera access to capture color.\nAllow access by going to Settings → Privacy → Camera.";
    
    enum SensorStatus
    {
        SensorStatusOk,
        SensorStatusNeedsUserToConnect,
        SensorStatusNeedsUserToCharge,
    };
    
    // Structure Sensor status.
    SensorStatus sensorStatus = SensorStatusOk;
    
    // Whether iOS camera access was granted by the user.
    bool colorCameraIsAuthorized = true;
    
    // Whether there is currently a message to show.
    bool needsDisplayOfStatusMessage = false;
    
    // Flag to disable entirely status message display.
    bool statusMessageDisabled = false;
};

@interface ViewController_3D () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    STSensorController *_sensorController;
    
    AVCaptureSession *_avCaptureSession;
    AVCaptureDevice *_videoDevice;
    
    UIImageView *_depthImageView;
    STFloatDepthFrame *_floatDepthFrame;
    STDepthToRgba *_rgbDepthFrame;
    
    UILabel* _statusLabel;
    
    AppStatus _appStatus;
    
    // Counting variables
    int _count;
    // Logger
    NSLogger *logger;
    // Face Recognition model
    cv::Ptr<cv::face::FaceRecognizer> _faceRecognizer;
    NSString *user;
    NSMutableArray *UserName;
    double threshold3D;
}

- (BOOL)connectAndStartStreaming;
- (void)renderDepthFrame:(STDepthFrame*)depthFrame;
- (BOOL)faceSegmentation:(cv::Mat&) depth_mat faceRect:(cv::Rect&) face faceMat:(cv::Mat&) face_mat;
- (void)faceRecognition:(cv::Mat&) depth_mat;
@end

@implementation ViewController_3D


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Init Counting variables
    _count = 0;
    // Logger Init
    logger = [[NSLogger alloc] init];
    
    // Load Face Recognition Model
//    if (![FaceRecognition_3D doesModelFileExist]){
//        cv::Ptr<cv::face::FaceRecognizer> initFaceRecognizer=cv::face::createLBPHFaceRecognizer();
//        [FaceRecognition_3D saveFaceRecognizer:initFaceRecognizer];
//        [FaceRecognition_3D loadFaceRecognizer:initFaceRecognizer];
//        //        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"YIWEN SHI" andLabel:0 andTrainNum:50];
//        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"HA LE" andLabel:1 andTrainNum:50];
//        //        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"SHIWANI BECTOR" andLabel:2 andTrainNum:50];
//        //        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"XIANG XU" andLabel:3 andTrainNum:50];
//        [FaceRecognition_3D saveFaceRecognizer:initFaceRecognizer];
//    }

    
    // Load threshold
    threshold3D = [[Threshold Load3DThresholdFile] doubleValue];
    NSLog(@"Threshold 3D: %.4f",threshold3D);
    // Load username
    UserName = [Setting_UserManagement LoadUserFile];
        // Load face recognition model
    _faceRecognizer=cv::face::createLBPHFaceRecognizer();
    if (![FaceRecognition_3D doesModelFileExist]){
        [FaceRecognition_3D loadDefaultFaceRecognizer:_faceRecognizer];
        [logger log:@"loaded Default Model"];
    } else {
        [FaceRecognition_3D loadFaceRecognizer:_faceRecognizer];
        [logger log:@"loaded Pretrained Model"];
    }
    

    // Structure Sensor Init
    _sensorController = [STSensorController sharedController];
    _sensorController.delegate = self;
    
    // Create three image views where we will render our frames
    
    CGRect depthFrame = self.view.frame;
    
    _depthImageView = [[UIImageView alloc] initWithFrame:depthFrame];
    _depthImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_depthImageView];
    
    
    [logger log:@"loaded Sensor"];
}

- (void)dealloc
{
}


- (void)viewDidAppear:(BOOL)animated
{
    static BOOL fromLaunch = true;
    if(fromLaunch)
    {
        
        //
        // Create a UILabel in the center of our view to display status messages
        //
        
        // We do this here instead of in viewDidLoad so that we get the correctly size/rotation view bounds
        if (!_statusLabel) {
            
            _statusLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
            _statusLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            _statusLabel.textAlignment = NSTextAlignmentCenter;
            _statusLabel.font = [UIFont systemFontOfSize:35.0];
            _statusLabel.numberOfLines = 2;
            _statusLabel.textColor = [UIColor whiteColor];
            
            [self updateAppStatusMessage];
            
            [self.view addSubview: _statusLabel];
        }
        
        [self connectAndStartStreaming];
        fromLaunch = false;
        
        // From now on, make sure we get notified when the app becomes active to restore the sensor state if necessary.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidBecomeActive)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
    }
    
    // Train
    UserName = [Setting_UserManagement LoadUserFile];
    _faceRecognizer=cv::face::createLBPHFaceRecognizer();
    if (UserName.count == 0) {
        [FaceRecognition_3D loadDefaultFaceRecognizer:_faceRecognizer];
    } else
    {
        for(int i=0; i < UserName.count; i++){
            [FaceRecognition_3D trainFaceRecognizer:_faceRecognizer andUser:UserName[i] andLabel:i andTrainNum:50];
        }
    }
    threshold3D=[[Threshold Load3DThresholdFile] doubleValue];
    NSLog(@"threshold is %f",threshold3D);
}


- (void)appDidBecomeActive
{
    [self connectAndStartStreaming];
}

- (void)viewDidDisappear:(BOOL)animated{
    [_sensorController stopStreaming];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)connectAndStartStreaming
{
    
    STSensorControllerInitStatus result = [_sensorController initializeSensorConnection];
    
    BOOL didSucceed = (result == STSensorControllerInitStatusSuccess || result == STSensorControllerInitStatusAlreadyInitialized);
    
    
    if (didSucceed)
    {
        // There's no status about the sensor that we need to display anymore
        _appStatus.sensorStatus = AppStatus::SensorStatusOk;
        [self updateAppStatusMessage];
        
        
        // Set sensor stream quality
        STStreamConfig streamConfig = STStreamConfigDepth320x240;
        
        
        // Request that we receive depth frames with synchronized color pairs
        // After this call, we will start to receive frames through the delegate methods
        NSError* error = nil;
        BOOL optionsAreValid = [_sensorController startStreamingWithOptions:@{kSTStreamConfigKey : @(streamConfig),
                                                                              kSTFrameSyncConfigKey : @(STFrameSyncOff)} error:&error];
        if (!optionsAreValid)
        {
            NSLog(@"Error during streaming start: %s", [[error localizedDescription] UTF8String]);
            return false;
        }
        // Allocate the depth (shift) -> to depth (millimeters) converter class
        _floatDepthFrame = [[STFloatDepthFrame alloc] init];
        
        _rgbDepthFrame = [[STDepthToRgba alloc] initWithStreamInfo:[_sensorController getStreamInfo:streamConfig]
                                                options:@{kSTDepthToRgbaStrategyKey: @(STDepthToRgbaStrategyRedToBlueGradient)}
                                                error:&error];
        
    }
    else
    {
        if (result == STSensorControllerInitStatusSensorNotFound)
            NSLog(@"[Debug] No Structure Sensor found!");
        else if (result == STSensorControllerInitStatusOpenFailed)
            NSLog(@"[Error] Structure Sensor open failed.");
        else if (result == STSensorControllerInitStatusSensorIsWakingUp)
            NSLog(@"[Debug] Structure Sensor is waking from low power.");
        else if (result != STSensorControllerInitStatusSuccess)
            NSLog(@"[Debug] Structure Sensor failed to init with status %d.", (int)result);
        
        _appStatus.sensorStatus = AppStatus::SensorStatusNeedsUserToConnect;
        [self updateAppStatusMessage];
    }
    
    return didSucceed;
    
}

- (void)showAppStatusMessage:(NSString *)msg
{
    _appStatus.needsDisplayOfStatusMessage = true;
    [self.view.layer removeAllAnimations];
    
    [_statusLabel setText:msg];
    [_statusLabel setHidden:NO];
    
    // Progressively show the message label.
    [self.view setUserInteractionEnabled:false];
    [UIView animateWithDuration:0.5f animations:^{
        _statusLabel.alpha = 1.0f;
    }completion:nil];
}

- (void)hideAppStatusMessage
{
    
    _appStatus.needsDisplayOfStatusMessage = false;
    [self.view.layer removeAllAnimations];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         _statusLabel.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         // If nobody called showAppStatusMessage before the end of the animation, do not hide it.
                         if (!_appStatus.needsDisplayOfStatusMessage)
                         {
                             [_statusLabel setHidden:YES];
                             [self.view setUserInteractionEnabled:true];
                         }
                     }];
}

-(void)updateAppStatusMessage
{
    // Skip everything if we should not show app status messages (e.g. in viewing state).
    if (_appStatus.statusMessageDisabled)
    {
        [self hideAppStatusMessage];
        return;
    }
    
    // First show sensor issues, if any.
    switch (_appStatus.sensorStatus)
    {
        case AppStatus::SensorStatusOk:
        {
            break;
        }
            
        case AppStatus::SensorStatusNeedsUserToConnect:
        {
            [self showAppStatusMessage:_appStatus.pleaseConnectSensorMessage];
            return;
        }
            
        case AppStatus::SensorStatusNeedsUserToCharge:
        {
            [self showAppStatusMessage:_appStatus.pleaseChargeSensorMessage];
            return;
        }
    }
    
    // Then show color camera permission issues, if any.
    if (!_appStatus.colorCameraIsAuthorized)
    {
        [self showAppStatusMessage:_appStatus.needColorCameraAccessMessage];
        return;
    }
    
    // If we reach this point, no status to show.
    [self hideAppStatusMessage];
}

-(bool) isConnectedAndCharged
{
    return [_sensorController isConnected] && ![_sensorController isLowPower];
}

#pragma mark -

#pragma mark Structure SDK Delegate Methods

- (void)sensorDidDisconnect
{
    NSLog(@"Structure Sensor disconnected!");
    
    _appStatus.sensorStatus = AppStatus::SensorStatusNeedsUserToConnect;
    [self updateAppStatusMessage];
    
    // Stop the color camera when there isn't a connected Structure Sensor
//    [self stopColorCamera];
}

- (void)sensorDidConnect
{
    NSLog(@"Structure Sensor connected!");
    [self connectAndStartStreaming];
}

- (void)sensorDidLeaveLowPowerMode
{
    _appStatus.sensorStatus = AppStatus::SensorStatusNeedsUserToConnect;
    [self updateAppStatusMessage];
}


- (void)sensorBatteryNeedsCharging
{
    // Notify the user that the sensor needs to be charged.
    _appStatus.sensorStatus = AppStatus::SensorStatusNeedsUserToCharge;
    [self updateAppStatusMessage];
}

- (void)sensorDidStopStreaming:(STSensorControllerDidStopStreamingReason)reason
{
    //If needed, change any UI elements to account for the stopped stream
    
    // Stop the color camera when we're not streaming from the Structure Sensor
//    [self stopColorCamera];
    
}

- (void)sensorDidOutputDepthFrame:(STDepthFrame *)depthFrame
{
    [self renderDepthFrame:depthFrame];
}

#pragma mark -

#pragma mark Face Segmentation and Recognition

-(BOOL) faceSegmentation:(cv::Mat&) depth_mat faceRect:(cv::Rect&) face faceMat:(cv::Mat&) face_mat
{
    // Some defined constant
    const double MAX_DEPTH = 512;
    const double MAX_RANGE = 916;
    const int ELEMENT_RADIUS = 2;

    // Get min range and max range
    double minRange, maxRange;
    cv::minMaxIdx(depth_mat, &minRange);
    maxRange = std::min(minRange + MAX_DEPTH, MAX_RANGE);
    [logger log:[NSString stringWithFormat:@"MinMax Ranges: %.2f %.2f",minRange, maxRange]];


    int cols = depth_mat.cols;
    int rows = depth_mat.rows;
    
    // filter out object not in range
    cv::Mat mask = depth_mat <= maxRange;
    // save this mask to image
    if (_count % 10 == 0) {
        NSString* mask_image_name = [NSString stringWithFormat:@"mask%.4d.jpg",_count];
        [Utils saveMATImage:mask andName:mask_image_name];
    }
    cv::normalize(mask, mask, 0, 1, cv::NORM_MINMAX);

    // Apply image erosion
    cv::Mat element = getStructuringElement(cv::MORPH_CROSS,
                                            cv::Size(2*ELEMENT_RADIUS+1, 2*ELEMENT_RADIUS+1));
    cv::erode(mask, mask, element);
    
    // Compute projected histogram
    // mask = MxN; xHist = 1xN; yHist = Mx1
    cv::Mat xHist, yHist;
    cv::reduce(mask, xHist, 0, CV_REDUCE_SUM, CV_32SC1); // Sum of each column
    cv::reduce(mask, yHist, 1, CV_REDUCE_SUM, CV_32SC1); // Sum of each row

    // Find top
    int i, j;
    const int* yHistData = yHist.ptr<int>(0);
    i = 0;
    while ((i < rows-1) && (yHistData[i] == 0)) {
        i++;
    }
    face.y = i;
    
    // Find the adaptive threshold for vertical projected histogram
    double maxVal;
    cv::Point maxLoc;
    cv::minMaxLoc(xHist, NULL, &maxVal, NULL, &maxLoc);
    int maxIdx = maxLoc.x;
    int step = 4;
    int lowerIdx = std::max(maxIdx - cols/8 - step, 0);
    int upperIdx = std::min(maxIdx + cols/8 + step, cols-1);
    // Compute the gradient histogram
    const int* xHistData = xHist.ptr<int>(0);
    std::vector<int> gradient;
    
    for (i = lowerIdx; i <= upperIdx-step; i++) {
        gradient.push_back(xHistData[i+step]-xHistData[i]);
    }
    int left = lowerIdx;
    int right = upperIdx;
    int min_grad = rows;
    int max_grad = -rows;
    int max_width = (int)gradient.size();
    for (i = 0; i < max_width/2; i++) {
        if (gradient[i] > max_grad) {
            max_grad = gradient[i];
            left = lowerIdx + i + step/2;
        }
        j = max_width-i-1;
        if (gradient[j] < min_grad) {
            min_grad = gradient[j];
            right = lowerIdx + j + step/2;
        }
    }
    
    face.x = left;
    // Width = right - left
    face.width = right - left;
    // Height = 1.5 * width
    face.height = std::min((3 * face.width) / 2, rows-face.y-1);
    
    [logger log:[NSString stringWithFormat:@"x:%.4d y:%.4d width:%.4d height: %.4d", face.x, face.y, face.width, face.height]];
    
    if (face.width > 30 && face.height > 30) {
        cv::Mat face_roi_mat = depth_mat(face);
        cv::Mat new_face_mat;
        face_roi_mat.convertTo(new_face_mat, CV_32FC1);
        cv::threshold(new_face_mat, new_face_mat, minRange, 0, cv::THRESH_TOZERO);
        cv::threshold(new_face_mat, new_face_mat, maxRange, 0, cv::THRESH_TRUNC);
        cv::Mat normalized_face_mat;
        cv::normalize(new_face_mat, normalized_face_mat, 0, 255, cv::NORM_MINMAX, CV_8UC1);
        normalized_face_mat = 255 - normalized_face_mat;
        cv::Mat paintMask = normalized_face_mat == 0;
        cv::Mat inpaint_face_mat;
        cv::inpaint(normalized_face_mat, paintMask, inpaint_face_mat, 3, cv::INPAINT_NS);
        cv::resize(inpaint_face_mat, face_mat, cv::Size(64,96));
        return true;
    }
    return false;
}

- (void) faceRecognition:(cv::Mat&) face_mat
{
    //Face recognition
    int label;
    double predicted_confidence;
    _faceRecognizer->predict(face_mat, label, predicted_confidence);
    
    [logger log:[NSString stringWithFormat:@"Label: %d Confidence: %.4f",label, predicted_confidence]];
    
    if(predicted_confidence < threshold3D){
        NSString* welcome;
        if (label==0){
            welcome = @"Welcome back, Yiwen.";
        }
        if (label==1){
            welcome = @"Welcome back, Ha.";
        }
        if (label==2){
            welcome = @"Welcome back, Shiwani.";
        }
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:welcome];
        [utterance setRate:0.1f];
        [synthesizer speakUtterance:utterance];
    }
    else{
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Sorry, you can not enter the door."];
        [utterance setRate:0.1f];
        [synthesizer speakUtterance:utterance];
    }
}


#pragma mark -

#pragma mark Rendering
/* https://www.cocoanetics.com/2010/07/drawing-on-uiimages/ */
- (UIImage *)drawingRectangleOnImage:(UIImage *)image withRectangle:(CGRect&) roi;
{
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set stroking color and draw circle
    [[UIColor greenColor] setStroke];
    
//    CGRect roi = CGRectMake(0.25*image.size.width, 0, image.size.width/2, image.size.height);
    
    // draw circle
    CGContextStrokeRectWithWidth(ctx, roi, 0.5);
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}

- (void)renderDepthFrame:(STDepthFrame *)depthFrame
{

    [_floatDepthFrame updateFromDepthFrame:depthFrame];
    [_rgbDepthFrame convertDepthFrameToRgba:_floatDepthFrame];
    size_t cols = depthFrame.width;
    size_t rows = depthFrame.height;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo;
    bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;
    bitmapInfo |= kCGBitmapByteOrder32Big;
    
    NSData *data = [NSData dataWithBytes:_rgbDepthFrame.rgbaBuffer length:cols * rows * 4];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data); //toll-free ARC bridging
    
    CGImageRef imageRef = CGImageCreate(cols,                        //width
                                        rows,                        //height
                                        8,                           //bits per component
                                        8 * 4,                       //bits per pixel
                                        cols * 4,                    //bytes per row
                                        colorSpace,                  //Quartz color space
                                        bitmapInfo,                  //Bitmap info (alpha channel?, order, etc)
                                        provider,                    //Source of data for bitmap
                                        NULL,                        //decode
                                        false,                       //pixel interpolation
                                        kCGRenderingIntentDefault);  //rendering intent
    
    // Assign CGImage to UIImage
    UIImage* coloredDepth = [UIImage imageWithCGImage:imageRef];
    if (_count % 10 == 0) {
        NSString* depth_image_name = [NSString stringWithFormat:@"colored_depth_%.4d.jpg",_count];
        [Utils saveUIImage:coloredDepth andName:depth_image_name];
    }

    // Create opencv Mat from depth frame
    cv::Mat depth_mat = cv::Mat((int)rows, (int)cols, CV_16UC1, depthFrame.data);
    // Face Recognition
    cv::Rect face;
    cv::Mat face_mat;
    BOOL success = [self faceSegmentation:depth_mat faceRect:face faceMat:face_mat];
    if (success) {
        [self faceRecognition:face_mat];
        // Draw face boundary
        CGRect cgface = CGRectMake(face.x, face.y, face.width, face.height);
        coloredDepth = [self drawingRectangleOnImage:coloredDepth withRectangle:cgface];
    }
    // Update View
    _depthImageView.image = coloredDepth;
    // Release buffer
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
}

@end
