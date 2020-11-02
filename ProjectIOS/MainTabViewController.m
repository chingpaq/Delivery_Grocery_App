//
//  UITabBarController+MainTabBarController.m
//  test
//
//  Created by Manuel B Parungao Jr on 02/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "MainTabViewController.h"



@implementation MainTabViewController
NSString *searchString;
BOOL loginAlready=NO;

-(void)viewDidLoad{
    
    [self setupView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completeOrder:)
                                                 name:@"CompletedOrder"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeTab:)
                                                 name:@"changeTab"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(incorrectVersion:)
                                                 name:@"incorrectVersion"
                                               object:nil];
    [Orders sharedManager];
    [DataSingletons sharedManager];
    [API sharedManager];
    
    self.sideMenuController.delegate=self;
}
-(void)viewWillAppear:(BOOL)animated{
    [self updateMenuBadge];
}

-(void)viewDidAppear:(BOOL)animated{
    self.handle = [[FIRAuth auth]
                   addAuthStateDidChangeListener:^(FIRAuth *_Nonnull auth, FIRUser *_Nullable user) {
                       if (user==nil)
                       {
                           
                           self.navigationController.navigationBarHidden=NO;
                           [self performSegueWithIdentifier:@"ShowLogin" sender:nil];
                       }
                       else{
                           
                           if (loginAlready==NO){
                               loginAlready=YES;
                               [CrashlyticsKit setUserEmail:[FIRAuth auth].currentUser.email];
                               if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
                                   [FIRDatabaseSingleton sharedManager];
                               }else{
                                   [FIRDatabaseSingleton sharedManagerSeller];
                               }
                           }
                       }
                   }];
    
}
-(void)setupView{
    self.leftMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftMenu setImage:[UIImage imageNamed:@"menu-1"] forState:UIControlStateNormal];
    self.leftMenu.adjustsImageWhenDisabled = NO;
    self.leftMenu.frame = CGRectMake(0, 0, 30, 50);
    
    [self.leftMenu addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightMenu = [MIBadgeButton buttonWithType:UIButtonTypeCustom];
    
    self.searchBar = [[UISearchBar alloc]init];
    self.searchBar.delegate=(id<UISearchBarDelegate>)self;
    
    [self.searchBar setBackgroundImage:[UIImage new]];
    [self.searchBar setTranslucent:YES];
    [self.searchBar setBackgroundColor:[UIColor clearColor]];
    self.searchBar.frame =CGRectMake(0, 0, self.searchBar.frame.size.width, 44);
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"SEOptimistLight" size:16]}];
    
    self.navigationItem.titleView = self.searchBar;
    
    self.searchBar.placeholder= @"Search Products";
    
    if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
        self.navigationItem.titleView = self.searchBar;
        [self.rightMenu setImage:[UIImage imageNamed:@"cart-1"] forState:UIControlStateNormal];
        self.rightMenu.adjustsImageWhenDisabled = NO;
        self.rightMenu.frame = CGRectMake(0, 0, 40, 40);
        [self.rightMenu setBadgeString:@""];
        [self.rightMenu setBadgeBackgroundColor:[UIColor clearColor]];
        [self.rightMenu setBadgeTextColor:[UIColor whiteColor]];
        
        [self.rightMenu addTarget:self action:@selector(presentRightMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
        //[self.rightMenu setBadgeEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 12)];
        [self.rightMenu setBadgeEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 12)];
    }else{
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"active"] isEqualToString:@"Yes"]){
            [self.rightMenu setImage:[UIImage imageNamed:@"icon-contact"] forState:UIControlStateNormal];
        }else{
            [self.rightMenu setImage:[UIImage imageNamed:@"profile-pic"] forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:@"No" forKey:@"active"];
        }
        
        self.rightMenu.adjustsImageWhenDisabled = NO;
        self.rightMenu.frame = CGRectMake(10, 10, 40, 40);
        [self.rightMenu setBadgeString:@""];
        [self.rightMenu setBadgeBackgroundColor:[UIColor clearColor]];
        [self.rightMenu setBadgeTextColor:[UIColor whiteColor]];
        
        [self.rightMenu addTarget:self action:@selector(activeSeller:) forControlEvents:UIControlEventTouchUpInside];
        [self.rightMenu setBadgeEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 12)];
        
        [self initLocationManager];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightMenu];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftMenu];
    self.navigationItem.hidesBackButton = YES;
    
}

