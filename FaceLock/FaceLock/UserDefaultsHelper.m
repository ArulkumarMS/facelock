//
//  UserDefaultsHelper.m
//  FaceLock
//
//  Created by Alan Xu on 4/7/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "UserDefaultsHelper.h"

@implementation UserDefaultsHelper
+(void)setBoolForKey:(BOOL) value andKey:(NSString*) key{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setBool:value forKey:key];
        [standardUserDefaults synchronize];
    }
    
}

+(BOOL)getBoolForKey:(NSString *)key{
    BOOL val = false;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults){
        val = [standardUserDefaults boolForKey:key];
    }
    return val;
}

@end
