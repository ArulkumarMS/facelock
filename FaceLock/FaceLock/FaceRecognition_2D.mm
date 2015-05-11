//
//  FaceRecognition_2D.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/6/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceRecognition_2D.h"


@implementation FaceRecognition_2D

+ (BOOL)LBPHfileExist{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPHmodel.xml"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:LBPHfilePath];
    NSLog(@"LBPHmodel.xml,%s", fileExists ? "true" : "false");
    return fileExists;
}

+ (void)saveFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPHmodel.xml"];
    const cv::String filename=([LBPHfilePath UTF8String]);
    LBPHFR->save(filename);
}

+ (void)loadFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPHmodel.xml"];
    const cv::String filename=([LBPHfilePath UTF8String]);
//    LBPHFR = cv::face::createLBPHFaceRecognizer();
    LBPHFR->load(filename);
}

+ (void)loadDefaultFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR
{
    NSString* LBPHfilePath = [[NSBundle mainBundle]pathForResource:@"LBPHmodel" ofType:@"xml"];
    const cv::String filename=([LBPHfilePath UTF8String]);
    LBPHFR->load(filename);
}

+ (void)trainFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR andUser:(NSString*) username andLabel: (int)label andTrainNum:(NSInteger)imageNum{
    
    std::vector<cv::Mat> Images;
    std::vector<int> Lables;
    
    for(int i=1; i<=imageNum; i++){
        
        //NSString *filename = [NSString stringWithFormat: @"%@%@", username, [@(i) stringValue]];
        
        //NSString* filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"jpg" ];
        //const char * cpath = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
        //cv::Mat cvImage = cv::imread( cpath, CV_LOAD_IMAGE_GRAYSCALE );
        NSString *filename = [NSString stringWithFormat: @"%@2D%@.jpg",
                              username, [@(i) stringValue]];
        NSLog(@"%@",filename);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
        const char * cpath = [path cStringUsingEncoding:NSUTF8StringEncoding];
        cv::Mat cvImage = cv::imread( cpath, CV_LOAD_IMAGE_GRAYSCALE );
        
        
        if(cvImage.data )                              // Check for invalid input
        {
//            NSLog(@"!!!");
            Images.push_back(cvImage);
            Lables.push_back(label);
        }
    }
    LBPHFR->update(Images, Lables);
//    LBPHFR->train(Images, Lables);
}
@end
