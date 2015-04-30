//
//  ViewController_3D.m
//  FaceLock
//
//  Created by Alan Xu on 4/16/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_3D.h"

#import <AVFoundation/AVFoundation.h>

#import <Structure/StructureSLAM.h>

#include <algorithm>

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
    UIImageView *_normalsImageView;
    UIImageView *_colorImageView;
    
    uint16_t *_linearizeBuffer;
    uint8_t *_coloredDepthBuffer;
    uint8_t *_normalsBuffer;
    
    STFloatDepthFrame *_floatDepthFrame;
    STNormalEstimator *_normalsEstimator;
    
    UILabel* _statusLabel;
    
    AppStatus _appStatus;
    
    // Face Recognition variables
    int _count;
    int _imagename_count;
    cv::Ptr<cv::face::FaceRecognizer> _faceRecognizer;
    // Logger
    NSLogger *logger;
    
}

- (BOOL)connectAndStartStreaming;
- (void)renderDepthFrame:(STDepthFrame*)depthFrame;
- (void)renderNormalsFrame:(STDepthFrame*)normalsFrame;
- (void)renderColorFrame:(CMSampleBufferRef)sampleBuffer;
//- (void)setupColorCamera;
//- (void)startColorCamera;
//- (void)stopColorCamera;

@end

@implementation ViewController_3D


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Logger Init
    logger = [[NSLogger alloc] init];
    // Face Recognition Init
    _count = 0;
    _imagename_count = 0;
    // Structure Sensor Init
    _sensorController = [STSensorController sharedController];
    _sensorController.delegate = self;
    
    // Create three image views where we will render our frames
    
//    CGRect depthFrame = self.view.frame;
//    depthFrame.size.height /= 2;
//    depthFrame.origin.y = self.view.frame.size.height/2;
//    depthFrame.origin.x = 1;
//    depthFrame.origin.x = -self.view.frame.size.width * 0.25;
    
    CGRect normalsFrame = self.view.frame;
//    normalsFrame.size.height /= 2;
//    normalsFrame.origin.y = self.view.frame.size.height/2;
//    normalsFrame.origin.x = 1;
//    normalsFrame.origin.y = self.view.frame.size.width * 0.25;
//    
//    CGRect colorFrame = self.view.frame;
//    colorFrame.size.height /= 2;
    
    _linearizeBuffer = NULL;
    _coloredDepthBuffer = NULL;
    _normalsBuffer = NULL;
    
//    _depthImageView = [[UIImageView alloc] initWithFrame:depthFrame];
//    _depthImageView.contentMode = UIViewContentModeScaleAspectFill;
//    [self.view addSubview:_depthImageView];
    
    _normalsImageView = [[UIImageView alloc] initWithFrame:normalsFrame];
    _normalsImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_normalsImageView];
    
//    _colorImageView = [[UIImageView alloc] initWithFrame:colorFrame];
//    _colorImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.view addSubview:_colorImageView];
    
//    [self setupColorCamera];
    
    if (![FaceRecognition_3D doesModelFileExist]){
        [logger log:@"IN 3D initiate part!"];
        cv::Ptr<cv::face::FaceRecognizer> initFaceRecognizer=cv::face::createLBPHFaceRecognizer();
        [FaceRecognition_3D saveFaceRecognizer:initFaceRecognizer];
        [FaceRecognition_3D loadFaceRecognizer:initFaceRecognizer];
//        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"YIWEN SHI 3D" andLabel:0 andTrainNum:46];
        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"HA LE 3D" andLabel:1 andTrainNum:50];
//        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"SHIWANI BECTOR 3D" andLabel:2 andTrainNum:10];
//        [FaceRecognition_3D trainFaceRecognizer:initFaceRecognizer andUser:@"XIANG XU 3D" andLabel:3 andTrainNum:10];
        [FaceRecognition_3D saveFaceRecognizer:initFaceRecognizer];
    }
    _faceRecognizer=cv::face::createLBPHFaceRecognizer();
    [FaceRecognition_3D loadFaceRecognizer:_faceRecognizer];
    
//     Sample usage of wireless debugging API
//    NSError* error = nil;
//    [STWirelessLog broadcastLogsToWirelessConsoleAtAddress:@"10.2.13.57" usingPort:4999 error:&error];
//    
//    if (error)
//        NSLog(@"Oh no! Can't start wireless log: %@", [error localizedDescription]);
}

- (void)dealloc
{
    if (_linearizeBuffer)
        free(_linearizeBuffer);
    
    if (_coloredDepthBuffer)
        free(_coloredDepthBuffer);
    
    if (_normalsBuffer)
        free(_normalsBuffer);
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
}


