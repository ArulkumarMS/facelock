//
//  Setting_UserManagement.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/19/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Setting_UserManagement.h"

@implementation Setting_UserManagement
+ (NSMutableArray*) LoadUserFile{
    NSString  *arrayPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    arrayPath = [[paths objectAtIndex:0]
                 stringByAppendingPathComponent:@"userlist.txt"];
    NSMutableArray *arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
    return arrayFromFile;
}

+ (void) initUserFile{
    NSString  *arrayPath;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //[array insertObject:@"Yiwen Shi" atIndex:0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    arrayPath = [[paths objectAtIndex:0]
                 stringByAppendingPathComponent:@"userlist.txt"];
    [array writeToFile:arrayPath atomically:YES];
    //NSMutableArray *arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
    NSLog(@"%lu",(unsigned long)[array count]);
}

+ (void) SaveUserFile:(NSMutableArray*)UserNameArray{
    NSString  *arrayPath;
    //[array insertObject:@"Yiwen Shi" atIndex:0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    arrayPath = [[paths objectAtIndex:0]
                 stringByAppendingPathComponent:@"userlist.txt"];
    [UserNameArray writeToFile:arrayPath atomically:YES];
}





@end
