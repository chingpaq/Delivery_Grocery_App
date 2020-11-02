//
//  ProposalsViewController.h
//  
//
//  Created by Manuel B Parungao Jr on 18/10/2017.
//

#import <UIKit/UIKit.h>
#import "ProposalDetailsViewController.h"
#import "API.h"
#import "Orders.h"
#import "CustomOffersMainCell.h"
#import "UIColor+DBColors.h"
#import "OrderPopoverViewController.h"
@import SVProgressHUD;


@interface ProposalsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,ProposalDetailsViewControllerDelegate, OrderPopoverViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *proposalsArray;
@property (strong, nonatomic)NSMutableArray *completedArray;
@property (strong, nonatomic) ProposalDetailsViewController *proposalDetailsController;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) OrderPopoverViewController *orderPopoverController;
@end
