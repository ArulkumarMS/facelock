//
//  ViewController.m
//  FaceLock
//
//  Created by Alan Xu on 3/13/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController.h"

#import <Structure/Structure.h>
#import <Structure/StructureSLAM.h>
#import <AVFoundation/AVFoundation.h>

#include <algorithm>
#include <opencv2/opencv.hpp>
//#include <stdint.h>
// Hello World

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>{
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
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
