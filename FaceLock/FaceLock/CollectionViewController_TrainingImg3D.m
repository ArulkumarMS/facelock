//
//  CollectionViewController_TrainingImg3D.m
//  FaceLock
//
//  Created by Yiwen Shi on 5/9/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "CollectionViewController_TrainingImg3D.h"

@interface CollectionViewController_TrainingImg3D ()

@end

@implementation CollectionViewController_TrainingImg3D

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.ImageNames=[[NSMutableArray alloc]init];
    for (NSInteger i=1; i<=50; i++) {
        NSString *ImageName=[NSString stringWithFormat:@"%@3D%ld.jpg", self.FullName,(long)i];
        NSLog(@"image name is: %@",ImageName);
        if (!self.ImageNames ) self.ImageNames  = [[NSMutableArray alloc] init];
        //[listData addObject:jobName];
        [self.ImageNames  addObject:ImageName];
    }
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(Add3DTrainingImage:)];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = addButton;    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

-(void)Add3DTrainingImage:(id)sender {
    [self performSegueWithIdentifier:@"Segue_Add3DTrainingImage" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Segue_Add3DTrainingImage"]){
        ViewController_Add3DImage *controller = (ViewController_Add3DImage *)segue.destinationViewController;
        controller.UserName = self.FullName;
    }
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
    return 50;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"CollectionCollaborationCell";
    CollectionViewCell_Collaboration *cell = [collectionView dequeueReusableCellWithReuseIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    NSInteger row = [indexPath row];
    
    // Configure the cell
    if ([Setting_ImageManagement ImageExist:self.ImageNames[row]]) {
        cell.Portrait.image=[Setting_ImageManagement loadImage:self.ImageNames[row]];
        //}
        //if([UIImage imageNamed:self.ImageNames[row]]!=nil){
        //    NSLog(@"%@ is found!",self.ImageNames[row]);
        //    cell.Portrait.image=[UIImage imageNamed:self.ImageNames[row]];
    }
    else{
        NSLog(@"%@ is not found!",self.ImageNames[row]);
        cell.Portrait.image=[UIImage imageNamed:@"Default.png"];
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row=[indexPath row];
    NSString *ImageName=[NSString stringWithFormat:@"%@%ld.jpg", self.FullName,(long)row+1];
    [Setting_ImageManagement removeOneImage:(NSString *)ImageName];
    [collectionView reloadData];
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
