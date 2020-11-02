//
//  SellerOrdersDetailsViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 25/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "CustomTableCellSellersTableViewCell.h"
#import "OrdersTableViewCell.h"
#import <FirebaseStorageUI/UIImageView+FirebaseStorage.h>
#import "ProductViewController.h"
#import "SellerOrdersMapViewController.h"
#import "CustomSingleHeaderTableViewCell.h"
#import "Buyer.h"

@protocol SellerOrdersDetailsViewControllerDelegate <NSObject>
@optional
-(void)acceptProposal:(id)sender;
-(void)oTWProposal:(id)sender;
-(void)cancelProposal:(id)sender;

@end
@interface SellerOrdersDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,ProductViewControllerDelegate,SellerOrdersMapViewControllerDelegate>
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableviewConstraint;
@property (strong, nonatomic) id<SellerOrdersDetailsViewControllerDelegate>delegate;
@property (strong, nonatomic) ProductViewController*productViewController;
@property (strong, nonatomic) SellerOrdersMapViewController*sellerOrdersMapViewController;
@property (strong, nonatomic)NSMutableArray *proposalsOrdersArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) IBOutlet UIButton *oMWButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic)NSMutableDictionary *proposalDict;

@end
