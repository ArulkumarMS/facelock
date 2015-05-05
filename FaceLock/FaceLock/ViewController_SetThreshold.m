//
//  ViewController_SetThreshold.m
//  FaceLock
//
//  Created by Yiwen Shi on 5/4/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_SetThreshold.h"

@interface ViewController_SetThreshold ()

@end

@implementation ViewController_SetThreshold

- (void)viewDidLoad {
    [super viewDidLoad];
    if(![Threshold Threshold2dfileExist]){
        [Threshold init2DThresholdFile];
    }
    if(![Threshold Threshold3dfileExist]){
        [Threshold init3DThresholdFile];
    }
    
    self.tfThreshold2D.text=[Threshold Load2DThresholdFile];
    self.tfThreshold3D.text=[Threshold Load3DThresholdFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)SaveTreshold:(id)sender {
    [Threshold Save2DThresholdFile:self.tfThreshold2D.text];
    [Threshold Save3DThresholdFile:self.tfThreshold3D.text];
    self.LBNotification.text=@"Threshold updated!";
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
