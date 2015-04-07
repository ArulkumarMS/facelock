//
//  Utils.m
//  FaceLock
//
//  Created by Alan Xu on 4/3/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "Utils.h"

@implementation Utils

#pragma mark - Save Image to Sandbox/Documents

+ (BOOL) saveMATImage:(cv::Mat)img andName:(NSString *)imagname{
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

+ (cv::Mat) loadImage2MAT:(NSString *)imagename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *img_path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", imagename]];
    NSData *img_data = [NSData dataWithContentsOfFile:img_path];
    UIImage *uiimage = [UIImage imageWithData:img_data];
    cv::Mat cvimage = [UIImageCVMatConverter cvMatFromUIImage:uiimage];
    return cvimage;
}

+ (cv::CascadeClassifier*)loadClassifier: (NSString*) model_file_path{
    NSString* model = [[NSBundle mainBundle]pathForResource:model_file_path ofType:@"xml"];
    cv::CascadeClassifier* cascade = new cv::CascadeClassifier();
    cascade->load([model UTF8String]);
    return cascade;
}

+ (cv::Mat) normalizeFace: (cv::Mat) img andEyeLeft: (cv::Mat) eye_left andEyeRight:(cv::Mat) eye_right andDstsize:(cv::Mat)dest_size andHistEqual:(BOOL)doLeftandRightSeparately{
    
    // distance between eyes
    double dist_between_eye = cv::norm(eye_left-eye_right);
    //NSLog(@"Distance between two eyes: %f", dist_between_eye);
    cv::Point center = cv::Point((eye_left.at<double>(0, 0)+eye_right.at<double>(0, 0))/2, (eye_left.at<double>(0, 1)+eye_right.at<double>(0, 1))/2);
    // get the direction
    cv::Mat eye_direction = eye_right - eye_left;
    // calculate rotation angle in radians
    double rotation = atan(eye_direction.at<double>(0, 0)/eye_direction.at<double>(0, 1));
    
    double Desired_Face_Width = dest_size.at<double>(0,0);
    double Desired_Face_Height = dest_size.at<double>(0,1);
    const double DESIRED_LEFT_EYE_X = 0.16; const double DESIRED_LEFT_EYE_Y = 0.14;
    const double DESIRED_RIGHT_EYE_X = 1 - DESIRED_LEFT_EYE_X;
    double disiredLen = (DESIRED_RIGHT_EYE_X-DESIRED_LEFT_EYE_X)*Desired_Face_Width;
    double scale = disiredLen/dist_between_eye;
    
    cv::Mat M = cv::getRotationMatrix2D(center, rotation, scale);
    M.at<double>(0, 2) += Desired_Face_Width * 0.5f - center.x;
    M.at<double>(1, 2) += Desired_Face_Width * DESIRED_LEFT_EYE_Y - center.y;
    //cv::Mat M = (cv::Mat_<double> (2, 3)<< a,b,0, d,e,0);
    cv::Mat warped = cv::Mat(Desired_Face_Height, Desired_Face_Width, CV_8U, cv::Scalar(128));
    cv::warpAffine(img, warped, M, warped.size());
    if (!doLeftandRightSeparately) {
        cv::equalizeHist(warped, warped);
    }else{
        [self equalizeLeftAndRightHalves:warped];
    }
    cv::Mat filtered = cv::Mat(warped.size(), CV_8U);
    cv::bilateralFilter(warped, filtered, 0, 20, 2);
    //cv::namedWindow("image", CV_WINDOW_AUTOSIZE);
    //imshow("image", filtered);
    
    return filtered;
}

+ (void) equalizeLeftAndRightHalves: (cv::Mat&) faceImg{
    // It is common that there is stronger light from one half of the face than the other. In that case,
    // if you simply did histogram equalization on the whole face then it would make one half dark and
    // one half bright. So we will do histogram equalization separately on each face half, so they will
    // both look similar on average. But this would cause a sharp edge in the middle of the face, because
    // the left half and right half would be suddenly different. So we also histogram equalize the whole
    // image, and in the middle part we blend the 3 images together for a smooth brightness transition.
    
    int w = faceImg.cols;
    int h = faceImg.rows;
    
    // 1) First, equalize the whole face.
    cv::Mat wholeFace;
    cv::equalizeHist(faceImg, wholeFace);
    
    // 2) Equalize the left half and the right half of the face separately.
    int midX = w/2;
    cv::Mat leftSide = faceImg(cv::Rect(0,0, midX,h));
    cv::Mat rightSide = faceImg(cv::Rect(midX,0, w-midX,h));
    cv::equalizeHist(leftSide, leftSide);
    cv::equalizeHist(rightSide, rightSide);
    
    // 3) Combine the left half and right half and whole face together, so that it has a smooth transition.
    for (int y=0; y<h; y++) {
        for (int x=0; x<w; x++) {
            int v;
            if (x < w/4) {          // Left 25%: just use the left face.
                v = leftSide.at<uchar>(y,x);
            }
            else if (x < w*2/4) {   // Mid-left 25%: blend the left face & whole face.
                int lv = leftSide.at<uchar>(y,x);
                int wv = wholeFace.at<uchar>(y,x);
                // Blend more of the whole face as it moves further right along the face.
                float f = (x - w*1/4) / (float)(w*0.25f);
                v = cvRound((1.0f - f) * lv + (f) * wv);
            }
            else if (x < w*3/4) {   // Mid-right 25%: blend the right face & whole face.
                int rv = rightSide.at<uchar>(y,x-midX);
                int wv = wholeFace.at<uchar>(y,x);
                // Blend more of the right-side face as it moves further right along the face.
                float f = (x - w*2/4) / (float)(w*0.25f);
                v = cvRound((1.0f - f) * wv + (f) * rv);
            }
            else {                  // Right 25%: just use the right face.
                v = rightSide.at<uchar>(y,x-midX);
            }
            faceImg.at<uchar>(y,x) = v;
        }// end x loop
    }//end y loop
}
@end
