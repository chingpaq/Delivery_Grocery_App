//
//  PaymentMenuViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 11/11/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PayMayaSDK/PayMayaSDK.h>
#import "PMDAPIManager.h"
#import "PMDCustomer.h"
#import "NSObject+KVCParsing.h"
#import "PMDCard.h"
#import "PMDCard+NSCoding.h"
#import "API.h"
#import "PaymentSelectionViewController.h"
#import "PaymentMethodsTableViewCell.h"
#import <FirebaseStorageUI/UIImageView+FirebaseStorage.h>


@interface PaymentMenuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) PMDAPIManager *apiManager;
@property (strong, nonatomic) PMDCard *card;
@property (nonatomic, strong) NSString *customerID;
@property (nonatomic, strong)PaymentSelectionViewController *paymentSelectionController;

@end
