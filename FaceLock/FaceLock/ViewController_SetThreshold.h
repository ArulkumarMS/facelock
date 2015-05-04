//
//  ViewController_SetThreshold.h
//  FaceLock
//
//  Created by Yiwen Shi on 5/4/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Threshold.h"

@interface ViewController_SetThreshold : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *tfThreshold2D;
@property (weak, nonatomic) IBOutlet UITextField *tfThreshold3D;
@property (weak, nonatomic) IBOutlet UILabel *LBNotification;

@end