-(void)changeTab:(NSNotification*)tab{
    self.selectedIndex=[[[tab userInfo] valueForKey:@"tab"] intValue];
}

#pragma mark -Search
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    rightButton.frame = CGRectMake(10, 10, 40, 60);
    [rightButton addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.leftBarButtonItem = nil;
    
    return YES;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    searchString = searchText;
    
    if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
        [self setSelectedIndex:0];
        HomeViewController *homeViewController= [self.viewControllers objectAtIndex:0];
        homeViewController.productsSearchArray = [API productsArrayUsingSearch:searchText];
        [homeViewController.tableView reloadData];
    }else{
        [self setSelectedIndex:1];
        FavoritesViewController *fvc= [self.viewControllers objectAtIndex:1];
        fvc.searchData = [API productsArrayUsingSearch:searchText];
        [fvc.tableView reloadData];
    }
    
    
    
    
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
-(void)searchBarCancelButtonClicked:(id)sender{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightMenu];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftMenu];
    [self.searchBar resignFirstResponder];
    self.searchBar.text=@"";
    
    if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
        HomeViewController *homeViewController= [self.viewControllers objectAtIndex:0];
        homeViewController.productsSearchArray = [[NSMutableArray alloc]init];
        [homeViewController.tableView reloadData];
        [self setSelectedIndex:0];
    }else{
        FavoritesViewController *fvc= [self.viewControllers objectAtIndex:1];
        [fvc.searchData removeAllObjects];
        [self setSelectedIndex:2];
    }
    
    
}

#pragma mark - menus
- (void)presentLeftMenuViewController:(id)sender{
    LeftViewController *lvc = (id)self.sideMenuController.leftViewController;
    lvc.delegate=(id<LeftViewControllerDelegate>)self;
    //[lvc.tableView reloadData];
    [self.sideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

- (void)presentRightMenuViewController:(id)sender{
    if ([[[Orders sharedManager] currentOrders] count]!=0){
        RightViewController *rvc = (id) self.sideMenuController.rightViewController;
        
        [rvc.tableView reloadData];
        [self.sideMenuController showRightViewAnimated:YES completionHandler:nil];
    }
}
#pragma mark - buttons
-(void)proceedToCheckout{
    
}

-(void)paymentsMenuPressed{
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    
    UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName:@"Payments" bundle:nil];
    UIViewController*vc = [mainStoryBoard instantiateViewControllerWithIdentifier:@"PaymentMenu"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
-(void)settingsMenuPressed{
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    self.settingsViewController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    [self.navigationController pushViewController:self.settingsViewController animated:YES];
}

-(void)ordersMenuPressed{
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    self.historyViewController = [[HistoryViewController alloc]initWithNibName:@"HistoryViewController" bundle:nil];
    [self.navigationController pushViewController:self.historyViewController animated:YES];
}

-(void)logoutPressed{
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:nil forKey:USER_ZIP_CODE];
        
        [FBSDKAccessToken setCurrentAccessToken:nil];
        self.navigationController.navigationBarHidden=YES;
        [self.navigationController popViewControllerAnimated:NO];
    }
}
-(void)aboutPressed{
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [self showMessagePrompt:[NSString stringWithFormat:@"e-Utos ver %@ \r\nDeveloped by Errand Corporation 2018",version]];
}
-(void)logout{
    [self.sideMenuController hideLeftViewAnimated:YES completionHandler:nil];
    self.navigationController.navigationBarHidden=NO;
    [self performSegueWithIdentifier:@"ShowLogin" sender:nil];
}

-(void)completeOrder:(NSNotification*)notification{
    [self performSegueWithIdentifier:@"showOrderCompletionSegue" sender:[notification object]];
}
-(void)incorrectVersion:(id)sender{
    [self showMessagePrompt:[NSString stringWithFormat:@"Please close this app and download the latest e-Utos version from the App Store"]];
    //self.view.userInteractionEnabled =NO;
}

#pragma mark - segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showOrderCompletionSegue"]) {
        self.completionVC = [segue destinationViewController];
        self.completionVC.delegate=self;
        self.completionVC.completedOrder =sender;
        self.completionVC.navigationController.navigationBarHidden=YES;
    }
    
    
}

