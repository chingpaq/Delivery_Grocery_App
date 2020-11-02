//
//  PaymentSelectionViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 11/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMDCard.h"
#import <PayMayaSDK/PayMayaSDK.h>
#import "PMDAPIManager.h"
#import "PMDCustomer.h"
#import "NSObject+KVCParsing.h"
#import "PMDVerifyCardViewController.h"
#import "API.h"
#import "CustomCreditCardAddTableViewCell.h"
@import SVProgressHUD;

@interface PaymentSelectionViewController : UIViewController<PayMayaPaymentsDelegate>
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;
@property (strong, nonatomic)PMDCard *card;
@property (strong, nonatomic)PMDAPIManager *apiManager;
@property (strong, nonatomic)NSString*customerID;
@property (strong, nonatomic)PMDCustomer*customer;

@property (strong, nonatomic) IBOutlet UIView *createCreditCardView;

@property (strong, nonatomic) IBOutlet UITextField *cardNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *expiryTextField;
@property (strong, nonatomic) IBOutlet UITextField *ccvTextField;
@property (strong, nonatomic) IBOutlet UITextField *countryTextField;
@property (strong, nonatomic) UIBarButtonItem *keyboardSaveButton;
@property (strong, nonatomic) UIBarButtonItem *keyboardAddButton;
@property (strong, nonatomic) UIToolbar *keyboardToolbar;
@property (nonatomic) int type;
@end
