//
//  WithdrawalViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 05/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import "WithdrawalViewController.h"

@interface WithdrawalViewController ()

@end

@implementation WithdrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.amountTextBox.text = [NSString stringWithFormat:@"%.2f",[[[NSUserDefaults standardUserDefaults] objectForKey:@"credits"] floatValue]];
    
    self.QRImageView.image=[UIImage mdQRCodeForString:[NSString stringWithFormat:@"%@:%@",[FIRAuth auth].currentUser.uid,self.amountTextBox.text] size:self.QRImageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
    self.amountTextBox.delegate=self;
}

-(void)viewDidAppear:(BOOL)animated{
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
#pragma mark - UITextField Delegate Methods

//- (BOOL)textField:(UITextField *)textField
//shouldChangeCharactersInRange:(NSRange)range
//replacementString:(NSString *)string {
//    // Prevent crashing undo bug – see note below.
//    if (range.length + range.location > textField.text.length) {
//        return false;
//    }
//    
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    return newLength <= 2;
//}

//-(void)textFieldDidBeginEditing:(UITextField *)textField {
//
//}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //textField.text = [NSString stringWithFormat:@"%.2f",[textField.text floatValue]];
    if (textField.text.length>1){
        self.QRImageView.image=[UIImage mdQRCodeForString:[NSString stringWithFormat:@"%@:%@",[FIRAuth auth].currentUser.uid,textField.text] size:self.QRImageView.bounds.size.width fillColor:[UIColor darkGrayColor]];
    }
    return TRUE;
}
- (IBAction)withdrawalButtonPressed:(id)sender {
    if (self.amountTextBox.text.floatValue <= [[[NSUserDefaults standardUserDefaults] objectForKey:@"credits"] floatValue]){
    [API addDebits:@{@"paidBy": [FIRAuth auth].currentUser.uid,
                     @"amount" : self.amountTextBox.text,
                     @"code" : [NSString stringWithFormat:@"%@%@",[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]],[FIRAuth auth].currentUser.uid],
                     @"paymentMethod" : @"Cash",
                     @"type" : @"Withdrawal"
                     }
           success:^(){
               [AZNotification showNotificationWithTitle:[NSString stringWithFormat:@"Successful Transaction. You may receive your money from the cashier"]  controller:self notificationType:AZNotificationTypeMessage shouldShowNotificationUnderNavigationBar:YES];
               
           } failure:^(NSString *message) {
               NSLog(@"Fail");
           }];
    }else{
        [AZNotification showNotificationWithTitle:[NSString stringWithFormat:@"Insufficient Funds."]  controller:self notificationType:AZNotificationTypeMessage shouldShowNotificationUnderNavigationBar:YES];
        
    }
}

@end
