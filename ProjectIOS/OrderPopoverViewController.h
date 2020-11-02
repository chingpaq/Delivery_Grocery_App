//
//  OrderPopoverViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 10/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "Seller.h"
#import "Buyer.h"

@import Firebase;
@import FirebaseStorageUI;

@protocol OrderPopoverViewControllerDelegate <NSObject>
@optional
-(void)gotoMap;
-(void)onTheWay:(id)orderDict;

@end
@interface OrderPopoverViewController : UIViewController
@property (strong, nonatomic) id<OrderPopoverViewControllerDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIButton *showButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *profileImageLeft;
@property (strong, nonatomic) IBOutlet UIView *popupView;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *contactDetail;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UITextView *ordersLabel;
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) NSMutableDictionary *orderDict;
@property (strong, nonatomic) NSString *userId;
@end
