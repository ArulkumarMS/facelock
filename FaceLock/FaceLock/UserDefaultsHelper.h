//
//  UserDefaultsHelper.h
//  FaceLock
//
//  Created by Alan Xu on 4/7/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsHelper : NSObject

+(void)setBoolForKey:(BOOL) value andKey:(NSString*) key;
+(BOOL)getBoolForKey:(NSString*) key;
@end
