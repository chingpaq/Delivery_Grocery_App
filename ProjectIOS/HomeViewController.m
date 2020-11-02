//
//  MainViewController.m
//  test
//
//  Created by Manuel B Parungao Jr on 02/07/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//
#import "HomeViewController.h"
@import Firebase;

@interface HomeViewController()
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation HomeViewController
BOOL homeViewInitialization=NO;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [SVProgressHUD dismiss];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.productsArray = [[NSMutableArray alloc]init];
    self.productsSearchArray = [[NSMutableArray alloc]init];
    self.activeSellersArray = [[NSMutableArray alloc]init];
    self.activeAdsArray = [[NSMutableArray alloc]init];
    
    [API getLatestPromos:@"1"
                 success:^(NSDictionary *dict){
                     
                     [self.productsArray addObject:dict];
                     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                     
                 } failure:^(NSString *message) {
                     NSLog(@"Fail");
                 }];
    [API getAds:@"1"
      queryType:FIRDataEventTypeValue
        success:^(NSArray *dict){
            
            self.activeAdsArray = [[NSMutableArray alloc]initWithArray:dict];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        } failure:^(NSString *message) {
            NSLog(@"Fail");
        }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableCollectionViewCell" bundle:nil] forCellReuseIdentifier:@"CustomTableCollectionViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(proceedOrder)
                                                 name:@"proceedToCheckout"
                                               object:nil];
    
    self.navigationController.navigationItem.prompt = @" ";
}

-(void)viewWillAppear:(BOOL)animated{
    
    //[self performSegueWithIdentifier:@"showGuideSegue" sender:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[self showAddressView];
    if ([FIRAuth auth].currentUser){
        if (![defaults objectForKey:USER_ZIP_CODE]){
            [self showAddressView];
            
        }else if (homeViewInitialization==NO){
            homeViewInitialization=YES;
            [API getBuyerDetails:[FIRAuth auth].currentUser.uid
                       eventType:FIRDataEventTypeValue
                         success:^(NSDictionary *dict){
                             // paymaya customer id
                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                             [defaults setObject:[dict objectForKey:@"pid"] forKey:@"paymayaId"];
                             NSLog(@"%@",dict);
                         } failure:^(NSString *message) {
                             NSLog(@"Fail");
                         }];
            
            
            [API getActiveSellers:[defaults objectForKey:USER_ZIP_CODE] eventType:FIRDataEventTypeValue
                          success:^(NSArray *dict){
                              NSLog(@"Sucess GetActiveSellers");
                              self.activeSellersArray = [[NSMutableArray alloc]initWithArray:dict];
                              
                              [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                          } failure:^(NSString *message) {
                              NSLog(@"Fail");
                          }];
            
            [API activeSellerUpdated:[defaults objectForKey:USER_ZIP_CODE] eventType:FIRDataEventTypeChildChanged
                             success:^(NSDictionary *dict){
                                 NSLog(@"Sucess ActiveSellerUpdated");
                                 NSMutableDictionary *seller = [[self.activeSellersArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sellerId=%@",[dict objectForKey:@"sellerId"]]]firstObject];
                                 
                                 [self.activeSellersArray removeObject:seller];
                                 
                                 NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"lastUpdate"] integerValue]];
                                 
                                 if ([date timeIntervalSinceNow]>-120){
                                     if ([[dict objectForKey:@"active"] isEqualToString:@"Yes"]){
                                         [self.activeSellersArray addObject:dict];
                                     }
                                 }
                                 
                                 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                             } failure:^(NSString *message) {
                                 NSLog(@"Fail");
                             }];
            
            
            [defaults setObject:[NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] forKey:@"lastUpdate"];
            if ([FBSDKAccessToken currentAccessToken]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                   parameters:@{@"fields" : @"first_name, last_name,  picture.width(540).height(540), email, name, id, gender, birthday, permissions, location, friends"}]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (error) {
                         NSLog(@"Login error: %@", [error localizedDescription]);
                         return;
                     }
                     [defaults setObject:result[@"picture"][@"data"][@"url"] forKey:USER_IMAGE_URL];
                     [defaults setObject:result[@"name"] forKey:USER_FULL_NAME];
                     [defaults setObject:result[@"last_name"] forKey:USER_LAST_NAME];
                     [defaults setObject:result[@"first_name"] forKey:USER_FIRST_NAME];
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
        }else if (homeViewInitialization==YES){
            for(NSDictionary *dict in self.activeSellersArray){
                NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"lastUpdate"] integerValue]];
                if ([date timeIntervalSinceNow]<-120){
                    [self.activeSellersArray removeObject:dict];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            }
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)proceedOrder{
    [self performSegueWithIdentifier:@"proceedOrderFromHomeSegue" sender:nil];
}