- (void)appDidBecomeActive
{
    [self connectAndStartStreaming];
}

- (void)viewDidDisappear:(BOOL)animated{
//    [self stopColorCamera];
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
        
        // Start the color camera, setup if needed
//        [self startColorCamera];
        
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
        
        // Allocate the depth -> surface normals converter class
        _normalsEstimator = [[STNormalEstimator alloc] initWithStreamInfo:[_sensorController getStreamInfo:streamConfig]];
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
#pragma mark Face Segmentation and Recognition

-(cv::Rect) faceSegmentation:(cv::Mat&) depth_mat
{
    const double MAX_DEPTH = 8192.0 / 9.0; // 2^9 / 9 * 16 = 910.2222
    const int ELEMENT_RADIUS = 2;
    int cols = depth_mat.cols;
    int rows = depth_mat.rows;
    cv::Rect face;
    // filter out object not in range
    cv::Mat mask = depth_mat <= MAX_DEPTH;
    // Save this mask to image
    _imagename_count++;
    if (_imagename_count % 10 == 0) {
        NSString* mask_image_name = [NSString stringWithFormat:@"mask%.4d.jpg",_imagename_count];
        [Utils saveMATImage:mask andName:mask_image_name];
    }
    cv::normalize(mask, mask, 0, 1, cv::NORM_MINMAX);
    // Find the largest Connected Components
//    cv::Mat labels;
//    cv::connectedComponents(mask, labels);
    // Apply image erosion
    cv::Mat element = getStructuringElement(cv::MORPH_CROSS,
                                            cv::Size(2*ELEMENT_RADIUS+1, 2*ELEMENT_RADIUS+1));
    cv::erode(mask, mask, element);
    // Compute projected histogram
    // mask = MxN
    // xHist = 1xN
    // yHist = Mx1
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
    
    [logger log:[NSString stringWithFormat:@"maxIdx: %.4d x:%.4d y:%.4d width:%.4d height: %.4d", maxIdx, face.x, face.y, face.width, face.height]];
    return face;
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
//    [self renderDepthFrame:depthFrame];
    [self renderNormalsFrame:depthFrame];
}

// This synchronized API will only be called when two frames match. Typically, timestamps are within 1ms of each other.
// Two important things have to happen for this method to be called:
// Tell the SDK we want framesync with options @{kSTFrameSyncConfigKey : @(STFrameSyncDepthAndRgb)} in [STSensorController startStreamingWithOptions:error:]
// Give the SDK color frames as they come in:     [_ocSensorController frameSyncNewColorBuffer:sampleBuffer];
- (void)sensorDidOutputSynchronizedDepthFrame:(STDepthFrame*)depthFrame
                               andColorBuffer:(CMSampleBufferRef)sampleBuffer
{
//    [self renderDepthFrame:depthFrame];
    [self renderNormalsFrame:depthFrame];
//    [self renderColorFrame:sampleBuffer];
}


#pragma mark -
#pragma mark Rendering

const uint16_t maxShiftValue = 2048;

- (void)populateLinearizeBuffer
{
    _linearizeBuffer = (uint16_t*)malloc((maxShiftValue + 1) * sizeof(uint16_t));
    
    for (int i=0; i <= maxShiftValue; i++)
    {
        float v = i/ (float)maxShiftValue;
        v = powf(v, 3)* 6;
        _linearizeBuffer[i] = v*6*256;
    }
}

// This function is equivalent to calling [STDepthAsRgba convertDepthFrameToRgba] with the
// STDepthToRgbaStrategyRedToBlueGradient strategy. Not using the SDK here for didactic purposes.
- (void)convertShiftToRGBA:(const uint16_t*)shiftValues depthValuesCount:(size_t)depthValuesCount
{
    for (size_t i = 0; i < depthValuesCount; i++)
    {
        // We should not get higher values than maxShiftValue, but let's stay on the safe side.
        uint16_t boundedShift = std::min (shiftValues[i], maxShiftValue);
        
        // Use a lookup table to make the non-linear input values vary more linearly with metric depth
        int linearizedDepth = _linearizeBuffer[boundedShift];
        
        // Use the upper byte of the linearized shift value to choose a base color
        // Base colors range from: (closest) White, Red, Orange, Yellow, Green, Cyan, Blue, Black (farthest)
        int lowerByte = (linearizedDepth & 0xff);
        
        // Use the lower byte to scale between the base colors
        int upperByte = (linearizedDepth >> 8);
        
        switch (upperByte)
        {
            case 0:
                _coloredDepthBuffer[4*i+0] = 255;
                _coloredDepthBuffer[4*i+1] = 255-lowerByte;
                _coloredDepthBuffer[4*i+2] = 255-lowerByte;
                _coloredDepthBuffer[4*i+3] = 255;
                break;
            case 1:
                _coloredDepthBuffer[4*i+0] = 255;
                _coloredDepthBuffer[4*i+1] = lowerByte;
                _coloredDepthBuffer[4*i+2] = 0;
                break;
            case 2:
                _coloredDepthBuffer[4*i+0] = 255-lowerByte;
                _coloredDepthBuffer[4*i+1] = 255;
                _coloredDepthBuffer[4*i+2] = 0;
                break;
            case 3:
                _coloredDepthBuffer[4*i+0] = 0;
                _coloredDepthBuffer[4*i+1] = 255;
                _coloredDepthBuffer[4*i+2] = lowerByte;
                break;
            case 4:
                _coloredDepthBuffer[4*i+0] = 0;
                _coloredDepthBuffer[4*i+1] = 255-lowerByte;
                _coloredDepthBuffer[4*i+2] = 255;
                break;
            case 5:
                _coloredDepthBuffer[4*i+0] = 0;
                _coloredDepthBuffer[4*i+1] = 0;
                _coloredDepthBuffer[4*i+2] = 255-lowerByte;
                break;
            default:
                _coloredDepthBuffer[4*i+0] = 0;
                _coloredDepthBuffer[4*i+1] = 0;
                _coloredDepthBuffer[4*i+2] = 0;
                break;
        }
    }
}

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
    [[UIColor redColor] setStroke];
    
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
    size_t cols = depthFrame.width;
    size_t rows = depthFrame.height;
    
    
    
    if (_linearizeBuffer == NULL /* || _normalsBuffer == NULL*/)
    {
        [self populateLinearizeBuffer];
        
    }
    if (_coloredDepthBuffer == NULL)
    {
        _coloredDepthBuffer = (uint8_t*)malloc(cols * rows * 4);
    }
    
    // Conversion of 16-bit non-linear shift depth values to 32-bit RGBA
    //
    // Adapted from: https://github.com/OpenKinect/libfreenect/blob/master/examples/glview.c
    //
    [self convertShiftToRGBA:depthFrame.data depthValuesCount:cols * rows];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo;
    bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;
    bitmapInfo |= kCGBitmapByteOrder32Big;
    
    NSData *data = [NSData dataWithBytes:_coloredDepthBuffer length:cols * rows * 4];
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
//    NSString* depth_image_name = [NSString stringWithFormat:@"depth%.4d.jpg",_imagename_count+1];
//    [Utils saveUIImage:coloredDepth andName:depth_image_name];
//    // Face Segmentation
//    cv::Mat depth_mat = cv::Mat((int)rows, (int)cols, CV_16UC1, depthFrame.data);
//    cv::Rect face = [self faceSegmentation:depth_mat];

    _depthImageView.image = coloredDepth;
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
}

