//
//  SearchViewController.h
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 12/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResultsController.h"
#import "ProductViewController.h"
#import "API.h"
#import "Orders.h"
#import "UIColor+DBColors.h"

@interface SearchViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate, UISearchResultsUpdating, SearchResultsControllerDelegate, ProductViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong,nonatomic) SearchResultsController *searchResultsController;
@property (strong, nonatomic)ProductViewController *productViewController;

@end