-(void)closeCompletion{
    [self.completionVC.view removeFromSuperview];
}

- (void)willHideRightView:(nonnull UIView *)rightView sideMenuController:(nonnull LGSideMenuController *)sideMenuController{
    
    if ([[[Orders sharedManager] currentOrders] count]>0){
        [self.rightMenu setBadgeString:[NSString stringWithFormat:@"%lu",(unsigned long)[[[Orders sharedManager] currentOrders] count]]];
        self.rightMenu.badgeBackgroundColor= [UIColor redColor];
    }else{
        [self.rightMenu setBadgeString:@""];
        self.rightMenu.badgeBackgroundColor= [UIColor clearColor];
    }
}
-(void)willShowRightView:(UIView *)rightView sideMenuController:(LGSideMenuController *)sideMenuController{
    RightViewController *rvc = (id) self.sideMenuController.rightViewController;
    
    [rvc.tableView reloadData];
}

-(void)willShowLeftView:(UIView *)leftView sideMenuController:(LGSideMenuController *)sideMenuController{
    LeftViewController *lvc = (id) self.sideMenuController.leftViewController;
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                           parameters:@{@"fields" : @"first_name, last_name,  picture.width(540).height(540), email, name, id, gender, birthday, permissions, location, friends"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (error) {
                 NSLog(@"Login error: %@", [error localizedDescription]);
                 return;
             }
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             
             [defaults setObject:result[@"picture"][@"data"][@"url"] forKey:USER_IMAGE_URL];
             [defaults setObject:result[@"name"] forKey:USER_FULL_NAME];
             [defaults setObject:result[@"location"][@"name"] forKey:USER_LOCATION];
             
             [API createOrUpdateBuyer:result success:^{
                 
             } failure:^(NSString *message) {
                 NSLog(@"Fail");
             }];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfilePicture" object:nil];
         }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"");
        });
    }
    
    
    [lvc.tableView reloadData];
}
#pragma mark - Misc
-(void)activeSeller:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //tag 0 is yes
    if (self.rightMenu.tag==0){
        if ([[[[Orders sharedManager]activeOrders] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"status CONTAINS[cd]%@ || status CONTAINS[cd]%@",@"On The Way",@"Accepted" ]] count]>0){
            [AZNotification showNotificationWithTitle:@"Sorry! Pls complete your transactions"  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:NO];
        }
        else{
            [self.rightMenu setImage:[UIImage imageNamed:@"profile-pic"] forState:UIControlStateNormal];
            self.rightMenu.tag=1;
            [defaults setObject:@"No" forKey:@"active"];
            [defaults setObject:[defaults objectForKey:USER_ZIP_CODE] forKey:CURRENT_LOC_CODE];
            [AZNotification showNotificationWithTitle:@"You are now offline"  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"startSellerMonitors" object:nil userInfo:@{@"active" : [NSNumber numberWithBool:NO]}];
            [[FIRDatabaseSingleton sharedManager] stopSellerOrdersMonitor];
        }
    }else{
        [self.rightMenu setImage:[UIImage imageNamed:@"icon-contact"] forState:UIControlStateNormal];
        self.rightMenu.tag=0;
        [defaults setObject:@"Yes" forKey:@"active"];
        [AZNotification showNotificationWithTitle:@"You are now online"  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:NO];
        
        [self currentPostalCode];
    }
    self.rightMenu.adjustsImageWhenDisabled = NO;
    self.rightMenu.frame = CGRectMake(10, 10, 40, 40);
    [self.rightMenu setBadgeString:@""];
    [self.rightMenu setBadgeBackgroundColor:[UIColor clearColor]];
    [self.rightMenu setBadgeTextColor:[UIColor whiteColor]];
    
    [self.rightMenu addTarget:self action:@selector(activeSeller:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightMenu setBadgeEdgeInsets:UIEdgeInsetsMake(12, 0, 0, 12)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightMenu];
}


