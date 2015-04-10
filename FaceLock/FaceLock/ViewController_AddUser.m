//
//  ViewController_AddUser.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/10/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_AddUser.h"


@implementation ViewController_AddUser

- (IBAction)back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)AddNewUser:(id)sender {
    NSLog(@"%@",self.TFFirstName.text);
    NSLog(@"%@",self.TFLastName.text);
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
