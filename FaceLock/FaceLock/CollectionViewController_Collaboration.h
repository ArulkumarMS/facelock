//
//  CollectionViewController_Collaboration.h
//  FaceLock
//
//  Created by Yiwen Shi on 4/24/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Setting_UserManagement.h"
#import "CollectionViewCell_Collaboration.h"
#import "Setting_ImageManagement.h"
#import "ViewController_Add2DImage.h"

@interface CollectionViewController_Collaboration : UICollectionViewController
@property(nonatomic) NSString *FullName;
@property(nonatomic) NSMutableArray *ImageNames;
@end
