//
//  PaymentCreateLoadViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 15/05/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
#import "API.h"
#import "AZNotification.h"

@interface PaymentCreateLoadViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *sellerTextBox;
@property (strong, nonatomic) IBOutlet UITextField *amountTextBox;
@property (strong, nonatomic) IBOutlet UIButton *createLoadButton;
@property (strong, nonatomic) NSMutableArray *sellerArray;
@property (strong, nonatomic) IBOutlet UITextField *cardLoadNumberTextField;
@property (strong, nonatomic) IBOutlet UITextField *cardPinNumberTextField;
@property (strong, nonatomic) NSMutableDictionary *sellerDict;
@end
