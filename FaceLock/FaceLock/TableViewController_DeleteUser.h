//
//  TableViewController_DeleteUser.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/19/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Setting_UserManagement.h"
#import "UserCell.h"

@interface TableViewController_DeleteUser : UITableViewController
@property (nonatomic, strong) NSMutableArray *UserName;
@property (nonatomic, strong) NSMutableArray *UserLabel;
@property (nonatomic, strong) NSMutableArray *Userportrait;
@end
