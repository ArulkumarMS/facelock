//
//  TableViewController_TrainingImg3D.m
//  FaceLock
//
//  Created by Yiwen Shi on 5/9/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "TableViewController_TrainingImg3D.h"

@interface TableViewController_TrainingImg3D ()

@end

@implementation TableViewController_TrainingImg3D

- (void)viewDidLoad {
    [super viewDidLoad];
    self.UserName=[Setting_UserManagement LoadUserFile];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.UserName count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    static NSString *simpleTableIdentifier = @"CollaborationUserCell";
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    NSInteger row = [indexPath row];
    if (cell == nil){
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.Name.text = [self.UserName objectAtIndex:row];
    cell.Label.text = [@(row) stringValue];
    self.fullname=[self.UserName objectAtIndex:row];
    NSString *PortraitImageName=[NSString stringWithFormat:@"%@2D1.jpg", self.fullname];
    if ([Setting_ImageManagement ImageExist:PortraitImageName]) {
        cell.Portrait.image=[Setting_ImageManagement loadImage:PortraitImageName];
    }
    else{
        cell.Portrait.image=[UIImage imageNamed:@"Default.png"];
    }
    //cell.Portrait.image=[Setting_ImageManagement loadImage:PortraitImageName];
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Segue_3DTrainingImg2"]){
        CollectionViewController_TrainingImg3D *controller = (CollectionViewController_TrainingImg3D *)segue.destinationViewController;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        NSInteger row = [indexPath row];
        controller.title=[self.UserName objectAtIndex:row];
        controller.FullName = [self.UserName objectAtIndex:row];
    }
}

@end
