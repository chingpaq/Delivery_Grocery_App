//
//  ViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 03/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FBSDKCoreKit;
@import FBSDKLoginKit;
//@import TwitterKit;
@import GoogleSignIn;
@import Firebase;
#import "UIViewController+Alerts.h"
#import "NSObject+FIRDatabaseSingleton.h"
#import "NSObject+reSideMenuSingleton.h"

@import SVProgressHUD;

@interface LoginViewController : UIViewController<GIDSignInUIDelegate>
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@property (strong, nonatomic) IBOutlet UILabel *signInLabel;
@property (weak, nonatomic) IBOutlet UIButton *FacebookLoginButton;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextBox;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextbox;
@property (strong, nonatomic) IBOutlet UIButton *userNewOrBackButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) UIBarButtonItem *keyboardDoneButton;
@property (strong, nonatomic) UIBarButtonItem *keyboardSkipButton;

@property (strong, nonatomic) UIToolbar *keyboardToolbar;
- (void)firebaseLoginWithCredential:(FIRAuthCredential *)credential;


@end

