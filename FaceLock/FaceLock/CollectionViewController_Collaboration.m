//
//  CollectionViewController_Collaboration.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/24/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "CollectionViewController_Collaboration.h"

@interface CollectionViewController_Collaboration ()

@end

@implementation CollectionViewController_Collaboration{
    
}

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.ImageNames=[[NSMutableArray alloc]init];
    for (NSInteger i=1; i<=10; i++) {
        NSString *ImageName=[NSString stringWithFormat:@"%@%ld.jpg", self.FullName,(long)i];
        NSLog(@"image name is: %@",ImageName);
        if (!self.ImageNames ) self.ImageNames  = [[NSMutableArray alloc] init];
        //[listData addObject:jobName];
        [self.ImageNames  addObject:ImageName];
    }
    /*
    ImageNames=@[@"%@1.jpg",
                          @"2.jpg",
                          @"3.jpg",
                          @"4.jpg",
                          @"5.jpg",
                          @"6.jpg",
                          @"7.jpg",
                          @"8.jpg",
                          @"9.jpg",
                          @"100.jpg",];
    */
     //Uncomment the following line to preserve selection between presentations
     //self.clearsSelectionOnViewWillAppear = NO;
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"CollectionCollaborationCell";
    CollectionViewCell_Collaboration *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    NSInteger row = [indexPath row];

    // Configure the cell
    //if ([self ImageExist:ImageNames[row]]) {
    //    cell.Portrait.image=[self loadImage:ImageNames[row]];
    //}
    if([UIImage imageNamed:self.ImageNames[row]]!=nil){
        NSLog(@"%@ is found!",self.ImageNames[row]);
        cell.Portrait.image=[UIImage imageNamed:self.ImageNames[row]];
    }
    else{
        NSLog(@"%@ is found!",self.ImageNames[row]);
        cell.Portrait.image=[UIImage imageNamed:@"Default.png"];
    }
    
    return cell;
}



- (BOOL)ImageExist:(NSString*)ImageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *ImagePath = [documentsDirectory stringByAppendingPathComponent:ImageName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:ImagePath];
    NSLog(@"%@,%s",ImageName, fileExists ? "true" : "false");
    return fileExists;
}

- (UIImage*)loadImage:(NSString*)ImageName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:ImageName];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end