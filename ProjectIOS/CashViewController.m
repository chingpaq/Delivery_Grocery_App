//
//  CashViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 11/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "CashViewController.h"

@interface CashViewController ()

@end

@implementation CashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([[[NSUserDefaults standardUserDefaults]objectForKey:@"CashDefault"] isEqualToString:@"Yes"] ){
        self.cashSwitch.on=YES;
    }else{
        self.cashSwitch.on=NO;
    }
        
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cashSwitchChanged:(id)sender {
    if (self.cashSwitch.isOn == YES){
        [[NSUserDefaults standardUserDefaults]setObject:@"Yes" forKey:@"CashDefault"];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:@"No" forKey:@"CashDefault"];
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

@end
