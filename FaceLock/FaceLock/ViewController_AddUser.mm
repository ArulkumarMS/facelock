//
//  ViewController_AddUser.m
//  FaceLock
//
//  Created by Yiwen Shi on 4/10/15.
//  Copyright (c) 2015 CBL. All rights reserved.
//

#import "ViewController_AddUser.h"


@implementation ViewController_AddUser


- (IBAction)TrainFaceRecg:(id)sender {    
    cv::Ptr<cv::face::FaceRecognizer> ini_LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer();
    _LBPHFaceRecognizer=cv::face::createLBPHFaceRecognizer();
    [FaceRecognition_2D saveFaceRecognizer:ini_LBPHFaceRecognizer];
    [FaceRecognition_2D loadFaceRecognizer:_LBPHFaceRecognizer];
    NSMutableArray *UserName=[Setting_UserManagement LoadUserFile];
    
    for(int i=0;i<=[UserName count]-1;i++){
        [FaceRecognition_2D trainFaceRecognizer:ini_LBPHFaceRecognizer andUser:UserName[i] andLabel:i andTrainNum:9];
    }

    [FaceRecognition_2D saveFaceRecognizer:ini_LBPHFaceRecognizer];
}

- (IBAction)AddNewUser:(id)sender {
    NSLog(@"%@",self.TFFirstName.text);
    NSLog(@"%@",self.TFLastName.text);
    //[self initUserFile];
    NSString *trimmedFirstName = [self.TFFirstName.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    NSString *trimmedLastName = [self.TFLastName.text stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceCharacterSet]];
    if([trimmedFirstName length] == 0 ){
        self.LBNotification.text=@"First Name can not be empty!";
    }
    else if([trimmedLastName length] == 0 ){
        self.LBNotification.text=@"Last Name can not be empty!";
    }
    else{
        fullname = [NSString stringWithFormat:@"%@ %@", trimmedFirstName.uppercaseString, trimmedLastName.uppercaseString];
        [Setting_UserManagement addNewUser:fullname];
    }
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Segue_take2Dimage"]){
        ViewController_Take2DImage *controller = (ViewController_Take2DImage *)segue.destinationViewController;
        controller.FullName = fullname;
    }
}

/*
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

- (void) SaveUserFile:(NSMutableArray*)UserNameArray{
    NSString  *arrayPath;
    //[array insertObject:@"Yiwen Shi" atIndex:0];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    arrayPath = [[paths objectAtIndex:0]
                 stringByAppendingPathComponent:@"array.out"];
    [UserNameArray writeToFile:arrayPath atomically:YES];
}

- (NSMutableArray*) LoadUserFile{
    NSString  *arrayPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    arrayPath = [[paths objectAtIndex:0]
                 stringByAppendingPathComponent:@"array.out"];
    NSMutableArray *arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
    return arrayFromFile;
}


- (void) addNewUser: (NSString*)NewUserName{
    NSMutableArray  *curUserName=[self LoadUserFile];
    
    // Print the contents
    NSLog(@"Before add a new user.");
    for (NSString *element in curUserName){
        NSLog(@"element: %@,%lu", element,(unsigned long)[curUserName indexOfObject:element]);
        if([element isEqualToString:NewUserName]){
            [self.LBNotification setText:@"Username already exists!"];
            return;
        }
    }
    [self.LBNotification setText:@""];
    NSLog(@"total user: %lu",(unsigned long)[curUserName count]);
    NSLog(@"After add a new user.");
    [curUserName addObject:NewUserName];
    for (NSString *element in curUserName)
        NSLog(@"element: %@,%lu", element,(unsigned long)[curUserName indexOfObject:element]);
    NSLog(@"total user: %lu",(unsigned long)[curUserName count]);
    [self SaveUserFile:curUserName];
    [self.LBNotification setText:@"New user added seccessfully!"];
}
*/



@end