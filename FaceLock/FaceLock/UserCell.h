//
//  UserCell.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/22/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell
@property (strong,nonatomic) IBOutlet UILabel * Name;
@property (strong,nonatomic) IBOutlet UILabel * Label;
@property (strong,nonatomic) IBOutlet UIImageView * Portrait;
@end
