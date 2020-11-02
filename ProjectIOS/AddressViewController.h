//
//  AddressViewController.h
//  Dashboard
//
//  Created by Jhaybie Basco on 2/28/17.
//  Copyright © 2017 RiseMovement. All rights reserved.
//

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@class UserCardView;

@protocol AddressViewControllerDelegate <NSObject>
@optional
- (void)didDismissViewController:(UIViewController *)viewController;
- (void)didSubmitAddressInfo:(NSUserDefaults*)defaults;
@end

@interface AddressViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) id<AddressViewControllerDelegate> delegate;
@property (strong, nonatomic) UserCardView *cardView;


@end
