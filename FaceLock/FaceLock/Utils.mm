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

+ (BOOL) saveUIImage:(UIImage*)image andName:(NSString *)imagename{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imagename]];
    BOOL result = [UIImageJPEGRepresentation(image, 1)writeToFile:filePath atomically:YES];
    
    return result;
}

+ (BOOL) saveMATImage:(cv::Mat)img andName:(NSString *)imagename{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",imagename]];
    UIImage* image = [UIImageCVMatConverter UIImageFromCVMat:img];
    BOOL result = [UIImageJPEGRepresentation(image, 1)writeToFile:filePath atomically:YES];
    
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

+ (void) saveMAT: (cv::Mat) cvMat andName:(NSString*) imagename andKey:(NSString*) keyname
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *filePath = [docs stringByAppendingPathComponent:imagename];
    
    cv::FileStorage fs([filePath UTF8String], cv::FileStorage::WRITE);
    if (fs.isOpened()) {
        fs[[keyname UTF8String]]>> cvMat;
    }
    fs.release();
}
+ (cv::CascadeClassifier*)loadClassifier: (NSString*) model_file_path
{
    NSString* model = [[NSBundle mainBundle]pathForResource:model_file_path ofType:@"xml"];
    cv::CascadeClassifier* cascade = new cv::CascadeClassifier();
    cascade->load([model UTF8String]);
    return cascade;
}

// 64x96
+ (cv::Mat) normalizeFace:(cv::Mat)gray andFaceSize:(cv::Point)face_size andNoise:(cv::Point)nose
{
    int desiredFaceWidth = face_size.x;
    int desiredFaceHeight = face_size.y;
    
    
    double scale = desiredFaceWidth / (gray.cols-12);
    // Get the transformation matrix for rotating and scaling the face to the desired angle & size.
    cv::Mat rot_mat = getRotationMatrix2D(nose, 0, scale);
    // Shift the center of the eyes to be the desired center between the eyes.
    rot_mat.at<double>(0, 2) += desiredFaceWidth * 0.5f - nose.x;
    rot_mat.at<double>(1, 2) += desiredFaceHeight * 0.75f - nose.y;
    
    // Rotate and scale and translate the image to the desired angle & size & position!
    // Note that we use 'w' for the height instead of 'h', because the input face has 1:1 aspect ratio.
    cv::Mat warped = cv::Mat(desiredFaceHeight, desiredFaceWidth, CV_8U, cv::Scalar(128)); // Clear the output image to a default grey.
    cv::warpAffine(gray, warped, rot_mat, warped.size());
    
    cv::equalizeHist(warped, warped);
    
    // Use the "Bilateral Filter" to reduce pixel noise by smoothing the image, but keeping the sharp edges in the face.
    cv::Mat filtered = cv::Mat(warped.size(), CV_8U);
    cv::bilateralFilter(warped, filtered, 0, 20.0, 2.0);
    
    return filtered;
}

/*****************************************************************************
 *   Face Recognition using Eigenfaces or Fisherfaces
 ******************************************************************************
 *   by Shervin Emami, 5th Dec 2012
 *   http://www.shervinemami.info/openCV.html
 ******************************************************************************
 *   Ch8 of the book "Mastering OpenCV with Practical Computer Vision Projects"
 *   Copyright Packt Publishing 2012.
 *   http://www.packtpub.com/cool-projects-with-opencv/book
 *****************************************************************************/
+ (cv::Mat) normalizeFace: (cv::Mat) img andEyeLeft: (cv::Point) leftEye andEyeRight:(cv::Point) rightEye andFaceSize:(cv::Point)face_size andHistEqual:(BOOL)doLeftAndRightSeparately
{
    const double DESIRED_LEFT_EYE_X = 0.16;     // Controls how much of the face is visible after preprocessing.
    const double DESIRED_LEFT_EYE_Y = 0.14;
    
    // If the input image is not grayscale, then convert the BGR or BGRA color image to grayscale.
    cv::Mat gray;
    if (img.channels() == 3) {
        cv::cvtColor(img, gray, CV_BGR2GRAY);
    }
    else if (img.channels() == 4) {
        cv::cvtColor(img, gray, CV_BGRA2GRAY);
    }
    else {
        // Access the input image directly, since it is already grayscale.
        gray = img;
    }
    
    // Make the face image the same size as the training images.
    
    // Since we found both eyes, lets rotate & scale & translate the face so that the 2 eyes
    // line up perfectly with ideal eye positions. This makes sure that eyes will be horizontal,
    // and not too far left or right of the face, etc.
    
    int desiredFaceWidth = face_size.x;
    int desiredFaceHeight = face_size.y;
    
    // Get the center between the 2 eyes.
    cv::Point2f eyesCenter = cv::Point2f( (leftEye.x + rightEye.x) * 0.5f, (leftEye.y + rightEye.y) * 0.5f );
    // Get the angle between the 2 eyes.
    double dy = (rightEye.y - leftEye.y);
    double dx = (rightEye.x - leftEye.x);
    double len = sqrt(dx*dx + dy*dy);
    double angle = atan2(dy, dx) * 180.0/CV_PI; // Convert from radians to degrees.
    
    // Hand measurements shown that the left eye center should ideally be at roughly (0.19, 0.14) of a scaled face image.
    const double DESIRED_RIGHT_EYE_X = (1.0f - DESIRED_LEFT_EYE_X);
    // Get the amount we need to scale the image to be the desired fixed size we want.
    double desiredLen = (DESIRED_RIGHT_EYE_X - DESIRED_LEFT_EYE_X) * desiredFaceWidth;
    double scale = desiredLen / len;
    // Get the transformation matrix for rotating and scaling the face to the desired angle & size.
    cv::Mat rot_mat = getRotationMatrix2D(eyesCenter, angle, scale);
    // Shift the center of the eyes to be the desired center between the eyes.
    rot_mat.at<double>(0, 2) += desiredFaceWidth * 0.5f - eyesCenter.x;
    rot_mat.at<double>(1, 2) += desiredFaceHeight * DESIRED_LEFT_EYE_Y - eyesCenter.y;
    
    // Rotate and scale and translate the image to the desired angle & size & position!
    // Note that we use 'w' for the height instead of 'h', because the input face has 1:1 aspect ratio.
    cv::Mat warped = cv::Mat(desiredFaceHeight, desiredFaceWidth, CV_8U, cv::Scalar(128)); // Clear the output image to a default grey.
    cv::warpAffine(gray, warped, rot_mat, warped.size());
    
    // Give the image a standard brightness and contrast, in case it was too dark or had low contrast.
    if (!doLeftAndRightSeparately) {
        // Do it on the whole face.
        cv::equalizeHist(warped, warped);
    }
    else {
        // Do it seperately for the left and right sides of the face.
        [self equalizeLeftAndRightHalves:warped];
    }
    
    // Use the "Bilateral Filter" to reduce pixel noise by smoothing the image, but keeping the sharp edges in the face.
    cv::Mat filtered = cv::Mat(warped.size(), CV_8U);
    cv::bilateralFilter(warped, filtered, 0, 20.0, 2.0);
    
    return filtered;
}


// Histogram Equalize seperately for the left and right sides of the face.
+ (void) equalizeLeftAndRightHalves:(cv::Mat&) faceImg
{
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
