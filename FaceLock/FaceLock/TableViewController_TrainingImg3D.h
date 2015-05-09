//
//  TableViewController_TrainingImg3D.h
//  FaceLock
//
//  Created by Yiwen Shi on 5/9/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Setting_UserManagement.h"
#import "UserCell.h"
#import "CollectionViewController_TrainingImg3D.h"
#import "Setting_ImageManagement.h"

@interface TableViewController_TrainingImg3D : UITableViewController
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSMutableArray *UserName;
@property (nonatomic, strong) NSMutableArray *UserLabel;
@property (nonatomic, strong) NSMutableArray *Userportrait;
@end