//
//  ViewController_Take3DImage.m
//  FaceLock
//
//  Created by Yiwen Shi on 5/9/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_Take3DImage.h"

@interface ViewController_Take3DImage ()

@end

@implementation ViewController_Take3DImage

- (void)viewDidLoad {
    [super viewDidLoad];
    _imagename_count=1;
    NSString *imagename = [NSString stringWithFormat:@"%@3D%d.jpg", self.FullName, _imagename_count];
    //[Utils saveMATImage:normalFaceImg andName:imagename];
    
    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
