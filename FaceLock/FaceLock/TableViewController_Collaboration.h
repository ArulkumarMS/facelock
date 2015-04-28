//
//  TableViewController_Collaboration.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/24/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Setting_UserManagement.h"
#import "UserCell.h"

@interface TableViewController_Collaboration : UITableViewController
@property (nonatomic, strong) NSMutableArray *UserName;
@property (nonatomic, strong) NSMutableArray *UserLabel;
@property (nonatomic, strong) NSMutableArray *Userportrait;
@end
