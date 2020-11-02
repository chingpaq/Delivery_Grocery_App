//
//  SellerOffersViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 24/04/2018.
//  Copyright © 2018 Manuel B Parungao Jr. All rights reserved.
//
#import "SellerOffersViewController.h"

@interface SellerOffersViewController ()

@end

@implementation SellerOffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.favoritesData= [[NSMutableArray alloc]init];
    self.searchData= [[NSMutableArray alloc]init];
    
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    self.searchData = [API productsArrayUsingSearch:nil];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addProductButtonPressed:(id)sender {
    [self displayToastWithMessage:@"Hello world" backgroundColor:[UIColor redColor]];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
    
}- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //cell.backgroundColor = [UIColor offWhite];
        cell.layer.borderColor = [[UIColor whiteColor] CGColor];
        cell.layer.borderWidth = 3;
        
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    if ([self.searchData count]>0){
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.textColor = [UIColor blackColor];
            
        }
        NSDictionary *dict = [self.searchData objectAtIndex:indexPath.row];
        cell.textLabel.text = [dict objectForKey:@"productName"];
        cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
        return cell;
        
    }
    Favorites *favorites = [self.favoritesData objectAtIndex:indexPath.row];
    cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
    cell.textLabel.text = favorites.productName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *selected = [self.searchData objectAtIndex:indexPath.row];
    switch (indexPath.row) {
        default:
        {
            
            [self.delegate changeItem:selected];
            [self.navigationController popViewControllerAnimated:NO];
//            NSString *productName;
//            if ([self.searchData count]>0){
//                NSDictionary*dict =[self.searchData objectAtIndex:indexPath.row];
//                productName = [dict objectForKey:@"productName"];
//                [self performSegueWithIdentifier:@"showFavoritesItemDetail" sender:dict];
//            }
//            else{
//                Favorites *dict= [self.favoritesData objectAtIndex:indexPath.row];
//                productName= dict.productName;
//                [self performSegueWithIdentifier:@"showFavoritesItemDetail" sender:@{@"productName":dict.productName,@"productId":dict.productId}];
//            }
//            
//            
//            
        }
            break;
    }
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *HeaderCellIdentifier = @"Header";
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCellIdentifier];
//        cell.backgroundColor = [UIColor grayColor];
//        cell.backgroundColor=[UIColor colorWithRed:56.0/255 green:185.0/255 blue:158.0/255 alpha:1];
//        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
//        cell.textLabel.textColor = [UIColor whiteColor];
//    }
//
//
//
//    if (section==0)
//
//        cell.textLabel.text=@"My Favorites";
//    else if (section==1){
//        cell.backgroundColor = [UIColor whiteColor];
//        cell.textLabel.text = @"Others:";
//    }
//    else{
//
//    }
//
//    return cell;
//}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchData.count>0)
        return self.searchData.count;
    return self.favoritesData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"sellerOfferSegue"]) {
//        
//        
//        self.productViewController = [segue destinationViewController];
//        NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productName contains '%@'", [sender objectForKey:@"productName"]]] firstObject];
//        
//        if (productDetail!=nil){
//            self.productViewController.productDict = [productDetail mutableCopy];
//        }else{
//            self.productViewController.productDict =sender;
//        }
//        self.productViewController.delegate=self;
//        
//        
//    }
//}

#pragma mark - ProductViewController delegate
-(void)addCartPressed:(id)sender
{
//    [[[Orders sharedManager] currentOrders] addObject:sender];
//    MainTabViewController *tbc = (MainTabViewController*)self.tabBarController;
//    
//    if ([[[Orders sharedManager] currentOrders] count]>0){
//        [tbc.rightMenu setBadgeString:[NSString stringWithFormat:@"%lu",(unsigned long)[[[Orders sharedManager] currentOrders] count]]];
//        tbc.rightMenu.badgeBackgroundColor= [UIColor redColor];
//    }else{
//        [tbc.rightMenu setBadgeString:@""];
//        tbc.rightMenu.badgeBackgroundColor= [UIColor clearColor];
//    }
}

@end

