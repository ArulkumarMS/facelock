//
//  Setting_UserManagement.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/19/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

@interface Setting_UserManagement : NSObject{
}

+ (NSMutableArray*) LoadUserFile;
+ (void) initUserFile;
+ (void) SaveUserFile:(NSMutableArray*)UserNameArray;
+ (void) addNewUser: (NSString*)NewUserName;
+ (void) deleteUser: (NSString*)DeleteUserName;

@end
