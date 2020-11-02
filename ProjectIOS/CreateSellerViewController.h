//
//  CreateSellerViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 22/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Alerts.h"
@import SVProgressHUD;
#import "NSObject+FIRDatabaseSingleton.h"
#import "API.h"
@import Firebase;
@import Photos;
#import "DBDarkTextField.h"


@protocol CreateSellerViewControllerDelegate <NSObject>

- (void)didDismissViewController:(UIViewController *)viewController;

@end
@interface CreateSellerViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet DBDarkTextField *emailTextbox;
@property (weak, nonatomic) IBOutlet DBDarkTextField *firstnameTextbox;
@property (weak, nonatomic) IBOutlet DBDarkTextField *lastnameTextbox;
@property (weak, nonatomic) IBOutlet DBDarkTextField *passwordTextbox;
@property (weak, nonatomic) IBOutlet DBDarkTextField *confirmPasswordTextbox;
@property (strong, nonatomic) IBOutlet DBDarkTextField *mobileNumberTextBox;
@property (strong, nonatomic) IBOutlet DBDarkTextField *postalCodeTextBox;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (strong, nonatomic) id<CreateSellerViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *UIImageView;
@property (strong, nonatomic) NSDictionary *imageDict;
@end
