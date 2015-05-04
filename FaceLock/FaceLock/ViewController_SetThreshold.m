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
    self.tfThreshold2D.text=[NSString stringWithFormat:@"%f", [Threshold getThreshold_2D]];
    self.tfThreshold3D.text=[NSString stringWithFormat:@"%f", [Threshold getThreshold_3D]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)SaveTreshold:(id)sender {
    [Threshold setThreshold_2D:[self.tfThreshold2D.text doubleValue]];
    [Threshold setThreshold_3D:[self.tfThreshold3D.text doubleValue]];
    self.LBNotification.text=@"Threshold updated!";
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
