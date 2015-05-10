//
//  FaceRecognition_3D.m
//  FaceLock
//
//  Created by Ha Le on 4/30/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceRecognition_3D.h"
#define MODEL_NAME_3D_NOXML @"LBPFace3DModel"
#define MODEL_NAME_3D @"LBPFace3DModel.xml"

@implementation FaceRecognition_3D

+ (BOOL)doesModelFileExist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *modelFilePath = [documentsDirectory stringByAppendingPathComponent:MODEL_NAME_3D];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:modelFilePath];
    return fileExists;
}

+ (void)saveFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) faceRecognizer{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *modelFilePath = [documentsDirectory stringByAppendingPathComponent:MODEL_NAME_3D];
    const cv::String filename=([modelFilePath UTF8String]);
    faceRecognizer->save(filename);
}

+ (void)loadFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) faceRecognizer{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *modelFilePath = [documentsDirectory stringByAppendingPathComponent:MODEL_NAME_3D];
    const cv::String filename=([modelFilePath UTF8String]);
    faceRecognizer->load(filename);
}

+ (void)loadDefaultFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) faceRecognizer
{
    NSString* filePath = [[NSBundle mainBundle]pathForResource:MODEL_NAME_3D_NOXML ofType:@"xml"];
    const cv::String filename=([filePath UTF8String]);
    faceRecognizer->load(filename);
}

+ (void)trainFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) faceRecognizer andUser:(NSString*) username andLabel: (int)label andTrainNum:(NSInteger)imageNum{
    
    std::vector<cv::Mat> Images;
    std::vector<int> Lables;
    
    for(int i=1; i<=imageNum; i++){
        NSString *filename = [NSString stringWithFormat: @"3DData/%@_3D_%.2d", username, i];
        NSString* filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"jpg" ];
        const char * cpath = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
        cv::Mat cvImage = cv::imread( cpath, CV_LOAD_IMAGE_GRAYSCALE );
        
        if(cvImage.data )                              // Check for invalid input
        {
            Images.push_back(cvImage);
            Lables.push_back(label);
        }
    }
    faceRecognizer->update(Images, Lables);
//    faceRecognizer->train(Images, Lables);
}
@end
