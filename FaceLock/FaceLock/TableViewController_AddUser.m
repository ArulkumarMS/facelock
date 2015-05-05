//
//  TableViewController_AddUser.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/19/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "TableViewController_AddUser.h"

@interface TableViewController_AddUser ()

@end

@implementation TableViewController_AddUser{
    //NSMutableArray  *curUserName;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //self.UserName=[NSMutableArray arrayWithObjects:@"Yiwen", @"Ha",@"Xiang",@"Shiwani", nil];
    //NSLog(@"namecount: %d",[self.UserName count]);
    self.UserName=[Setting_UserManagement LoadUserFile];
    UIBarButtonItem *addButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(AddUser2:)];
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = addButton;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)addNewItem{

    [self.UserName addObject:@"K"];
    [self.tableView reloadData];
}

-(void)AddUser2:(id)sender {
    [self performSegueWithIdentifier:@"Segue_Add_User2" sender:self];
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
    return [self.UserName count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"AddUserCell";
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    NSInteger row = [indexPath row];
    if (cell == nil){
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.Name.text = [self.UserName objectAtIndex:row];
    cell.Label.text = [@(row) stringValue];
    NSString *PortraitImageName=[NSString stringWithFormat:@"%@1.jpg", cell.Name.text];
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
        [curUserName removeObjectAtIndex:indexPath.row];
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

@end
