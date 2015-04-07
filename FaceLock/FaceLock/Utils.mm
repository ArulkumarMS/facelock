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

+ (cv::Mat) normalizeFace: (cv::Mat) img andEyeLeft: (cv::Mat) eye_left andEyeRight:(cv::Mat) eye_right andOffset:(cv::Mat)offset andDstsize:(cv::Mat)dest_size{
    // distance between eyes
    double dist_between_eye = cv::norm(eye_left-eye_right);
    NSLog(@"Distance between two eyes: %f", dist_between_eye);
    // calculate offsets
    double offset_h = floor(offset.at<double>(0, 0)*dest_size.at<double>(0, 0));
    //double offset_v = floor(offset.at<double>(0, 1)*dest_size.at<double>(0, 1));
    // get the direction
    cv::Mat eye_direction = eye_right - eye_left;
    // calculate rotation angle in radians
    double rotation = atan(eye_direction.at<double>(0, 0)/eye_direction.at<double>(0, 1));
    NSLog(@"Rotation Angle is %f", rotation*180/M_PI);
    // calculate the reference eye-width
    double reference = dest_size.at<double>(0,0) - 2* offset_h;
    // scale factor
    double scale = dist_between_eye/reference;
    // rotate orginal around the left eye
    cv::Mat image = [self ScaleRotateTranslate:img andEyeLeft:eye_left andRotation:rotation andScale:scale];
    // crop the rotated image
    //double x = eye_left.at<double>(0, 0) - scale*offset_h, y = eye_left.at<double>(0,1) - scale*offset_v;
    //double w = dest_size.at<double>(0,0)*scale, h = dest_size.at<double>(0,1)*scale;
    //cv::Rect rect = cv::Rect(x, y, w, h);
    //cv::Mat image = img(rect);
    return image;
}

+ (cv::Mat) ScaleRotateTranslate: (cv::Mat&)image andEyeLeft:(cv::Mat) eye_Left andRotation: (double) angle andScale:(double) scale{
    double nx = eye_Left.at<double>(0, 0);
    double ny = eye_Left.at<double>(0, 1);
    
    double x = nx, y= ny;
    double sx = scale, sy = scale;
    
    double cosine = cos(angle);
    double sine = sin(angle);
    
    double a = cosine/sx, b = sine/sx, c = x - nx*a - ny*b;
    double d = -sine/sy, e = cosine/sy, f = y - nx*d - ny*e;
    NSLog(@"Image Width is %d and Height is %d", image.cols, image.rows);
    
    cv::Mat M = (cv::Mat_<double> (2, 3)<< a,b,c,d,e,f);
    //cv::Mat imageT;
    cv::Mat warped = cv::Mat(image.rows/sx, image.cols*sx, CV_8U, cvScalar(128));
    cv::warpAffine(image, warped, M, warped.size());
    //[self equalizeLeftAndRightHalves:warped];
    //cv::bilateralFilter(warped, warped, 0, 20, 2);
    cv::Mat dstImg = cv::Mat(warped.size(), CV_8U, cvScalar(128));
    return dstImg;
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
