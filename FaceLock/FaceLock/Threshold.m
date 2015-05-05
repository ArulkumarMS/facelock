//
//  Threshold.m
//  FaceLock
//
//  Created by Yiwen Shi on 5/4/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "Threshold.h"
@implementation Threshold

+ (BOOL)Threshold2dfileExist{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"2DThreshold.txt"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSLog(@"2DThreshold.txt,%s", fileExists ? "true" : "false");
    return fileExists;
}

+ (NSString *) Load2DThresholdFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/2DThreshold.txt", documentsDirectory];
    return [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
}

+ (void) init2DThresholdFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/2DThreshold.txt", documentsDirectory];
    [@"0" writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];

}

+ (void) Save2DThresholdFile:(NSString *)Threshold2D{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/2DThreshold.txt", documentsDirectory];
    [Threshold2D writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

+ (BOOL)Threshold3dfileExist{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"3DThreshold.txt"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSLog(@"3DThreshold.txt,%s", fileExists ? "true" : "false");
    return fileExists;
}

+ (NSString *) Load3DThresholdFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/3DThreshold.txt", documentsDirectory];
    return [NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
}

+ (void) init3DThresholdFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/3DThreshold.txt", documentsDirectory];
    [@"0" writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}

+ (void) Save3DThresholdFile:(NSString *)Threshold3D{
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@/3DThreshold.txt", documentsDirectory];
    [Threshold3D writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
}
@end