#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.productsSearchArray count]==0)
        
        return 3;
    else{
        return [self.productsSearchArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.productsSearchArray count]>0){
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.textColor = [UIColor blackColor];
            
        }
        NSDictionary *dict = [self.productsSearchArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"productName"];
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        return cell;
        
    } else if (indexPath.row==1){
        static NSString* viewIdentifier = @"CustomTableCollectionViewCell";
        
        CustomTableCollectionViewCell *cell = [tableView dequeueReusableCellWithIdentifier:viewIdentifier forIndexPath:indexPath];
        cell.productsArray= self.productsArray;
        cell.collectionView.delegate=self;
        cell.collectionView.dataSource=self;
        [cell.collectionView reloadData];
        
        return cell;
        
    }else if (indexPath.row==0){
        static NSString *cellIdentifier = @"CustomTableCellSellersTableViewCell";
        CustomTableCellSellersTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        //if (cell==nil){
        [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableCellSellersTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        
        
        
        //}else{
        
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        //}
        cell.activeSellersArray = [[NSMutableArray alloc]initWithArray:self.activeSellersArray];
        cell.userInteractionEnabled=NO;
        
        
        [cell getSellers];
        cell.backgroundColor=[UIColor lightGrayColor];
        
        return cell;
        
    }else if (indexPath.row==2){
        
        static NSString *cellIdentifier = @"CustomAdCell";
        CustomAdCell *cell= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        //if (cell == nil) {
        
        [self.tableView registerNib:[UINib nibWithNibName:@"CustomAdCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        
        
        cell.pageControl.numberOfPages = self.activeAdsArray.count; //photo.count;
        cell.pageControl.currentPage = 0;
        
        
        for(int i = 0; i < self.activeAdsArray.count; i++)
        {
            CGRect frame;
            frame.origin.x = (cell.scrollView.frame.size.width *i) + 10;
            
            frame.origin.y = 0;
            frame.size = CGSizeMake(cell.scrollView.frame.size.width - 20, cell.scrollView.frame.size.height);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            NSDictionary *dict = [self.activeAdsArray objectAtIndex:i];
            
            FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/advertisement/%@.jpg", [dict objectForKey:@"image"]]];
            [imageView sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"e_utos_ant"]];
            
            
            [cell.scrollView addSubview:imageView];
            
            cell.scrollView.contentSize = CGSizeMake(cell.scrollView.frame.size.width*self.activeAdsArray.count, cell.scrollView.frame.size.height);
        }
        
        //}
        
        
        return cell;
    }
    return nil;
}



#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.productsSearchArray count]>0){
        return 50;
    }else if (indexPath.row==0){
        return 290-50+100;
    }else if(indexPath.row==2){
        return 170;
    }else{
        return 200;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.productsSearchArray count]>0){
        NSDictionary *dict= [self.productsSearchArray objectAtIndex:indexPath.row];
        
        if (dict!=nil){
            [self performSegueWithIdentifier:@"showDetailViewSegue" sender:dict];
        }
    }else{
        switch (indexPath.row) {
            case 2:{
                //[self performSegueWithIdentifier:@"activeSellersSegue" sender:nil];
            }
                break;
            case 5:{
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - UICollectionView Delegates
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString* collectionViewIdentifier = @"CollectionCellType1";
    
    
    
    CollectionCellType1 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewIdentifier forIndexPath:indexPath];
    
    NSDictionary *dict = [self.productsArray objectAtIndex:indexPath.row];
    cell.mainLabel.text = [dict objectForKey:@"productName"];
    FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [dict objectForKey:@"productId"]]];
    [cell.imageView sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"e_utos_ant"]];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.productsArray count];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(150, 190);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //top, left, bottom, right
    return UIEdgeInsetsMake(1, 1, 1, 1);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict= [self.productsArray objectAtIndex:indexPath.row];
    
    if (dict!=nil){
        [self performSegueWithIdentifier:@"showDetailViewSegue" sender:dict];
    }
}


#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetailViewSegue"]) {
        self.productViewController = [segue destinationViewController];
        NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productName contains '%@'", [sender objectForKey:@"productName"]]] firstObject];
        
        if (productDetail!=nil){
            self.productViewController.productDict = [productDetail mutableCopy];
        }else{
            self.productViewController.productDict =sender;
        }
        self.productViewController.delegate=self;
        
    }
    else if ([segue.identifier isEqualToString:@"proceedOrderFromHomeSegue"]){
        self.ordersMapViewController = [segue destinationViewController];
        self.ordersMapViewController.delegate=self;
    }
    else if ([segue.identifier isEqualToString:@"activeSellersSegue"]){
        self.activeSellersViewController = [segue destinationViewController];
        self.activeSellersViewController.activeSellersArray = [[NSMutableArray alloc]initWithArray:self.activeSellersArray];
    }
    else if ([segue.identifier isEqualToString:@"e_utos_mo_na_segue"]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:sender userInfo:@{@"tab" : [NSNumber numberWithInt:3]}];// show proposals
        
        self.waitingViewController = [segue destinationViewController];
        self.waitingViewController.delegate=self;
        self.waitingViewController.productDict =sender;
        
    }
    
}


-(void)proposalsReceived:(id)sender{
    [[DataSingletons sharedManager]setReceivedOffer:NO];
    [self performSegueWithIdentifier:@"e_utos_mo_na_segue" sender:sender];
    
}
#pragma mark WaitingController delegates
-(void)proposalsReceived{
    //self.tabBarController.selectedIndex=3;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:nil userInfo:@{@"tab" : [NSNumber numberWithInt:3]}];// show proposals
    //[self updateMenuBadge];
}

-(void)addCartPressed:(id)sender
{
    [[[Orders sharedManager] currentOrders] addObject:sender];
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
    
    if (![[defaults objectForKey:USER_MOBILE] isEqualToString:@""])
    {
        NSMutableDictionary *dict = [@{@"mobileNumber":[defaults objectForKey:USER_MOBILE]} mutableCopy];
        
        [[[[[FIRDatabaseSingleton sharedManager] mainFirebaseReference] child:@"buyers"] child:[FIRAuth auth].currentUser.uid]
         updateChildValues:dict withCompletionBlock:^(NSError* _Nullable error, FIRDatabaseReference * _Nonnull ref){}];
    }

}

-(void)backPressedFrom{
    //[self updateMenuBadge];
}
@end


