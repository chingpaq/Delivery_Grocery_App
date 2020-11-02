//
//  SearchDetailViewController.m
//  ProjectIOS
//
//  Created by Manuel B Parungao Jr on 13/10/2017.
//  Copyright © 2017 Manuel B Parungao Jr. All rights reserved.
//

#import "ProductViewController.h"

@interface ProductViewController ()

@end

@implementation ProductViewController
@synthesize productName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.tableView.delegate=self;
//    self.tableView.dataSource=self;
    
    
    // Done button on keyboard
    self.keyboardToolbar = [[UIToolbar alloc] init];
    [self.keyboardToolbar sizeToFit];
    self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Add to Cart"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(doneButtonTapped:)];
    //self.keyboardDoneButton.enabled = false;
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    self.offerButton = [[UIBarButtonItem alloc] initWithTitle:@"Products"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(replaceTapped:)];
    
    [self.keyboardToolbar setItems:[NSArray arrayWithObjects:self.keyboardDoneButton, nil]];
    
    if ([self.productDict objectForKey:@"productId"]){
        self.productName.text = [NSString stringWithFormat:@"%@ %@ %@",[self.productDict objectForKey:@"productName"],[self.productDict objectForKey:@"uom"],[self.productDict objectForKey:@"description"]];
        FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [self.productDict objectForKey:@"productId"]]];
        [self.productImage sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"e_utos_ant"]];
        //self.uom.text = [self.productDict objectForKey:@"uom"];
        
        NSString*bp = [NSString stringWithFormat:@"%@",[self.productDict objectForKey:@"srp"]];
        self.buyingPrice.placeholder = bp;
        self.buyingPrice.text = bp;
        self.buyingPrice.inputAccessoryView= self.keyboardToolbar;
        //self.buyingPrice.keyboardType = UIKeyboardTypen
        self.qty.keyboardType = UIKeyboardTypeNumberPad;
        self.qty.inputAccessoryView= self.keyboardToolbar;
        self.addItemsToFavorites.hidden=YES;
        self.currencyLabel.text = [self.productDict objectForKey:@"currency"];
        if ([self.productDict objectForKey:@"buyingPrice"]){
            self.qty.text =[self.productDict objectForKey:@"quantity"];
            self.buyingPrice.text =[self.productDict objectForKey:@"buyingPrice"];
            self.qty.text =[self.productDict objectForKey:@"quantity"];
            self.addItemsToFavorites.hidden=YES;
            self.addCartButton.hidden=YES;
            self.currencyLabel.text = [self.productDict objectForKey:@"currency"];
            self.keyboardDoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(changeOfferTapped:)];
            [self.keyboardToolbar setItems:[NSArray arrayWithObjects:self.keyboardDoneButton,flexibleSpace,self.offerButton, nil]];
            [self.qty becomeFirstResponder];
        }
        
        
        [API addNewProducts:self.productDict];
    }else{
        self.productName.text = [NSString stringWithFormat:@"%@",[self.productDict objectForKey:@"productName"]];
        //self.uom.text=@"";
        self.buyingPrice.text = @"";
        
        
    }
    
    
    if ([API getFavorites:[self.productDict objectForKey:@"productName"]].count>0){
        self.addItemsToFavorites.hidden=YES;
    }else{
        self.addItemsToFavorites.hidden=NO;
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    if (![self.productDict objectForKey:@"productId"]){
    [API getProduct:[self.productDict objectForKey:@"productName"]
            success:^(NSDictionary *dict){
                
                self.productDict=[dict mutableCopy];
                self.productName.text = [NSString stringWithFormat:@"%@ %@ %@",[self.productDict objectForKey:@"productName"],[self.productDict objectForKey:@"uom"],[self.productDict objectForKey:@"description"]];
                FIRStorageReference *storageRef = [[FIRStorage storage] referenceForURL:[NSString stringWithFormat:@"gs://e-utos.appspot.com/products/%@.jpg", [self.productDict objectForKey:@"productId"]]];
                [self.productImage sd_setImageWithStorageReference:storageRef placeholderImage:[UIImage imageNamed:@"e_utos_ant"]];
                self.currencyLabel.text = [self.productDict objectForKey:@"currency"];
                self.qty.text = @"1";
                NSString*bp = [NSString stringWithFormat:@"%@",[self.productDict objectForKey:@"srp"]];
                self.buyingPrice.placeholder = bp;
                self.buyingPrice.text = bp;
                self.buyingPrice.inputAccessoryView= self.keyboardToolbar;
                self.addItemsToFavorites.hidden=YES;
                
            } failure:^(NSString *message) {
                NSLog(@"Fail");
            }];
    }
    
    
    
    
    
}
//-(void)viewDidDisappear:(BOOL)animated{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTab" object:nil userInfo:@{@"tab" : [NSNumber numberWithInt:0]}];// show proposals
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addCartPressed:(id)sender {
    
    [self.productDict setObject:self.buyingPrice.text forKey:@"buyingPrice"];
    [self.productDict setObject:[self.productDict objectForKey:@"uom"] forKey:@"buyingUOM"];
    [self.productDict setObject:self.qty.text forKey:@"quantity"];
    
    [self.delegate addCartPressed:self.productDict];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addFavoritesPressed:(id)sender {
    [API addToFavorites:self.productDict];
    
    [AZNotification showNotificationWithTitle:@"Item added to favorites"  controller:self notificationType:AZNotificationTypeSuccess shouldShowNotificationUnderNavigationBar:YES];
    
    self.addItemsToFavorites.hidden=YES;
}

-(void)doneButtonTapped:(id)sender{
    [self addCartPressed:nil];
}
-(void)changeOfferTapped:(id)sender{
    [self.productDict setObject:self.qty.text forKey:@"newQty"];
    [self.productDict setObject:self.buyingPrice.text forKey:@"newBuyingPrice"];
    
    [self.delegate changeCartDetails:self.productDict];
    [self.navigationController popViewControllerAnimated:NO];
    
}
-(void)setCartDetails:(NSMutableDictionary*)itemDict{
        self.qty.text =[itemDict objectForKey:@"quantity"];
        self.buyingPrice.text =[itemDict objectForKey:@"buyingPrice"];
}
-(void)replaceTapped:(id)sender{
    [self performSegueWithIdentifier:@"sellerOfferSegue" sender:nil];
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"sellerOfferSegue"]) {
        
        
        self.sellerOffersVC = [segue destinationViewController];
        self.sellerOffersVC.delegate =self;
//        NSDictionary *productDetail= [[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productName contains '%@'", [sender objectForKey:@"productName"]]] firstObject];
//
//        if (productDetail!=nil){
//            self.productViewController.productDict = [productDetail mutableCopy];
//        }else{
//            self.productViewController.productDict =sender;
//        }
//        self.productViewController.delegate=self;
        
        
    }
}

