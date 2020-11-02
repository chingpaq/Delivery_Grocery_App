//
//  ProposalDetailsViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 18/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "API.h"
#import "CustomHeadersTableViewCell.h"
#import "OrdersTableViewCell.h"
#import <FirebaseStorageUI/UIImageView+FirebaseStorage.h>
#import "ProductViewController.h"
#import "CustomSingleHeaderTableViewCell.h"
#import "CustomTableCellSellersTableViewCell.h"

@protocol ProposalDetailsViewControllerDelegate <NSObject>
@optional
-(void)acceptProposal:(id)sender;
-(void)rejectProposal:(id)sender;
-(void)cancelProposal:(id)sender;

@end


@interface ProposalDetailsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,ProductViewControllerDelegate>
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (strong, nonatomic) id<ProposalDetailsViewControllerDelegate>delegate;
@property (strong, nonatomic) ProductViewController*productViewController;
@property (strong, nonatomic)NSMutableArray *proposalsOrdersArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) IBOutlet UIButton *rejectButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic)NSMutableDictionary *proposalDict;
@end
