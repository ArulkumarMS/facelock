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
                 stringByAppendingPathComponent:@"array.out"];
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
                 stringByAppendingPathComponent:@"array.out"];
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
                 stringByAppendingPathComponent:@"array.out"];
    [UserNameArray writeToFile:arrayPath atomically:YES];
}


+ (void) addNewUser: (NSString*)NewUserName{
    NSMutableArray  *curUserName=[self LoadUserFile];
    
    // Print the contents
    NSLog(@"Before add a new user.");
    for (NSString *element in curUserName){
        NSLog(@"element: %@,%lu", element,(unsigned long)[curUserName indexOfObject:element]);
        if([element isEqualToString:NewUserName]){
            //[self.LBNotification setText:@"Username already exists!"];
            NSLog(@"Username already exists!");
            return;
        }
    }
    //[self.LBNotification setText:@""];
    NSLog(@"total user: %lu",(unsigned long)[curUserName count]);
    NSLog(@"After add a new user.");
    [curUserName addObject:NewUserName];
    for (NSString *element in curUserName)
        NSLog(@"element: %@,%lu", element,(unsigned long)[curUserName indexOfObject:element]);
    NSLog(@"total user: %lu",(unsigned long)[curUserName count]);
    [self SaveUserFile:curUserName];
    
}


+ (void) deleteUser: (NSString*)DeleteUserName{
    NSMutableArray  *curUserName=[self LoadUserFile];
    
    // Print the contents
    NSLog(@"Before delete a new user.");
    for (NSString *element in curUserName){
        NSLog(@"element: %@,%lu", element,(unsigned long)[curUserName indexOfObject:element]);
        if([element isEqualToString:DeleteUserName]){
            //[self.LBNotification setText:@"Username already exists!"];
            [curUserName removeObject:DeleteUserName];
            NSLog(@"Username already delete!");
            return;
        }
    }
    NSLog(@"Username does not exist!");
    NSLog(@"total user: %lu",(unsigned long)[curUserName count]);
    NSLog(@"After delete a new user.");
    for (NSString *element in curUserName)
        NSLog(@"element: %@,%lu", element,(unsigned long)[curUserName indexOfObject:element]);
    NSLog(@"total user: %lu",(unsigned long)[curUserName count]);
    [self SaveUserFile:curUserName];
    
}
@end
