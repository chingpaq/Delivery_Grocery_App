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
#import "MainTabViewController.h"
#import "Products.h"
#import "API.h"
#import "Favorites.h"
#import "UIColor+DBColors.h"
#import "ProductViewController.h"

@interface FavoritesViewController :DBViewController<UITableViewDelegate, UITableViewDataSource, ProductViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *addProductButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *favoritesData;
@property (strong, nonatomic) NSMutableArray *searchData;
@property (strong, nonatomic)ProductViewController *productViewController;


@end

