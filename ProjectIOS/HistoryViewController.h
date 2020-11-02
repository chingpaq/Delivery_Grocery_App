//
//  HistoryViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 02/06/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
@import FirebaseStorageUI;
//@import Realm;
#import "API.h"
#import "CustomOffersMainCell.h"


@interface HistoryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *historyArray;

@end