- (void) renderNormalsFrame: (STDepthFrame*) depthFrame
{
    // Convert depth units from shift to millimeters (stored as floats)
    [_floatDepthFrame updateFromDepthFrame:depthFrame];
    
    // Estimate surface normal direction from depth float values
    STNormalFrame *normalsFrame = [_normalsEstimator calculateNormalsWithDepthFrame:_floatDepthFrame];
    
    size_t cols = normalsFrame.width;
    size_t rows = normalsFrame.height;
    
    // Convert normal unit vectors (ranging from -1 to 1) to RGB (ranging from 0 to 255)
    // Z can be slightly positive in some cases too!
    if (_normalsBuffer == NULL)
    {
        _normalsBuffer = (uint8_t*)malloc(cols * rows * 4);
    }
    for (size_t i = 0; i < cols * rows; i++)
    {
        _normalsBuffer[4*i+0] = (uint8_t)( ( ( normalsFrame.normals[i].x / 2 ) + 0.5 ) * 255);
        _normalsBuffer[4*i+1] = (uint8_t)( ( ( normalsFrame.normals[i].y / 2 ) + 0.5 ) * 255);
        _normalsBuffer[4*i+2] = (uint8_t)( ( ( normalsFrame.normals[i].z / 2 ) + 0.5 ) * 255);
        _normalsBuffer[4*i+3] = 255;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo bitmapInfo;
    bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipFirst;
    bitmapInfo |= kCGBitmapByteOrder32Little;
    
    NSData *data = [NSData dataWithBytes:_normalsBuffer length:cols * rows * 4];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cols,
                                        rows,
                                        8,
                                        8 * 4,
                                        cols * 4,
                                        colorSpace,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
    
    UIImage* normalsImg = [[UIImage alloc] initWithCGImage:imageRef];
    
    //    CGRect roi = CGRectMake(0.25*normalsImg.size.width, 0, normalsImg.size.width/2, normalsImg.size.height);
    //    normalsImg = [self drawingRectangleOnImage:normalsImg withRectangle:roi];
    
    // Face Segmentation
    cv::Mat depth_mat = cv::Mat((int)rows, (int)cols, CV_16UC1, depthFrame.data);
    cv::Rect face = [self faceSegmentation:depth_mat];
    CGRect cgface = CGRectMake(face.x, face.y, face.width, face.height);
    normalsImg = [self drawingRectangleOnImage:normalsImg withRectangle:cgface];
    
    // Update View
    _normalsImageView.image = normalsImg;
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    if (face.width == 0 || face.height == 0) {
        return;
    }
    
    // Crop face
    cv::Mat normals_mat = cv::Mat((int) rows, (int) cols, CV_8UC4, _normalsBuffer);
    cv::Mat normals_face = normals_mat(face).clone();
    // Face Alignment
    cv::Mat aligned_face;
    cv::resize(normals_face, aligned_face, cv::Size(64,96));
//    cv::Point face_size(64,96);
//    cv::Mat aligned_face = [Utils normalizeFace:normals_face andFaceSize:face_size];
    // Save face
    _imagename_count++;
    NSString* aligned_face_name = [NSString stringWithFormat:@"aligned_3dface_%.4d.jpg",_imagename_count];
    [Utils saveMATImage:aligned_face andName:aligned_face_name];
    cv::Mat gray;
    cv::cvtColor(aligned_face, gray, CV_RGBA2GRAY);
    
    //Face recognition
    int label;
    double predicted_confidence;
    _faceRecognizer->predict(gray, label, predicted_confidence);
    NSString* event = [NSString stringWithFormat:@"Label: %d Confidence: %.4f",label, predicted_confidence];
    [logger log:event];
    if(predicted_confidence < 100){
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
//    else{
//        NSLog(@"Sorry, you can not enter the door.\n");
//        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
//        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:@"Sorry, you can not enter the door."];
//        [utterance setRate:0.1f];
//        [synthesizer speakUtterance:utterance];
//    }

    
    /*
    _count++;
    if (_count == 1) {
        // Crop face
        cv::Mat normals_mat = cv::Mat((int) rows, (int) cols, CV_8UC4, _normalsBuffer);
        __block cv::Mat normals_face = normals_mat(face).clone();
     
        // Run nose detection, face alignment and face recognition in a thread (using global thread pool)
        dispatch_queue_t face_recognition_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(face_recognition_queue, ^{
            // Face Alignment
            cv::Point face_size(64,96);
            cv::Mat aligned_face = [Utils normalizeFace:normals_face andFaceSize:face_size];
            // Save face
            _imagename_count++;
            NSString* aligned_face_name = [NSString stringWithFormat:@"aligned_3dface%.4d.jpg",_imagename_count];
            [Utils saveMATImage:aligned_face andName:aligned_face_name];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                
            });
            _count = 0;
        });
    }
     */
}

- (void)renderColorFrame:(CMSampleBufferRef)sampleBuffer
{
    
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    size_t cols = CVPixelBufferGetWidth(pixelBuffer);
    size_t rows = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    unsigned char *ptr = (unsigned char *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    NSData *data = [[NSData alloc] initWithBytes:ptr length:rows*cols*4];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    CGBitmapInfo bitmapInfo;
    bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipFirst;
    bitmapInfo |= kCGBitmapByteOrder32Little;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cols,
                                        rows,
                                        8,
                                        8 * 4,
                                        cols*4,
                                        colorSpace,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault);
    
    _colorImageView.image = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
}


/*
#pragma mark -  AVFoundation

- (BOOL)queryCameraAuthorizationStatusAndNotifyUserIfNotGranted
{
    // This API was introduced in iOS 7, but in iOS 8 it's actually enforced.
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus != AVAuthorizationStatusAuthorized)
        {
            NSLog(@"Not authorized to use the camera!");
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted)
             {
                 // This block fires on a separate thread, so we need to ensure any actions here
                 // are sent to the right place.
                 
                 // If the request is granted, let's try again to start an AVFoundation session. Otherwise, alert
                 // the user that things won't go well.
                 if (granted)
                 {
                     
                     dispatch_async(dispatch_get_main_queue(), ^(void) {
                         
                         [self startColorCamera];
                         
                         _appStatus.colorCameraIsAuthorized = true;
                         [self updateAppStatusMessage];
                         
                     });
                     
                 }
                 
             }];
            
            return false;
        }
        
    }
    
    return true;
    
}

- (void)setupColorCamera
{
    // If already setup, skip it
    if (_avCaptureSession)
        return;
    
    bool cameraAccessAuthorized = [self queryCameraAuthorizationStatusAndNotifyUserIfNotGranted];
    
    if (!cameraAccessAuthorized)
    {
        _appStatus.colorCameraIsAuthorized = false;
        [self updateAppStatusMessage];
        return;
    }
    
    // Use VGA color.
    NSString *sessionPreset = AVCaptureSessionPreset640x480;
    
    // Set up Capture Session.
    _avCaptureSession = [[AVCaptureSession alloc] init];
    [_avCaptureSession beginConfiguration];
    
    // Set preset session size.
    [_avCaptureSession setSessionPreset:sessionPreset];
    
    // Create a video device and input from that Device.  Add the input to the capture session.
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (_videoDevice == nil)
        assert(0);
    
    // Configure Focus, Exposure, and White Balance
    NSError *error;
    
    // iOS8 supports manual focus at near-infinity, but iOS7 doesn't.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    bool avCaptureSupportsFocusNearInfinity = [_videoDevice respondsToSelector:@selector(setFocusModeLockedWithLensPosition:completionHandler:)];
#else
    bool avCaptureSupportsFocusNearInfinity = false;
#endif
    
    // Use auto-exposure, and auto-white balance and set the focus to infinity.
    if([_videoDevice lockForConfiguration:&error])
    {
        
        // Allow exposure to change
        if ([_videoDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            [_videoDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        
        // Allow white balance to change
        if ([_videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            [_videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        
        if (avCaptureSupportsFocusNearInfinity)
        {
            // Set focus at the maximum position allowable (e.g. "near-infinity") to get the
            // best color/depth alignment.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            [_videoDevice setFocusModeLockedWithLensPosition:1.0f completionHandler:nil];
#endif
        }
        else
        {
            
            // Allow the focus to vary, but restrict the focus to far away subject matter
            if ([_videoDevice isAutoFocusRangeRestrictionSupported])
                [_videoDevice setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionFar];
            
            if ([_videoDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
                [_videoDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            
        }
        
        [_videoDevice unlockForConfiguration];
    }
    
    //  Add the device to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (error)
    {
        NSLog(@"Cannot initialize AVCaptureDeviceInput");
        assert(0);
    }
    
    [_avCaptureSession addInput:input]; // After this point, captureSession captureOptions are filled.
    
    //  Create the output for the capture session.
    AVCaptureVideoDataOutput* dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // We don't want to process late frames.
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    
    // Use BGRA pixel format.
    [dataOutput setVideoSettings:[NSDictionary
                                  dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [_avCaptureSession addOutput:dataOutput];
    
    // Force the framerate to 30 FPS, to be in sync with Structure Sensor.
    if ([_videoDevice respondsToSelector:@selector(setActiveVideoMaxFrameDuration:)]
        && [_videoDevice respondsToSelector:@selector(setActiveVideoMinFrameDuration:)])
    {
        // Available since iOS 7.
        if([_videoDevice lockForConfiguration:&error])
        {
            [_videoDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
            [_videoDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
            [_videoDevice unlockForConfiguration];
        }
    }
    else
    {
        NSLog(@"iOS 7 or higher is required. Camera not properly configured.");
        return;
    }
    
    [_avCaptureSession commitConfiguration];
}

- (void)startColorCamera
{
    if (_avCaptureSession && [_avCaptureSession isRunning])
        return;
    
    // Re-setup so focus is lock even when back from background
    if (_avCaptureSession == nil)
        [self setupColorCamera];
    
    // Start streaming color images.
    [_avCaptureSession startRunning];
}

- (void)stopColorCamera
{
    if ([_avCaptureSession isRunning])
    {
        // Stop the session
        [_avCaptureSession stopRunning];
    }
    
    _avCaptureSession = nil;
    _videoDevice = nil;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // Pass into the driver. The sampleBuffer will return later with a synchronized depth or IR pair.
    [_sensorController frameSyncNewColorBuffer:sampleBuffer];
}
*/

@end
