//
//  SellerOrdersViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 20/03/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SellerOrdersDetailsViewController.h"
#import "API.h"
#import "Orders.h"
#import "CustomOffersMainCell.h"
#import "UIColor+DBColors.h"
#import "AZNotification.h"
#import "OrderPopoverViewController.h"

@import SVProgressHUD;

@interface SellerOrdersViewController :UIViewController<UITableViewDelegate, UITableViewDataSource,SellerOrdersDetailsViewControllerDelegate, OrderPopoverViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *proposalsArray;
@property (strong, nonatomic)NSMutableArray *completedArray;
@property (strong, nonatomic)NSMutableArray *openOrdersArray;
@property (strong, nonatomic) ProposalDetailsViewController *proposalDetailsController;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) OrderPopoverViewController *orderPopoverController;
@end
