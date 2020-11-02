//
//  UITabBarController+MainTabBarController.h
//  test
//
//  Created by Manuel B Parungao Jr on 02/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RightViewController.h"
#import "LeftViewController.h"
#import "CompletionViewController.h"
#import "HomeViewController.h"
#import "UIViewController+LGSideMenuController.h"
@import MIBadgeButton;
#import <CoreLocation/CoreLocation.h>
#import "UIColor+DBColors.h"
#import "FavoritesViewController.h"
#import "HistoryViewController.h"
#import "AddressViewController.h"
#import "SettingsViewController.h"

@interface MainTabViewController:UITabBarController<UISearchBarDelegate, LeftViewControllerDelegate, CompletionViewControllerDelegate,LGSideMenuDelegate, CLLocationManagerDelegate, AddressViewControllerDelegate>
@property (strong, nonatomic) CompletionViewController *completionVC;
@property (strong, nonatomic) MIBadgeButton *rightMenu;
@property (strong, nonatomic) UIButton *leftMenu;
@property (strong, nonatomic) UISearchBar *searchBar;
@property(strong, nonatomic) FIRAuthStateDidChangeListenerHandle handle;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) HistoryViewController *historyViewController;
@property (strong, nonatomic) SettingsViewController *settingsViewController;

-(void)setupView;
@end
