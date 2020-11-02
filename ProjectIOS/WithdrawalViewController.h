//
//  WithdrawalViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 05/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+MDQRCode.h"
#import "API.h"
#import "AZNotification.h"

@interface WithdrawalViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *QRImageView;
@property (strong, nonatomic) IBOutlet UITextField *amountTextBox;
@property (strong, nonatomic) IBOutlet UIButton *withdrawButton;

@end
