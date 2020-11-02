//
//  MainViewController.h
//  test
//
//  Created by Manuel B Parungao Jr on 02/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//
#import <UIKit/UIKit.h>
@import SVProgressHUD;
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "NSObject+FIRDatabaseSingleton.h"
@import Firebase;
@import Realm;
@import MIBadgeButton;
#import "Products.h"
#import "API.h"
#import "CollectionCellType1.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomTableCollectionViewCell.h"
#import <FirebaseStorageUI/UIImageView+FirebaseStorage.h>
#import "ProductViewController.h"
#import "Orders.h"
#import "OrdersMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DataSingletons.h"
#import "MapViewController.h"
#import "CustomAdCell.h"
#import "ActiveSellersViewController.h"
#import "AddressViewController.h"
#import "Constants.h"
#import "ProductViewController.h"
#import "CustomTableCellSellersTableViewCell.h"
#import "MainTabViewController.h"
#import "WaitingViewController.h"

@interface HomeViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource,ProductViewControllerDelegate,CLLocationManagerDelegate, OrdersMapViewControllerDelegate, AddressViewControllerDelegate,WaitingViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *productsArray;
@property (strong, nonatomic) NSMutableArray *productsSearchArray;
@property (strong, nonatomic) NSMutableArray *activeSellersArray;
@property (strong, nonatomic) NSMutableArray *activeAdsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (strong, nonatomic) ProductViewController *productViewController;
@property (strong, nonatomic) OrdersMapViewController *ordersMapViewController;
@property (strong, nonatomic) ActiveSellersViewController *activeSellersViewController;
@property (strong, nonatomic) WaitingViewController *waitingViewController;
@property (strong, nonatomic) CLLocationManager *locationManager;


@end
