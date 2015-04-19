//
//  ViewController_AddUser.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/10/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController_AddUser.h"


@interface ViewController_AddUser : UIViewController{
}
@property (weak, nonatomic) IBOutlet UITextField *TFFirstName;
@property (weak, nonatomic) IBOutlet UITextField *TFLastName;
@property (weak, nonatomic) IBOutlet UILabel *LBNotification;


- (void) initUserFile;
@end