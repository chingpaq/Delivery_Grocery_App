//
//  SellerOffersViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 24/04/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//
//
//  ViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 03/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBViewController.h"
@import Realm;
@import MIBadgeButton;
#import "Products.h"
#import "API.h"
#import "Favorites.h"
#import "UIColor+DBColors.h"

@protocol SellerOffersViewControllerDelegate  <NSObject>
@optional
-(void)changeItem:(id)sender;
@end
@interface SellerOffersViewController :DBViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) id<SellerOffersViewControllerDelegate>delegate;
@property (strong, nonatomic) IBOutlet UIButton *addProductButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *favoritesData;
@property (strong, nonatomic) NSMutableArray *searchData;


@end




