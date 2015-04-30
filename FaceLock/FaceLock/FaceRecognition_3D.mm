//
//  FaceRecognition_3D.m
//  FaceLock
//
//  Created by Ha Le on 4/30/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceRecognition_3D.h"


@implementation FaceRecognition_3D

+ (BOOL)LBPHfileExist{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPH3Dmodel.xml"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:LBPHfilePath];
    NSLog(@"LBPH3Dmodel.xml,%s", fileExists ? "true" : "false");
    return fileExists;
}

+ (void)saveFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR{
    //    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"LBPHmodel" ofType:@"xml" ];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPH3Dmodel.xml"];
    const cv::String filename=([LBPHfilePath UTF8String]);
    LBPHFR->save(filename);
}

+ (void)loadFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *LBPHfilePath = [documentsDirectory stringByAppendingPathComponent:@"LBPH3Dmodel.xml"];
    const cv::String filename=([LBPHfilePath UTF8String]);
    //cv::Ptr<cv::face::FaceRecognizer> LBPHFR=cv::face::createLBPHFaceRecognizer();
    LBPHFR->load(filename);
}

+ (void)trainFaceRecognizer:(cv::Ptr<cv::face::FaceRecognizer>) LBPHFR andUser:(NSString*) username andLabel: (int)label andTrainNum:(NSInteger)imageNum{
    
    std::vector<cv::Mat> Images;
    std::vector<int> Lables;
    
    for(int i=1; i<=imageNum; i++){
        //NSString *path = [[NSBundle mainBundle] pathForResource:@"pattern" ofType:@"bmp"];
        //const char * cpath = [path cStringUsingEncoding:NSUTF8StringEncoding];
        //cv::Mat img_object = cv::imread( cpath, CV_LOAD_IMAGE_GRAYSCALE );
        
        NSString *filename = [NSString stringWithFormat: @"%@%@",
                              username, [@(i) stringValue]];
        NSLog(@"%@",filename);
        NSString* filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"jpg" ];
        const char * cpath = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
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
