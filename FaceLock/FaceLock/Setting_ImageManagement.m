//
//  Setting_ImageManagement.m
//  FaceLock
//
//  Created by Yiwen Shi on 5/3/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "Setting_ImageManagement.h"

@implementation Setting_ImageManagement

+ (BOOL)ImageExist:(NSString*)ImageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *ImagePath = [documentsDirectory stringByAppendingPathComponent:ImageName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:ImagePath];
    NSLog(@"%@,%s",ImageName, fileExists ? "true" : "false");
    return fileExists;
}

+ (UIImage*)loadImage:(NSString*)ImageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:ImageName];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}


+ (void)removeImage:(NSString *)UserName andTrainNum:(NSInteger)imageNum
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for(int i=1; i<=imageNum; i++){
        NSString *ImageName = [NSString stringWithFormat: @"%@%@.jpg", UserName, [@(i) stringValue]];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:ImageName];
        if([fileManager fileExistsAtPath:filePath]){
            NSError *error;
            BOOL success = [fileManager removeItemAtPath:filePath error:&error];
            if (success) {
                NSLog(@"Delete Image -:%@ ",ImageName);
            }
            else
            {
                NSLog(@"Could not delete Image -%@:%@ ",ImageName, [error localizedDescription]);
            }

        }

    }
}

+ (void)removeOneImage:(NSString *)ImageName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:ImageName];
    if([fileManager fileExistsAtPath:filePath]){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (success) {
            NSLog(@"Delete Image -:%@ ",ImageName);
        }
        else
        {
            NSLog(@"Could not delete Image -%@:%@ ",ImageName, [error localizedDescription]);
        }
    }
}
@end
