//
//  TableViewController_DeleteUser.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/18/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "TableViewController_User.h"

@interface TableViewController_User ()

@end

@implementation TableViewController_User{
    //NSArray *userName;
    NSMutableArray  *curUserName;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //[self initUserFile];
    curUserName=[self LoadUserFile];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //curUserName=[NSMutableArray arrayWithObjects:@"Yiwen", @"Ha",@"Xiang",@"Shiwani", nil];
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
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //if ([_settingOptions isEqualToString:@"Delete User"]) {
        return [curUserName count];
    //}
    //else if ([_settingOptions isEqualToString:@"Collaboration"]) {
    //    return [curUserName count];
    //}
    //else if ([_settingOptions isEqualToString:@"Threshold"]) {
    //    return 1;
    //}
    //return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"UserCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    //if ([_settingOptions isEqualToString:@"Delete User"]) {
        cell.textLabel.text = [curUserName objectAtIndex:indexPath.row];
    //}
    //else if ([_settingOptions isEqualToString:@"Collaboration"]) {
    //    cell.textLabel.text = [curUserName objectAtIndex:indexPath.row];
    //}
    //else if ([_settingOptions isEqualToString:@"Threshold"]) {
    //    cell.textLabel.text = @"Threshold";
    //}
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (NSMutableArray*) LoadUserFile{
    NSString  *arrayPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    arrayPath = [[paths objectAtIndex:0]
                 stringByAppendingPathComponent:@"array.out"];
    NSMutableArray *arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
    return arrayFromFile;
}

- (void) initUserFile{
    NSString  *arrayPath;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //[array insertObject:@"Yiwen Shi" atIndex:0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    arrayPath = [[paths objectAtIndex:0]
                 stringByAppendingPathComponent:@"array.out"];
    [array writeToFile:arrayPath atomically:YES];
    //NSMutableArray *arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
    NSLog(@"%lu",(unsigned long)[array count]);
}

@end