#pragma mark - maps
- (void)initLocationManager{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [self.locationManager requestAlwaysAuthorization];
    [self startUpdating];
}
-(void)startUpdating{
    [self.locationManager startUpdatingLocation];
}

-(void) stopUpdating{
    [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:
(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    
    [[DataSingletons sharedManager]setUserLocation:newLocation];
    [self stopUpdating];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    //[defaults setValue:@"No" forKey:@"active"];
    if ([[defaults objectForKey:@"active"] isEqualToString:@"Yes"]){
        [self.rightMenu setImage:[UIImage imageNamed:@"icon-contact"] forState:UIControlStateNormal];
        [defaults setObject:@"No" forKey:@"active"];
        self.rightMenu.tag =1;
        [self activeSeller:nil];
    }else{
        [self.rightMenu setImage:[UIImage imageNamed:@"profile-pic"] forState:UIControlStateNormal];
        [defaults setObject:@"No" forKey:@"active"];
        self.rightMenu.tag =1;
    }
}


-(void)currentPostalCode{
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:[[DataSingletons sharedManager]userLocation].coordinate.latitude longitude:[[DataSingletons sharedManager]userLocation].coordinate.longitude];
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         
         if (placemark){
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             [defaults setValue:placemark.postalCode forKey:CURRENT_LOC_CODE];
             //[defaults setValue:@"1103" forKey:CURRENT_LOC_CODE];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"startSellerMonitors" object:nil userInfo:@{@"active" : [NSNumber numberWithBool:YES]}];
         }
     }];
}

- (void)showMessagePrompt:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:nil
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction =
    [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void)updateMenuBadge{
    
    
    if ([[[Orders sharedManager] currentOrders] count]>0){
        [self.rightMenu setBadgeString:[NSString stringWithFormat:@"%lu",(unsigned long)[[[Orders sharedManager] currentOrders] count]]];
        self.rightMenu.badgeBackgroundColor= [UIColor redColor];
        [[reSideMenuSingleton sharedManager]mainViewController].rightViewController.view.hidden=NO;
        
    }else{
        [self.rightMenu setBadgeString:@""];
        self.rightMenu.badgeBackgroundColor= [UIColor clearColor];
        [[reSideMenuSingleton sharedManager]mainViewController].rightViewController.view.hidden=YES;
    }
}


#pragma mark - SHow Address
-(void)showAddressView{
    AddressViewController *avc = [[AddressViewController alloc] initWithNibName:@"AddressViewController" bundle:nil];
    avc.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    avc.delegate = self;
    [self presentViewController:avc
                       animated:true
                     completion:nil];
}

- (void)didSubmitAddressInfo:(NSUserDefaults *)defaults{
    [self viewWillAppear:YES];
    
    if ([defaults objectForKey:USER_IMAGE_URL]){
        NSURL *url = [NSURL URLWithString:[defaults objectForKey:USER_IMAGE_URL]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        
        [API createFirebaseImage:nil urlString:@"profile" fileName:[FIRAuth auth].currentUser.uid imageData:img success:^(NSDictionary *dict2){
            NSLog(@"Success Picture ");
        } failure:^(NSString *message) {
            NSLog(@"Fail Picture");
        }];
    }
    
    if (!([[defaults objectForKey:USER_MOBILE] isEqualToString:@""] || [[defaults objectForKey:USER_ZIP_CODE] isEqualToString:@""] || [defaults objectForKey:USER_MOBILE]==nil || [defaults objectForKey:USER_ZIP_CODE]==nil))
    {
        NSMutableDictionary *dict = [@{@"mobileNumber":[defaults objectForKey:USER_MOBILE],@"postalCode":[defaults objectForKey:USER_ZIP_CODE]} mutableCopy];
        
        if ([[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] isEqualToString:@"Main"]){
            [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"] child:[FIRAuth auth].currentUser.uid]
             updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){}];
        }else{
            [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"sellers"] child:[FIRAuth auth].currentUser.uid]
         updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){}];
        }
    }
    
}


@end




