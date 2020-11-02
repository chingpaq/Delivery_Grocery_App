//
//  ViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 03/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.navigationController.navigationBarHidden=YES;

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"2018 e-Utos v%@",version];

    self.keyboardToolbar = [[UIToolbar alloc] init];
    [self.keyboardToolbar sizeToFit];
    self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(doneButtonTapped:)];
    //self.keyboardDoneButton.enabled = false;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    self.keyboardSkipButton = [[UIBarButtonItem alloc] initWithTitle:@"Skip"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(skipButtonTapped:)];
    
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:flexibleSpace, flexibleSpace, self.keyboardDoneButton, nil]];
    
    self.emailTextBox.inputAccessoryView = self.keyboardToolbar;
    self.passwordTextbox.inputAccessoryView = self.keyboardToolbar;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([FIRAuth auth].currentUser){
        if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
            [FIRDatabaseSingleton sharedManager];
        }else{
            [FIRDatabaseSingleton sharedManagerSeller];
        }
        self.navigationController.navigationBarHidden=NO;
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        //[FBSDKAccessToken setCurrentAccessToken:nil];
    }
    
    [self.emailTextBox becomeFirstResponder];

}
- (IBAction)FacebookLoginButtonWasPressed:(id)sender {
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions:@[ @"public_profile", @"email",@"user_location" ]
                        fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"FBLogin Error");
                                       } else if (result.isCancelled) {
                                           NSLog(@"FBLogin cancelled");
                                       } else {
                                           FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                                                            credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
                                           
                                           [self firebaseLoginWithCredential:credential];
                                       }
                                   }];
     

}
- (IBAction)loginWasPressed:(id)sender {
    if ([self.emailTextBox.text isEqualToString:@""]){
        return;
    }
    
    
    
    if([self.loginButton.titleLabel.text isEqualToString:@"Next"]){
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        [self.userNewOrBackButton setTitle:[NSString stringWithFormat:@"< %@",self.emailTextBox.text] forState:UIControlStateNormal];
        self.signInLabel.text = @"Enter Password";
        self.passwordTextbox.hidden=NO;
        self.emailTextBox.hidden=YES;
        [self.passwordTextbox becomeFirstResponder];
    }else{
        if ([self.passwordTextbox.text isEqualToString:@""]){
            return;
        }
        
        [SVProgressHUD show];
        [[FIRAuth auth] signInWithEmail:self.emailTextBox.text
                               password:self.passwordTextbox.text
                             completion:^(FIRUser *user, NSError *error) {
                                 [SVProgressHUD dismiss];
                                 
                                 if (error) {
                                     
                                     [self showMessagePrompt:error.localizedDescription];
                                     return;
                                 }else{
                                     if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
                                         [FIRDatabaseSingleton sharedManager];
                                     }else{
                                         [FIRDatabaseSingleton sharedManagerSeller];
                                     }
                                     self.navigationController.navigationBarHidden=NO;
                                     [self.navigationController popViewControllerAnimated:NO];
                                 }
                                 
                             }];
    }
    
    
    
    
    
//    self.navigationController.navigationBarHidden=NO;
//    [self performSegueWithIdentifier:@"ShowHome" sender:nil];

}

- (void)firebaseLoginWithCredential:(FIRAuthCredential *)credential
{
    if ([FIRAuth auth].currentUser) {
        [[FIRAuth auth]
         .currentUser linkWithCredential:credential
         completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
             NSLog(@"Account already linked");
         }];
    } else {
        [[FIRAuth auth] signInWithCredential:credential
                                  completion:^(FIRUser *user, NSError *error) {
                                      NSLog(@"Account Created");
                                      
                                      if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
                                          [FIRDatabaseSingleton sharedManager];
                                      }else{
                                          [FIRDatabaseSingleton sharedManagerSeller];
                                      }
                                      
                                       [SVProgressHUD dismiss];
                                      self.navigationController.navigationBarHidden=NO;
                                      [self.navigationController popViewControllerAnimated:NO];
                                  }];
    }
}
- (IBAction)forgotPasswordPressed:(id)sender {
[self showMessagePrompt:@"Not yet implemented"];
}
- (IBAction)createOrBackButtonPassed:(id)sender {
    
    if ([self.userNewOrBackButton.titleLabel.text isEqualToString:@"New user? Click me!"]){
        [self performSegueWithIdentifier:@"createUserSegue" sender:nil];
    }else{
        [self.loginButton setTitle:@"Next" forState:UIControlStateNormal];
        [self.userNewOrBackButton setTitle:@"New user? Click me!" forState:UIControlStateNormal];
        self.signInLabel.text = @"Sign In";
        self.passwordTextbox.hidden=YES;
        self.emailTextBox.hidden=NO;
        self.passwordTextbox.text=@"";
    }
    
}

-(void)doneButtonTapped:(id)sender{
    [self.emailTextBox resignFirstResponder];
    [self.passwordTextbox resignFirstResponder];
}
@end