#pragma mark - seller delegates
-(void)changeItem:(id)sender{
    self.productDict = [[[API productsDetailArrayUsingSearch:[NSString stringWithFormat:@"productName contains '%@'", [sender objectForKey:@"productName"]]] firstObject] mutableCopy];
    
    if (self.productDict==nil){
        self.productDict=[[NSMutableDictionary alloc]init];
        [self.productDict setValue:[sender objectForKey:@"productName"] forKey:@"productName"];
        [self.productDict setValue:@"100.00" forKey:@"buyingPrice"];
        [self.productDict setValue:[sender objectForKey:@"uom"] forKey:@"buyingUOM"];
        
    }else{
        [self.productDict setValue:[self.productDict objectForKey:@"srp"] forKey:@"buyingPrice"];
        [self.productDict setValue:[sender objectForKey:@"uom"] forKey:@"buyingUOM"];
    }
    [self viewDidLoad];
    [self viewDidAppear:YES];
}
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
    
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //cell.backgroundColor = [UIColor offWhite];
        cell.layer.borderColor = [[UIColor whiteColor] CGColor];
        cell.layer.borderWidth = 3;
        
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    cell.textLabel.font=[UIFont fontWithName:@"SEOptimistLight" size:15.0f];
    cell.textLabel.text = @"Hello world";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        default:
        {
            
        }
            break;
    }
    
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0+5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
