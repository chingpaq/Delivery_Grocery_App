//
//  UIViewController+CreateAccountViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 05/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "CreateAccountViewController.h"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden=NO;
    self.emailTextbox.delegate=self;
    self.firstnameTextbox.delegate=self;
    self.lastnameTextbox.delegate=self;
    self.passwordTextbox.delegate=self;
    self.confirmPasswordTextbox.delegate=self;
    self.mobileNumberTextBox.delegate=self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isMovingFromParentViewController) {
        self.navigationController.navigationBarHidden=YES;
    }
}
- (IBAction)signupWasPressed:(id)sender {
    if (![self.emailTextbox.text isEqualToString:@""]){
        if ([self.passwordTextbox.text isEqualToString:@""] || [self.confirmPasswordTextbox.text isEqualToString:@""]){
            [self showMessagePrompt:@"Empty password"];
            
        }
        else{
            if ([self.passwordTextbox.text isEqualToString:self.confirmPasswordTextbox.text]){
                [self createProfileUsingEmail];
            }
            else{
                [self showMessagePrompt:@"Passwords don't match"];
            }
        }
    }else{
        [self showMessagePrompt:@"Email is required"];
    }
}

-(void)createProfileUsingEmail
{
    [SVProgressHUD show];
    [[FIRAuth auth] createUserWithEmail:self.emailTextbox.text
                               password:self.passwordTextbox.text
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 [SVProgressHUD dismiss];
                                 if (error) {
                                     [self showMessagePrompt: error.localizedDescription];
                                     return;
                                 }
                                 NSLog(@"%@ created", user.email);
                                 // create buyer profile
                                 [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"] child:[FIRAuth auth].currentUser.uid]
                                  setValue:@{@"name": [NSString stringWithFormat:@"%@ %@", self.firstnameTextbox.text,self.lastnameTextbox.text],
                                             @"firstName" : self.firstnameTextbox.text,
                                             @"lastName" : self.lastnameTextbox.text,
                                             @"mobileNumber" : self.mobileNumberTextBox.text,
                                             }];
                                 [self showMessagePrompt:@"Account created. Please login using your email"];
                                 [self.navigationController popViewControllerAnimated:NO];
                             }];
    
    [self updateFirstLastName];
    
}

-(void)updateFirstLastName
{
    if (![self.lastnameTextbox.text isEqualToString:@""] && ![self.firstnameTextbox.text isEqualToString:@""])
    {
        FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
        changeRequest.displayName = [NSString stringWithFormat:@"%@ %@", self.firstnameTextbox.text, self.lastnameTextbox.text];
        [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
            //ok
        }];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}




@end

